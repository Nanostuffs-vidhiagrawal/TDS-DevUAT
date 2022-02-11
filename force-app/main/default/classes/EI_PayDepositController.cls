public without sharing class EI_PayDepositController {
  @Auraenabled
    public static List<DepositInstallmentWrapper> getDepositsToPay(String status,String branchid, String depositId, Boolean topUpVal, Decimal topUpAmnt) {
        
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit__c> depositList = new List<Deposit__c>();
        List<Branch__c> branch = new List<Branch__c>();
        system.debug('++++++++status+++'+status);
        String depositStatus = status.trim();
        if(branchid == null){
            branch =[Select id from Branch__c where id in (Select Branch__c from Branch_User_Mapping__c where User__c =: UserInfo.getUserId()) and Is_Active__c = true ORDER BY Branch_Name__c Limit 1];
            
            if(topUpVal == true){
                  if(branch.size()>0){
                depositList = [SELECT Id,Customer__c,Deposit_Amount__c,Status__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                               Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where id=: depositId and Status__c=:depositStatus  and ((Customer__c =:accountid and Branch__c = NULL) or (Branch__c =: branch[0].id and Customer__c =:accountid )) ]; //and Deposit_Transferred__c=false
                }
                else{
                    depositList = [SELECT Id,Customer__c,Deposit_Amount__c,Status__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                                   Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where id=: depositId and Status__c=:depositStatus  and Customer__c =:accountid and Branch__c = NULL ]; //and Deposit_Transferred__c=false           
                }
            }else{
                 if(branch.size()>0){
                depositList = [SELECT Id,Customer__c,Status__c,Deposit_Amount__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                               Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where Status__c=:depositStatus  and ((Customer__c =:accountid and Branch__c = NULL) or (Branch__c =: branch[0].id and Customer__c =:accountid )) ]; //and Deposit_Transferred__c=false
                }
                else{
                    depositList = [SELECT Id,Customer__c,Deposit_Amount__c,Status__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                                   Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where Status__c=:depositStatus  and Customer__c =:accountid and Branch__c = NULL ]; //and Deposit_Transferred__c=false           
                }
                
            }
           
        }
        else{
            if(topUpVal == true){
                 depositList = [SELECT Id,Customer__c,Deposit_Amount__c,Status__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                           Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where id=: depositId and Branch__c =: branchid  and Status__c=:depositStatus];//and Deposit_Transferred__c=false
           
            }else{
                 depositList = [SELECT Id,Customer__c,Deposit_Amount__c,Status__c,Start_Date_Text__c,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
                           Number_of_Tenants_Value__c,Property_Address_Without_Country__c,(Select Id,Status__c,Amount__c,Payment_Method__c,Is_Topup__c from Installments1__r where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate Limit 1) from Deposit__c where id=: depositId and Branch__c =: branchid  and Status__c=:depositStatus];//and Deposit_Transferred__c=false
           
            }
            
        }       
        //depositList = [SELECT Id,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,
        //Number_of_Tenants_Value__c from Deposit__c where Customer__c =:accountid and Status__c=:depositStatus];
        list<DepositInstallmentWrapper> result = new list<DepositInstallmentWrapper>();
        for(Deposit__c deposit: depositList){
            
            DepositInstallmentWrapper inst = new DepositInstallmentWrapper();
            
            inst.objDeposit = deposit;
            //inst.objDeposit.Installments1__r = deposit.Installments1__r;
            if(String.isBlank(depositId)){
                inst.isSelected = true;
            }else if(deposit.Id == depositId){
                inst.isSelected = true;
            }else{
                inst.isSelected = false;
            }
            inst.isTopUp = false;
            if(status == 'Deposits held by scheme'){
                
System.debug('@@ 46 '+status);
                if(topUpVal == true){
                    inst.isTopUp = true;
                }
             if(!deposit.Installments1__r.isEmpty()){
               if(topUpVal == true && topUpAmnt > 0){
                    
                    inst.paymentAmount = deposit.Installments1__r[0].Amount__c+topUpAmnt;
               }else{
                    inst.paymentAmount = deposit.Installments1__r[0].Amount__c;
               }
             }
                else{
                    
                     if(topUpVal == true){
                         if(deposit.Deposit_Amount__c != deposit.Protected_Amount__c)
                         inst.paymentAmount = topUpAmnt;
                         else{
                          inst.paymentAmount=topUpAmnt;
                         }
                    }else
                         inst.paymentAmount = null;
                }
                   
            }else{
                
                inst.paymentAmount = deposit.Protected_Amount__c;
                
            }
            if(deposit.Installments1__r != null && !deposit.Installments1__r.isEmpty()){
                inst.installmentId = deposit.Installments1__r[0].Id;
                inst.paymentMethod = deposit.Installments1__r[0].Payment_Method__c;
                inst.isTopUp = deposit.Installments1__r[0].Is_Topup__c;  
            }
            
            
            
            result.add(inst);
        }
        return result;
    }
    @Auraenabled
    public static String  updateDepositsInstallments(list<DepositInstallmentWrapper> depositInstallmentList, String paymentMethod, String referenceNumber){
        
        // There are two Payment Types  Topup and Normal payment 
        //map<Deposit__c,Installment__c> depositVsInstallment = new map<Deposit__c,Installment__c>();
        Boolean isBLK = false;
        if(String.isNotBlank(referenceNumber) && referenceNumber.contains('BLK')){
            isBLK = true;
        }
        system.debug('>>>>>>>'+JSON.serializePretty(depositInstallmentList));
        list<Deposit__c> depositsTobeUpdated = new list<Deposit__c>();
        list<Installment__c> installmentsTobeUpserted = new list<Installment__c>();
        
        for(DepositInstallmentWrapper depIns:depositInstallmentList){
            
                
            //intallments needs to be added in getDepositsToPay 
            Installment__c installment = new Installment__c();
            if(depIns.objDeposit.Status__c != 'Deposits held by scheme' && depIns.objDeposit.Status__c != 'Awaiting payment'){
                depIns.objDeposit.Status__c = 'Awaiting payment';
                depIns.objDeposit.Protected_Amount__c = depIns.paymentAmount;
                installment.X30_Days_Reminder__c = System.today().addDays(30);
                installment.X60_Days_Reminder__c = System.today().addDays(60);
                depositsTobeUpdated.add(depIns.objDeposit);
            }else if(depIns.objDeposit.Status__c == 'Deposits held by scheme'){
                if(!depIns.isTopUp){
                    installment.X30_Days_Reminder__c = System.today().addDays(30);
                    installment.X60_Days_Reminder__c = System.today().addDays(60);
                }
            }else if(depIns.objDeposit.Status__c == 'Awaiting payment'){
                depIns.objDeposit.Protected_Amount__c = depIns.paymentAmount;
                depositsTobeUpdated.add(depIns.objDeposit);
            }
            
            
            installment.Status__c = 'Pending';
            installment.Deposit__c = depIns.objDeposit.Id;
            installment.Payment_Method__c = paymentMethod;
            installment.Installment_Type__c = 'Receivable';
            installment.Amount__c = depIns.paymentAmount;
            if(isBLK){
                installment.BLK_Number__c = referenceNumber;
            }
            if(depIns.objDeposit.Status__c == 'Deposits held by scheme'){
                installment.Is_Topup__c = true;
            }else{
                installment.Is_Topup__c = false;
            }
            
            
            if(String.isNotBlank(depIns.installmentId)){
                installment.Id = depIns.installmentId;
            }
            
            installmentsTobeUpserted.add(installment);
                
            
            
        }
        
        try{
            if(!depositsTobeUpdated.isEmpty())
                Update depositsTobeUpdated;
            
            if(!installmentsTobeUpserted.isEmpty())
                Upsert installmentsTobeUpserted Id;
            
            if(isBLK && String.isNotBlank(referenceNumber))
                updateBulkNumberSetting(referenceNumber);
        }catch(Exception e){
            
        }
        return 'Process Completed';
    }
    @AuraEnabled
    public static string getBulkNumber(){
        String memberid;
        MemberId__c myMemberid = MemberId__c.getInstance('MemberID');
        string mbrid =string.valueof(myMemberid.BulkNumber__c);
        mbrid = mbrid.substringBeforeLast('.');
        integer needaddzero = 5-mbrid.length();
        string prefix ='0';
        for(integer i =1; i<needaddzero;i++){
            prefix = prefix+'0';
        }
        
        memberid = 'BLK'+prefix+mbrid;
        
        return memberid+'SDS';
    }
    
    public static void updateBulkNumberSetting(String referenceNumber){
        Integer BLKNumber;
        if(String.isNotBlank(referenceNumber)){
            referenceNumber = referenceNumber.replace('BLK',''); 
            referenceNumber = referenceNumber.replace('SDS',''); 
            BLKNumber = Integer.valueOf(referenceNumber);
            MemberId__c myMemberid = MemberId__c.getInstance('MemberID');
            myMemberid.BulkNumber__c = BLKNumber+1;
            
            update myMemberid;
            
        }
    }
    // List<DepositInstallmentWrapper> getDepositsToPay(String status,String branchid, String depositId)
    @auraEnabled
    public static  List<DepositInstallmentWrapper> cancelPaymentDeposit(list<DepositInstallmentWrapper> depositInstallmentList, String status,String branchid, String depositId){
        List<Deposit__c> depositsTobeUpdated = new List<Deposit__c>();
        List<Installment__c> installmentsTobeUpdated = new List<Installment__c>();
        for(DepositInstallmentWrapper depIns:depositInstallmentList){
            
            depIns.objDeposit.Status__c = 'Registered (not paid)';
            depositsTobeUpdated.add(depIns.objDeposit);
            installmentsTobeUpdated.add(new Installment__c(Id = depIns.installmentId,X30_Days_Reminder__c = null,X60_Days_Reminder__c= null ));
            
        }
        update depositsTobeUpdated;
        update installmentsTobeUpdated;
        return getDepositsToPay(status,branchid,depositId,false,0);
    }
    public class DepositInstallmentWrapper {
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public  Deposit__c objDeposit{get;set;}
        @AuraEnabled public  list<Installment__c> objInstallment{get;set;}
        @AuraEnabled public  String installmentId{get;set;}
        @AuraEnabled public  Decimal paymentAmount{get;set;}
        @AuraEnabled public  String paymentMethod{get;set;}
        @AuraEnabled public  Boolean isTopUp{get;set;}
    }
    public class PaymentConfirmationWrapper{
        
        @AuraEnabled public String PaymentReferenceNumber{get;set;}
        @AuraEnabled public Decimal TotalDeposits{get;set;}
        @AuraEnabled public Decimal AmountToBePaid{get;set;}
        @AuraEnabled public list<Installment__c> installmentList{get;set;}
    }
    @Auraenabled
    public static PaymentConfirmationWrapper  getPaymentConfiramtion(String referenceNumber){
        
        PaymentConfirmationWrapper wrap = new PaymentConfirmationWrapper();
        if(String.isNotBlank(referenceNumber)){
            
            User user = [Select Id,AccountId from User where Id =: UserInfo.getUserId()];
            
            if(referenceNumber.contains('DAN')){
                
                //Deposit_Account_Number__c,Deposit__c
                //??? addd User check as well
                list<Installment__c> installmentList = [Select Id,Deposit__c,Deposit__r.Deposit_Account_Number__c,Deposit__r.Property_Address__c,Amount__c from Installment__c 
                                                        where Installment_Type__c = 'Receivable' AND Deposit__r.Deposit_Account_Number__c =: referenceNumber AND Deposit__r.Customer__c =: user.AccountId ORDER BY CreatedDate DESC LIMIT 1];
               
                if(!installmentList.isEmpty()){
                    
                    
                    wrap.PaymentReferenceNumber = referenceNumber;
                    wrap.TotalDeposits = 1;
                    wrap.AmountToBePaid = installmentList[0].Amount__c;
                    wrap.installmentList = installmentList;
                }
                
                    
                
            }else{
                
                //???? Add User check as well
                list<Installment__c> installmentList = [Select Id,Deposit__c,Deposit__r.Deposit_Account_Number__c,Deposit__r.Property_Address__c,Amount__c from Installment__c 
                                                        where Installment_Type__c = 'Receivable' AND BLK_Number__c =: referenceNumber AND Deposit__r.Customer__c =: user.AccountId ORDER BY CreatedDate DESC];
                
                if(!installmentList.isEmpty()){
                    wrap.installmentList = installmentList;
                    wrap.TotalDeposits = installmentList.size();
                    wrap.PaymentReferenceNumber = referenceNumber;
                    Decimal totalAmount = 0;
                    for(Installment__c inst : installmentList){
                        
                        totalAmount += inst.Amount__c;
                    }
                    wrap.AmountToBePaid = totalAmount;
                }
                
                
            }
            
        }
        
        
        
        return wrap;
    }
}