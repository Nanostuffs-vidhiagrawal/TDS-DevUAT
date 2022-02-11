public class EI_UpdateUserfromContactHandler {

    @future
    public static void updateUsers(Set<Id> conIds)
    {
       // User userObjs = new User();
        User userObjs = [Select Id,ContactId from User WHERE ContactId IN :conIds LIMIT 1];
       List<Contact> conList = [SELECT ID,Salutation, Firstname, Lastname, Email, Phone,MobilePhone, MailingStreet, MailingCity, 
                                MailingState, MailingCountry,MailingPostalCode, LastModifiedBy.Profile.Name,
                                User_Status__c  FROM Contact WHERE Id IN :conIds];
                              
        
       List<User> userList = new List<User>();
       if(userObjs.ContactId != null)
       {
           for (Contact conObj : conList) {
               User usrObj = new User();
          if(conObj.FirstName != usrObj.FirstName || conObj.LastName != usrObj.LastName || conObj.Email != usrObj.Email || conObj.Salutation != usrObj.Title
            || conObj.Phone!=usrObj.Phone || conObj.MailingStreet!=usrobj.Street || conObj.MailingCity !=usrobj.City || conObj.MailingState != usrobj.state ||
            conObj.MailingCountry!= usrobj.Country || conObj.MailingPostalCode !=usrobj.PostalCode || conObj.MobilePhone !=usrobj.MobilePhone )
            {
               usrObj.Id = userObjs.Id;
               usrObj.FirstName = conObj.FirstName;
               usrObj.LastName = conObj.LastName;
               usrObj.Email = conObj.Email;
               usrObj.Title = conObj.Salutation;
               usrObj.Phone = conObj.Phone;
               usrObj.MobilePhone =conObj.MobilePhone; 
               usrobj.Street= conObj.MailingStreet;
               usrobj.City =  conObj.MailingCity;
               usrobj.state = conObj.MailingState;
               usrobj.Country =  conObj.MailingCountry; 
               usrobj.PostalCode =  conObj.MailingPostalCode;
               userList.add(usrObj);
               System.debug('Update List of User :'+userList);
           }
          
       }
        if(userList.size() > 0)
        {
        EI_RecursionUtility.isUserUpdate = false;
           update userList;
        }

    }
}
}