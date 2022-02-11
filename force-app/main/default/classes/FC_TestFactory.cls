/**
 * @who   Tiago Lopes <tiago.lopes@weare4c.com>
 * @what  Entry point for Test Data generation.
 *        Usage:
          The TestFactory will pre-fill all the fields we typically need
          Account a = (Account)TestFactory.createSObject(new Account());
          insert a;

          You can also set values to be used. Any values set in the constructor will override the defaults
          Opportunity o = (Opportunity)TestFactory.createSObject(new Opportunity(AccountId = a.Id));

          You can also specify a specific set of overrides for different scenarios
          Account a = (Account)TestFactory.createSObject(new Account(), 'AccountDefaults');

          Get a bunch of records for testing bulk
          Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200);

          ou can optionally insert records as created like this, note the final parameter of true:
          Account a = (Account) TestFactory.createSObject(new Account(), true);
          Contact c = (Contact) TestFactory.createSObject(new Contact(AccountID = a.Id), true);

 * @when  24/10/2019
 */

public class FC_TestFactory {

  /**
   * Create SObject with default Defaults implementation class
   * ------------------------
   * @param sObj to assign field set values
   * @return given SObject including the new assigned fields
   */
  public static SObject createSObject(SObject sObj) {
    // Check what type of object we are creating and add any defaults that are needed.
    String objectName = String.valueOf(sObj.getSObjectType());
    // Construct the default values class. Salesforce doesn't allow '__' in class names
    String defaultClassName = objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
    // If there is a class that exists for the default values, then use them
    if(Type.forName('FC_TestFactoryDefaults.' + defaultClassName) != null) {
      if(!(sObj.getSObjectType() == Account.SObjectType && String.isNotBlank(String.valueOf(sObj.get('FirstName'))))) {
        sObj = createSObject(sObj, 'FC_TestFactoryDefaults.' + defaultClassName);
      }
    }
    return sObj;
  }

  /**
   * Create SObject with default Defaults implementation class and insert it
   * ------------------------
   * @param sObj to assign field set values
   * @param doInsert with boolean flag to perform insert
   * @return given SObject including the new assigned fields
   */
  public static SObject createSObject(SObject sObj, Boolean doInsert) {
    SObject retObject = createSObject(sObj);
    if(doInsert) {
      insert retObject;
    }
    return retObject;
  }

  /**
   * Create SObject with overriden Defaults implementation class name passed as string
   * ------------------------
   * @param sObj to assign field set values
   * @param defaultClassName with defaults implementation class name
   * @return given SObject including the new assigned fields
   */
  public static SObject createSObject(SObject sObj, String defaultClassName) {
    // Create an instance of the defaults class so we can get the Map of field defaults
    Type t = Type.forName(defaultClassName);
    if(t == null) {
      Throw new TestFactoryException('Invalid defaults class.');
    }
    FieldDefaults defaults = (FieldDefaults)t.newInstance();
    addFieldDefaults(sObj, defaults.getFieldDefaults());
    return sObj;
  }

