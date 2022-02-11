@isTest
public class EI_ChangemyDetailsTest {

	@isTest
    public static void checkProfile(){
       
		Profile p = getStandardUserProfile();
        Contact c = getContact();
        User u = getUserWithProfile(p);
        System.runAs(u){
          
        User newuser = EI_ChangemyDetails.checkProfile();
             System.assertEquals(u.Id,newuser.Id);
             System.assertEquals(p.Id,newuser.ProfileId);
        }
    }
    
    
     @isTest
    public static void changeuserpassword(){
        
        Profile p = getStandardUserProfile();
        Contact c = getContact();
        User u = getUserWithProfile(p);
          System.runAs(u){
          String newpass = EI_ChangemyDetails.changeuserpassword('Pass@123','Pass@123','Password@123');
         
            system.assertEquals('Success',newpass);
           newpass = EI_ChangemyDetails.changeuserpassword('','Pass@123','Password@123');
           system.assertEquals('Error', newpass);
    }
    }
    
    private static User getUserWithProfile(Profile p){
        User u = new User(Alias = 'newUser', Email='tdstestuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='tdstestuser@testorg.com');
       // insert u;
         return u;
        
    }
    private static Contact getContact(){
        Contact c = new Contact();
        c.FirstName='shyaam';
        c.LastName='varma';
        c.Phone='3456735487';
        insert c;
        return c;
        
    }
    private static Profile getStandardUserProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Standard User'];
       return p;
    }
    
}