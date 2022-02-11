public without sharing class EI_AllocatePaymentsController {
    
    @AuraEnabled
    public static list<InboundReportWrapper> returnInboundReports(Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        map<Id,list<InboundReportWrapper>> installMentIdVs = new map<Id,list<InboundReportWrapper>>();
        list<Inbound_Report__c> inboundReports = [Select Id,Name,File_Name__c,Payment_Method__c,Collection_Date__c,Matched_Colour__c,Installment__c,Installment__r.Deposit__r.Deposit_Account_Number__c,Reference1__c,Amount__c,Reference2__c,Reference3__c,Reference4__c,Reference5__c,Reason_For_Unallocation__c,CreatedDate from Inbound_Report__c where Matched_Colour__c != '' AND Reason_For_Unallocation__c != 'Refund to customer' AND Status__c != 'Inactive' AND RecordType.Name = 'SDS Inbound Report' ORDER BY Matched_Colour__c ASC];
        
        list<InboundReportWrapper> wrapperToReturn = new list<InboundReportWrapper>();
        list<InboundReportWrapper> wrapperToReturnFilter = new list<InboundReportWrapper>();
        list<InboundReportWrapper> wrapperToReturnBlue = new list<InboundReportWrapper>();
        list<InboundReportWrapper> wrapperToReturnGreen = new list<InboundReportWrapper>();
        list<InboundReportWrapper> wrapperToReturnAmber = new list<InboundReportWrapper>();
        list<InboundReportWrapper> wrapperToReturnRed = new list<InboundReportWrapper>();
        
        for(Inbound_Report__c report : inboundReports){
            InboundReportWrapper wrap = new InboundReportWrapper();
            wrap.isSelected = false;
            wrap.objInboundReport = report;
            if(report.Installment__c != null){
                if(installMentIdVs.containsKey(report.Installment__c)){
                    
                    list<InboundReportWrapper> wrappers = installMentIdVs.get(report.Installment__c);
                    wrappers.add(wrap);
                    installMentIdVs.put(report.Installment__c,wrappers);
                }else{
                    
                    installMentIdVs.put(report.Installment__c,new list<InboundReportWrapper>{wrap});
                }
            }else{
                wrap.matchedColour = report.Matched_Colour__c;
                wrapperToReturnRed.add(wrap);
            }
            
        }
        for(Id instId : installMentIdVs.keySet()){
            if(installMentIdVs.get(instId).size() == 1){
                InboundReportWrapper wrap = installMentIdVs.get(instId)[0];
                wrap.matchedColour = wrap.objInboundReport.Matched_Colour__c;
                if(wrap.matchedColour == 'Green'){
                    wrapperToReturnGreen.add(wrap);
                }else{
                    wrapperToReturnAmber.add(wrap);
                }

            }else{
                for(InboundReportWrapper wrap : installMentIdVs.get(instId)){
					wrap.matchedColour = 'Blue'; 
                    wrapperToReturnBlue.add(wrap);
                }
            }
        }
        if(!wrapperToReturnGreen.isEmpty()){
            wrapperToReturn.addAll(wrapperToReturnGreen);
        }
        if(!wrapperToReturnAmber.isEmpty()){
            wrapperToReturn.addAll(wrapperToReturnAmber);
        }
        if(!wrapperToReturnBlue.isEmpty()){
            wrapperToReturn.addAll(wrapperToReturnBlue);
        }
        if(!wrapperToReturnRed.isEmpty()){
            wrapperToReturn.addAll(wrapperToReturnRed);
        }
        
        if(isFilter){
            
            if(filterType == 'date'){
                endCreatedDate = endCreatedDate.addDays(1);
                for(InboundReportWrapper wrap : wrapperToReturn){
                    
                    if(wrap.objInboundReport.CreatedDate < endCreatedDate && wrap.objInboundReport.CreatedDate > startCreatedDate){
                        wrapperToReturnFilter.add(wrap);
                    }
                    
                }
                
            }else{
                for(InboundReportWrapper wrap : wrapperToReturn){
                    
                    if(wrap.objInboundReport.Amount__c == amount){
                        wrapperToReturnFilter.add(wrap);
                    }
                    
                }
            }
            
            return wrapperToReturnFilter;
        }else{
            return wrapperToReturn;
        }
        
        
    }
    
    @AuraEnabled
    public static list<InboundReportWrapper> moveToRed(list<InboundReportWrapper> wrapperList, String Id,Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        //move selected reports to Red
        list<Inbound_Report__c> reportsToUpdate = new list<Inbound_Report__c>();
        
        if(String.isBlank(Id)){
            for(InboundReportWrapper wrap : wrapperList){
                Inbound_Report__c report = wrap.objInboundReport;
                if(wrap.isSelected && wrap.objInboundReport.Matched_Colour__c != 'Red'){
                    
                    report.Matched_Colour__c = 'Red';
                    report.Installment__c = null;
                    reportsToUpdate.add(report);
                }
            }
        }else{
            Inbound_Report__c report = new Inbound_Report__c();
            report.Id = Id;
            report.Matched_Colour__c = 'Red';
            report.Installment__c = null;
            reportsToUpdate.add(report);
        }
        
        
        
        if(!reportsToUpdate.isEmpty()){
            try {
                Update reportsToUpdate;

            } catch (Exception exc) {
                //Create Logs 
            }
        }
        return returnInboundReports(amount, isFilter,  filterType,  startCreatedDate,  endCreatedDate);
    }
    @AuraEnabled
    public static list<InboundReportWrapper> allocateInboundReports(list<InboundReportWrapper> wrapperList, String Id, Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        //allocate selected inbound reports
        list<Inbound_Report__c> reportsToUpdate = new list<Inbound_Report__c>();
        
        for(InboundReportWrapper wrap : wrapperList){
            
            Inbound_Report__c report = wrap.objInboundReport;
            if(wrap.isSelected && wrap.objInboundReport.Matched_Colour__c != 'Red' && wrap.matchedColour != 'Blue'){
                report.Matched_Colour__c = '';
                reportsToUpdate.add(report);
            }else if(String.isNotBlank(Id) && Id == wrap.objInboundReport.Id && wrap.objInboundReport.Matched_Colour__c != 'Red' && wrap.matchedColour != 'Blue'){
                report.Matched_Colour__c = '';
                reportsToUpdate.add(report);
            }
        }
        
        
        if(!reportsToUpdate.isEmpty()){
            try {
                Update reportsToUpdate;
                //Payment will be created from trigger 

            } catch (Exception exc) {
                //Create Logs 
            }
        }
        return returnInboundReports( amount, isFilter,  filterType,  startCreatedDate,  endCreatedDate);

    }
    
    @AuraEnabled
    public static list<InboundReportWrapper> refundPayment(list<InboundReportWrapper> wrapperList, String Id, Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        
        list<Installment__c> installmentsToUpdate = new list<Installment__c>();
        //move selected reports to Red
        list<Inbound_Report__c> reportsToUpdate = new list<Inbound_Report__c>();
        //Create Installment Record Here
        Installment__c inst = new Installment__c();
        inst.Status__c = 'Pending Processing';
        //inst.Amount__c = reportsToUpdate[0].Amount__c;
        inst.Installment_Type__c = 'Payable';
        inst.Deposit__c = System.Label.EI_UnallocateDepositId;
        inst.RecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId();
        
        Insert inst;
        
        for(InboundReportWrapper wrap : wrapperList){
            Inbound_Report__c report = wrap.objInboundReport;
            if(String.isNotBlank(Id) && Id == wrap.objInboundReport.Id){
                
                report.Reason_For_Unallocation__c = 'Refund to customer';
                report.Installment__c = inst.Id;
                installmentsToUpdate.add(new Installment__c(Id= inst.Id,Amount__c = report.Amount__c));
                reportsToUpdate.add(report);
            }
        }
        
        
        if(!reportsToUpdate.isEmpty()){
            try {
                Update reportsToUpdate;
                Update installmentsToUpdate;
				
            } catch (Exception exc) {
                //Create Logs 
            }
        }
        return returnInboundReports( amount, isFilter,  filterType,  startCreatedDate, endCreatedDate);
        
    }

    @AuraEnabled
    public static list<InboundReportWrapper> splitPayment(list<SplitReportWrapper> splitList, InboundReportWrapper wrap, Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        
        Id reportRecId = Schema.SObjectType.Inbound_Report__c.getRecordTypeInfosByName().get('SDS Inbound Report').getRecordTypeId();
        //Need to substract split from existing inbound report

        list<Inbound_Report__c> reportsToCreate = new list<Inbound_Report__c>();

        
        for(SplitReportWrapper newSplit : splitList){
            //??? Verify all needed field once
            Inbound_Report__c report = new Inbound_Report__c();
            report.RecordTypeId = reportRecId;
            report.Reference1__c = newSplit.reference;
            report.Parent_Report__c = wrap.objInboundReport.Id;
            report.File_Name__c = wrap.objInboundReport.File_Name__c;
            report.Payment_Method__c = wrap.objInboundReport.Payment_Method__c;
            report.Amount__c = newSplit.newAmount;
            report.Collection_Date__c = wrap.objInboundReport.Collection_Date__c;
            reportsToCreate.add(report);
            
        }

        Insert reportsToCreate;
        Update new Inbound_Report__c(Id = wrap.objInboundReport.Id, Status__c = 'Inactive',Matched_Colour__c = '');
        
        return returnInboundReports( amount, isFilter,  filterType,  startCreatedDate,  endCreatedDate);
        
    }


    public class InboundReportWrapper{
        @AuraEnabled public  Inbound_Report__c objInboundReport{get;set;}
        @AuraEnabled public  Boolean isSelected{get;set;}
        @AuraEnabled public  String matchedColour{get;set;}
        @AuraEnabled public  list<SplitReportWrapper> spliList{get;set;}
        
    }
    public class SplitReportWrapper{
        @AuraEnabled public  Decimal newAmount{get;set;}
        @AuraEnabled public  String  reference{get;set;}
        
    }
}