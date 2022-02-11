public without sharing class EI_AdjudicatorPaymentAndInstalllment implements Queueable,Database.AllowsCallouts{
	
    public Map<String,Set<Id>> mapOfcaseIds;
    public Set<Id> caseIds;
    public Set<Id> depIds;
    public EI_AdjudicatorPaymentAndInstalllment(Map<String,Set<Id>> mapOfcaseIds) {
        System.debug('mapOfcaseIds Queue Cons => ' + mapOfcaseIds);
        this.mapOfcaseIds = mapOfcaseIds;
        this.caseIds = new Set<Id>();
    }
    
    public void execute(QueueableContext QU) {
        System.debug('QueueableContext => ');
        for(string MailTy : mapOfcaseIds.keyset()) {
            for(Id caseId : mapOfcaseIds.get(MailTy)) {
                if(!caseIds.contains(caseId))  
                    caseIds.add(caseId); 
            }
        }
        
        String SDSEmail = 'ashish.singh1@espire.com';
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        Set<Id> setOfCaseForRwAdj = new Set<Id>();
        
        if(!mapOfcaseIds.isEmpty()) {
            
            Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
                ([SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c, 
                  Deposit_Account_Number__r.Name, Deposit_Account_Number__c, Deposit_Account_Number__r.Agreed_amount__c,
                  Tenancy_Property_Address__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, 
                  Agreed_amount__c, Deposit_Protected_Amount__c, Remaining_protected_amount__c, 
                  (SELECT Id, Account__c, Contact__c, Case__c, Case__r.Deposit_Account_Number__c,
                   Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                   Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c 
                   FROM Case_Participants__r), 
                  (SELECT Id, Awarded_to_Agent__c, Awarded_to_Landlord__c, Awarded_to_Tenant__c,Dispute_Status__c, Webhook_Report_Link__c 
                   FROM Adjudication_Reports__r where Status__c='Published' order by createdDate desc limit 1) 
                  FROM Case where Id In :caseIds
                 ]);
            
            //Map of CASE is not empty START
            if(!mapOfCaseWithCasePar.isEmpty()) {
                
                for(Case singCas : mapOfCaseWithCasePar.values()) {
                    
                    if(!mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r.isEmpty()) 
                    {
                        Adjudication_Report__c adjRepObj = mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0];
                        
                        Integer NoOfTenants = 0;
                        Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
                        for (Case_Participant__c cp : singCas.Case_Participants__r) // check if working or not
                        {                        
                            /*if(cp.Type__c == 'Tenant'){
                                NoOfTenants++;
                            }*/
                            mapOfCasIdVsCasPart.put(cp.Id, cp); //mapIdOpp.get(i).xxx_r[0].Name;   
                        }
                        //Decimal payableAmount = singCas.Amount_to_tenants__c / NoOfTenants;
                        Decimal toatalAmountToTenant = adjRepObj.Awarded_to_Tenant__c ;
                        Decimal toatalAmountToAGLL = adjRepObj.Awarded_to_Agent__c + adjRepObj.Awarded_to_Landlord__c;
                        
                        //Map of CASE PARTICIPANTS is not empty START
                        if(!mapOfCasIdVsCasPart.isEmpty()) {
                            
                            Set<String> ContactIds = new Set<String>();
                            //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
                            Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
                            
                            for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                                ContactIds.add(casePar.Contact__c);
                            }
                            
                            MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
                            System.debug('casPar => ' + mapOfCasIdVsCasPart.values());
                            System.debug('toatalAmountToTenant => ' + toatalAmountToTenant);
                            System.debug('mapOFContactIdVsBankDet => ' + mapOFContactIdVsBankDet);
                            System.debug('mapOfContactIdVsInst Before => ' + mapOfContactIdVsInst);
                            
                            for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                                //   if(setOfCaseForRwAdj.contains(casPar.Case__c)) {
                                if(casPar.Type__c == 'Tenant') {
                                    Decimal amtToTenant = (toatalAmountToTenant*casPar.Split_percent__c)/100;
                                        if(amtToTenant>0) {
                                            //getInstallments(casPar,amtToTenant,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                            EI_UtilityClassForPayments.getNewInstallments(casPar, amtToTenant, false, 'Final Payment', 
                                                                                          mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                          'Deposit repayment request', null);
                                        }
                                }
                                else {
                                    if(toatalAmountToAGLL>0) 
                                    {
                                        //getInstallments(casPar,toatalAmountToAGLL,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                        EI_UtilityClassForPayments.getNewInstallments(casPar, toatalAmountToAGLL, false, 'Final Payment', 
                                                                                      mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                      'Deposit repayment request', null);
                                    }
                                }
                                //  }
                            }
                            
                            System.debug('mapOfContactIdVsInst After => ' + mapOfContactIdVsInst);
                            
                            if(!mapOfContactIdVsInst.isEmpty()){
                                insert mapOfContactIdVsInst.values();
                            }
                            
                            
                            
                            Deposit__c depo = new Deposit__c();
                            depo.Id = singCas.Deposit_Account_Number__c;
                            depo.Agreed_amount__c = singCas.Amount_to_agent_landlord__c + singCas.Amount_to_tenants__c;
                            updatedepositdata.add(depo);
                            System.debug('updatedepositdata => ' + updatedepositdata);
                        }
                        //Map of CASE PARTICIPANTS is not empty START
                    }
                    
                }

            }
            //Map of CASE is not empty END
        }

        if(!updatedepositdata.isEmpty()){
            update updatedepositdata;
        }
    }
    
    public static void getInstallments(Case_Participant__c casePAr,Decimal AmountforInst,Boolean bol,MAp<String,Bank_Account__c> mapOFContactIdVsBankDet,Map<Id,cpm__Installment__c> mapOfContactIdVsInst){
        System.debug('getInstallments Start');
        cpm__Installment__c Installmentrec = new cpm__Installment__c();
        Installmentrec.cpm__Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.DAN__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.cpm__Status__c = 'Pending processing';  
        Installmentrec.cpm__Amount__c = AmountforInst;
        
        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
            }else{
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
            }
        }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec); 
        System.debug('getInstallments END mapOfContactIdVsInst =>' + mapOfContactIdVsInst);
    }
    
    public static void getpayment(cpm__Installment__c inst,MAp<String,Bank_Account__c> mapOFContactIdVsBankDet,List<cpm__Payment__c> createPaymentList){
        
        cpm__Payment__c  payment = new cpm__Payment__c();
        payment.cpm__Installment__c =inst.Id;
        payment.cpm__Contact__c = inst.cpm__Contact__c;
        payment.Created_at__c = date.today();
        payment.Credit_note_reference__c = null;//creditReference;
        payment.Payment_reference__c = null;//paymentReference;
        payment.cpm__Collection_Date__c = date.today();
        payment.cpm__Amount__c = inst.cpm__Amount__c;
        if(mapOFContactIdVsBankDet.containsKey(inst.cpm__Contact__c)){
            if(mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).ValidInternationBankDetails__c){
                payment.Payee_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Contact__r.name;
                payment.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Bank_Account_Holder_Name__c;
                payment.Bank_account_number__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Account_Number__c;
                payment.Bank_sort_code__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Sort_Code__c;
                payment.Bank_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Bank_Name__c;
            }else{
                payment.Payee_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Contact__r.name;
                payment.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Bank_Account_Holder_Name__c;
                payment.Bank_account_number__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).International_Account_Number__c;
                payment.Bank_sort_code__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Sort_Code__c;
                payment.Bank_name__c = mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).Bank_Name__c;
                payment.cpm__IBAN__c= mapOFContactIdVsBankDet.get(inst.cpm__Contact__c).IBAN__c;
            }
        }            
        payment.DAN__c = inst.DAN__c;
        payment.Case__c = inst.Case__c;
        createPaymentList.add(payment);
    }
	
}