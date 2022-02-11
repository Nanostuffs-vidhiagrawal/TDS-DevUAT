//Tajinder TJSingh 24/11/2021 18:42 - Repayment_Request__r.Deposit__r.Createby_ContactId__c -- field in SOQL was missing at 158
public without sharing class EI_UpdateRepaymentRequestToCase {
    
    public static void  updatecaseandrelateditems(list<case> caselist){
        Id DisitemId = Schema.SObjectType.Dispute_Item__c.getRecordTypeInfosByName().get('SDS Dispute Item').getRecordTypeId();
        Id CaseparId = Schema.SObjectType.Case_Participant__c.getRecordTypeInfosByName().get('SDS Case Participant').getRecordTypeId();
        set<id> caseid = new set<id>();
        set<id>depositid = new set<id>();
        set<id> repaymentid = new set<id>();
        list<Dispute_Item__c> disitemlist = new list<Dispute_Item__c>();
        list<Case_Participant__c> caseparticipantlist = new list<Case_Participant__c>();
        list<case> updatecaselist = new list<case>();
        for(case caseobj : caselist){
            case newobj = new case ();
            //newobj.Id = caseobj.Id;
           // newobj.SlaStartDate=caseobj.LastModifiedDate;
          //  updatecaselist.add(newobj);
            caseid.add(caseobj.Id);
            if(caseobj.Deposit_Account_Number__c !=null){
            depositid.add(caseobj.Deposit_Account_Number__c);
            }
        }
       /* if(!updatecaselist.isempty())  {
           // update updatecaselist;
            
        }*/
        
        list<Repayment_Request__c> repaymentlist = [select id,Account__c,AL_CleaningAmt__c,AL_DmgPropAmt__c,
                                                    AL_GardeningAmt__c,AL_OtherAmt__c,AL_Other_Reason__c,AL_RedecorationAmt__c,
                                                    AL_Rent_Arrears__c,AL_Repay_Requested__c,Case__c,Deposit__c,Status__c,Deposit__r.Customer__r.RecordType.Name,
                                                    Tenancy_End_Date__c,Tenancy_End_Date_Agent__c,Tenant_Cleaning__c,Tenant_Dmg_to_Property__c,
                                                    Tenant_Gardening__c,Tenant_Other__c,Tenant_Other_Reason__c,Tenant_Redecoration__c,
                                                    Tenant_Rent_Arrears__c,Tenant_Repay_Requested__c,Total_Amount_By_Agent_Landlord__c,
                                                    Total_Amount_Offer_from_AALL_To_Tenant__c,Total_Amount_Requested_AL__c  from Repayment_Request__c where Status__c='Repayment Disputed - Self-Resolution' and Case__c IN :caseid and Deposit__c IN:depositid  ]; 
        
       
        
        list<deposit_allocation__c > depall = [select id,Deposit_Holder__c,Deposit_Holder__r.Name,Is_Lead__c, Role__c,Deposit__c from  Deposit_allocation__c  where Deposit__c IN :depositid  and Role__c='Tenant'  and Is_Lead__c=true limit 1  ];
        if(!repaymentlist.isempty()) {
            
            for(Repayment_Request__c repayobj :repaymentlist )  {
            calculateWorkingDaysBetweenTwoDates(system.today(), 10);
                case casedata = new case ();
                casedata.id=repayobj.Case__c;
                if(depall.size()>0){
                casedata.Lead_Tenant_Name__c =depall[0].Deposit_Holder__r.Name;
                }
                else{
                casedata.Lead_Tenant_Name__c =null;    
                }
                casedata.Agreed_amount_from_AGLL_to_TT__c =repayobj.Total_Amount_Offer_from_AALL_To_Tenant__c-repayobj.Total_Amount_By_Agent_Landlord__c;
            //    casedata.Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 10);
                casedata.Respond_Date__c=EI_UtilityClassForPayments.dueDateMethod(system.today(), 10);
                casedata.Self_Resolution_Start_Date__c =system.today();
            //    if(repayobj.AL_Repay_Requested__c ){
             //       casedata.Dispute_Initiated_By__c='Tenant';  
             //   }
             //   if(repayobj.Tenant_Repay_Requested__c ){
                    if(repayobj.Deposit__r.Customer__r.RecordType.Name=='Corporate Landlord' ||repayobj.Deposit__r.Customer__r.RecordType.Name=='Individual Landlord')   {
                        casedata.Dispute_Initiated_By__c='Landlord';     
                    }
                    else{
                        casedata.Dispute_Initiated_By__c='Agent';    
                    }
              //  }
                updatecaselist.add(casedata);
                
                 
                
                if(repayobj.AL_CleaningAmt__c > 0 || repayobj.Tenant_Cleaning__c > 0)  {
                    Dispute_Item__c cleaningdispute = new  Dispute_Item__c();
                    cleaningdispute.RecordTypeId =DisitemId;
                    cleaningdispute.Dispute__c=repayobj.Case__c;
                    cleaningdispute.Claimed_by_Landlord__c=repayobj.AL_CleaningAmt__c;
                    cleaningdispute.Agreed_by_AGLL__c=repayobj.AL_CleaningAmt__c;
                    cleaningdispute.Tenant_Response__c=repayobj.Tenant_Cleaning__c;
                    cleaningdispute.Agreed_by_Tenant__c=repayobj.Tenant_Cleaning__c;
                    cleaningdispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Cleaning__c/repayobj.AL_CleaningAmt__c)*100;
                    cleaningdispute.Type__c='Cleaning';
                    disitemlist.add(cleaningdispute);
                }
                if(repayobj.AL_DmgPropAmt__c > 0 || repayobj.Tenant_Dmg_to_Property__c > 0)  {
                    Dispute_Item__c Damagedispute = new  Dispute_Item__c();
                    Damagedispute.RecordTypeId =DisitemId;
                    Damagedispute.Dispute__c=repayobj.Case__c;
                    Damagedispute.Claimed_by_Landlord__c=repayobj.AL_DmgPropAmt__c;
                    Damagedispute.Agreed_by_AGLL__c=repayobj.AL_DmgPropAmt__c;
                    Damagedispute.Tenant_Response__c=repayobj.Tenant_Dmg_to_Property__c;
                    Damagedispute.Agreed_by_Tenant__c=repayobj.Tenant_Dmg_to_Property__c;
                    Damagedispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Dmg_to_Property__c/repayobj.AL_DmgPropAmt__c)*100;
                    Damagedispute.Type__c='Damage';
                    disitemlist.add(Damagedispute);
                }
                if(repayobj.AL_GardeningAmt__c > 0 || repayobj.Tenant_Gardening__c > 0)  {
                    Dispute_Item__c Gardeningdispute = new  Dispute_Item__c(); 
                    Gardeningdispute.RecordTypeId=DisitemId;
                    Gardeningdispute.Dispute__c=repayobj.Case__c;
                    Gardeningdispute.Claimed_by_Landlord__c=repayobj.AL_GardeningAmt__c;
                    Gardeningdispute.Agreed_by_AGLL__c=repayobj.AL_GardeningAmt__c;
                    Gardeningdispute.Tenant_Response__c=repayobj.Tenant_Gardening__c;
                    Gardeningdispute.Agreed_by_Tenant__c=repayobj.Tenant_Gardening__c;
                    Gardeningdispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Gardening__c/repayobj.AL_GardeningAmt__c)*100;
                    Gardeningdispute.Type__c='Gardening';
                    disitemlist.add(Gardeningdispute);
                }
                if(repayobj.AL_Rent_Arrears__c > 0 || repayobj.Tenant_Rent_Arrears__c > 0)  {
                    Dispute_Item__c rentdispute = new  Dispute_Item__c(); 
                    rentdispute.RecordTypeId =DisitemId;
                    rentdispute.Dispute__c=repayobj.Case__c;
                    rentdispute.Claimed_by_Landlord__c=repayobj.AL_Rent_Arrears__c;
                    rentdispute.Agreed_by_AGLL__c=repayobj.AL_Rent_Arrears__c;
                    rentdispute.Tenant_Response__c=repayobj.Tenant_Rent_Arrears__c;
                    rentdispute.Agreed_by_Tenant__c=repayobj.Tenant_Rent_Arrears__c;
                    rentdispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Rent_Arrears__c/repayobj.AL_Rent_Arrears__c)*100;
                    rentdispute.Type__c='Rent';
                    disitemlist.add(rentdispute);
                }
                if(repayobj.AL_RedecorationAmt__c > 0 || repayobj.Tenant_Redecoration__c > 0)  {
                    Dispute_Item__c redecorationdispute = new  Dispute_Item__c(); 
                    redecorationdispute.RecordTypeId =DisitemId;
                    redecorationdispute.Dispute__c=repayobj.Case__c;
                    redecorationdispute.Claimed_by_Landlord__c=repayobj.AL_RedecorationAmt__c;
                    redecorationdispute.Agreed_by_AGLL__c=repayobj.AL_RedecorationAmt__c;
                    redecorationdispute.Tenant_Response__c=repayobj.Tenant_Redecoration__c;
                    redecorationdispute.Agreed_by_Tenant__c=repayobj.Tenant_Redecoration__c;
                    redecorationdispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Redecoration__c/repayobj.AL_RedecorationAmt__c)*100;
                    redecorationdispute.Type__c='Redecoration';
                    disitemlist.add(redecorationdispute);
                }
                if(repayobj.AL_OtherAmt__c > 0 || repayobj.Tenant_Other__c > 0)  {
                    Dispute_Item__c otherdispute = new  Dispute_Item__c();
                    otherdispute.RecordTypeId =DisitemId;
                    otherdispute.Dispute__c=repayobj.Case__c;
                    otherdispute.Claimed_by_Landlord__c=repayobj.AL_OtherAmt__c;
                    otherdispute.Agreed_by_AGLL__c=repayobj.AL_OtherAmt__c;
                    otherdispute.Tenant_Response__c=repayobj.Tenant_Other__c;
                    otherdispute.Agreed_by_Tenant__c=repayobj.Tenant_Other__c;
                    otherdispute.Adjustment_Percentage_by_TT__c=(repayobj.Tenant_Other__c/repayobj.AL_OtherAmt__c)*100;
                    if(repayobj.AL_Other_Reason__c!=null){
                    otherdispute.Other_Reason__c=repayobj.AL_Other_Reason__c;
                    }
                    if(repayobj.Tenant_Other_Reason__c!=null){
                    otherdispute.Tenant_Statement__c=repayobj.Tenant_Other_Reason__c;
                    }
                    otherdispute.Type__c='Other';
                    disitemlist.add(otherdispute);
                    
                }
                repaymentid.add(repayobj.Id);
            }
            if(!disitemlist.isempty()) {
                insert disitemlist;
                
            }
        }
        
        
        list<Repayment_Request_Line__c> requestlinelist = 
            [Select Id,Account__c,Repayment_Request__r.Account__r.RecordType.Name,Repayment_Request__r.Account__r.personcontactId,
             Repayment_Request__r.Total_Amount_By_Tenant__c,Account__r.RecordType.Name,CalculatePercent__c,Account__r.PersonContactId,AL_ReqAmt__c,
             Is_Lead__c,Repayment_Request__c,Repayment_Requested_Mail_Sent__c,Requested_By__c,Tenant_ReqAmt__c,Repayment_Request__r.Case__c,
             Repayment_Request__r.Deposit__r.Customer__r.RecordType.Name,Repayment_Request__r.Deposit__r.Createby_ContactId__c ,Repayment_Request__r.Deposit__r.Customer__r.personcontactId, 
             Repayment_Request__r.Deposit__r.Customer__c from Repayment_Request_Line__c where 
             Repayment_Request__r.Case__r.status='Repayment disputed - self-resolution' 
             and Repayment_Request__c IN :repaymentid and Account__r.RecordType.Name='Tenant'];
        
        system.debug('line--> 124 ' + requestlinelist);
        if(!repaymentlist.isempty()) {
            for(Repayment_Request_Line__c requestline :requestlinelist ) {
                if(requestline.Account__r.RecordType.Name=='Tenant') {
                    Case_Participant__c newparticipant = new  Case_Participant__c(); 
                    newparticipant.RecordTypeId= CaseparId;
                    newparticipant.Account__c =requestline.Account__c;
                    newparticipant.Contact__c=requestline.Account__r.PersonContactId;
                    newparticipant.Case__c=requestline.Repayment_Request__r.Case__c;
                    newparticipant.Payable_Amount__c=requestline.Tenant_ReqAmt__c;
                    system.debug('line--> 157' + requestline.CalculatePercent__c );
                    newparticipant.Split_percent__c=requestline.CalculatePercent__c;
                    if(!depall.isempty() && requestline.Account__r.RecordType.Name=='Tenant' 
                       && requestline.Account__c == depall[0].Deposit_Holder__c) {
                           newparticipant.Type__c='Tenant';
                           newparticipant.Is_Lead__c=true;
                       }
                    else{
                        newparticipant.Type__c='Tenant';
                    }
                    caseparticipantlist.add(newparticipant);
                } 
                
            }
            
            Case_Participant__c newcse = new  Case_Participant__c();
            newcse.RecordTypeId =CaseparId;
            if(requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.RecordType.Name=='Corporate Landlord'){
                newcse.Account__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__c;
                newcse.Contact__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Createby_ContactId__c;
                newcse.Type__c='Landlord';
                newcse.Case__c=requestlinelist[0].Repayment_Request__r.Case__c;
                newcse.Payable_Amount__c=requestlinelist[0].Repayment_Request__r.Total_Amount_By_Tenant__c;
                system.debug('Line 185 -> '+newcse.Account__c+' contact '+newcse.Contact__c+' case '+newcse.Case__c);
                caseparticipantlist.add(newcse);
            }
            else if(requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.RecordType.Name=='Individual Landlord'){
                //newcse.Account__c =requestlinelist[0].Repayment_Request__r.Account__c;   
                //newcse.Contact__c =requestlinelist[0].Repayment_Request__r.Account__r.personcontactId;
                newcse.Account__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__c;   
                newcse.Contact__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.personcontactId;
                newcse.Case__c=requestlinelist[0].Repayment_Request__r.Case__c;
                newcse.Type__c='Landlord'; 
                newcse.Payable_Amount__c=requestlinelist[0].Repayment_Request__r.Total_Amount_By_Tenant__c;
                system.debug('Line 185 -> '+newcse.Account__c+' contact '+newcse.Contact__c+' case '+newcse.Case__c);
                caseparticipantlist.add(newcse);
            }
            else if(requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.RecordType.Name=='Letting Agent'){
                newcse.Account__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__c;
                newcse.Contact__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.personcontactId;
                newcse.Type__c='Agent';   
                newcse.Case__c=requestlinelist[0].Repayment_Request__r.Case__c;
                newcse.Payable_Amount__c=requestlinelist[0].Repayment_Request__r.Total_Amount_By_Tenant__c;
                system.debug('Line 185 -> '+newcse.Account__c+' contact '+newcse.Contact__c+' case '+newcse.Case__c);
                caseparticipantlist.add(newcse);
            }
            else if(requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__r.RecordType.Name=='Organization'){
                newcse.Account__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Customer__c;
                newcse.Contact__c =requestlinelist[0].Repayment_Request__r.Deposit__r.Createby_ContactId__c;
                newcse.Type__c='Agent'; 
                newcse.Case__c=requestlinelist[0].Repayment_Request__r.Case__c;
                newcse.Payable_Amount__c=requestlinelist[0].Repayment_Request__r.Total_Amount_By_Tenant__c;
                system.debug('Line 185 -> '+newcse.Account__c+' contact '+newcse.Contact__c+' case '+newcse.Case__c);
                caseparticipantlist.add(newcse);
            }
            
            system.debug('line--> 169 ' + caseparticipantlist);
            if(!caseparticipantlist.isempty()) {
                insert caseparticipantlist;
                
            } 
            if(!updatecaselist.isempty()) {
                update updatecaselist;
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
}