public class Dummy_class {
     public static void beforeupdatecaseandrelateditems(list<case>caselist){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
       
        for(Case caseObject:caselist){                    
            //If(caseObject.Status != caseMap.get(caseObject.Id).Status){                
           
            if(caseObject.Status == 'Review of decision requested' && caseObject.Days_Remaining__c > 0
               && caseObject.RecordtypeId == devRecordTypeId){
                   if(caseObject.Tenant_responded_on_adjudication__c == true
                      || caseObject.Agent_landlord_responded_on_adjudication__c == true){
                         
                          if(caseObject.Tenant_responded_on_adjudication__c == true && caseObject.Tenant_adjudication_date__c == null){
                              caseObject.Tenant_adjudication_date__c= calculateWorkingDaysBetweenTwoDates(system.today(),5);
                             
                          }
                          if(caseObject.Agent_landlord_responded_on_adjudication__c == true && caseObject.Agent_landlord_adjudication_date__c == null) {            
                             
                             
                              caseObject.Agent_landlord_adjudication_date__c = calculateWorkingDaysBetweenTwoDates(system.today(),5);
                             
                          }
                      }
                   else if(caseObject.Tenant_responded_on_adjudication__c==false && caseObject.Agent_landlord_responded_on_adjudication__c == false){
                       caseObject.addError('Select Tenant responded on adjudication Chekbox Or Agent landlord responded on adjudication checkbox');
                       
                   }
                   
                   
               }
            /*else {
caseObject.Status.addError('Can not change the status.');
}*/            
           
           
            /*if( caseObject.Agent_landlord_responded_on_adjudication__c == true && caseObject.Tenant_responded_on_adjudication__c == true){
caseObject.Tenant_adjudication_date__c= calculateWorkingDaysBetweenTwoDates(system.today(),5);
caseObject.Agent_landlord_adjudication_date__c = calculateWorkingDaysBetweenTwoDates(system.today(),5);
}*/
        }
    }        
   
