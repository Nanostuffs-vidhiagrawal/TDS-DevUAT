public class EI_UtilityClassForPayments {

    public static list<Holiday> holidayList;
    public static Id installmentRecordType;
    public static Id paymentRecordType;
    
    public static void getNewInstallments(Case_Participant__c casePAr, Decimal AmountforInst, Boolean bol, String category, 
                                          Map<String,Bank_Account__c> mapOFContactIdVsBankDet, Map<Id,Installment__c> mapOfContactIdVsInst, 
                                          String paymentType, String paymentTypeStatus)
    {
        if(String.valueOf(installmentRecordType)!='' || String.valueOf(installmentRecordType)!=null) {
            installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        }
        
        Installment__c Installmentrec = new Installment__c();
        Installmentrec.RecordTypeId = installmentRecordType;
        Installmentrec.Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.Deposit__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.Status__c ='Pending processing';
        Installmentrec.Category__c=category;
        Date daysCompletionDate = dueDateMethod(casePAr.Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c,30);
        if(daysCompletionDate != null){
            Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
        }
        
        Installmentrec.Payment_type__c = paymentType;
		Installmentrec.Payment_type_status__c = paymentTypeStatus;
		Installmentrec.Due_Date__c = dueDateMethod(date.today(), 5);
		Installmentrec.Installment_Type__c = 'Payable';
        //X30_Days_Completion_Date__c??

        
        Installmentrec.Amount__c = AmountforInst; 
        
        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                Installmentrec.Custom_Account_Number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c; //International bank details (IBAN)
                Installmentrec.Swift_Code__c = 	mapOFContactIdVsBankDet.get(casePAr.Contact__c).Swift_Code__c; //International bank details (Swift Code)
                Installmentrec.BIC__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).BIC__c; //International bank details (BIC)
                Installmentrec.International_Payment__c = true;
                // Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
            }else{
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
                Installmentrec.International_Payment__c = false;
            }
        }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
    }
    
    //NPP 43
    public static string createCreditNoteRecord(String creditReference, String contactID, String paymentReference, Decimal Amount,
                                                Date paymentRecievedByScheme, String DspositId, String CaseIDs, Bank_Account__c bankdetails, 
                                                String category, String paymentType, String paymentTypeStatus)
    {
        if(String.valueOf(installmentRecordType)!='' || String.valueOf(installmentRecordType)!=null) {
            installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        }
        Date daysCompletionDate = dueDateMethod(paymentRecievedByScheme,30);
        
        if(bankdetails == null)
        {
            try{
                Installment__c Installmentrec = new Installment__c(RecordTypeId = installmentRecordType, Deposit__c =DspositId,Contact__c =contactID,
                                                                   Created_at__c=date.today(), Credit_note_reference__c = null, 
                                                                   Payment_reference__c =paymentReference, Amount__c=Amount, 
                                                                   Status__c='Pending Processing', Case__c =CaseIDs, 
                                                                   Payment_type__c=paymentType, Payment_type_status__c=paymentTypeStatus, 
                                                                   Installment_Type__c = 'Payable', Due_Date__c = dueDateMethod(date.today(), 5),  
                                                                   Category__c=category);
                if(daysCompletionDate != null){
                    Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
                }                                                   
                
                insert Installmentrec;
                
                
                return 'successfully Updated';
            }
            catch (exception e)
            {
                return e.getMessage();
            } 
        }
        else
        {
            if(bankdetails.ValidInternationBankDetails__c) {
                try{
                    
                    Installment__c Installmentrec = new Installment__c(RecordTypeId = installmentRecordType, Contact__c =bankdetails.Contact__c, Created_at__c= date.today(),
                                                                       Credit_note_reference__c =creditReference,Payment_reference__c =paymentReference,
                                                                       Bank_account_holder_name__c=bankdetails.Bank_Account_Holder_Name__c,
                                                                       Bank_account_number__c =bankdetails.Account_Number__c,Bank_sort_code__c = bankdetails.Sort_Code__c,
                                                                       Bank_name__c =bankdetails.Bank_Name__c,Amount__c =Amount,Deposit__c =DspositId,Status__c='Pending Processing', 
                                                                       Case__c =CaseIDs,Payment_type__c=paymentType,Payment_type_status__c=paymentTypeStatus,
                                                                       Due_Date__c=dueDateMethod(date.today(), 5), Installment_Type__c = 'Payable',International_Payment__c = false, 
                                                                       Category__c=category );
                    if(daysCompletionDate != null) {
                        Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
                    } 
                    
                    insert Installmentrec;
                    
                    
                    return 'successfully Updated';
                }
                catch (exception e)
                {
                    return e.getMessage();
                }
            }else{
                
                try{System.debug('Line 817 - ');  
                    
                    
                    Installment__c Installmentrec = new Installment__c(RecordTypeId = installmentRecordType, Contact__c =bankdetails.Contact__c, Created_at__c= date.today(),
                                                                       Credit_note_reference__c =creditReference, Payment_reference__c =paymentReference,
                                                                       Bank_account_holder_name__c=bankdetails.International_Bank_Account_Holder_Name__c,
                                                                       Bank_account_number__c =bankdetails.International_Account_Number__c,
                                                                       Bank_name__c =bankdetails.International_Bank_Name__c,Amount__c =Amount,Deposit__c =DspositId,
                                                                       Status__c='Pending Processing', Swift_Code__c = bankdetails.Swift_Code__c, BIC__c = bankdetails.BIC__c, 
                                                                       Custom_Account_Number__c=bankdetails.IBAN__c, Case__c =CaseIDs, Payment_type__c=paymentType,
                                                                       Payment_type_status__c=paymentTypeStatus, International_Payment__c = true, 
                                                                       Due_Date__c=dueDateMethod(date.today(), 5), Installment_Type__c = 'Payable', Category__c=category );
                    if(daysCompletionDate != null) {
                        Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
                    } 
                    
                    insert Installmentrec;
                    
                    
                    
                    return 'successfully Updated';
                   }
                catch (exception e)
                {
                    return e.getMessage();
                }
            }   
        }
        
        // return 'Error';
    }
    
    public static string getInstallmentForChangeover(String creditReference, String contactID, String paymentReference, Decimal Amount,
                                                     Date paymentRecievedByScheme, String depositId, String CaseIDs, Bank_Account__c bankdetails, 
                                                     Boolean isTenantChangeover, String status, String installmentType, String category, 
                                                     Date collectionDate, String paymentType, String paymentTypeStatus)
    {
        if(String.valueOf(installmentRecordType)!='' || String.valueOf(installmentRecordType)!=null) {
        	installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        }
        if(String.valueOf(paymentRecordType)!='' || String.valueOf(paymentRecordType)!=null) {
            paymentRecordType = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        }
        Installment__c Installmentrec = new Installment__c(RecordTypeId = installmentRecordType, Contact__c =contactID, Created_at__c=date.today(),
                                                           Credit_note_reference__c = null, Payment_reference__c=paymentReference,
                                                           Amount__c=Amount, Deposit__c=depositId, Case__c =CaseIDs, 
                                                           Payment_type__c=paymentType, Payment_type_status__c=paymentTypeStatus, 
                                                           Due_Date__c = dueDateMethod(date.today(), 5), Status__c=status, 
                                                           Installment_Type__c=installmentType, Category__c=category, 
                                                           IsTenantChangeover__c=isTenantChangeover);
        try {
            insert Installmentrec;
            
            try {
                Payment__c payment = new Payment__c();
                payment.RecordTypeId = paymentRecordType;
                //payment.Inbound_Report__c = report.Id;
                payment.Installment__c = Installmentrec.Id;
                //??? Colletion Date 
                payment.Collection_Date__c = collectionDate;
                payment.Amount__c = Installmentrec.Amount__c;
                payment.DAN__c =Installmentrec.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Receivable';
                insert payment;
            } catch (exception e1) {
                return e1.getMessage();
            }
            
            return 'Successful';
            
        } catch (exception e) {
            return e.getMessage();
        }
    }
    
    public static void getInstallmentsForNoResponse(Repayment_Request_Line__c repReqLine, Decimal AmountforInst, Boolean bol, String category, 
                                          Map<String,Bank_Account__c> mapOFContactIdVsBankDet, Map<Id,Installment__c> mapOfRepReqIdVsInst)
    {
        if(String.valueOf(installmentRecordType)!='' || String.valueOf(installmentRecordType)!=null) {
            installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        }
        Installment__c Installmentrec = new Installment__c();
        Installmentrec.RecordTypeId = installmentRecordType;
        Installmentrec.Contact__c = repReqLine.Account__r.personContactId;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.Deposit__c = repReqLine.Repayment_Request__r.Deposit__c;                                                               
        Installmentrec.Case__c = repReqLine.Repayment_Request__r.Case__c; 
        Installmentrec.Status__c ='Pending processing';
        Installmentrec.Category__c=category;
        Date daysCompletionDate = dueDateMethod(repReqLine.Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c,30);
        if(daysCompletionDate != null) {
            Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
        }
        
        //Installmentrec.Payment_type__c = 
		//Installmentrec.Payment_type_status__c =
		Installmentrec.Due_Date__c = dueDateMethod(date.today(), 5);
		Installmentrec.Installment_Type__c = 'Payable';
        //X30_Days_Completion_Date__c??

        
        Installmentrec.Amount__c = AmountforInst; 
        
        if(mapOFContactIdVsBankDet.containsKey(repReqLine.Account__c)){
            if(!mapOFContactIdVsBankDet.get(repReqLine.Account__c).ValidInternationBankDetails__c){
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).International_Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).International_Bank_Name__c;
                Installmentrec.Custom_Account_Number__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).IBAN__c; //International bank details (IBAN)
                Installmentrec.Swift_Code__c = 	mapOFContactIdVsBankDet.get(repReqLine.Account__c).Swift_Code__c; //International bank details (Swift Code)
                Installmentrec.BIC__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).BIC__c; //International bank details (BIC)
                Installmentrec.International_Payment__c = true;
                // Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).IBAN__c;
            }else{
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(repReqLine.Account__c).Bank_Name__c;
                Installmentrec.International_Payment__c = false;
            }
        }
        mapOfRepReqIdVsInst.put(repReqLine.Id,Installmentrec); 
        
    }
    
    public static String getPropertyTransferDeposit(String creditReference, String contactID, String paymentReference, Decimal Amount,
                                                     Date paymentRecievedByScheme, String depositId, String CaseIDs, Bank_Account__c bankdetails, 
                                                     Boolean IsPropertyTransfer, String status, String installmentType, String category, 
                                                     Date collectionDate, String paymentType, String paymentTypeStatus)
    {
        if(String.valueOf(installmentRecordType)!='' || String.valueOf(installmentRecordType)!=null) {
        	installmentRecordType = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        }
        if(String.valueOf(paymentRecordType)!='' || String.valueOf(paymentRecordType)!=null) {
            paymentRecordType = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        }
        Installment__c Installmentrec = new Installment__c(RecordTypeId = installmentRecordType, Contact__c =contactID, Created_at__c=date.today(),
                                                           Credit_note_reference__c = null, Payment_reference__c=paymentReference,
                                                           Amount__c=Amount, Deposit__c=depositId, Case__c =CaseIDs, 
                                                           Payment_type__c=paymentType, Payment_type_status__c=paymentTypeStatus, 
                                                           Due_Date__c = dueDateMethod(date.today(), 5), Status__c=status, 
                                                           Installment_Type__c=installmentType, Category__c=category, 
                                                           IsPropertyTransfer__c=IsPropertyTransfer);
        try {
            insert Installmentrec;
            
            try {
                Payment__c payment = new Payment__c();
                payment.RecordTypeId = paymentRecordType;
                //payment.Inbound_Report__c = report.Id;
                payment.Installment__c = Installmentrec.Id;
                //??? Colletion Date 
                payment.Collection_Date__c = collectionDate;
                payment.Amount__c = Installmentrec.Amount__c;
                payment.DAN__c =Installmentrec.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Receivable';
                insert payment;
            } catch (exception e1) {
                return e1.getMessage();
            }
            
            return 'Successful';
            
        } catch (exception e) {
            return e.getMessage();
        }
    }
    
    public static Date dueDateMethod(Date startDate, Integer noOfDays)
    {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }  
        //List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static Integer calculateWorkingDaysBetweenTwoDates(Date startDate, Date endDate)
    {        
        if(startDate == null || endDate==null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }  
        //List<Holiday> holidays = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        if(startDate != endDate)
        {
            Integer noOfDaysBetween = Integer.valueOf(math.abs(startDate.daysBetween(endDate)));
            Integer allWorkingDays=0;
            
            for(Integer i=0;i<=noOfDaysBetween;i++) {
                if(checkifItisWorkingDay(startDate.addDays(i),holidayList) && i!=0) {
                    allWorkingDays++;
                }
            }
            return allWorkingDays;
        }
        else 
        {
            return 0;           
        }
        
    }
    
    /*public static Integer calculateWorkingDaysBetweenTwoDates(Date startDate, Date endDate)
    {        
        if(startDate == null || endDate==null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }  
        //List<Holiday> holidays = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        if(startDate != endDate)
        {
            Integer noOfDaysBetween = Integer.valueOf(math.abs(startDate.daysBetween(endDate)));
            Integer allWorkingDays=0;
            
            for(Integer i=0;i<=noOfDaysBetween;i++) {
                if(checkifItisWorkingDay(startDate.addDays(i),holidayList)) {
                    allWorkingDays++;
                }
            }
            return allWorkingDays;
        }
        else 
        {
            if(checkifItisWorkingDay(startDate,holidayList)) {
                return 1;
            }
            else
            {
                return 0;
            }            
        }
        
    }*/
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        DateTime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
	
    /*
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    */
    
}