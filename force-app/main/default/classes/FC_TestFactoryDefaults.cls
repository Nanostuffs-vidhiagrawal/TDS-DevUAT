/**
 * @who   Tiago Lopes <tiago.lopes@weare4c.com>
 * @what  Class that holds implemented models for SObject field defaults.
 *        Edit this class to include new default field assignment for existing and new SObjects.
 * @when  24/10/2019
 */
@isTest
public class FC_TestFactoryDefaults {

  // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
  // For custom objects, omit the __c from the Object Name

  public class UserDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      String lastName = 'Tester';
      Integer uniqueInteger = System.now().millisecond();
      return new Map<Schema.SObjectField, Object> {
        User.FirstName         => 'Inigo Montoya',
        User.LastName          => lastName,
        User.Alias             => EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(lastName + uniqueInteger))).substring(0,8),
        User.Email             => lastName + '.' + uniqueInteger + '.' + UserInfo.getOrganizationId() + '@example.com',
        User.Username          => lastName + '.' + uniqueInteger + '@example.com.' + UserInfo.getOrganizationId(),
        User.ProfileId         => [SELECT Id FROM Profile WHERE Name  = 'System Administrator' LIMIT 1].Id,
        // User.UserRoleId     => [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1].Id,
        User.TimeZoneSidKey    => 'America/Chicago',
        User.LanguageLocaleKey => 'en_US',
        User.EmailEncodingKey  => 'UTF-8',
        User.LocaleSidKey      => 'en_US'
      };
    }
  }

  public class AccountDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
        Account.Name => 'Test Account'
      };
    }
  }

  public class EmptyAccountDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
      };
    }
  }

  public class MyAccountDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
        Account.Name => 'My Test Account'
      };
    }
  }

  public class ContactDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
        Contact.FirstName => 'First',
        Contact.LastName  => 'Last'
      };
    }
  }

  public class OpportunityDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
        Opportunity.Name      => 'Test Opportunity',
        Opportunity.StageName => 'Closed Won',
        Opportunity.CloseDate => System.today()
      };
    }
  }

  public class CaseDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
        Case.Subject => 'Test Case'
      };
    }
  } 
  
  public class EntitlementDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            Entitlement.Name => FC_Constant.Entitlement_Dispute_EW_Insured_TEST_ENTITLEMENT_NAME
      };
    }
  } 
  
  public class DisputeItemDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            Dispute_Item__c.Type__c => FC_Constant.Dispute_Item_Type_Damage
      };
    }
  }  
  
  public class AgentWorkDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            AgentWork.UserId => UserInfo.getUserId()
      };
    }
  }  
  
  public class DisputeAPIMappingsDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            Dispute_API_Mapping__c.Payload_Parameter_Name__c => 'test'
      };
    }
  }  
  
  public class DisputeAPIObjectDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            Dispute_API_Object__c.Name => 'dispute'
      };
    }
  }
  
  public class APIAccountDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            API_Account__c.Dispute_Record_Type__c =>  FC_Constant.RecordType_Dispute_EW_Insured_Dev_Name,
            API_Account__c.API_Account_Id__c =>       FC_Constant.TEST_CLIENT_APIACCOUNTID,
            API_Account__c.Client_Id__c =>            FC_Constant.TEST_CLIENT_ID,
            API_Account__c.Client_Secret__c =>        FC_Constant.TEST_CLIENT_SECRET,
            API_Account__c.Deposit_Scheme_Name__c =>  FC_Constant.Despoit_Scheme_England_And_Wales_Insured,
            API_Account__c.Data_Owner_User__c =>      UserInfo.getUserId()
      };
    }
  }  
  
  public class SchemeDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
            Scheme__c.Name => FC_Constant.Despoit_Scheme_England_And_Wales_Insured,
            Scheme__c.Region__c => FC_Constant.Region_England_And_Wales
      };
    }
  }

  public class DepositDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
              Deposit__c.Deposit_Amount__c => 2000,
              Deposit__c.Start_Date__c => System.today(),
              Deposit__c.End_Date__c => System.today().addDays(365),
              Deposit__c.Rent_Amount__c => 1500
      };
    }

  }

  public class PropertyDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
              Property__c.Street__c => 'Test Street',
              Property__c.City__c => 'Test City'
      };
    }
  }  
  
  public class SpringCMSettingsDefaults implements FC_TestFactory.FieldDefaults {
    public Map<Schema.SObjectField, Object> getFieldDefaults() {
      return new Map<Schema.SObjectField, Object> {
              SpringCM_Settings__c.API_User_Client_Id__c => '123',
              SpringCM_Settings__c.API_User_Client_Secret__c => '234',
              SpringCM_Settings__c.Auth_Endpoint__c => 'https://authuat.springcm.com/api/v201606/apiuser',
              SpringCM_Settings__c.Sharelinks_Endpoint__c => 'https://apiuatna11.springcm.com/v201411/sharelinks',
              SpringCM_Settings__c.Spring_AID__c => '12345',
              SpringCM_Settings__c.Document_Merge_Endpoint__c => 'eu11'
      };
    }
  }
}