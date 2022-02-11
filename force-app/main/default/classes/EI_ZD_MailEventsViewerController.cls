public without sharing class EI_ZD_MailEventsViewerController {
    
    @AuraEnabled
    public static list<Mailjet_Message__c> getMailjetMessageDetails(String recId) {
        
        return [select id,Email_ID__c,Message_Id__c,Sent_Message__c,Record_ID__c,Subject__c,Createddate
                from Mailjet_Message__c where record_id__c =: recId order by createddate desc];
        
    }
    @AuraEnabled
    public static list<wrapperClass> getEventDetails(String messageID, String recordId) {
        HttpRequest req;
        if(recordId.startsWith('500')) {
            List<Case> caserecord =[Select Id, RecordType.Name from Case where Id=:recordId and RecordType.name='Dispute SDS Custodial' limit 1];            
            system.debug(messageID);
            
            if(caserecord.size()>0) {
                req = EI_SDS_MailJetUtilityCls.mailJetAuthentication();
            } else {
                req = EI_ZD_EmailUtility.mailJetAuthentication();    
            }
            
        } else {
        	req = EI_SDS_MailJetUtilityCls.mailJetAuthentication();    
        }
        
        req.setMethod('GET');
        req.setEndPoint('https://api.mailjet.com/v3/REST/messagehistory/'+messageID);
        Http http = new Http();
        HTTPResponse res = http.send(req); 
        system.debug(res.getStatus()) ;
        String resBody = res.getBody();
        system.debug(resBody);
        fromJSON response = (fromJSON) System.JSON.deserialize(resBody, fromJSON.class);
        system.debug(response.Data);
        List<wrapperClass> wcList = new List<wrapperClass>();
        for(cls_Data cd : response.Data){
            wrapperClass wc= new wrapperClass();   
            wc.EventType = cd.EventType;
            String eventAt =  cd.EventAt+'000';
            wc.eventAt = datetime.newinstance(long.valueOf(eventAt))+'';
            wc.EventType = cd.EventType;
            wcList.add(wc);
        }
        return wcList;
    }
    public class fromJSON{
        public Integer Count;	//4
        public List<cls_Data> Data;
        public Integer Total;	//4
    }
    public class cls_Data {
        @AuraEnabled 	public String Comment;	//
        @AuraEnabled	public Integer EventAt;	//1623846267
        @AuraEnabled	public String EventType;	//sent
        @AuraEnabled	public String State;	//
        @AuraEnabled	public String Useragent;	//
        @AuraEnabled	public Integer UseragentID;	//0
    }
    
   public class wrapperClass {
        
        @AuraEnabled	public String EventAt;	
        @AuraEnabled	public String EventType;	//sent
        //@AuraEnabled	public String Email;
        
    }
    
    
}