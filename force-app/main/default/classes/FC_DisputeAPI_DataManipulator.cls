/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Performs DML for Dispute API
 *
 * @when 13/12/2019
 */
public virtual without sharing class FC_DisputeAPI_DataManipulator {
    private static final String BRANCH = 'branch',AGENT = 'agent',LANDLORD = 'landlord',TENANT = 'tenant',
            TENANCY = 'tenancy',DISPUTE = 'dispute',DISPUTE_LINE = 'dispute_line',EVIDENCE = 'evidence';
    private API_Account__c apiAccount;
    private Map<String,Map<SObjectType,List<SObject>>> sObjectByPayloadObjectName;

    /**
     * Only for testing purposes
     */
    @TestVisible
    private Boolean throwException = false;
    /**
     * Interface allowing to apply different strategy for various API consumers if ever required
     */
    private interface IDataManipulatorStrategy {
        /**
         * Returns order of execution of objects consumed by the API
         *
         * @return Order of execution of objects consumed by the API
         */
        List<String> getOrderOfExecution();
        /**
         * Performs additional processing related to SOBject type and performs the DML operation 
         *
         * @param payloadObject
         * @param sObjectsByType
         *
         * @return List of processed and Database Manupulated SObjects
         */
        List<SObject> processObjects(String payloadObject, Map<SObjectType,List<SObject>> sObjectsByType);
        /**
         * Used to pass the API Account to dynamically instanciated implementation class 
         *
         * @param 
         */
        void setAPIAccount(API_Account__c apiAccount);
    }
    /**
     * Public constructor
     *
     * @param sObjectByPayloadObjectName Objects processed by PayloadMappings
     * @param apiAccount
     */
    public FC_DisputeAPI_DataManipulator(Map<String,Map<SObjectType,List<SObject>>> sObjectByPayloadObjectName, API_Account__c apiAccount) {
        this.sObjectByPayloadObjectName = sObjectByPayloadObjectName;
        this.apiAccount = apiAccount;
    }
    /**
     * Performs the actual DML operations
     *
     * @return List of successfully upserted dispute cases 
     */
    public List<SObject> performDML() {
        IDataManipulatorStrategy dmlStrategy = getStrategy(apiAccount);

        Savepoint sp = Database.setSavepoint();
        Id jobId;
        try {
            List<Case> disputes;
            List<sObject> queueableRecords = new List<sObject>();
            for(String payloadObject : dmlStrategy.getOrderOfExecution()) {
                if(sObjectByPayloadObjectName.containsKey(payloadObject)) {
                    List<SObject> processedObjects = dmlStrategy.processObjects(payloadObject, sObjectByPayloadObjectName.get(payloadObject));

                    if(payloadObject == DISPUTE) {
                        disputes = processedObjects;

                    }
                    queueableRecords.addAll(
                            handleQueueableRecords(dmlStrategy, processedObjects, payloadObject)
                    );
                }
            }
            if(queueableRecords.size() > 0) {
                jobId = System.enqueueJob(new QueueableObjectDML(queueableRecords));
            }
            if(throwException) throw new SchemeException('test');
            return disputes;
        }
        catch(Exception exc) {
            if(jobId != null) {
                System.abortJob(jobId);
            }
            Database.rollback(sp);
            throw exc;
        }
    }
    /**
     * Handles the objects to be created asynchronously by the service
     *
     * @param dmlStrategy
     * @param recordsToProcess
     * @param payloadObject
     *
     * @return
     */
    private List<sObject> handleQueueableRecords(IDataManipulatorStrategy dmlStrategy, List<sObject> recordsToProcess, String payloadObject) {
        List<sObject> processedRecords = new List<SObject>();
        if(dmlStrategy instanceof DataManipulatorStrategyMain) {
            DataManipulatorStrategyMain dataManipulator = (DataManipulatorStrategyMain) dmlStrategy;
            if(payloadObject == DISPUTE) {
                processedRecords = dataManipulator.handleCaseParticipants((List<Case>) recordsToProcess);
            }else if(payloadObject == TENANCY) {
                processedRecords = dataManipulator.handleDepositAllocations((List<Deposit__c>) recordsToProcess);
            }
        }
        return processedRecords;
    }
    /**
     * Get the strategy to be applied for the particular API Account.
     * If no Starategy or mistyped classname is specified, it returns default strategy and adds error into log.
     *
     * @param apiAccount
     *
     * @return
     */
    private IDataManipulatorStrategy getStrategy(API_Account__c apiAccount) {
        Type strategyType = Type.forName(apiAccount.DML_Strategy_Processor__c);
        IDataManipulatorStrategy strategyInstance;

        if(strategyType == null) {
            FC_ErrorLogger.error('Bad DML Strategy Name provided for API Account: ' + apiAccount.API_Account_Id__c, apiAccount.Id);
            strategyInstance = new DataManipulatorStrategyMain();
        }
        else {
            strategyInstance = (IDataManipulatorStrategy)strategyType.newInstance();
        }
        strategyInstance.setAPIAccount(apiAccount);
        return strategyInstance;
    }
    /**
     * Overridable default strategy implementation of IDataManipulatorStrategy interface
     */
    public virtual class DataManipulatorStrategyMain implements IDataManipulatorStrategy {
        private API_Account__c apiAccount;
        private Scheme__c scheme;
        private List<Contact> agents;
        private List<Account> landlords;
        private List<Account> tenants;
        private List<Account> branches;
        private List<Deposit__c> deposits;
        private String customerType;
        /**
         * Returns order of execution of objects consumed by the API
         *
         * @return Order of execution of objects consumed by the API
         */
        public virtual List<String> getOrderOfExecution(){
            return new List<String> {BRANCH,AGENT,LANDLORD,TENANT,TENANCY,DISPUTE,DISPUTE_LINE,EVIDENCE};
        }
        /**
         * Performs additional processing related to SOBject type and performs the DML operation.
         * Handled all of the possible object types in current implementation and dispatches them to their consecutive class
         *
         * @param payloadObject
         * @param sObjectsByType
         *
         * @return List of processed and Database Manupulated SObjects
         */
        public virtual List<SObject> processObjects(String payloadObject, Map<SObjectType,List<SObject>> sObjectsByType) {
            try {
                if(payloadObject == BRANCH) {
                    branches = processBranches(sObjectsByType.get(Account.SObjectType));
                    return branches;
                }
                else if(payloadObject == AGENT) {
                    agents = processAgents(sObjectsByType.get(Contact.SObjectType));
                    return agents;
                }
                else if(payloadObject == LANDLORD) {
                    landlords = processPersonAccounts(sObjectsByType, FC_Constant.RecordType_Account_Individual_Landlord);
                    return landlords;
                }
                else if(payloadObject == TENANT) {
                    tenants = processPersonAccounts(sObjectsByType, FC_Constant.RecordType_Account_Tenant);
                    return tenants;
                }
                else if(payloadObject == TENANCY) {
                    deposits = processTenancies(sObjectsByType);
                    return deposits;
                }
                else if(payloadObject == DISPUTE) {
                    return processDisputes(sObjectsByType.get(Case.SObjectType));
                }
                else if(payloadObject == DISPUTE_LINE) {
                    return processDisputeItems(sObjectsByType.get(Dispute_Item__c.SObjectType));
                }
                else if(payloadObject == EVIDENCE) {
                    return processEvidences(sObjectsByType.get(Evidence_Attachment__c.SObjectType));
                }
            }
            catch(DmlException dmlExc) {
                if(dmlExc.getDmlType(0) == StatusCode.DUPLICATE_EXTERNAL_ID) {
                    throw new FC_DisputeAPI_Exception.DuplicatedExtIdException('Duplicate external Id for relation for object ' + payloadObject + ' found');
                }
                else if(dmlExc.getDmlType(0) == StatusCode.INVALID_FIELD) {
                    String value = dmlExc.getDmlMessage(0).substringBetween('external ID: ', ' ').substringAfter(apiAccount.API_Account_Id__c.toLowerCase()+'-');
                    throw new FC_DisputeAPI_Exception.PayloadException('Invalid foreign key \'' + value + '\' for ' + payloadObject);
                }
                else if(dmlExc.getDmlType(0) == StatusCode.DUPLICATE_VALUE) {
                    String field = dmlExc.getDmlMessage(0).substringBetween('duplicate value found: ', ' ');
                    if(field == 'External_Id__c' || field == '<unknown>') {
                        throw new FC_DisputeAPI_Exception.DuplicatedExtIdException('Duplicate ' + payloadObject + ' id found');
                    }
                    else {
                        throw dmlExc;
                    }
                }
                else {
                    throw dmlExc;
                }
            }
            catch(Exception exc) {
                throw exc;
            }
            return null;
        }
        /**
         * Exposed method to allow parent class to set API Account
         *
         * @param apiAccount
         */
        public void setApiAccount(API_Account__c apiAccount) {
            this.apiAccount = apiAccount;
            this.scheme = getSchemeByName(apiAccount.Deposit_Scheme_Name__c);
        }
        /**
         * Branch Accounts processing
         *
         * @param branches
         *
         * @return List of upserted objects
         */
        protected virtual List<Account> processBranches(List<Account> inputBranches) {
            List<Account> branches = new List<Account>(inputBranches);
            for(Account branch : inputBranches) {
                branch.RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType, 'Letting_Agent');
                branch.Region__c = scheme.Region__c;
                branch = (Account)setDataOwnerId(branch);
            }
            upsert branches Branch_External_ID__c;
            return branches;
        }
        /**
         * Agent Person Accounts processing
         *
         * @param agents
         *
         * @return List of upserted objects
         */
        protected virtual List<Contact> processAgents(List<Contact> inputAgents) {
            List<Contact> agents = new List<Contact>(inputAgents);
            for(Contact agent : agents) {
                agent.Account = String.isBlank(agent.Branch_External_Id__c) ? null : new Account(Branch_External_ID__c = agent.Branch_External_Id__c);
                agent = (Contact)setDataOwnerId(agent);
            }
            upsert agents Agent_External_Id__c;
            return agents;
        }
        /**
         * Landlord Person Accounts processing
         *
         * @param landlordContacts
         * @param recordTypeDevName
         *
         * @return List of upserted objects
         */
        protected virtual List<Account> processPersonAccounts(Map<SObjectType,List<SObject>> sObjectsByType, String recordTypeDevName) {
            List<Contact> personAccountContacts = new List<Contact>((List<Contact>)sObjectsByType.get(Contact.SObjectType));
            List<Account> personAccounts = new List<Account>((List<Account>)sObjectsByType.get(Account.SObjectType));

            if(personAccounts.isEmpty()) {
                personAccounts = new Account[personAccountContacts.size()];
            }

            Schema.SObjectField personAccountExternalIdField = getPersonAccountExternalIdSObjectFieldByRecordTypeName(recordTypeDevName);
            for(Integer i=0; i< personAccountContacts.size(); i++) {
                personAccounts[i] = personAccounts[i] != null ? personAccounts[i] : new Account();
                personAccounts[i].RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType, recordTypeDevName);
                personAccounts[i].put(personAccountExternalIdField, personAccountContacts[i].get(personAccountExternalIdField.getDescribe().getName()));
                personAccounts[i].LastName = personAccountContacts[i].LastName;
                personAccounts[i].Region__c = scheme.Region__c;
                personAccounts[i] = (Account)setDataOwnerId(personAccounts[i]);
            }
            Database.upsert(personAccounts, personAccountExternalIdField, true);

            Map<Id,Account> landlordAccountsWithPersonContactMap = new Map<Id,Account>([SELECT Id, PersonContactId, Landlord_External_ID__c FROM Account WHERE Id IN :personAccounts]);

            for(Integer i=0; i< personAccounts.size(); i++) {
                Account landlordAccountWithPersonContact = landlordAccountsWithPersonContactMap.get(personAccounts[i].Id);
                personAccountContacts[i].Id = landlordAccountWithPersonContact.PersonContactId;
                personAccountContacts[i] = (Contact)setDataOwnerId(personAccountContacts[i]);
            }
            update personAccountContacts;
            return personAccounts;
        }
        /**
         * Tenancies object processing. Processes single payloadObject into Property and Deposit SObjects
         *
         * @param sObjectsByType
         * @param accountsForDepositAllocation
         *
         * @return List of upserted objects
         */
        protected virtual List<Deposit__c> processTenancies(Map<SObjectType,List<SObject>> sObjectsByType) {
            List<Property__c> properties = sObjectsByType.get(Property__c.SObjectType);
            List<Deposit__c> deposits = sObjectsByType.get(Deposit__c.SObjectType);

            for(Integer i=0; i<properties.size(); i++) {
                this.customerType = deposits[i].Customer_Type__c;
                if(String.isNotBlank(deposits[i].Customer_External_ID__c) && customerType != null) {
                    Account accountToRelate = getAccountToRelate(deposits[i].Customer_External_ID__c, customerType);
                    properties[i].Property_Owner__r = accountToRelate;
                    deposits[i].Customer__r = accountToRelate;
                }
                deposits[i].Scheme__c = scheme.Id;
            }
            insert properties;
            for(Integer i=0; i<deposits.size(); i++) {
                deposits[i].Property__c = properties[i].Id;
            }
            insert deposits;
            return deposits;
        }
        /**
         * Deposit object processing
         *
         * @param deposits
         *
         * @return List of deposit allocation records
         */
        protected virtual List<Deposit_Allocation__c> handleDepositAllocations(List<Deposit__c> deposits) {
            List<Deposit_Allocation__c> depositAllocations = new List<Deposit_Allocation__c>();
            if(tenants != null) {
                depositAllocations.addAll(
                        createDepositAllocations(deposits, tenants, TENANT)
                );
            }
            if(landlords != null) {
                depositAllocations.addAll(
                        createDepositAllocations(deposits, landlords, LANDLORD)
                );
            }
            if(branches != null) {
                depositAllocations.addAll(
                        createDepositAllocations(deposits, branches, AGENT)
                );
            }
            return depositAllocations;
        }
        /**
         * Creates Deposit Allocations for tenancies (Deposits)
         *
         * @param deposits
         * @param accountsForDepositAllocation
         *
         * @return List of upserted objects
         */
        protected virtual List<Deposit_Allocation__c> createDepositAllocations(List<Deposit__c> deposits, List<Account> accountsForDepositAllocation, String role) {
            List<Deposit_Allocation__c> depositAllocations = new List<Deposit_Allocation__c>();

            for(Deposit__c deposit : deposits) {
                for(Account accountToAllocate : accountsForDepositAllocation) {
                    Deposit_Allocation__c depositAllocation = new Deposit_Allocation__c(
                            Deposit__c = deposit.Id,
                            Deposit_Holder__c = accountToAllocate.Id,
                            Role__c = role
                    );
                    depositAllocations.add(depositAllocation);
                }
            }
            return depositAllocations;
        }
        /**
         * Dispute Cases processing
         *
         * @param disputes
         * @param tenants
         *
         * @return List of upserted objects
         */
        protected virtual List<Case> processDisputes(List<Case> disputes) {
            for(Case dispute : disputes) {
                if(dispute.Deposit_Owner_External_Id__c != null) {
                    Account accountToRelate = getAccountToRelate(dispute.Deposit_Owner_External_Id__c, customerType);
                    dispute.Account = String.isBlank(dispute.Deposit_Owner_External_Id__c) ? null : accountToRelate;
                }
                dispute.API_Account__c = apiAccount.Id;
                dispute.RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType, apiAccount.Dispute_Record_Type__c);
                dispute.Branch__r = String.isBlank(dispute.Branch_External_ID__c) ? null : new Account(Branch_External_ID__c = dispute.Branch_External_ID__c);
                dispute.Landlord__r = String.isBlank(dispute.Lead_Landlord_External_ID__c) ? null : new Contact(Landlord_External_ID__c = dispute.Lead_Landlord_External_ID__c);
                dispute.Tenant__r = String.isBlank(dispute.Lead_Tenant_External_ID__c) ? null : new Contact(Tenant_External_ID__c = dispute.Lead_Tenant_External_ID__c);
                dispute.Deposit_Account_Number__r = String.isBlank(dispute.Deposit_External_ID__c) ? null : new Deposit__c(External_ID__c = dispute.Deposit_External_ID__c);
                dispute.Agent_Contact__r = String.isBlank(dispute.Agent_External_ID__c) ? null : new Contact(Agent_External_ID__c = dispute.Agent_External_ID__c);
                dispute = (Case)setDataOwnerId(dispute);
            }
            insert disputes;
            return disputes;
        }
        /**
         * Dispute Items processing
         *
         * @param disputeItems
         *
         * @return List of upserted objects
         */
        protected virtual List<Dispute_Item__c> processDisputeItems(List<Dispute_Item__c> disputeItems) {
            for(Dispute_Item__c disputeItem : disputeItems) {
                disputeItem.Dispute__r = String.isBlank(disputeItem.Dispute_External_Id__c) ? null : new Case(External_ID__c = disputeItem.Dispute_External_Id__c);
            }
            insert disputeItems;
            return disputeItems;
        }
        /**
         * Evidences processing
         *
         * @param evidences
         *
         * @return List of upserted objects
         */
        protected virtual List<Evidence_Attachment__c> processEvidences(List<Evidence_Attachment__c> evidences) {
            for(Evidence_Attachment__c evidence : evidences) {
                evidence.Dispute__r = String.isBlank(evidence.Dispute_External_Id__c) ? null : new Case(External_ID__c = evidence.Dispute_External_Id__c);
                evidence.Dispute_Item__r = String.isBlank(evidence.Dispute_Item_External_ID__c) ? null : new Dispute_Item__c(External_ID__c = evidence.Dispute_Item_External_ID__c);
                // dropping extensions being sent as part of file name
                evidence.Filename__c = evidence.Filename__c.substringBefore('.');
            }
            insert evidences;
            return evidences;
        }
        /**
        *Case participants processing
        *
        * @param disputes
        *
        * @return List of case participants to insert
        */
        protected virtual List<Case_Participant__c> handleCaseParticipants(List<Case> disputes) {
            List<Case_Participant__c> participants = new List<Case_Participant__c>();
            if(tenants != null) {
                participants.addAll(
                        createCaseParticipants(disputes, tenants, TENANT)
                );
            }
            if(landlords != null) {
                participants.addAll(
                        createCaseParticipants(disputes, landlords, LANDLORD)
                );
            }
            if(branches != null) {
                participants.addAll(
                        createCaseParticipants(disputes, branches, AGENT)
                );
            }
            return participants;
        }
        /**
         * Creates Case Participant records for the relevant parties
         *
         * @param disputes
         * @param caseParticipantAccounts
         * @param type
         *
         * @return
         */
        protected virtual List<Case_Participant__c> createCaseParticipants(List<Case> disputes, List<Account> caseParticipantAccounts, String type) {
            List<Case_Participant__c> caseParticipants = new List<Case_Participant__c>();
            Map<Id,Account> accountsWithPersonContactIdMap = new Map<Id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :caseParticipantAccounts]);
            for(Account acc : caseParticipantAccounts) {
                Case_Participant__c caseParticipant = new Case_Participant__c(
                        Case__c = disputes[0].Id,
                        Account__c = acc.Id,
                        Contact__c = agents != null && type == AGENT ? agents[0].Id : accountsWithPersonContactIdMap.get(acc.Id).PersonContactId,
                        Type__c = type,
                        Access_Code__c = generateParticipantAccessCode(disputes[0].Id, acc.Id)
                );
                caseParticipants.add(caseParticipant);

            }
            return caseParticipants;
        }
        /**
         * Get Scheme by Name
         *
         * @param schemeName
         *
         * @return Scheme object
         */
        private Scheme__c getSchemeByName(String schemeName) {
            try {
                return [SELECT Id, Region__c FROM Scheme__c WHERE Name = :schemeName];
            }
            catch (QueryException exc) {
                throw new SchemeException('Could not find scheme for configured name: ' + schemeName);
            }
        }
        /**
         * Data submitted by API to be owned by its specific supplier API Account User instead of being owned by the Site Guest User
         *
         * @param record
         *
         * @return
         */
        private SObject setDataOwnerId(SObject record) {
            if(apiAccount.Data_Owner_User__c != null) {
                //add try / catch here - if the OwnerId cannot be set in case data model changes and sharing gets controlled by parent it will log it in error log
                try {
                    record.put('OwnerId', apiAccount.Data_Owner_User__c);
                }
                catch(Exception e){
                    FC_ErrorLogger.debug('The data model has changed and code in Data Manipulator should be adjusted not to try to set the OwnerId for object ' +record.getSObjectType().getDescribe().getName());
                }
            }
            return record;
        }

        /**
         * Generates an 8 digit string used for Case Participant access code field, based on their parent case and respective account ID
         * Really basic guid generator based on concatenating last 4 digits from case and account record ID
         *
         * @param caseId with parent case ID
         * @param accId with corresponding account ID
         *
         * @return String with generated access code
         */
        private String generateParticipantAccessCode(String caseId, String accId){
            String accessCode;
            try{
                accessCode = caseId.substring(13) + accId.substring(13);
            }
            catch(Exception e){
                FC_ErrorLogger.debug('Failed to generate Access Code for Case Participant with account ID ' + accId);
            }
            return accessCode;
        }
        /**
         * Get the Account to be matched through the relation on the object
         *
         * @param externalId
         * @param customerType
         *
         * @return
         */
        private Account getAccountToRelate(String externalId, String customerType) {
            if(customerType.equalsIgnoreCase(BRANCH)) {
                return new Account(Branch_External_Id__c = externalId);
            }
            else if (customerType.equalsIgnoreCase(LANDLORD)) {
                return new Account(Landlord_External_Id__c = externalId);
            }
            throw new FC_DisputeAPI_Exception.PayloadException('Customer Type not defined');
        }
        /**
         * Get External object of Person Account to be used for the upsert operation
         *
         * @param recordTypeDevName
         *
         * @return
         */
        private Schema.SObjectField getPersonAccountExternalIdSObjectFieldByRecordTypeName(String recordTypeDevName) {
            if(recordTypeDevName == FC_Constant.RecordType_Account_Tenant) {
                return Account.Tenant_External_ID__c;
            }
            else if (recordTypeDevName == FC_Constant.RecordType_Account_Individual_Landlord) {
                return Account.Landlord_External_ID__c;
            }
            throw new FC_DisputeAPI_Exception.PayloadException('Object Type not supported by service.');
        }
    }
    /**
     * Queueable class used for insertion of specific object types
     */
    private virtual class QueueableObjectDML implements Queueable {
        private List<sObject> recordsToInsert;

        public QueueableObjectDML(List<sObject> records) {
            this.recordsToInsert = records;
        }
        /**
         * Execute the queueable job
         *
         * @param context
         */
        public void execute(QueueableContext context) {
            performDML(this.recordsToInsert);
        }
        /**
         * Performs DML on all the objects in recordsToInsert list
         *
         * @param records
         */
        public virtual void performDML(List<sObject> records) {
            try {
                insert records;
            }catch(Exception ex) {
                FC_ErrorLogger.error(ex);
            }
        }

    }

    private class SchemeException extends Exception{}
}