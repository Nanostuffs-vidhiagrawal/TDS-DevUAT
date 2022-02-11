public class EI_AccountPercentageBar {
    
    @AuraEnabled
    Public static String getscore(){
        String total;
        Decimal contactdetails;
        Decimal bankdetails;
        Decimal prescribeinfo;
        Decimal marketingpref;
        user us = [select id,contactid,accountid from user where id=:Userinfo.getUserId()];
        Contact conc = [select id,Email,Phone,Property_Name__c,MailingState,MailingCity,mailingstreet,Town__c,mailingcountry,MailingPostalCode,County__c,Prescribed_Information_clauses__c,Marketing_Agreement__c,Newsletter_Subscription__c,Bank_Account_Name__c,Bank_Name__c,Sort_Code__c,Account_Number__c from contact where id=:us.ContactId];
        List<Bank_Account__c> listBank = [Select id,ValidInternationBankDetails__c from Bank_Account__c where Contact__c =: conc.id]; 
        if(conc.Email==null|| conc.Phone== null || conc.mailingstreet==null ||
           conc.MailingCity==null || conc.mailingcountry==null || conc.MailingPostalCode ==null ){
               contactdetails =0;
           }
        else{
            contactdetails =25;   
        }
        
        if (conc.Prescribed_Information_clauses__c==null){
            prescribeinfo=0;
        }
        else{
            prescribeinfo=25;
        }
        
        
        if(conc.Marketing_Agreement__c!=true || conc.Newsletter_Subscription__c!=true){
            marketingpref = 0;    
        }
        else{
            marketingpref = 25;  
        }
        
        if(listBank.size()>0 &&  listBank[0].ValidInternationBankDetails__c){
            bankdetails = 25;    
        }
        else{
            bankdetails = 0;  
        }
        
        
        total =String.valueof(contactdetails+'#'+marketingpref+'#'+prescribeinfo+'#'+bankdetails);
        return total;
    }
    
    
}