@istest
public class EI_ZD_LoginController_Test {
    @testSetup
    public static void dataset(){
         Id sys = [select id from profile where name='System Administrator'].id;
        Id role =[select id from userrole limit 1].id;
         User u = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = sys, country='United States',IsActive =true,
                            userroleid=role,
                             timezonesidkey='America/Los_Angeles', username='tester@noe1234mail.com');
        insert u;
           system.runAs(u) {
                    
        Id p = [select id from profile where name='ZD_Tenant'].id;
       
        account ac = EI_ZD_TestDataFactory.createTenant(1)[0];
        insert ac;
        account a =[select personcontactid from account];
              User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = a.personcontactid,
                             timezonesidkey='America/Los_Angeles', username='arora.charu05@gmail.com');
        
        insert user;
            // statements to be executed by this test user.
        }
            }
    
    @isTest
    public static void testMethod1(){
   
    
        EI_ZD_LoginController.checkPortal('qwer',null,false);
         EI_ZD_LoginController.checkPortal(null,null,false);
        EI_ZD_LoginController.checkPortal('qwer','qwert',false);
        ei_ZD_LoginCOntroller.checkPortal('1z8zYDth8hf+3riM8DZ2iUAsJM2JnYnsP6m9V8u49iD7VhpSBtL11fFsRfUFkU/+','1z8zYDth8hf+3riM8DZ2iYiWHRYPyejcmIOQ7auRqv4=',true);
  EI_ZD_loginController.resetPasswordMethod('');
        EI_ZD_loginController.resetPasswordMethod('arora.charu05@gmail.com');
    }
}