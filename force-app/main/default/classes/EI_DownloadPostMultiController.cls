public class EI_DownloadPostMultiController {

    public list<Mailjet_Message__c> mailjet{get;set;}
    public string PDFData{get;set;}
    public string Source{get;set;}
    public EI_DownloadPostMultiController(){
        
        list<String> idList = new list<String>();
        mailjet = new list<Mailjet_Message__c>();
        String recId = ApexPages.currentPage().getParameters().get('Id');
        String isDownload = ApexPages.currentPage().getParameters().get('isDownload');
        Source = ApexPages.currentPage().getParameters().get('source');
        if(recId.contains(',')){
            list<String> splitList = recId.split(',');
            idList.addAll(splitList);
        }else{
            idList.add(recId);
        }
		system.debug('>>>>'+idList);
        mailjet = [Select Id,Name,Sent_Message__c,Source__c,Contact__c,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingCountry,Contact__r.MailingPostalCode from Mailjet_Message__c where Id IN : idList];

        //String str = 'attachment; filename='+msg.Name+'.pdf';
        if(isDownload == 'true'){
        	Apexpages.currentPage().getHeaders().put('content-disposition','attachment; filename=AllFiles.pdf');
        }
    }
    
    public void updateIsPrinted(){
        list<String> idList = new list<String>();
        mailjet = new list<Mailjet_Message__c>();
        String recId = ApexPages.currentPage().getParameters().get('Id');

        if(recId.contains(',')){
            list<String> splitList = recId.split(',');
            idList.addAll(splitList);
        }else{
            idList.add(recId);
        }
		system.debug('>>>>'+idList);
        mailjet = [Select Id,Name,Sent_Message__c,Source__c,Contact__c,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingCountry,Contact__r.MailingPostalCode from Mailjet_Message__c where Id IN : idList];
		
        for(Mailjet_Message__c msg : mailjet){
        	msg.Is_Printed__c = true;   
        }
        
        if(!mailjet.isEmpty()){
            update mailjet;
        }
        
    }
}