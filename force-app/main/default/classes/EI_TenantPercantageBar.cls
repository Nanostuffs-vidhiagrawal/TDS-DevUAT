public class EI_TenantPercantageBar {
@AuraEnabled
    Public static string getscore(){
        String total;
       // Decimal total;
        Decimal contactdetails;
        Decimal bankdetails;
        Decimal prescribeinfo;
        Decimal marketingpref;
        user us = [select id,contactid,accountid from user where id=:Userinfo.getUserId()];
        Contact conc = [select id,FirstName, LastName,Salutation,Email,Phone,Property_Name__c,MailingState,MailingCity,mailingstreet,Town__c,mailingcountry,MailingPostalCode,County__c,Prescribed_Information_clauses__c,Marketing_Agreement__c,Newsletter_Subscription__c,Bank_Account_Name__c,Bank_Name__c,Sort_Code__c,Account_Number__c from contact where id=:us.ContactId];
        list<Bank_Account__c> bankaccountdetails = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where contact__c=:us.ContactId limit 1];
        if(conc.Salutation==null|| conc.FirstName==null|| conc.LastName==null/*|| conc.Email==null|| conc.Property_Name__c==null */|| conc.Phone== null || conc.mailingstreet==null ||
           conc.MailingCity==null || conc.mailingcountry==null || conc.MailingPostalCode ==null ||conc.MailingState==null){
             //  contactdetails =0;
             contactdetails =0;   
           }
        else{
            contactdetails =100/3;   
        }
                
        
        if(conc.Marketing_Agreement__c!=true || conc.Newsletter_Subscription__c!=true){
              marketingpref =0;           }
        else{
            marketingpref = 100/3;  
        }
        
        if(bankaccountdetails.size()>0/*bankaccountdetails[0].Bank_Account_Holder_Name__c==null || bankaccountdetails[0].Bank_Name__c==null || bankaccountdetails[0].Sort_Code__c==null || bankaccountdetails[0].Account_Number__c==null */){
            bankdetails = 100/3;    
        }
        else{
           bankdetails =0;    
        }
        
        
      //  total =contactdetails+marketingpref+bankdetails;
        total =String.valueof(contactdetails+'#'+marketingpref+'#'+bankdetails);
        return total;
    }
}