public abstract  class EI_ZD_TestDataFactory {
    public static API_Account__c createAPIAccount() 
     {
         API_Account__c apiAccount = new API_Account__c(
         	 Client_Id__c='ZD123456', 
             Client_Secret__c='ZDTopSecret', 
             Dispute_Record_Type__c='Zero_Deposit_Dispute', 
             API_Account_Id__c='zd_espire', 
             Deposit_Scheme_Name__c='Zero Deposit',  
             DML_Strategy_Processor__c='FC_DisputeAPI_DataManipulator.DataManipulatorStrategyMain'
         );
         return apiAccount;         
     }
     public static Dispute_API_Object__c createDisputeAPIObject() 
     {
         Dispute_API_Object__c dispApiObj = new Dispute_API_Object__c(
         	 Name='dispute', 
             isRequired__c=true,
             isActive__c=true,
             Object_Type__c='Object'
         );
         return dispApiObj;         
     }
    public static list<Dispute_API_Mapping__c> createDisputeAPIMappings(String dispApiObjj) 
     {
         list<Dispute_API_Mapping__c> listOfDisApiMap = new list<Dispute_API_Mapping__c>();
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Deposit_Owner_External_Id__c', 
             Payload_Parameter_Name__c='deposit_owner_id', 
             Salesforce_Field_Length__c=255,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Dispute_Reasons__c', 
             Payload_Parameter_Name__c='dispute_reasons', 
             Salesforce_Field_Length__c=32768,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='External_ID__c', 
             Payload_Parameter_Name__c='external_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Dispute_Initiated_By__c', 
             Payload_Parameter_Name__c='initiated_by', 
             Salesforce_Field_Length__c=255,
             Salesforce_Field_Type__c='PICKLIST', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Lead_Landlord_External_ID__c', 
             Payload_Parameter_Name__c='lead_landlord_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Deposit_External_ID__c', 
             Payload_Parameter_Name__c='tenancy_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Total_Claim_Amount__c', 
             Payload_Parameter_Name__c='total_claim_amount', 
             Salesforce_Field_Length__c=18,
             Salesforce_Field_Type__c='DOUBLE', 
             isRequired__c=true, 
             SObject_Name__c='Case',
             isActive__c=true,
             Dispute_API_Object__c=	dispApiObjj
         ));
         
         return listOfDisApiMap;         
     }
    
    
    
    public static Dispute_API_Object__c createAgentAPIObject() 
     {
         Dispute_API_Object__c AgntApiObj = new Dispute_API_Object__c(
         	 Name='agent', 
             isActive__c=true,
             Object_Type__c='Object'
         );
         return AgntApiObj;         
     }
    public static list<Dispute_API_Mapping__c> createAgentAPIMappings(String agentApiObjj) 
     {
         list<Dispute_API_Mapping__c> listOfDisApiMap = new list<Dispute_API_Mapping__c>();
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonEmail', 
             Payload_Parameter_Name__c='email', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Agent_External_ID__c', 
             Payload_Parameter_Name__c='external_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='FirstName', 
             Payload_Parameter_Name__c='firstname', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonTitle', 
             Payload_Parameter_Name__c='job_title', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=false, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='LastName', 
             Payload_Parameter_Name__c='lastname', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonMobilePhone', 
             Payload_Parameter_Name__c='mobile', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=false, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObjj
         ));
         
         return listOfDisApiMap;         
     }
    
    
    public static Dispute_API_Object__c createLandlordAPIObject() 
     {
         Dispute_API_Object__c lndlApiObj = new Dispute_API_Object__c(
         	 Name='landlord', 
             isActive__c=true,
             isRequired__c=true,
             Object_Type__c='Object'
         );
         return lndlApiObj;         
     }
    public static list<Dispute_API_Mapping__c> createLandloarAPIMappings(String lndlApiObjj) 
     {
         list<Dispute_API_Mapping__c> listOfDisApiMap = new list<Dispute_API_Mapping__c>();
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonBirthdate', 
             Payload_Parameter_Name__c='birth_date', 
             Salesforce_Field_Length__c=0,
             Salesforce_Field_Type__c='DATE', 
             isRequired__c=false, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='BillingCity', 
             Payload_Parameter_Name__c='city', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='BillingCountry', 
             Payload_Parameter_Name__c='country', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonEmail', 
             Payload_Parameter_Name__c='email', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Landlord_External_ID__c', 
             Payload_Parameter_Name__c='external_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='FirstName', 
             Payload_Parameter_Name__c='firstname', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='LastName', 
             Payload_Parameter_Name__c='lastname', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Phone', 
             Payload_Parameter_Name__c='phone_number', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=false, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='BillingPostalCode', 
             Payload_Parameter_Name__c='postcode', 
             Salesforce_Field_Length__c=20,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=false, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='BillingStreet', 
             Payload_Parameter_Name__c='street', 
             Salesforce_Field_Length__c=255,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	lndlApiObjj
         ));
         return listOfDisApiMap;         
     }
    
    
    
    public static Dispute_API_Object__c createTenancyAPIObject() 
     {
         Dispute_API_Object__c tencyApiObj = new Dispute_API_Object__c(
         	 Name='tenancy', 
             isActive__c=true,
             isRequired__c=true,
             Object_Type__c='Object'
         );
         return tencyApiObj;         
     }
    public static list<Dispute_API_Mapping__c> createTenancyAPIMappings(String tencyApiObjj) 
     {
         list<Dispute_API_Mapping__c> listOfDisApiMap = new list<Dispute_API_Mapping__c>();
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='City__c', 
             Payload_Parameter_Name__c='city', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Property__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Country__c', 
             Payload_Parameter_Name__c='country', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Property__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Customer_External_ID__c', 
             Payload_Parameter_Name__c='customer_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Customer_Type__c', 
             Payload_Parameter_Name__c='customer_type', 
             Salesforce_Field_Length__c=255,
             Salesforce_Field_Type__c='PICKLIST', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Deposit_Amount__c', 
             Payload_Parameter_Name__c='deposit_amount', 
             Salesforce_Field_Length__c=18,
             Salesforce_Field_Type__c='DOUBLE', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='End_Date__c', 
             Payload_Parameter_Name__c='end_date', 
             Salesforce_Field_Length__c=0,
             Salesforce_Field_Type__c='DATE', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='External_Id__c', 
             Payload_Parameter_Name__c='external_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Postal_Code__c', 
             Payload_Parameter_Name__c='postcode', 
             Salesforce_Field_Length__c=10,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Property__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Zero_Deposit_Reference__c', 
             Payload_Parameter_Name__c='reference', 
             Salesforce_Field_Length__c=255,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Rent_protection__c', 
             Payload_Parameter_Name__c='rent_protection', 
             Salesforce_Field_Length__c=0,
             Salesforce_Field_Type__c='BOOLEAN', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Start_Date__c', 
             Payload_Parameter_Name__c='start_date', 
             Salesforce_Field_Length__c=0,
             Salesforce_Field_Type__c='DATE', 
             isRequired__c=true, 
             SObject_Name__c='Deposit__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Street__c', 
             Payload_Parameter_Name__c='street', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Property__c',
             isActive__c=true,
             Dispute_API_Object__c=	tencyApiObjj
         ));
         return listOfDisApiMap;         
     }
    
    
    public static Dispute_API_Object__c createTenantAPIObject() 
     {
         Dispute_API_Object__c agentApiObj = new Dispute_API_Object__c(
         	 Name='tenant', 
             isActive__c=true,
             isRequired__c=true,
             Object_Type__c='Array'
         );
         return agentApiObj;         
     }
    public static list<Dispute_API_Mapping__c> createTenantAPIMappings(String agentApiObj) 
     {
         list<Dispute_API_Mapping__c> listOfDisApiMap = new list<Dispute_API_Mapping__c>();
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonBirthdate', 
             Payload_Parameter_Name__c='birth_date', 
             Salesforce_Field_Length__c=0,
             Salesforce_Field_Type__c='DATE', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='PersonEmail', 
             Payload_Parameter_Name__c='email', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Tenant_External_ID__c', 
             Payload_Parameter_Name__c='external_id', 
             Salesforce_Field_Length__c=244,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='FirstName', 
             Payload_Parameter_Name__c='firstname', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='LastName', 
             Payload_Parameter_Name__c='lastname', 
             Salesforce_Field_Length__c=80,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
         
         listOfDisApiMap.add(new Dispute_API_Mapping__c(
             Salesforce_Field_API_Name__c='Phone', 
             Payload_Parameter_Name__c='phone_number', 
             Salesforce_Field_Length__c=40,
             Salesforce_Field_Type__c='STRING', 
             isRequired__c=true, 
             SObject_Name__c='Account',
             isActive__c=true,
             Dispute_API_Object__c=	agentApiObj
         ));
       
         return listOfDisApiMap;         
     }
    
    
    
    
    public static Scheme__c createScheme() 
     {
         Scheme__c scheme = new Scheme__c(name='Zero Deposit',Deposit_Account_Number_Prefix__c='1234',
                                         Region__c='Zero Deposit');
         return scheme;
         
     }
    public static QueryLimits__c createQueryLimit() 
    {
     QueryLimits__c queryLimit = new QueryLimits__c(CheckOn__c=true,
                                                    Name = 'All Limits');
     return  queryLimit;
    }
    
    public static ZD_Payment_API__c createPaymentCustomSetting() 
    {
        ZD_Payment_API__c  Payment= new ZD_Payment_API__c(Live_secret_key__c='kskjfkshdfhj',
                                                         UAT_secret_key__c='skhfkhfkhkf',
                                                         name='ZD_Payment'); 
        return Payment;
    }
    
    
    
    public static List<Account> createagent( Integer numberOfClients) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType = 'Account' And DeveloperName = 'ZD_Agent']; 
        List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='agent Name'+ i,
                                          PersonEmail='abcd'+i+'@test.com',
                                          Agent_External_ID__c ='agent'+i,
                                          PersonTitle='Mr',
                                          PersonMobilePhone='+916754343547',
                                          RecordTypeId=recType.id);
            accounts.add( account);
        }
        return accounts;
    }
    public static List<Account> createLandlord( Integer numberOfClients) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType = 'Account' And DeveloperName = 'ZD_Landlord']; 
        List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='landlord Name'+ i,
                                          PersonEmail='landlord'+i+'@test.com',
                                          Landlord_External_ID__c ='landlord'+i,
                                          BillingCity='Bijnor',
                                          BillingStreet='xyz',
                                          BillingCountry='India',
                                          BillingPostalCode ='246701',
                                          Phone='+916754343547',
                                          RecordTypeId=recType.id);
            accounts.add( account);
        }
        return accounts;
    }
    public static List<Account> createTenant( Integer numberOfClients) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType = 'Account' And DeveloperName = 'ZD_Tenant']; 
        List<Account> accounts = new List<Account>();
        DateTime current = System.now();
        Long timeInMili = current.getTime()/1000;
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='Tenant Name'+ i,
                                          PersonEmail='tenant'+i+'@test.com',
                                          Tenant_External_ID__c =string.valueof(timeInMili),
                                          Phone='+916754343547',
                                          RecordTypeId=recType.id);
            accounts.add( account);
        }
        return accounts;
    }
    
    public static List<Property__c> createProperty( Integer numberOfClients,id ownerID) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType = 'Property__c' And DeveloperName = 'ZD_Property']; 
        List<Property__c> propperties = new List<Property__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Property__c property = new Property__c(City__c='xyz',
                                                   Country__c='xyz',
                                                   Postal_Code__c='xyz',
                                                   Street__c='xyz',
                                                   Property_Owner__c =ownerID,
                                                   RecordTypeId=recType.id);
            propperties.add( property);
        }
        return propperties;
    }
    public static List<Deposit__c> createDeposite( Integer numberOfClients,id Scheme,id customer,id property) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType = 'Deposit__c' And DeveloperName = 'ZD_Deposit']; 
        List<Deposit__c> Deposits = new List<Deposit__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Deposit__c deposit = new Deposit__c(End_Date__c=date.today(),
                                                Scheme__c =Scheme,
                                                Deposit_Amount__c=800.00,
                                                Customer_Type__c='Landlord',
                                                External_Id__c ='deposit'+i,
                                                Start_Date__c=(date.today()).addDays(-260),
                                                Customer__c =customer,
                                                Property__c=property,
                                                RecordTypeId=recType.id);
            Deposits.add( deposit);
        }
        return Deposits;
    }
    public static List<case> createDispute( Integer numberOfClients,id deposit) 
    {
        RecordType recType = [Select Id From RecordType Where sObjectType ='case' And DeveloperName = 'Zero_Deposit_Dispute'];
        List<case> Disputes = new List<case>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            case  dispute= new case(RecordTypeId=recType.id,
                                    External_ID__c ='dispute'+i,
                                    Dispute_Initiated_By__c ='Landlord',
                                    Total_Claim_Amount__c=700.00,
                                    Deposit_Account_Number__c =deposit,
                                    status ='New',
                                    Origin='Zero Deposit'
                                   );
            Disputes.add( dispute);
        }
        
        return Disputes;
    }
    public static List<Case_Participant__c> createCaseParticipant ( Integer numberOfClients,id caseid,id AccountId,string type) 
    {
        List<Case_Participant__c> caseParties = new List<Case_Participant__c>();
        id  conId=[select id,PersonContactId from Account where id =:AccountId].PersonContactId;
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Case_Participant__c  caseParti= new Case_Participant__c(Case__c =caseid,
                                                                    Account__c =AccountId,
                                                                    Type__c=type,
                                                                    contact__c =conId 
                                                                   );
            caseParties.add(caseParti);
        }
        
        return caseParties;
    }
    
    
    
}