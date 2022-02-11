/*
*Apex class TO UPDATE CONTACT IF COMMUNITY USER HAS BEEN CHANGED ANY INFORMATION
DEVELOPED BY ESPIRE
DATE:- 27 JAN 2022
*/
global class EI_UpdateContactforCommunityUserHandler {
    
    //Method to update contact if community user has been updated.
    @future
    public static void updateContacts(Set<Id> userIds)
    {
        List<User> user = [Select Id, Firstname, Lastname, Email,User.ContactId,Title,phone,Street, City, State, Country, PostalCode from User WHERE Id IN :userIds];
        List<Contact> conList = new List<Contact>();
        
        if(user[0] != null && user[0].ContactId != null){
            for (User usrObj : User) {
                Contact conObj = new Contact();
                if(conObj.FirstName != usrObj.FirstName || conObj.LastName != usrObj.LastName || conObj.Email != usrObj.Email 
                   || conObj.Salutation != usrObj.Title || usrObj.Phone !=conObj.Phone || usrObj.Street !=conObj.MailingStreet 
                   || usrObj.City !=conObj.MailingCity  || usrObj.Country !=conObj.MailingCountry || usrobj.State != conObj.MailingState
                   || usrObj.PostalCode !=conObj.MailingPostalCode )
                    
                {
                    conObj.Id = usrObj.ContactId;
                    conObj.FirstName = usrObj.FirstName;
                    conObj.LastName = usrObj.LastName;
                    conObj.Email = usrObj.Email;
                    conObj.Salutation = usrObj.Title;
                    conObj.Phone = usrObj.Phone;
                    conObj.MailingStreet = usrObj.Street;
                    conObj.MailingCity = usrObj.City;
                    conObj.MailingCountry =usrobj.Country;
                    conObj.MailingState =usrobj.State;
                    conobj.MailingPostalCode =usrobj.PostalCode;
                }
                conList.add(conObj);
                System.debug('Update List of Contacts :'+conList);
            }
            if(conList.size() > 0)
            {
                EI_RecursionUtility.isUserUpdate = false;
                update conList;
            }
        }
    }
}