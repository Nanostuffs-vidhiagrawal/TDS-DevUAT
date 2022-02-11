public class DeactivatePortalaccount {
    
    @AuraEnabled 
    public static string deactivateaccount(){
        String checkMessage;
        boolean status;
        User u = [select Id,Name, contact.name,MemberId__c,contactId,email,accountid,IsActive from User where Id = :UserInfo.getUserId()];  
        if(u.ContactId !=Null || u.accountid !=Null){
            list<account> acclist = [select id,name,Deposit_Protections__c from account where id=:u.accountid and Deposit_Protections__c!=0 ];
            list<case> cslist =[select id,accountid from case where accountid=:u.accountid];
            system.debug('line-->9'+acclist );
            if(acclist.size()>0 || cslist.size()>0){
                checkMessage = 'Msg1';   
                system.debug('line-->11'+ checkMessage);
                status=false;                 
               // DeactivatePortalaccount.deactivationmail(u.contactid,u.contact.name,u.MemberId__c,status,u.Email); 
                EI_AgentLandlordPostloginemails.accountcloserrequestwithactivetenancies(u.Email,u.name,u.MemberId__c);  

            }
            else {
                EI_AgentLandlordPostloginemails.customeraccountclosertotds(u.Email,u.name,u.MemberId__c);
                EI_AgentLandlordPostloginemails.accountcloserstatustouser(u.Email,u.name);
                system.debug('line 13');
                u.IsActive = false;
                update u;
                status=true;
                checkMessage = 'Msg2';
               // DeactivatePortalaccount.deactivationmail(u.contactid,u.contact.name,u.MemberId__c,status,u.Email);
            }            
        }        
        return checkMessage;
    }
    
    @AuraEnabled
    Public static void deactivationmail(String conid,String userName,string memberId,boolean status,String customerEmail){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        string st = Label.CloseAccountEmailaddress;
       //  string st = 'client.relations@safedepositsscotland.com'; // this is actual email.//
        list<string> stlist = new list<string>();
       // stlist.add(st);
        list<string> stlist2 = new list<string>();
        system.debug('check for 39  ' +status );        
        if(status){
            stlist.add(st);
            system.debug('check for 45  ' +stlist );
            stlist2.add(customerEmail);
            string htmlBody = 'Customer ID -'+memberId+' deactivated their account on ' +date.today().format()+'. The customer does not have any live tenancies or disputes<br/>';
            htmlBody+= 'however if you wish to contact them for further information on why they are leaving the customer details are:<br/><br/>';
            htmlBody+= 'Customer ID -'+memberId+'<br/><br/>';
            htmlBody+= 'Customer Name –'+userName+'<br/><br/>';
            htmlBody+= 'Customer Email – '+customerEmail+'<br/><br/>';
            system.debug('check for 79  ' +stlist );
            Messaging.SingleEmailMessage message2 = new Messaging.SingleEmailMessage();
            message2.setSenderDisplayName(Label.CustomerSupport); 
            message2.setReplyTo('no-reply@company.com');
            message2.setUseSignature(false); 
            message2.setBccSender(false); 
            message2.setSaveAsActivity(false);
            message2.setHtmlBody(htmlBody);
            message2.setSubject(Label.CustomerAccountClosure);
            message2.setToAddresses(stlist);
            mails.add(message2);
            system.debug('check for 60  ' +stlist );
            Messaging.sendEmail(mails,true);    
            
            
            string htmlBody1 = 'Hi '+userName+'<br/><br/>';
            htmlBody1+= 'Your account has been closed. if You wished to re-open their account you must contact SafeDeposits customer services and an<br/>';
            htmlBody1+= 'internal SafeDeposits colleague will be able to reactivate the account.<br/><br/>';
            system.debug('check for 79  ' +stlist );
            Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
            message1.setSenderDisplayName(Label.CustomerSupport); 
            message1.setReplyTo('no-reply@company.com');
            message1.setUseSignature(false); 
            message1.setBccSender(false); 
            message1.setSaveAsActivity(false);
            message1.setHtmlBody(htmlBody1);
            message1.setSubject(Label.CustomerAccountClosure);
            message1.setToAddresses(stlist2);
            mails.add(message1);
            system.debug('check for 60  ' +stlist );
            Messaging.sendEmail(mails,true);
        }
        else{
            stlist.add(st);
            string htmlBody = 'A request to close an account with active tenancies or disputes has been made. The customer details are:<br/><br/>';
            htmlBody+= 'Customer ID -'+memberId+'<br/><br/>';
            htmlBody+= 'Customer Name –'+userName+'<br/><br/>';
            htmlBody+= 'Customer Email – '+customerEmail+'<br/><br/>';
            htmlBody+= 'Please contact this customer for further information on why they are requesting this closure.';
            system.debug('check for 79  ' +stlist );
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSenderDisplayName(Label.CustomerSupport); 
            message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false);
            message.setHtmlBody(htmlBody);
            message.setSubject(Label.CloseAccountActiveTenancies);
            message.setToAddresses(stlist);
            mails.add(message);
            system.debug('check for 97 ' +stlist );
            Messaging.sendEmail(mails,true);
        }
    }
}