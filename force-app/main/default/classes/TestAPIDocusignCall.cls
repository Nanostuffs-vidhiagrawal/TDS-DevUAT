public without sharing class TestAPIDocusignCall {
    public class FileData
{
    @AuraEnabled
    public string Content{get;set;}
    @AuraEnabled
    public blob ContentBlob{get;set;}
    @AuraEnabled
    public string ContentType{get;set;}
}

    public static string loginDocuSignCall(){
        SpringCM_Settings__c cmSetting = [Select id,API_User_Client_Id__c,API_User_Client_Secret__c,Auth_Endpoint__c from SpringCM_Settings__c limit 1];
        String body = '{"client_secret":"'+cmSetting.API_User_Client_Secret__c+'","client_id":"'+cmSetting.API_User_Client_Id__c+'"}';
        System.debug('Body@ '+body);
        String token;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(cmSetting.Auth_Endpoint__c);
        request.setMethod('POST');
        request.setheader('Content-Type', 'application/json');
        
       request.setBody(body);
         HttpResponse response = http.send(request);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if (response.getStatusCode() == 200){
            token = (String)results.get('access_token'); 
            return token;
        }else{
            return String.valueOf(response.getStatusCode());
        }
       
    }
  
    public static string TestAPIDoc1(string depositId){
       List<Deposit__c> dep = [Select id,Spring_URL_For_Certificate__c,Name from Deposit__c where id=:depositId];  
        system.debug('@@ '+dep);
        string sessionId = loginDocuSignCall();
        system.debug('sessionId '+sessionId );
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(dep[0].Spring_URL_For_Certificate__c);
        request.setMethod('GET');
        request.setheader('Content-Type', 'application/pdf');
         request.setHeader('Accept', 'PDF');
		request.setHeader('Authorization', 'Bearer ' + sessionId);  
       request.setTimeout(120000);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
             string htmlBody = response.getBody();
       //   String base64Content = ( String ) JSON.deserialize(  response.getBody(), String.class );
		//	blob retFile = response.getBodyAsBlob();
         Blob myBlob = response.getBodyAsBlob();
            Attachment attachment = new Attachment();
          attachment.Body = myBlob;
          attachment.Name = String.valueOf('DepositProtectionCertificate.pdf');
          attachment.ParentId = dep[0].Id; 
          insert attachment;
                   
     
               
                return attachment.Id;
            
          
     /*        Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage();
              List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
	 	  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName('DPC.pdf');
                        efa.setBody(myBlob);
                     //   efa.setContentType('docx');
                        attachments.add(efa);
              singlemail.setFileAttachments(attachments);
               singlemail.setSubject('Your SafeDeposits Scotland registration');
            string toEmail = 'singh.taji26@gmail.com';
            List<string> emailList = new List<string>();
            emailList.add(toEmail);
            singlemail.setPlainTextBody('This is test email');
            singlemail.setToAddresses(emailList);
		  Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail});
*/
        }
        else
        {
            system.debug('Error '+response.getStatusCode() );
            
            return null;
        }
    }


}