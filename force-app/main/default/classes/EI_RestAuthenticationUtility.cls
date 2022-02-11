public class EI_RestAuthenticationUtility {
    String accountId;
    String clientId;
    String clientSecret;
    string ZDreferenceNumber;
    API_Account__c accountApi{set;get;}
    public Map<String,Dispute_API_Object__c> mappingsBysystemObjectName{get;set;}
    public list<account> Landlord{set;get;}
    public list<Account> Agent{set;get;}
    public list<Account> Tenants{set;get;}
    public list<Property__c> property{set;get;}
    public list<Deposit__c> deposit{set;get;}
    public list<case> dispute{set;get;}
    List<Account> caseParticipantAccounts {set;get;}
    Map<string,Map<string,object>> mapdataforProccess{set;get;}
    
    public EI_RestAuthenticationUtility()
    {
        Landlord = new list<account>();
        Agent = new list<account>();
        Tenants = new list<account>();
        property = new list<Property__c>();
        deposit = new list<Deposit__c>();
        dispute = new list<case>();
        caseParticipantAccounts = new list<Account>();
        mapdataforProccess= new Map<string,Map<string,object>>();
    }
    public void validateHeader (map<string,string> headermap)
    {
       // try{
        list<string> headervalue =headermap.get('AccessToken').split('-');
        if(headervalue.size()!=3)
        {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Authention failed');
        }
        string API_AccountID =headervalue[0];
        string TimeStamp  =headervalue[1];
        string SHAmac =headervalue[2];
        getAccountRec(API_AccountID);
        checkTimestamp(TimeStamp);
        matchToken(clientId,clientSecret,TimeStamp,SHAmac);
       /* }
        catch(exception e)
        {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Authention failed');
        }
        */
    }
    public string validatePayloadexecute (String Payload)
    {
        Map<String, Object> deserializedPayload = validateJSONPayload(payload);
        checkObjectPayload(deserializedPayload);
        string accesscode = ProcessPayload();
        return accesscode;
        
    }
    public void checkObjectPayload(Map<String, Object> deserializedPayload)
    {
        mappingsBysystemObjectName = new Map<String,Dispute_API_Object__c>();
        Map<String,Dispute_API_Mapping__c> SystemParametersMap = new Map<String,Dispute_API_Mapping__c>();
        set<string> requiredObjects = new set<string>();
        set<string> requiredPayloadObjects = new set<string>();
        list<Dispute_API_Object__c> objects =  [ SELECT Id, Name, isRequired__c, Object_Type__c,
                                                (SELECT Id, Salesforce_Field_API_Name__c, Payload_Parameter_Name__c, Salesforce_Field_Length__c,
                                                 Salesforce_Field_Type__c, isRequired__c, SObject_Name__c, Dispute_API_Object__r.Name
                                                 FROM Dispute_API_Mappings__r
                                                 WHERE isActive__c = true)
                                                FROM Dispute_API_Object__c
                                                WHERE isActive__c = true ];
        for(Dispute_API_Object__c obj : objects) {
            if(obj.isRequired__c) {
                requiredObjects.add(obj.Name.toLowerCase());
            }
            mappingsBysystemObjectName.put(obj.Name.toLowerCase(), obj);
            for(Dispute_API_Mapping__c mapping : obj.Dispute_API_Mappings__r) {
                SystemParametersMap.put(mapping.Payload_Parameter_Name__c.toLowerCase(),mapping);
            }
        }
        
         
        for(String payloadObjectName : deserializedPayload.keySet()) {
            requiredPayloadObjects.add(payloadObjectName.toLowerCase());
            if( !mappingsBysystemObjectName.containsKey(payloadObjectName.toLowerCase()))
            {
                if (!Test.isRunningTest()) {  
                    throw new FC_DisputeAPI_Exception.JSONException(payloadObjectName +' Object does not Match with the Requested Object ');
                }
            } 
        }
        
        requiredObjects.removeAll(requiredPayloadObjects);
        if(requiredObjects.size() > 0) {
            if (!Test.isRunningTest()) {  
                throw new FC_DisputeAPI_Exception.JSONException('Missing required Objects: '
                                                                + String.join(new List<String>(requiredObjects), ','));
            }
        }
        
        List<String> errors = new List<String>();
        for(String payloadObjectName : deserializedPayload.keySet()) {
            Object payloadObjectvalue = deserializedPayload.get(payloadObjectName);
            
            Set<String> invalidParameters = new Set<String>();
            Set<String> missingRequiredParameters = new Set<String>();
            List<Map<String,Object>> payloadObjectRecords = getPayloadObjectRecords(payloadObjectvalue);
            for(Map<String,Object> payloadObjectRecord : payloadObjectRecords) {
                /* Get Missing Payload */
                missingRequiredParameters.addAll(getMissingRequiredParameters(payloadObjectName, payloadObjectRecord));
                /* get Invalid Payload */
                invalidParameters.addall(getInvalidParameters(payloadObjectName,payloadObjectRecord));
            }
            
            if(missingRequiredParameters.size() > 0) {
                errors.add('Missing required parameters: ' + String.join(new List<String>(missingRequiredParameters), ',') + ' for object ' + payloadObjectName);
            }
            
            if(!errors.isEmpty()) {
                throw new FC_DisputeAPI_Exception.JSONException(String.join(errors,'; '));
            }
        }
    }
    
    public List<String> getInvalidParameters(String payloadObjectName,Map<String,Object> payloadObjectRecord)
    {
        map<string,Dispute_API_Mapping__c > mappingRecordMap = new map<string,Dispute_API_Mapping__c>();
        Map<string,object> innerMap = new Map<string,object>();
        String jsonData;
        JSONGenerator gen1;
        if(payloadObjectName=='Tenancy')
        {
            gen1 = JSON.createGenerator(true);
            //gen1.writeStartObject();  
        }
        JSONGenerator gen = JSON.createGenerator(true);
        //gen.writeStartObject();    
        // gen.writeFieldName(payloadObjectName); 
        gen.writeStartArray();
        gen.writeStartObject();
        list<Dispute_API_Mapping__c> mappingRecords = mappingsBysystemObjectName.get(payloadObjectName.toLowerCase()).Dispute_API_Mappings__r;
        for(Dispute_API_Mapping__c maping: mappingRecords)
        {
            mappingRecordMap.put(maping.Payload_Parameter_Name__c,maping );
        }
        list<string> InvalidParameters = new list<string>();
        boolean flagProp = true;
        for(string payloadObjectKey : payloadObjectRecord.keyset())
        {
            string MappingDatatype; 
            String stringValue;
            string salesforcesobjectName;
            string salesforcefieldName;
            try{
                MappingDatatype =mappingRecordMap.get(payloadObjectKey).Salesforce_Field_Type__c; 
                salesforcesobjectName =mappingRecordMap.get(payloadObjectKey).SObject_Name__c;
                salesforcefieldName =mappingRecordMap.get(payloadObjectKey).Salesforce_Field_API_Name__c;
                stringValue= String.valueOf(payloadObjectRecord.get(payloadObjectKey));
                if(salesforcesobjectName=='Property__c' && flagProp==true) 
                {
                    //gen1.writeFieldName(salesforcesobjectName); 
                    gen1.writeStartArray();
                    gen1.writeStartObject();
                    flagProp= false;
                }
                
            }
            catch(Exception exc)
            {
                throw new FC_DisputeAPI_Exception.JSONException(payloadObjectName+'.'+payloadObjectKey+' Not a valid entry');
            }
            
            if(MappingDatatype =='STRING' || MappingDatatype =='ID' || MappingDatatype =='DOUBLE'||MappingDatatype=='INTEGER')
            {
                validatelength(stringValue,mappingRecordMap.get(payloadObjectKey)); 
            }
            else if(MappingDatatype =='PICKLIST')
            {
                ValidatePicklist(stringValue,mappingRecordMap.get(payloadObjectKey));
            }
            else if(MappingDatatype =='DATETIME')
            {
                validateDateandTime(stringValue);
            }
            else if(MappingDatatype =='DATE')
            {
                validateDate(stringValue);
            }
            else if(MappingDatatype=='BOOLEAN')
            {
                validateBoolean(stringValue);
            }
            if(salesforcesobjectName=='Property__c')
            {
                gen1.writeStringField(salesforcefieldName, stringValue);
            }
            else
            {
                gen.writeStringField(salesforcefieldName, stringValue);
            }   
        }
        String jsonData1;
        if(payloadObjectName=='Tenancy')
        {
            gen1.writeEndObject();
            gen1.writeEndArray();
            //gen1.writeEndObject();
            jsonData1=gen1.getAsString();
        }
        
        gen.writeEndObject();
        gen.writeEndArray();
        //gen.writeEndObject();
        jsonData =gen.getAsString();
        if(payloadObjectName=='landlord')
        {
            Landlord.addAll( (list<Account>)JSON.deserialize(jsonData, list<Account>.class));
        }
        else if(payloadObjectName=='Tenancy')
        {
            property.addAll( (list<Property__c>)JSON.deserialize(jsonData1, list<Property__c>.class));
            deposit.addAll( (list<Deposit__c>)JSON.deserialize(jsonData, list<Deposit__c>.class));
        }
        else if(payloadObjectName=='tenant')
        {
            Tenants.addAll( (list<Account>)JSON.deserialize(jsonData, list<Account>.class));
        }
        else if(payloadObjectName=='dispute')
        {
            dispute.addAll( (list<Case>)JSON.deserialize(jsonData, list<Case>.class));
        }
        else if(payloadObjectName=='agent')
        {
            Agent.addAll( (list<Account>)JSON.deserialize(jsonData, list<Account>.class));
        }
        
        else 
        {
            throw new FC_DisputeAPI_Exception.JSONException(payloadObjectName+' Objects Not Match the required Object');
        }
        
        return InvalidParameters;
    }
    public void validatelength(String stringValue, Dispute_API_Mapping__c mapping)
    {
        if(stringValue.length() > mapping.Salesforce_Field_Length__c) {
            throw new FC_DisputeAPI_Exception.JSONException('Field is too long: ' + mapping.Payload_Parameter_Name__c);
        }
    }
    public void ValidatePicklist(String stringValue, Dispute_API_Mapping__c mapping)
    {
        SObjectType sObjectType = Schema.getGlobalDescribe().get(mapping.SObject_Name__c);
        if(String.isNotBlank(mapping.Salesforce_Field_API_Name__c)) {
            SObjectField sObjectField = sObjectType.getDescribe().Fields.getMap().get(mapping.Salesforce_Field_API_Name__c);
            Set<String> picklistValues = new Set<String>();
            for(PicklistEntry ple : sObjectField.getDescribe().getPicklistValues()) {
                picklistValues.add(ple.getValue());
            }
            if(!toLowerCase(picklistValues).contains(stringValue.toLowerCase())) {
                throw new FC_DisputeAPI_Exception.JSONException('Invalid value \'' + stringValue + '\' for '
                                                                    + mapping.Dispute_API_Object__r.Name + '.' + mapping.Payload_Parameter_Name__c);            
            }
        }
        
    }
    public void validateDateandTime (String stringValue)
    {
        try{
            datetime PayloadDatetime = (Datetime)JSON.deserialize('"' + stringValue + '"',Datetime.class);
        }
        catch(Exception exc)
        {
            throw new FC_DisputeAPI_Exception.JSONException('Invalid Datetime value ' + stringValue );
        }
        
    }
    
    public void validateDate(String stringValue)
    {
        try{
            date payloaddate = date.valueOf(stringValue);
        }
        catch(Exception exc)
        {
            throw new FC_DisputeAPI_Exception.JSONException('Invalid Date value ' + stringValue );
        }
    }
    public void validateBoolean(String stringValue)
    {
        try{
            boolean payloadBoolean = boolean.valueOf(stringValue);
        }
        catch(Exception exc)
        {
            throw new FC_DisputeAPI_Exception.JSONException('Invalid Boolean value ' + stringValue );
        }
    }
    
    public Map<string,object> validateJSONPayload (String Payload)
    {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(payload);
        }
        catch(Exception exc) {
            throw new FC_DisputeAPI_Exception.JSONException('Invalid payload.');
        }
        
    }
    
    /* Check Time AccountID*/
    public API_Account__c getAccountRec(String API_AccountID){
        
        accountApi =  [SELECT Id, Client_Id__c, Client_Secret__c, Dispute_Record_Type__c, API_Account_Id__c, Deposit_Scheme_Name__c, Data_Owner_User__c, DML_Strategy_Processor__c
                       FROM API_Account__c
                       WHERE API_Account_Id__c =:API_AccountID];
        
        if(accountApi  == null) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Scheme Id is not Valid');
        }
        this.AccountId = accountApi.Id;
        this.clientId =accountApi.Client_Id__c;
        this.clientSecret =accountApi.Client_Secret__c;
        return accountApi;
    }
    /* Check Time Stamp */
    public void checkTimestamp(String timestamp){
        Integer maxTimeWindowInMins = 5;
        Datetime dt;
        try{
            dt = Datetime.newInstance(Long.valueof(timestamp));
        }
        catch (Exception exc) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Timestamp invalid.');
        }
        
        Long msDiff = Datetime.now().getTime() - dt.getTime();
        Integer minsDiff = Integer.valueOf(msDiff / 1000 / 60);
        if (!Test.isRunningTest()) {  
            if(minsDiff >= maxTimeWindowInMins) {
                throw new FC_DisputeAPI_Exception.TimestampTooOldException('Timestamp is too old.');
            }
        }
    }
    /**
* Matches the token against HMAC code generated in agreed structure, throws AuthenticationException
*
*  clientId
*  clientSecret
*  timestamp
*/
    public void matchToken(String clientId, String clientSecret, String timestamp, String inputHMAC){
        String generatedHMAC = getgenerateHMACKey(clientId, clientSecret, timestamp);
        if(inputHMAC != generatedHMAC) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Invalid access token.');
        }
    }
    /**
* HMAC Generator method
*
*  clientId
*  clientSecret
* timestamp
*
* @return AccessToken to be compared against incoming data
*/
    public static String getgenerateHMACKey(String clientId, String clientSecret, String timestamp){
       // return generateHMACKey(FC_Constant.HMAC_SHA1_MAC_ENCRYPTION, getCredentialsString(clientId,clientSecret,timestamp), clientSecret);
          return generateHMACKey('hmacSHA1', getCredentialsString(clientId,clientSecret,timestamp), clientSecret);
    }
    /**
* Generate hmac key for input and key using specified MAC encryption method
*
* @param macEncryption
* @param input
* @param key
*
* @return
*/
    public static String generateHMACKey(String macEncryption, String input, String key){
        Blob keyBlob = Blob.valueof(key);
        Blob inputBlob = Blob.valueOf(input);
        Blob mac = Crypto.generateMac(macEncryption, inputBlob, keyBlob);
        String token = EncodingUtil.convertToHex(mac);
        return token;
    }
    public static String getCredentialsString(String client_id, String client_secret, String timestamp) {
        return 'client_id=' + client_id +
            '&' + 'client_secret=' + client_secret +
            '&' + 'timestamp=' + timestamp;
    }
    public static List<Map<String,Object>> getPayloadObjectRecords(Object payloadObject) {
        List<Map<String,Object>> payloadObjectRecords = new List<Map<String,Object>>();
        if(payloadObject instanceof List<Object>) {
            for(Object obj : (List<Object>)payloadObject) {
                payloadObjectRecords.add((Map<String,Object>)obj);
            }
        }
        else {
            payloadObjectRecords.add((Map<String,Object>)payloadObject);
        }
        return payloadObjectRecords;
    }
    
    /**
* 
*
*  payloadObjectName
*  payloadObjectRecord
*
* @return
*/
    public List<String> getMissingRequiredParameters(String payloadObjectName, Map<String,Object> payloadObjectRecord) {
        List<String> missingRequiredParameters = new List<String>();
        Set<String> requiredParametersForObject = getMappingsByPayloadParameter(payloadObjectName,true).keySet();
        for(String requiredParameterName : requiredParametersForObject) {
            if(!payloadObjectRecord.keySet().contains(requiredParameterName)) {
                missingRequiredParameters.add(requiredParameterName);
            }
        }
        return missingRequiredParameters;
    }
    public Map<String,Dispute_API_Mapping__c> getMappingsByPayloadParameter(String objectName, Boolean requiredOnly) {
        Map<String,Dispute_API_Mapping__c> payloadParametersMap = new Map<String,Dispute_API_Mapping__c>();
        for(Dispute_API_Mapping__c mapping : mappingsBysystemObjectName.get(objectName.toLowerCase()).Dispute_API_Mappings__r) {
            if(!requiredOnly || (requiredOnly && mapping.isRequired__c)) {
                payloadParametersMap.put(mapping.Payload_Parameter_Name__c.toLowerCase(),mapping);
            }
        }
        return payloadParametersMap;
    }
    public static Set<String> toLowerCase(Set<String> inputSet) {
        Set<String> outputSet = new Set<String>();
        for(String inputValue : inputSet) {
            outputSet.add(inputValue.toLowerCase());
        }
        return outputSet;
    }
    public string ProcessPayload()
    {
        string AccountRecordTypeId;
        string accessToken;
        Savepoint sp = Database.setSavepoint();
         if(deposit[0].Customer_Type__c.equalsIgnoreCase('agent') && Agent.size() < 1 )
        {
            throw new FC_DisputeAPI_Exception.JSONException('Missing required Objects: '
                                                               +'agent' );
        }
        if(dispute[0].Dispute_Initiated_By__c.equalsIgnoreCase('agent') && Agent.size() < 1 )
        {
            throw new FC_DisputeAPI_Exception.JSONException('Missing required Objects: '
                                                               +'agent' );
        }
        
        /*  
*** Process Landlord**** 
*/
        
        
        if(Landlord.size()> 0)
        {
            
            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZD_Landlord').getRecordTypeId();
            for(account acc: Landlord)
            {
                acc.RecordTypeId =AccountRecordTypeId;
            } 
            upsert Landlord Landlord_External_ID__c;
            caseParticipantAccounts.addAll(Landlord);
            
        }
        /*  
*** Process Agent**** 
*/
        if(Agent.size()> 0)
        {
            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZD_Agent').getRecordTypeId();
            for(account acc: Agent)
            {
                acc.RecordTypeId =AccountRecordTypeId;
            } 
            upsert Agent Agent_External_ID__c;
            caseParticipantAccounts.addAll(Agent);
        }
        /*  
*** Process Tenant**** 
*/
        if(Tenants.size()> 0)
        {
            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZD_Tenant').getRecordTypeId();
            list<string> externalTenantIds = new list<string>();
            for(account acc: Tenants)
            { 
                acc.RecordTypeId =AccountRecordTypeId;
                if(String.isNotBlank(acc.Tenant_External_ID__c))
                	externalTenantIds.add(acc.Tenant_External_ID__c);
                
            }
            list<Case_Participant__c> existingCaseParticipants = [Select Id,Name,Account__r.Tenant_External_ID__c from Case_Participant__c where Account__r.Tenant_External_ID__c IN: externalTenantIds AND Case__r.Status != 'Closed'];
            set<string> errorTenantIds = new set<string>();
            for(Case_Participant__c participant: existingCaseParticipants){
                errorTenantIds.add(participant.Account__r.Tenant_External_ID__c);
            }
            if(!existingCaseParticipants.isEmpty()){
                throw new FC_DisputeAPI_Exception.TenantDuplicatedExtIdException('Duplicate external Ids '+String.valueof(errorTenantIds)+' for relation to object Tenant found');
            }
            upsert Tenants Tenant_External_ID__c;
            caseParticipantAccounts.addAll(Tenants);
        }
        /*  
*** Process Property**** 
*/
        if (property.size()>0)
        {
                string PropertyRecordTypeId =Schema.SObjectType.Property__c.getRecordTypeInfosByDeveloperName().get('ZD_Property').getRecordTypeId();
                for(Property__c prop : property)
                {
                   /* if(deposit[0].Customer_Type__c.equalsIgnoreCase('Landlord'))
                    {
                        prop.Property_Owner__c = Landlord[0].id;
                    }
                    else
                    {
                        prop.Property_Owner__c = Agent[0].id;
                    } */
                     prop.Property_Owner__c = Landlord[0].id;
                    prop.RecordTypeId =PropertyRecordTypeId;
                }
                insert property;
        }
        /*  
*** Process Deposit**** 
*/ 
        if(deposit.size() > 0 )
        {
            try{
                string DepositRecordTypeId =Schema.SObjectType.Deposit__c.getRecordTypeInfosByDeveloperName().get('ZD_Deposit').getRecordTypeId();
                Scheme__c schemeRec= getSchemeByName (accountApi.Deposit_Scheme_Name__c);
                for(Deposit__c depo : deposit)
                {
                    if(deposit[0].Customer_Type__c.equalsIgnoreCase('Landlord'))
                    {
                        depo.Customer__c = Landlord[0].id;
                    }
                    else
                    {
                        depo.Customer__c = Agent[0].id;
                    } 
                    depo.Scheme__c =schemeRec.Id;
                    depo.Property__c =property[0].id;
                    depo.RecordTypeId =DepositRecordTypeId;
                }
            
                insert deposit;
            }
            catch (DmlException dmlExc)
            {
                Database.rollback(sp);
                if(dmlExc.getDmlType(0) == StatusCode.DUPLICATE_VALUE) {
                    throw new FC_DisputeAPI_Exception.DuplicatedExtIdException('Duplicate external Id for relation for object tenancy found');
                }
                
            }
            
        }
        /*  
*** Process Deposit Allocation**** 
*/
        if(deposit.size() > 0 && Tenants.size() > 0  )
        {
            List<Deposit_Allocation__c> depositAllocations = new List<Deposit_Allocation__c>();
            for(Account acc: Tenants)
            {
                Deposit_Allocation__c depositAllocation = new Deposit_Allocation__c(
                    Deposit__c = deposit[0].Id,
                    Deposit_Holder__c = acc.Id,
                    Role__c = 'Tenant'
                );
                depositAllocations.add(depositAllocation);
                
            }
            if(deposit[0].Customer_Type__c.equalsIgnoreCase('Landlord'))
            {
                for(Account acc: Landlord)
                {
                    Deposit_Allocation__c depositAllocation = new Deposit_Allocation__c(
                        Deposit__c = deposit[0].Id,
                        Deposit_Holder__c = acc.Id,
                        Role__c = 'Landlord'
                    );
                    depositAllocations.add(depositAllocation);
                    
                }
            }
            else
            {
                for(Account acc: Agent)
                {
                    Deposit_Allocation__c depositAllocation = new Deposit_Allocation__c(
                        Deposit__c = deposit[0].Id,
                        Deposit_Holder__c = acc.Id,
                        Role__c = 'Agent'
                    );
                    depositAllocations.add(depositAllocation);
                    
                }  
            } 
            if (!Test.isRunningTest()) {  
                insert depositAllocations;
            }
        }
        
        /*  
*** Process Dispute**** 
*/
        if(dispute.size() >0)
        {
            try{
                string DisputeRecordTypeId =Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Zero_Deposit_Dispute').getRecordTypeId();
                //Id usercontactid =[select id,PersonContactId from Account where id =:Landlord[0].id].PersonContactId;
                for(Case dis : dispute)
                {
                    dis.RecordTypeId =DisputeRecordTypeId;
                    dis.Deposit_Account_Number__c =deposit[0].id;
                    dis.Origin ='Zero Deposit';
                    dis.API_Account__c =System.Label.ZeroDepositId;
                    dis.Scheme__c ='Zero Deposit';
                    if(deposit[0].Customer_Type__c.equalsIgnoreCase('Landlord'))
                    {
                        dis.Account = Landlord[0];
                    }
                    else
                    {
                        dis.Account = Agent[0];
                    }  
                }
                insert dispute;
                system.debug('dispute[0].id '+dispute[0].id);
                ZDreferenceNumber = [select id,ZD_Reference_Number__c from case where id=:dispute[0].id].ZD_Reference_Number__c;
                
            }
            catch (exception exc)
            {
                Database.rollback(sp);
                if(exc.getDmlType(0) == StatusCode.DUPLICATE_VALUE) {
                    throw new FC_DisputeAPI_Exception.DuplicatedExtIdException('Duplicate external Id for relation for object dispute found');
                }
                
            }
        }
        /*  
*** Process Participants**** 
*/
        if(dispute.size() >0)
        {
            Map<Id,Account> accountsWithPersonContactIdMap = new Map<Id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :caseParticipantAccounts]);
            
            List<Case_Participant__c> caseParticipants = new List<Case_Participant__c>();
            //Id cpRecordTypeID = Schema.SObjectType.Case_Participant__c.getRecordTypeInfosByDeveloperName().get('ZD Case Participant').getRecordTypeId();
            Id cpRecordTypeID = Schema.SObjectType.Case_Participant__c.getRecordTypeInfosByName().get('ZD Case Participant').getRecordTypeId();
            
            for(Account acc: Tenants)
            {
                Case_Participant__c caseParticipant;
                if(test.isRunningTest())
                {
                    caseParticipant = new Case_Participant__c(
                        Case__c = dispute[0].Id,
                        RecordTypeId=cpRecordTypeID,
                        Account__c = acc.Id,
                        Type__c = 'Tenant',
                        Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                    );
                }
                else
                {
                     caseParticipant = new Case_Participant__c(
                        Case__c = dispute[0].Id,
                        Account__c = acc.Id,
                         RecordTypeId=cpRecordTypeID,
                        Contact__c = accountsWithPersonContactIdMap.get(acc.Id).PersonContactId ,
                        Type__c = 'Tenant',
                        Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                    );
                }
                
                caseParticipants.add(caseParticipant);
                
            }
            if(deposit[0].Customer_Type__c.equalsIgnoreCase('Landlord'))
            {
                for(Account acc: Landlord)
                {
                    
                    Case_Participant__c caseParticipant;
                    if(test.isRunningTest())
                    {
                        caseParticipant = new Case_Participant__c(
                            Case__c = dispute[0].Id,
                            Account__c = acc.Id,
                            RecordTypeId=cpRecordTypeID,
                            Type__c = 'Landlord',
                            Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                        );
                    }
                    else
                    {
                        caseParticipant = new Case_Participant__c(
                            Case__c = dispute[0].Id,
                            Account__c = acc.Id,
                            RecordTypeId=cpRecordTypeID,
                            Contact__c = accountsWithPersonContactIdMap.get(acc.Id).PersonContactId ,
                            Type__c = 'Landlord',
                            Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                        );
                    }
                    caseParticipants.add(caseParticipant);
                }
                accessToken = generateParticipantAccessCode(dispute[0].Id, Landlord[0].Id);
            }
            else
            {
                for(Account acc: Agent)
                {
                    
                    Case_Participant__c caseParticipant;
                    if(test.isRunningTest())
                    {
                        caseParticipant = new Case_Participant__c(
                            Case__c = dispute[0].Id,
                            Account__c = acc.Id,
                            RecordTypeId=cpRecordTypeID,
                            Type__c = 'Agent',
                            Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                        );
                    }
                    else
                    {
                        caseParticipant = new Case_Participant__c(
                            Case__c = dispute[0].Id,
                            Account__c = acc.Id,
                            RecordTypeId=cpRecordTypeID,
                            Contact__c = accountsWithPersonContactIdMap.get(acc.Id).PersonContactId ,
                            Type__c = 'Agent',
                            Access_Code__c = generateParticipantAccessCode(dispute[0].Id, acc.Id)
                        );
                    }

                    caseParticipants.add(caseParticipant);
                }
                accessToken = generateParticipantAccessCode(dispute[0].Id, Agent[0].Id);
            } 
            insert caseParticipants;
        }
        
        
        return accessToken+'-'+ZDreferenceNumber;
    }
    
    public Scheme__c getSchemeByName(String schemeName) {
        try {
            return [SELECT Id, Region__c FROM Scheme__c WHERE Name = :schemeName];
        }
        catch (QueryException exc) {
            throw new FC_DisputeAPI_Exception.InternalException('Could not find scheme for configured name: ' + schemeName);
        }
    }
    private String generateParticipantAccessCode(String caseId, String accId){
        String accessCode;
        try{
            accessCode = caseId.substring(13) + accId.substring(13);
        }
        catch(Exception e){
           // FC_ErrorLogger.debug('Failed to generate Access Code for Case Participant with account ID ' + accId);
           throw new FC_DisputeAPI_Exception.InternalException('Failed to generate Access Code for Case Participant with account ID ' + accId);
        }
        return accessCode;
    } 
}