  /**
   * Create SObject with overriden Defaults implementation class name passed as string
   * ------------------------
   * @param sObj to assign field set values
   * @param defaultClassName with defaults implementation class name
   * @param doInsert with boolean flag to perform insert
   * @return given SObject including the new assigned fields
   */
  public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
    SObject retObject = createSObject(sObj, defaultClassName);
    if(doInsert) {
      insert retObject;
    }
    return retObject;
  }

  /**
   * Create SObject in bulk specifying a number
   * -------------------------
   * @param sObj with an instance of the SObject to replicate
   * @param numberOfObjects with amount
   *
   * @return SObject list
   */
  public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
    return createSObjectList(sObj, numberOfObjects, (String)null);
  }

  /**
   * Create SObject in bulk specifying a number and an insert flag
   * -------------------------
   * @param sObj with instance of SObject to replicate
   * @param numberOfObjects with amount of objects to create and insert
   * @param doInsert with boolean to flag to perform insertion
   *
   * @return list of Sobjects
   */
  public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
    SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
    if(doInsert) {
      insert retList;
    }
    return retList;
  }

  /**
   * Create SObject in bulk specifying a number and an insert flag, using a specific defaults implementation
   * --------------------------
   * @param sObj with instance of SObject to replicate
   * @param numberOfObjects with amount of objects to create and insert
   * @param defaultClassName with defaults class implementation name as string
   * @param doInsert with boolean to flag to perform insertion
   *
   * @return list of Sobjects
   */
  public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
    SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
    if(doInsert) {
      insert retList;
    }
    return retList;
  }

  /**
   * Create Sobject in bulk specifying a number and using a specific defaults implementation
   * -------------------------
   * @param sObj with instance of SObject to replicate
   * @param numberOfObjects with amount of objects to create and insert
   * @param defaultClassName with defaults class implementation name as string
   *
   * @return
   */
  public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
    SObject[] sObjs = new SObject[] {};
    SObject newObj;

    // Get one copy of the object
    if(defaultClassName == null) {
      newObj = createSObject(sObj);
    } else {
      newObj = createSObject(sObj, defaultClassName);
    }

    // Get the name field for the object
    String nameField = String.valueOf(nameFieldMap.get(sObj.getSObjectType()));
    if(nameField == null) {
      nameField = 'Name';
    }
    Boolean nameIsAutoNumber = sObj.getSobjectType().getDescribe().fields.getMap().get(nameField).getDescribe().isAutoNumber();

    // Clone the object the number of times requested. Increment the name field so each record is unique
    for(Integer i = 0; i < numberOfObjects; i++) {
      SObject clonedSObj = newObj.clone(false, true);
      if(!nameIsAutoNumber) {
        clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
      }
      sObjs.add(clonedSObj);
    }
    return sObjs;
  }

  // adds field defaults to SObject
  private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
    // Loop through the map of fields and if they weren't specifically assigned, fill them.
    Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
    for(Schema.SObjectField field : defaults.keySet()) {
      if(!populatedFields.containsKey(String.valueOf(field))) {
        sObj.put(field, defaults.get(field));
      }
    }
  }

  // When we create a list of SObjects, we need to have a unique field for the insert if there isn't an autonumber field.
  // Usually we use the Name field, but some objects don't have a name field.
  private static Map<Schema.SObjectType, Schema.SObjectField> nameFieldMap = new Map<Schema.SObjectType, Schema.SObjectField> {
    Contact.sObjectType => Contact.LastName,
    Case.sObjectType => Case.CaseNumber //this is the autonumber field
  };

  public class TestFactoryException extends Exception {}

  // Use the FieldDefaults interface to set up values you want to default in for all objects.
  public interface FieldDefaults {
    Map<Schema.SObjectField, Object> getFieldDefaults();
  }

  /*** Scenario based data set up methods ***/
  public static void setUpDisputeScenarioWithParticipants(String disputeRecordTypeName){
    Account tenantAcc1 = (Account) FC_TestFactory.createSObject(new Account(FirstName='Daffy', LastName = 'Duck', PersonEmail = 'Daffy@Duck.com', PersonHomePhone = '123456789', RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person')), true);
    Account tenantAcc2= (Account) FC_TestFactory.createSObject(new Account(FirstName='Speedy', LastName = 'Gonzalez', PersonEmail = 'Speed@Gonzalez.com', PersonHomePhone = '987654321', RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person')), true);
    Account landlordAcc1 = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd', Phone = '123432234'), true);
    Contact tenantCon1 = [SELECT Email, HomePhone FROM Contact WHERE Id = :[select PersonContactId FROM Account WHERE Id =: tenantAcc1.Id].PersonContactId];
    Contact tenantCon2 = [SELECT Email, HomePhone FROM Contact WHERE Id = :[select PersonContactId FROM Account WHERE Id =: tenantAcc2.Id].PersonContactId];
    Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
    Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlordAcc1.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);
    Case newDispute = (Case) FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New, RecordTypeId=
            FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,disputeRecordTypeName), Deposit_Account_Number__c = deposit1.Id)
            , 'FC_TestFactoryDefaults.CaseDefaults',true);
    Case_Participant__c tenantPart1 = (Case_Participant__c) FC_TestFactory.createSObject(
            new Case_Participant__c(Account__c = tenantAcc1.Id,
                    Case__c = newdispute.Id,
                    Contact__c = tenantCon1.Id,
                    Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
            true);
    Case_Participant__c tenantPart2 = (Case_Participant__c) FC_TestFactory.createSObject(
            new Case_Participant__c(Account__c = tenantAcc1.Id,
                    Case__c = newdispute.Id,
                    Contact__c = tenantCon2.Id,
                    Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
            true);
    Case_Participant__c landlordPart = (Case_Participant__c) FC_TestFactory.createSObject(
            new Case_Participant__c(Account__c = landlordAcc1.Id,
                    Case__c = newdispute.Id,
                    Type__c = FC_Constant.Allocation_And_Participant_Role_Landlord),
            true);
  }

  /*** Scenario based data set up methods ***/
  public static void setUpDisputeScenarioWithParticipants(String disputeRecordTypeName, Integer size){
    Account tenantAcc1 = (Account) FC_TestFactory.createSObject(new Account(FirstName='Daffy', LastName = 'Duck', PersonEmail = 'Daffy@Duck.com', PersonHomePhone = '123456789', RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person')), true);
    Contact tenantCon1 = [SELECT Email, HomePhone FROM Contact WHERE Id = :[select PersonContactId FROM Account WHERE Id =: tenantAcc1.Id].PersonContactId];
    Account landlordAcc1 = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd', Phone = '123432234'), true);
    Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
    Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlordAcc1.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);

    List<Case> cases = new List<Case>();
    for(Integer i = 0; i < size; i++) {
      Case newDispute = (Case) FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New, RecordTypeId=
              FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,disputeRecordTypeName), Deposit_Account_Number__c = deposit1.Id)
              , 'FC_TestFactoryDefaults.CaseDefaults',false);
      cases.add(newDispute);
    }

    insert cases;
    List<Case_Participant__c> participants = new List<Case_Participant__c>();

    for(Case c : cases){
      Case_Participant__c cp = (Case_Participant__c) FC_TestFactory.createSObject(
                    new Case_Participant__c(Account__c = tenantAcc1.Id,
                    Case__c = c.Id,
                    Contact__c = tenantCon1.Id,
                    Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
                    false);
      participants.add(cp);
    }

    insert participants;

  }
}