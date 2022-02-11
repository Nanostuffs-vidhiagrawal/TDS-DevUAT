public without sharing class EI_DownloadPostController {
	
    public string PDFData{get;set;}
    public string Source{get;set;}
    public Mailjet_Message__c msg{get;set;}
    public EI_DownloadPostController(){
        
        
        Id recId = ApexPages.currentPage().getParameters().get('Id');
        String isDownload = ApexPages.currentPage().getParameters().get('isDownload');
        msg = [Select Id,Name,Sent_Message__c,Source__c,Contact__c,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingCountry,Contact__r.MailingPostalCode from Mailjet_Message__c where Id =: recId];
        PDFData = msg.Sent_Message__c;
        Source = msg.Source__c;
        String str = 'attachment; filename='+msg.Name+'.pdf';
        if(isDownload == 'true'){
            Apexpages.currentPage().getHeaders().put('content-disposition',str);
        }
        
    }
    
    public void updateIsPrinted(){
        
        Id recId = ApexPages.currentPage().getParameters().get('Id');

        Mailjet_Message__c msg = [Select Id,Name,Sent_Message__c from Mailjet_Message__c where Id =: recId];
        PDFData = msg.Sent_Message__c;
        
        msg.Is_Printed__c = true;
        
        update msg;
        
    }
}