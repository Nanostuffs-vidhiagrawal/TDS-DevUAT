public without sharing class EI_ImportDataFromCSVController {

    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Inbound_Report__c> reportList{get;set;}
    public string fileType{get;set;}
    public string fileName{get;set;}
    public Decimal totalCount{get;set;}
    public Decimal totalAmount{get;set;}
    
    public EI_ImportDataFromCSVController (){
        csvFileLines = new String[]{};
        reportList= New List<Inbound_Report__c>();
        fileType = 'BACS';
        totalCount = 0;
        totalAmount = 0;
    }
    
    public void importCSVFile(){
        
        try{
            totalCount = 0;
            totalAmount = 0;
            // Read CSV file body and store it in variable
            csvAsString = csvFileBody.toString();
            Id reportRecId = Schema.SObjectType.Inbound_Report__c.getRecordTypeInfosByName().get('SDS Inbound Report').getRecordTypeId();
            reportList = new list<Inbound_Report__c>();
            // Split CSV String to lines

            csvFileLines = csvAsString.split('\n');
            if(fileType == 'Cheque'){
                // Iterate CSV file lines and retrieve one column at a time.
                for(Integer i=1; i < csvFileLines.size(); i++){
                    
                    
                    Inbound_Report__c reportObj = new Inbound_Report__c() ;
                    String[] csvRecordData = csvFileLines[i].split(',');
                    //???? add Fields of Inbound Report 19-02-2021

                    system.debug('><><><><><><>csvRecordData'+csvRecordData);
                    list<string> dateList = csvRecordData[0].split('/');
                    reportObj.Collection_Date__c = Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[0]));
                    reportObj.RecordTypeId = reportRecId;
                    reportObj.File_Name__c = fileName;
                    reportObj.Reference1__c = csvRecordData[1] ;
                    System.debug('>>>>>'+csvRecordData[2]);
                    if(String.isNotBlank(csvRecordData[2]))
                    	reportObj.Amount__c = Decimal.valueOf(csvRecordData[2].replace('\r','')) ;
                    reportObj.Payment_Method__c = 'Cheque';
                    reportObj.Payee_Name__c = csvRecordData[3] ;
                    
                    if(reportObj.Amount__c != null && reportObj.Amount__c >0){
                        totalAmount += reportObj.Amount__c;
                        reportList.add(reportObj);
                    }
                        
                }
                // if all correct then insert Account into Org
                if(reportList.size()>0){
                    totalCount = reportList.size();
                    insert reportList;
                }
                    
            }else if(fileType == 'BACS'){
                // Iterate CSV file lines and retrieve one column at a time.
                for(Integer i=2; i < csvFileLines.size(); i++){
                    Inbound_Report__c reportObj = new Inbound_Report__c() ;
                    String[] csvRecordData = csvFileLines[i].split(',');
                    
                    
                    list<string> dateList = csvRecordData[9].split('/');
                    reportObj.Collection_Date__c = Date.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[0]));
                    reportObj.RecordTypeId = reportRecId;
                    reportObj.File_Name__c = fileName;
                    reportObj.Reference1__c = csvRecordData[10] ; 
                    reportObj.Reference2__c = csvRecordData[11] ;
                    reportObj.Reference3__c = csvRecordData[12] ;
                    reportObj.Reference4__c = csvRecordData[13] ;
                    reportObj.Reference5__c = csvRecordData[14] ;
                    reportObj.Type__c = csvRecordData[15] ;
                    if(csvRecordData.size()>17 && String.isNotBlank(csvRecordData[17]))
                        reportObj.Amount__c = Decimal.valueOf(csvRecordData[17].replace('\r','')) ;
                    reportObj.Payment_Method__c = 'Bank Transfer';
                    if(reportObj.Amount__c != null && reportObj.Amount__c >0){
                        totalAmount += reportObj.Amount__c;
                        reportList.add(reportObj);
                    }
                        
                }
                // if all correct then insert Account into Org
                if(reportList.size()>0){
                    totalCount = reportList.size();
                    insert reportList;
                }
                    
            }else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a valid file type');
                ApexPages.addMessage(errorMessage);
            }
            
            csvFileBody = null;
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data into Salesforce. Please make sure input csv file is correct');
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }
}