/* @Who : Ashish Singh
 * @When : 15-03-2021
 * @What : Class for Contact and Global Variables
 */
public class EI_GlobalVariables {
	public static userContact currentUser;
        
    public EI_GlobalVariables(){
     currentUser = new userContact();
    }
	
    /*@What : Get Logged in User Details
     * 
     */ 
    
    public static userContact currentLoggedInUser(){
        currentUser.usr = [SELECT 
                             	Id, 
                             	AccountId, 
                             	ContactId, 
                             	User_Type__c
                  			FROM 
                             	User
                  			WHERE Id = :UserInfo.getUserId()];
        return currentUser;
    }
    
   
    public class userContact{
        public User usr {get;set;}
        public Contact con {get;set;}
        public Account acc {get;set;}        
    }    
}