    public static void beforeupdatecaseholdandrelateditems(list<case>caselist, Map<id,Case>oldMap){
       
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
       
        for(Case newCase:caselist) {
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId == devRecordTypeId
               && (newCase.Status == 'On Hold' || oldMap.get(newCase.Id).Status=='On Hold') )
            {
                if(newCase.Status=='On Hold' ){
                    newCase.On_Hold_Start_Date__c = Date.today();                  
                   
                }
               
                if(oldMap.get(newCase.Id).Status=='On Hold'){
                    newCase.On_Hold_End_Date__c = Date.today();                
                    Decimal totalNoOfDays = (newCase.Total_On_Hold_Days__c!=null ? newCase.Total_On_Hold_Days__c : 0) + newCase.On_Hold_Start_Date__c.daysBetween(newCase.On_Hold_End_Date__c);
                    newCase.Total_On_Hold_Days__c = totalNoOfDays;
                   
                }
            }
        }
    }
   
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
   
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
            return false;
        }
        else
        {
            return true;    
        }
    }
   
      public static void createPaymentAndInstalmentsRecordNew(List<Case> caseList,Map<Id,Case> oldMap,Map<Id,Case> newMap){
        system.debug('line');
        String SDSEmail = 'ashish.singh1@espire.com';
        Set<String> setOfCaseIds = new Set<String>();
        Set<Id> setOfCaseForAggAmount = new Set<Id>(); // Evidence gathering AA/LL
        Set<Id> setOfCaseForRwAdj = new Set<Id>();  // Deposit to be repaid - resolved without adjudication
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
       
           
            for(Case eachCase : caseList){
            if(oldMap.get(eachCase.Id).Status != eachCase.Status && oldMap.get(eachCase.Id).Status == 'Review of decision requested' && eachCase.Status == 'Review request declined' && eachCase.RecordtypeId==devRecordTypeId ){
                    //if(eachCase.Amount_to_tenants__c > 0 || eachCase.Amount_to_agent_landlord__c > 0){
                        // setOfCaseForAggAmount.add(eachCase.Id);
                    setOfCaseIds.add(eachCase.Id);
                    // }
            }
        }
           
          if(!setOfCaseIds.isEmpty()) {
            system.debug('line-->121' );
           
            Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
                ([SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c,
                  Deposit_Account_Number__r.Name, Deposit_Account_Number__c, Deposit_Account_Number__r.Agreed_amount__c,
                  Tenancy_Property_Address__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c,
                  Agreed_amount__c, Deposit_Protected_Amount__c, Remaining_protected_amount__c,
                  (SELECT Id, Account__c, Contact__c, Case__c, Case__r.Deposit_Account_Number__c,
                   Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName,
                   Payable_Amount__c, Split_percent__c FROM Case_Participants__r),
                  (SELECT Id,Awarded_to_Agent__c,Awarded_to_Landlord__c,Awarded_to_Tenant__c FROM Adjudication_Reports__r where Status__c='Published' order by createddate desc limit 1) FROM Case where Id In :setOfCaseIds
                 limit 1]);
           
            //Map of CASE is not empty START
            if(!mapOfCaseWithCasePar.isEmpty()) {
               
               
                for(Case singCas : mapOfCaseWithCasePar.values()) {
                     Decimal amtToBePaid=0;                    
                    if(!mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r.isEmpty()){
                       
                   
                    Integer NoOfTenants = 0;
                    Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
                    for (Case_Participant__c cp : singCas.Case_Participants__r) // check if working or not
                    {                        
                        if(cp.Type__c == 'Tenant'){
                            NoOfTenants++;
                        }
                        mapOfCasIdVsCasPart.put(cp.Id, cp); //mapIdOpp.get(i).xxx_r[0].Name;  
                    }
                    //(singCas.Adjudication_Reports__c).Awarded_to_Tenant__c = ((singCas.Amount_to_tenants__c)*(singCas.Case_Participants__r).Split_percent__c)/100);
                     
                    Decimal amtToTenant = (mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Tenant__c );
                   
                    if(mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c!=null)
                        amtToBePaid =+ mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c;
                        //amtToAGLL =+ lstCase[0].Adjudication_Reports__r[0].Awarded_to_Agent__c;
                   
                    if(mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c!=null)
                         amtToBePaid =+ mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Landlord__c;
                        //amtToAGLL =+ lstCase[0].Adjudication_Reports__r[0].Awarded_to_Landlord__c;
                   
                   
                    //Map of CASE PARTICIPANTS is not empty START
                    if(!mapOfCasIdVsCasPart.isEmpty()) {
                       
                        Set<String> ContactIds = new Set<String>();
                        List<cpm__Payment__c> createPaymentList = new List<cpm__Payment__c>();
                        Map<Id,cpm__Installment__c> mapOfContactIdVsInst = new Map<Id,cpm__Installment__c>();
                       
                            for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                                ContactIds.add(casePar.Contact__c);
                            }
                       
                        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
System.debug('casPar => ' + mapOfCasIdVsCasPart.values());
                        //System.debug('payableAmount => ' + payableAmount);
                        System.debug('mapOFContactIdVsBankDet => ' + mapOFContactIdVsBankDet);
                        System.debug('mapOfContactIdVsInst Before => ' + mapOfContactIdVsInst);
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                           
                         //   if(setOfCaseForRwAdj.contains(casPar.Case__c)) {
                            if(casPar.Type__c == 'Tenant') {
                                    Decimal tenantamount= (amtToTenant*casPar.Split_percent__c)/100 ;
                                    if(tenantamount>0) {
                                        getInstallments(casPar,tenantamount,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                    }
                             }
                             else {
                                    if(amtToBePaid>0)
                                    {
                                        getInstallments(casPar,amtToBePaid,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                    }
                              }
                          //  }
                        }
                       
                        System.debug('mapOfContactIdVsInst After => ' + mapOfContactIdVsInst);
                       
                        if(!mapOfContactIdVsInst.isEmpty()){
                            system.debug(' line 202' + mapOfContactIdVsInst);
                            insert mapOfContactIdVsInst.values();
                        }
                        System.debug('createPaymentList before => ' + createPaymentList);
                        for(cpm__Installment__c inst : mapOfContactIdVsInst.values()){
                            getpayment(inst,mapOFContactIdVsBankDet,createPaymentList);
                        }
                        System.debug('createPaymentList After => ' + createPaymentList);
                        if(!createPaymentList.isEmpty()) {
                            insert createPaymentList;
                        }

                        Deposit__c depo = new Deposit__c();
                        depo.Id = singCas.Deposit_Account_Number__c;
                        depo.Agreed_amount__c = amtToBePaid + amtToTenant;
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
         
         
      /*  for(Case getcase : caseList){
           getcase.Status='Deposit to be repaid - decision issued';
             
         //  update upvalue;
          }*/
         

           
                       
            //Map of CASE is not empty START
         
           
     
    }
   
    public static void getInstallments(Case_Participant__c casePAr,Decimal AmountforInst,Boolean bol,MAp<String,Bank_Account__c> mapOFContactIdVsBankDet,Map<Id,cpm__Installment__c> mapOfContactIdVsInst){
       
        cpm__Installment__c Installmentrec = new cpm__Installment__c();
        Installmentrec.cpm__Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.DAN__c = casePAr.Case__r.Deposit_Account_Number__c;                                                              
        Installmentrec.Case__c = casePAr.Case__c;
        Installmentrec.cpm__Status__c = 'Pending processing';  
        /*if(disuptedInst){
        Installmentrec.cpm__Amount__c = AmountforInst;
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);  
        }*/
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