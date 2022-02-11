public class EI_ZD_PaymentAPI {
    public static string getperformcallout(string SfClaimId, String claimId, String customerType,Decimal amount, String scheme,String tenantId){
       
        String URL = '';
        list<Payment_API__c> paymentApi = new list<Payment_API__c>();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        ZD_Payment_API__c mhc = ZD_Payment_API__c.getInstance('ZD_Payment');
        string seckey = EI_ZD_EvidenceUploadToAzure.isRunningOnSandbox() ? mhc.UAT_secret_key__c :mhc.Live_secret_key__c ;
        Http http = new Http();
        req.setEndpoint('https://uat-app.zerodeposit.com/disputes/tds/payment-link/');
        req.setMethod('POST');
        req.setHeader('Authorization', seckey);
        string Data='{"tenant":'+integer.valueOf(tenantId)+',"amount":'+amount+',"claim":"'+claimId+'"}';
        req.setBody(Data);
        res = http.send(req);
        if(res.getstatusCode() == 201 && res.getbody() != null){
            List<Object> payments = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for(Object obj : payments){
                Map<String, Object> payment = (Map<String, Object>)obj;
                if(tenantId==string.valueOf(payment.get('tenant'))){
                    URL = string.valueOf(payment.get('url'));
                }
                paymentApi.add(new Payment_API__c(SF_CaseId__c =SfClaimId, Amount__c=amount,ClaimID__c=claimId,TenantID__c=string.valueOf(payment.get('tenant')),URL__c=string.valueOf(payment.get('url')),User_Type__c=customerType,scheme__c=scheme)); 
            }
            
           
             sendMailCaseClosed(paymentApi,'Tenant');
             insert paymentApi;
        }
        return URL;
    }
    
    //perform callout for trigger in future context
    @future (callout=true)
    public static void getperformcalloutTrigger(string SfClaimId,String claimId, String customerType,Decimal amount, String scheme,String tenantId,string agreedBy){
        
        String URL = '';
        list<Payment_API__c> paymentApi = new list<Payment_API__c>();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        ZD_Payment_API__c mhc = ZD_Payment_API__c.getInstance('ZD_Payment');
        string seckey = EI_ZD_EvidenceUploadToAzure.isRunningOnSandbox() ? mhc.UAT_secret_key__c :mhc.Live_secret_key__c ;
        Http http = new Http();
        req.setEndpoint('https://uat-app.zerodeposit.com/disputes/tds/payment-link/');
        req.setMethod('POST');
        req.setHeader('Authorization', seckey);
        string Data='{"tenant":'+integer.valueOf(tenantId)+',"amount":'+amount+',"claim":"'+claimId+'"}';
        req.setBody(Data);
        res = http.send(req);
        if(res.getstatusCode() == 201 && res.getbody() != null){
            List<Object> payments = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for(Object obj : payments){
                Map<String, Object> payment = (Map<String, Object>)obj;
                if(tenantId==string.valueOf(payment.get('tenant'))){
                    URL = string.valueOf(payment.get('url'));
                }
                paymentApi.add(new Payment_API__c(SF_CaseId__c =SfClaimId,Amount__c=amount,ClaimID__c=claimId,TenantID__c=string.valueOf(payment.get('tenant')),URL__c=string.valueOf(payment.get('url')),User_Type__c=customerType,scheme__c=scheme)); 
            }
              sendMailCaseClosed(paymentApi,agreedBy);
            insert paymentApi;
           
        }
    }
     public static void sendMailCaseClosed(list<Payment_API__c> listPaymentApi,string agreedBy){
        Map<String,String> tenantIdMap = new Map<String,String>();
         Map<String,decimal> tenantMap = new Map<String,decimal>();
        list<String> caseidList = new List<String>();
        for(Payment_API__c pa : listPaymentApi){
            caseidList.add(pa.SF_CaseId__c);
            tenantIdMap.put(pa.TenantID__c,pa.URL__c);
            tenantMap.put(pa.TenantID__c, pa.Amount__c);
        }
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,Total_Agreed_by_Tenant__c,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c,account__r.Tenant_External_ID__c from case_participants__r)
                                                               from case where id in : caseidList]);
        
        Map<String,String> var = new Map<String,String>();
        list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
        list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
        for(String caseId : casePartMap.keySet()){
            Case newCase = casePartMap.get(caseId);
            String floa ='';
            String sloa ='';
             
            String postcode='';
        for(case_participant__c cp : casePartMap.get(caseId).case_participants__r){

            if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c;
                
            }
             if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c;
                
            }
           if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            
            if(tenantMap.containsKey(cp.Account__r.Tenant_External_ID__c) ){
                var.put('agreeamt',tenantMap.get(cp.Account__r.Tenant_External_ID__c)+'');
                
            }
            /*
                   if(newcase.Total_Agreed_by_Tenant__c!=null){
            var.put('agreeamt',newcase.Total_Agreed_by_Tenant__c+'');
            
        }*/
            
            if(cp.type__c == 'Tenant'){
                String link = null;
                if(tenantIdMap.containsKey(cp.Account__r.Tenant_External_ID__c)){
                    if(tenantIdMap.get(cp.Account__r.Tenant_External_ID__c)!=null)
                         link = tenantIdMap.get(cp.Account__r.Tenant_External_ID__c);
                }
                
                EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id,null,link,'Make Payment');
                rec.link = link;
                tenantList.add(rec);

                //EI_ZD_EmailUtility.sendEmail('Claim Agreed - Your Payment is Now Due', JSON.Serialize(rec),var,'tenantCaseCLose','mailJetZD');
                
                
            }
            else {
                EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
                agentList.add(rec);
            }
        }
           if(agreedBy=='Tenant')
           {
                 if(tenantList.size()>0)
                    system.debug(tenantList);
                EI_ZD_EmailUtility.sendEmailNew('Claim Agreed - Your Payment is Now Due', JSON.Serialize(tenantList),var,'tenantCaseCLose','mailJetZD');
                if(agentList.size()>0)  {
                    System.enqueueJob(new EI_ZD_EmailQueueable('Claim Agreed - Confirm Bank Details for Payout - '+floa +', '+sloa, JSON.Serialize(agentList),var,'AGLLCaseCLose','mailJetZD'));
                    //  EI_ZD_EmailUtility.sendEmailNew('Claim Agreed - Confirm Bank Details for Payout -'+floa +' '+sloa+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c +' '+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.city__c    , JSON.Serialize(agentList),var,'AGLLCaseCLose','mailJetZD');  
                }
               // new template 
           }
            else
            {
                if(tenantList.size()>0)
                    system.debug(tenantList);
                EI_ZD_EmailUtility.sendEmailNew('Your Landlord Has Agreed With Your Proposal – Payment is Now Due', JSON.Serialize(tenantList),var,'closeTTAgreed','mailJetZD');
                if(agentList.size()>0)  {
                        System.enqueueJob(new EI_ZD_EmailQueueable('Claim Agreed - Confirm Bank Details for Payout - '+floa, JSON.Serialize(agentList),var,'closeAGLLAgreed','mailJetZD'));
                    //  EI_ZD_EmailUtility.sendEmailNew('Claim Agreed - Confirm Bank Details for Payout -'+floa +' '+sloa+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c +' '+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.city__c    , JSON.Serialize(agentList),var,'AGLLCaseCLose','mailJetZD');  
                }
              
            }
         
            //EI_ZD_EmailUtility.sendEmail('Claim Agreed - Confirm Bank Details for Payout -'+floa +' '+sloa+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c +' '+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.city__c , JSON.Serialize(agentList),var,'AGLLCaseCLose','mailJetZD');
        }
    }
}