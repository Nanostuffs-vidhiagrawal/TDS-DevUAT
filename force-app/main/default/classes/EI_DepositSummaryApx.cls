public without sharing class EI_DepositSummaryApx {
    
    @AuraEnabled
    public static list<Installment__c>  getInstallment(string depositId){
        List<Installment__c> install = [Select id,Status__c,Is_Topup__c,Amount__c from Installment__c where Deposit__c =: depositId and Status__c = 'Pending' and Is_Topup__c = true limit 1];
        If(install.size()>0){
            return install;
        }else
            
            return new  List<Installment__c>();  
    }
    
   /*  @AuraEnabled
    public static string getInstallment(string depositId){
        List<Installment__c> install = [Select id,Status__c,Is_Topup__c,Amount__c from Installment__c where Deposit__c =: depositId and Status__c = 'Pending' and Is_Topup__c = true limit 1];
        If(install.size()>0){
            return 'Yes';
        }else
            return 'No';
    }*/
    
    @AuraEnabled
    public static string getDPC2(string depositId){
        return TestAPIDocusignCall.TestAPIDoc1(depositId);
    }
    
    @AuraEnabled
    public static void deleteAttachment(Id attachid){
        Attachment attach = [Select id from Attachment where id=: attachid];
        delete attach;
    }
    
    @AuraEnabled
    public static list<depositsummarywrapper>  getDepositDetails(string depositId){
        try{
            Deposit__c depo = [select id,Case_Status__c,ChangeOver_CaseStatus__c,name,Customer_Name__c,customer__c,Protected_Amount__c,Property__c,customer__r.Salutation, customer__r.Name ,customer__r.Phone, customer__r.PersonEmail,Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Amount_of_Deposit_Protected_by_TDS__c,Status__c,Tenant_Changeover_Status__c, WD_Date_Deposit_Received__c, User_reference_for_the_deposit__c from Deposit__c where id=:depositId];
            list<depositsummarywrapper> wraplist = new list<depositsummarywrapper>();
            for (Deposit__c deposit : ([select id,Deposit_Transferred__c,Property_Address_Without_Country__c,(Select Id,status__c from Repayment_Requests__r where status__c='In Process'), No_of_lead_tenants__c, Case_Status__c,ChangeOver_CaseStatus__c,name,customer__c,Date_Deposit_Received__c,Property__c,customer__r.Salutation, customer__r.Name ,customer__r.Phone, customer__r.PersonEmail,Property_Address__c,Start_Date__c,Rent_Amount__c,Protected_Amount__c,Deposit_Amount__c,Amount_of_Deposit_Protected_by_TDS__c,Status__c,Tenant_Changeover_Status__c,WD_Date_Deposit_Received__c,Customer_Name__c, User_reference_for_the_deposit__c from Deposit__c where id=:depositId]))
            {
                wraplist.add(new depositsummarywrapper(deposit));
            }
            
            for (Case cse : ([select id,Status,Deposit_Account_Number__c,PreviousStatus__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c from Case where Deposit_Account_Number__c=:depositId limit 1]))
            {
                wraplist.add(new depositsummarywrapper(cse));
            }
            
            for (Adjudication_Report__c AR : ([select id,Status__c,Dispute__r.Deposit_Account_Number__c,Adjudication_Report_URL__c,Webhook_Report_Link__c,CreatedDate from Adjudication_Report__c  where Dispute__r.Deposit_Account_Number__c=:depositId and Status__c='Published' order by createddate desc limit 1]))
            {
                wraplist.add(new depositsummarywrapper(AR));
            }
            
            for (Deposit_Allocation__c depall : ([select id,Deposit__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Email__c, Deposit_Holder__r.Phone,Deposit_Holder__r.Tenant_Details_Not_Viewable__pc,Deposit_Holder__r.Tenant_Details_Viewable__pc from Deposit_Allocation__c  where Deposit__c=:depositId  ]))
            {
                wraplist.add(new depositsummarywrapper(depall));
            }
            
            for (Property_Allocation__C DAP :([select id ,Relation_to_Property__c,contact__c,Contact__r.Salutation,Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Contact__r.Phone, contact__r.OtherPhone, contact__r.Email, contact__r.Alternative_Email__c,  Property__c from Property_Allocation__C where property__c =:depo.Property__c  ])){
                wraplist.add(new depositsummarywrapper(DAP));
            }
            
            return wraplist;                                                                                                                                                                                                             
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
	    
    @AuraEnabled
    public static String cancelDepositTransfer(String depositId) {
        System.debug('Line 72');
        Deposit__c deposit = new Deposit__c(id=depositId);
        deposit.Deposit_Transferred_to_Account__c = null;
        deposit.Deposit_Transferred__c = false ;
        update deposit;
        
        Case newCase = [Select id,Status from Case where Deposit_Account_Number__c =:depositId and Status=:Label.Deposit_transfer_requested];
        System.debug('Line 78 -> '+newCase);
        newCase.status = Label.Deposit_transfer_cancelled;
        update newCase;
        System.debug('Line 79');
        return 'canceldeposit';
    }
    
    @AuraEnabled
    public static Account getTenentDetails(string tenantid){
        Account Acc = [select id,Salutation, FirstName,ownerid,IsCustomerPortal, LastName,Phone,Tenant_Details_Viewable__pc,
                       PersonEmail, Phone_Code__pc, PersonMobilePhone, Other_Phone_Code__pc, Alternative_Email__pc, PersonOtherPhone,Tenant_Details_Not_Viewable__pc, 
                       PersonMailingCity, PersonMailingCountry, PersonMailingStreet, PersonMailingPostalCode,
                       PersonMailingState  from account where id=:tenantid ];
        return  Acc;       
    }
    
    @AuraEnabled
    public static String getAgentLandlordRepaymentRequest(String depositId){
        List<Repayment_Request__c> repaymentRequest = new List<Repayment_Request__c>();
        repaymentRequest = [SELECT id from Repayment_Request__c where Deposit__c =:depositId
                           and AL_Repay_Requested__c=true];
        if(!repaymentRequest.Isempty()){                   
            return repaymentRequest[0].id;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String getTenantRepaymentRequest(String depositId){
        List<Repayment_Request__c> repaymentRequest = new List<Repayment_Request__c>();
        repaymentRequest = [SELECT id from Repayment_Request__c where Deposit__c =:depositId
                           and Tenant_Repay_Requested__c=true];
        if(!repaymentRequest.Isempty()){                   
            return repaymentRequest[0].id;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Account updatetenentdetails(Account tenantaccount, string tenantPhoneCode, string tenantOtherPhoneCode){
        SavePoint sp = Database.setSavePoint();
        try{
            //  tenantaccount.OwnerId=tenantaccount.OwnerId;
            tenantaccount.Phone_Code__pc=tenantPhoneCode;
            tenantaccount.Other_Phone_Code__pc=tenantOtherPhoneCode;
            update tenantaccount;
            system.debug('line 43   ' + tenantaccount);
        }
        catch(Exception e){
            Database.rollback(sp);
        }    
        return tenantaccount;
        
    }
    
    @AuraEnabled //get landlord registration status Picklist Values
    public static Map<String, String> getstatus(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = Contact.LandLord_Registration_Status__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> takesalutation(){
        try{
            List<Map<String, String>> listOFMap = new List<Map<String, String>>();
            Map<String, String> salutation = new Map<String, String>();
            Schema.DescribeFieldResult fieldResultsalutation = Account.Salutation.getDescribe();
            List<Schema.PicklistEntry> pListsalutation = fieldResultsalutation.getPicklistValues();
            for (Schema.PicklistEntry p : pListsalutation){
                salutation.put(p.getValue(), p.getLabel());
            }
            listOFMap.add(salutation);
            
            return listOFMap;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static contact getlandlorddetails (string landlordid){
        contact cont = [select id,Salutation, FirstName,ownerid, LastName,Phone_Code__c, Phone, Email ,
                        LandLord_Registration_Number__c,LandLord_Registration_Status__c, Alternative_Email__c,Other_Phone_Code__c, OtherPhone, MailingCity, MailingCountry,MailingStreet, MailingPostalCode,MailingState  from contact where id=:landlordid]; 
        return cont;
    }
    
    @AuraEnabled
    public static Contact updatelandlord (Contact landlordaccount,string landlordtitle, string landlordPhoneCode, string landlordOtherPhoneCode){
        system.debug('checkmy');
        system.debug('line 63  ' + landlordaccount.id);
        
        landlordaccount.Salutation=landlordtitle;
        landlordaccount.Phone_Code__c=landlordPhoneCode;
        landlordaccount.Other_Phone_Code__c=landlordOtherPhoneCode;
        update landlordaccount;
        system.debug('line 67  ' + landlordaccount);
        
        return landlordaccount;
        
    }
    
    @AuraEnabled
    public static string deletelandlord (string landlordid,string depositdelid ){
        string message = 'Landlord deleted';
        Deposit__c depo2 = [select id,name,customer__c,Protected_Amount__c,Property__c,Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Amount_of_Deposit_Protected_by_TDS__c,Status__c,Tenant_Changeover_Status__c from Deposit__c where id=:depositdelid];
        system.debug('check-->93' +landlordid );
        system.debug('check-->94' +depo2.Property__c );
        list<Property_Allocation__C> PAL = [select id,contact__c, Property__c from Property_Allocation__C where property__c =:depo2.Property__c and contact__c=:landlordid];
        delete pal;
        
        /*contact personcont = [select id  from contact where id=:landlordid];   
        delete personcont;  */
        return Message; 
    }
    
    // In this Deposit status is changing from 'Awaiting receipt of deposit' to 'Deposit registration deleted';
    @AuraEnabled
    public static Deposit__c changedepositstatus(string depositid){
        Deposit__c dep = new Deposit__c ();
        dep.id = depositid;
        dep.Status__c='Deposit registration deleted';
        
        update dep;  
        system.debug('line-->45' + dep);
        return dep;
    }
    
    //Cancel Tenancy Changeover
    @AuraEnabled
    public static string tenancychangeovercancel(string depositid){
        string Message = 'Tenant changeover cancelled';
        Case updateCase = [Select id,Subject,Deposit_Account_Number__c,Account.Name,Account.PersonEmail,ownerid,owner.email,owner.Name,Status from Case where Deposit_Account_Number__c=: depositid and   Status = 'Tenant changeover initiated - agent/landlord' limit 1];
        list<deposit__c > deplist = [select Id,Tenant_Changeover_Status__c,Customer__r.Name,Customer__r.Email__c,Customer__r.PersonEmail, Tenant_Changeover_Deposit__c from Deposit__c where id=:depositid and Tenant_Changeover_Status__c ='In Progress' and Tenant_Changeover_Deposit__c !=null limit 1 ];    
        list<Deposit_Allocation__c > olddepositalllist = [select id,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name,Deposit__c,  Istenantmoved__c, Tenencychangeoveramount__c from Deposit_Allocation__c where /* Istenantmoved__c =true and*/ Deposit__c =:depositid ];
        system.debug('line-->142' + olddepositalllist );
        if(deplist.size()>0){
          
            list<deposit__c> deletedepositlist = [select Id,Tenant_Changeover_Status__c,Status__c, Tenant_Changeover_Deposit__c from Deposit__c where id=:deplist[0].Tenant_Changeover_Deposit__c and  Status__c = null limit 1 ];  
            
            if(deletedepositlist.size()>0) {
                delete deletedepositlist;
            }
        }  
        
        if(olddepositalllist.size()>0){
            list<Deposit_Allocation__c> removemoveoutlist = new list<Deposit_Allocation__c> (); 
            for(Deposit_Allocation__c dept :olddepositalllist){
                if(dept.Istenantmoved__c==true){
                Deposit_Allocation__c dac = new Deposit_Allocation__c();
                dac.id =dept.id;
                dac.Istenantmoved__c=false;
                dac.Tenencychangeoveramount__c=null;
                removemoveoutlist.add(dac);
                }
            } 
            update removemoveoutlist;
            
            
        }
        if(deplist.size()>0){
            list<deposit__c> updatedepositlist = new list<deposit__c> ();
            deposit__c  depst = new deposit__c();
            for(deposit__c  deposit :deplist ){
                depst.id =deposit.id; 
                depst.Tenant_Changeover_Status__c='Reject';
                depst.Tenant_Changeover_Deposit__c=null;   
                updatedepositlist.add(depst); 
            }
            update updatedepositlist;
        }
        updateCase.Status='Tenant Changeover Cancelled';
        update updateCase;
            
        tenancycancelemaildetails(depositid,olddepositalllist);
        
        
        return Message;  
    }
    
    @AuraEnabled
    public static string tenancycancelemaildetails (string depositid,list<Deposit_Allocation__c>olddepositall) {
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        string message = 'Emails sent';
        list<deposit__c> olddeposit = [select id,name,Property_Address__c,Customer__c,Property_Address_WO_Country__c,Customer__r.IsPersonAccount,customer__r.name,Customer__r.PersonEmail,customer__r.Email__c from deposit__c where id=:depositid limit 1];
        list<Deposit_Allocation__c> oldDepall = [select id,Deposit_Holder__r.name,Deposit_Holder__r.Personcontactid,Deposit_Holder__r.PersonEmail from Deposit_Allocation__c where id in : olddepositall and Deposit__c =:depositid ];
        //system.debug('line-->268' + oldDepall);
        // List<String> emaillist = new List<String>();
        // List < Messaging.SingleEmailMessage > emails4 = new List < Messaging.SingleEmailMessage >();
        if(olddeposit.size()>0 && oldDepall.size()>0){
            for (Deposit_Allocation__c dep :oldDepall ){
                system.debug('line-->267' + dep.Deposit_Holder__r.Personcontactid);
                system.debug('line-->268' + dep.Deposit_Holder__r.PersonEmail);
                system.debug('line-->269' + depositid);
                EI_TenancyChangeoverEmail.changeovercanceltenants(dep.Deposit_Holder__r.PersonEmail,dep.Deposit_Holder__r.name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,depositid,dep.Deposit_Holder__r.Personcontactid);
                emailWrapperList.add(EI_TenancyChangeoverEmail.changeovercanceltenants(dep.Deposit_Holder__r.PersonEmail,dep.Deposit_Holder__r.name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,depositid,dep.Deposit_Holder__r.Personcontactid));
            }
            system.debug('line-->273' + olddeposit[0].Customer__c);
            system.debug('line-->274' + olddeposit[0].Customer__r.Email__c);
            system.debug('line-->275' + olddeposit[0].Id);
            EI_TenancyChangeoverEmail.changeovercancellandlordagent(olddeposit[0].Customer__r.Email__c,olddeposit[0].Customer__r.PersonEmail,olddeposit[0].Customer__r.Name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,olddeposit[0].Id,olddeposit[0].Customer__c);
            emailWrapperList.add(EI_TenancyChangeoverEmail.changeovercancellandlordagent(olddeposit[0].Customer__r.Email__c,olddeposit[0].Customer__r.PersonEmail,olddeposit[0].Customer__r.Name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,olddeposit[0].Id,olddeposit[0].Customer__c));
            if(emailWrapperList.size()>0){
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
        }
        return message;
        
    }
    
    @AuraEnabled
    public static string  saveEqualDepositApx (string depositId,decimal oldDepositAmount,
                                               decimal newDepositAmount,Decimal heldAmount)
    {
        Deposit__c dep = new Deposit__c(id=depositId,Deposit_Amount__c = newDepositAmount);
        try
        {
            update dep; 
            return 'successfully Updated';
        }
        catch(exception e)
        {
            
            return e.getMessage();            
        }
        
        
    }
    
    @AuraEnabled
    public static String  saveGraterAmountDepositApx (string depositId,decimal oldDepositAmount,
                                                      decimal newDepositAmount,Decimal heldAmount)
    {
        system.debug('depositId --> ' + depositId);
        system.debug('oldDepositAmount -->' + oldDepositAmount);
        system.debug('newDepositAmount -->' + newDepositAmount);
        system.debug('heldAmount -->' + heldAmount );
        
        
        Deposit__c dep = new Deposit__c(id=depositId,Deposit_Amount__c = newDepositAmount,Deposit_Amount_Amend__c = true);
        try
        {
            EI_depositAmountEmail emails = new EI_depositAmountEmail();
          //  emails.sendEmailgraterAmount( heldAmount, newDepositAmount,depositId,null);
            update dep; 
            return 'successfully Updated';
        }
        catch(exception e)
        {	
            return e.getMessage();     
           
        }
    }
    
    @AuraEnabled
    public static String saveLessAmountDepositApx (string depositId,string DAN,decimal oldDepositAmount,
                                                   decimal newDepositAmount, Decimal heldAmount,
                                                   List<Deposit_Allocation__c> tenantDetails,date startDateDeposit)
    {
        try
        {
            system.debug('line-->346 ' + tenantDetails[0].Deposit_Holder__c);
            list<Bank_Account__c> Tenantbankdetails  = [select id,Account_Number__c,Bank_Account_Holder_Name__c,Bank_Name__c,Contact__r.name,
                                                        BIC__c,Contact__c,IBAN__c,Sort_Code__c from Bank_Account__c where Account__c=: tenantDetails[0].Deposit_Holder__c order by Createddate desc ];
            system.debug('line-->349 ' + Tenantbankdetails);
            
          //  EI_depositAmountEmail emails = new EI_depositAmountEmail();
            
            if(Tenantbankdetails.size() >0)
            {
               // emails.sendEmail( heldAmount, newDepositAmount,depositId,tenantDetails);
                Deposit__c dep = new Deposit__c(id=depositId,Deposit_Amount__c = newDepositAmount,/*Amount_of_Deposit_Protected_by_TDS__c*/ 
                                                Protected_Amount__c =newDepositAmount,Deposit_Amount_Amend__c = true);
                update dep;
                system.debug('line-->349 ' + DAN);
                system.debug('line-->349 ' + heldAmount);
                system.debug('line-->349 ' + newDepositAmount);
                system.debug('line-->349 ' + depositId);
                system.debug('line-->349 ' + Tenantbankdetails[0]);
                
                string response = EI_DepositSummaryApx.CreateCreditNote('test', DAN, (heldAmount-newDepositAmount), Tenantbankdetails[0].Contact__c, 
                                                                        tenantDetails[0].Deposit__r.Payment_Received_By_Scheme__c, depositId, null, 
                                                                        Tenantbankdetails[0]);
                return 'successfully Updated';
            }
            else
            {
               
            //    emails.ConfirmationWithoutBankdetailssendEmail( heldAmount, newDepositAmount,depositId,tenantDetails);
                Deposit__c dep = new Deposit__c(id=depositId,Deposit_Amount__c = newDepositAmount,Deposit_Amount_Amend__c = true);
                update dep;
                
                string response = EI_DepositSummaryApx.CreateCreditNote('test', DAN, (heldAmount-newDepositAmount), tenantDetails[0].Contact__c, 
                                                                        tenantDetails[0].Deposit__r.Payment_Received_By_Scheme__c, depositId, null, 
                                                                        null);
                // send email to Tenant
                return 'Bank Details Missing';
            }
            
        }
        catch(exception e)
        {
             return e.getMessage();            
        }
    }
    
    @AuraEnabled
    public static List<Deposit_Allocation__c>  getTenant (String searchField, string depositId ){
        string searchkey = '%' + searchField + '%';
        list<Deposit_Allocation__c> depositlist =[select id,Deposit_Holder__c,Contact__c,Deposit_Holder__r.Name,Deposit_Holder__r.PersonEmail,
                                                  Contact__r.FirstName,Contact__r.Email,Contact__r.Phone_Code__c,Contact__r.Phone,Contact__r.LastName, Deposit__r.Payment_Received_By_Scheme__c
                                                  from Deposit_Allocation__c
                                                  where Deposit__c =:depositId and (Contact__r.FirstName like :searchkey or Contact__r.LastName LIKE :searchkey or Contact__r.Email LIKE : searchkey)
                                                 ] ;
        
        return depositlist;
    }
    
    @AuraEnabled
    public static string CreateCreditNote(string creditReference, string paymentReference, decimal Amount, String contactID, 
                                          Date paymentRecievedByScheme, string DspositId, String CaseIDs, Bank_Account__c bankdetails)
    {
        if(Amount>0) {
            String returnedStr = EI_UtilityClassForPayments.createCreditNoteRecord(creditReference, contactID, paymentReference, Amount,
                                                                                   paymentRecievedByScheme, DspositId, CaseIDs, bankdetails, 
                                                                                   'Final Payment', 'Deposit amendment', null);
            return returnedStr;
        } else {
            return 'Amount should be greater than 0';
        }
        
    }
       
    @AuraEnabled
    public static Boolean checkRepaymentRequested(String depositId){
      
        try{
            List<Repayment_Request__c> repReqList = [SELECT AL_Repay_Requested__c
                                            FROM Repayment_Request__c
                                            where Deposit__c = :depositId AND Status__c = 'Repayment requested – agent/landlord' AND AL_Repay_Requested__c = true
                                            ORDER BY CREATEDDATE DESC
                                            LIMIT 1];
          
            if(repReqList.size()>0){
                return true;
            }else{
                return false; 
            }
            
      //      return IsrepaymentRequested;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* wrapper class */  
    public class depositsummarywrapper {
        @AuraEnabled public  Deposit__c objdeposit{get;set;}
        @AuraEnabled public  Case  objcase{get;set;}
        @AuraEnabled public  Deposit_Allocation__c objDA{get;set;}
        @AuraEnabled public  Property_Allocation__C objPA{get;set;}
        @AuraEnabled public  Adjudication_Report__c objAR{get;set;}
        public depositsummarywrapper(Deposit__c objdeposit ){
            this.objdeposit = objdeposit;
        } 
        public depositsummarywrapper(Case  objcase ){
            this.objcase = objcase;
        } 
        public depositsummarywrapper(Deposit_Allocation__c objDA ){
            this.objDA = objDA;
        }
        public depositsummarywrapper(Property_Allocation__C objPA ){
            this.objPA = objPA;
        }
        public depositsummarywrapper(Adjudication_Report__c objAR){
            this.objAR = objAR; 
        }
    } 
    
    @AuraEnabled
    public static boolean getLeadTenant(String depositId){
        
        Boolean isLeadTenant = true;
        try{
            User userObj = [Select Id,ProfileId,Profile.Name,ContactId,AccountId FROM User where Id =: userInfo.getUserId()];
            for(Deposit_Allocation__c eachDA : [select Id, Deposit__c, Role__c, Is_Lead__c, Deposit_Holder__c, Contact__c from Deposit_Allocation__c  where Deposit__c=:depositId]){
                if(eachDA.Contact__c == userObj.ContactId && eachDA.Deposit_Holder__c == userObj.AccountId && (!eachDA.Is_Lead__c && eachDA.Role__c == 'Tenant')){
                    isLeadTenant = false;
                }
            }
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
        return isLeadTenant;
    }
    
    // For EI_LandlordDetails Component
    @AuraEnabled
    public static Map<String, SObject> checkDuplicateRecord(Id conId, String email, String firstname, String surname){
        
        Map<String, SObject> returnVal = new Map<String, SObject>();
        
        Contact conCheck = [Select Id, firstName, lastName, email From Contact Where Id =: conId Limit 1];
        
        if(conCheck.email != email){ 
            list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                        from user where profile.UserLicense.Name ='Customer Community Login' 
                                        and email =:email];
            if(userlistEmail.size() > 0 ){	
                returnVal.put('Duplicate Email', userlistEmail[0]);
                return returnVal;
                //return 'Duplicate email';
            }
        }
        if(conCheck.FirstName != firstname || conCheck.LastName != surname || conCheck.email != email){
            String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
            
            List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                  RETURNING Contact(ID, Name WHERE email=:email.trim()
                                                                    AND CreatedById = :UserInfo.getUserId() 
                                                                    AND (Account.RecordType.Name = 'Individual Landlord' 
                                                                         OR Account.RecordType.Name = 'Corporate Landlord') ) ];
            
            if(searchNameList[0].size() > 0 ){
                returnVal.put('Duplicate Name', searchNameList[0][0]);
                return returnVal;    
                //return 'Duplicate Name';
            }
        }
        returnVal.put('No duplicate', new User());
        return returnVal;    
        //return 'No duplicate';
    }
        
    // For EI_TenentDetails Component
    @AuraEnabled
    public static String checkDuplicateRecords(Id accId, String email, String firstname, String surname){
        
        boolean isChange = false;
        Account accCheck = [Select Id, firstName, lastName, PersonEmail From Account Where Id =: accId limit 1];
        
        /*  if(accCheck.FirstName != firstname || accCheck.LastName != surname){
        String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
        
        List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
        RETURNING Contact(ID WHERE email=:email.trim()) ];
        
        if(searchNameList[0].size() > 0 ){  
        return 'Duplicate Name';
        }
        
        }
        else
        */
        
        if(accCheck.PersonEmail != email){
            
            list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                        from user where profile.UserLicense.Name ='Customer Community Login' 
                                        and email =:email];
            if(userlistEmail.size() > 0 ){	
                return 'Duplicate email';
            }
        }
            
        return 'No duplicate'; 
    }
    
    @AuraEnabled
    public static List<string> getPhoneCodePiclistValues(){
        try {
            Schema.DescribeFieldResult fieldDescription = Contact.Phone_Code__c.getDescribe();
            List<String> countryCodes = new List<String>();
            for (Schema.PicklistEntry cc : fieldDescription.getPicklistValues()) {
                
                if(cc.isActive()){
                    countryCodes.add(cc.getValue());
                }    
            }
            return countryCodes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}