@RestResource(urlMapping='/setVars/*')
global class EI_ZD_HerokuUtility {
 	@HttpPost 
    global static void getConfigVars() {
        
        RestRequest req = RestContext.request;
		map<String,String> worldpayParams = req.params;
        //system.debug('>>>>>>>>>>>'+JSON.serializePretty(req) );
        List<Heroku_Credentials__mdt> metaDataList = [SELECT Username__c,Password__c,Email_Ids__c,Endpoint__c FROM Heroku_Credentials__mdt WHERE QualifiedApiName= 'Creds'];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(metaDataList[0].Endpoint__c);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/vnd.heroku+json; version=3');
        
        Blob beforeblob = Blob.valueOf(metaDataList[0].Username__c+':'+metaDataList[0].Password__c);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        request.setHeader('Authorization', 'Basic '+paramvalue);
        HttpResponse response = new HttpResponse();
        if(Test.isRunningTest()){
            
            response.setBody('{"ASD":"12322323232","DATABASE_URL":"postgres://nhhzeopdnhsgxu:f7a850d547785b90fd8e73937969cc6a4b1e974a73dc1ec25729d52ef7eac75c@ec2-54-74-35-87.eu-west-1.compute.amazonaws.com:5432/dai25p4a8579lh"}');
        	response.setStatusCode(200);
        }else{
            response = http.send(request);
        }
        
        system.debug(response.getStatusCode() + response.getStatus());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            
            String resBody = response.getBody();
            list<String> emailList = new list<String>();
            map<String,Object> mapURL = (map<String,Object>)JSON.deserializeUntyped(resBody);
			String connectionString = String.valueOf(mapURL.get('DATABASE_URL'));
            
            if(metaDataList[0].Email_Ids__c.contains(';')){
                emailList = metaDataList[0].Email_Ids__c.split(';');
            }else{
                emailList.add(metaDataList[0].Email_Ids__c);
            }
            
            list<API_Account__c> apiAccountList = [Select Id,Name,Heroku_Connection_String__c from API_Account__c where Name = 'ZeroDeposit'];
            
            if(!apiAccountList.isEmpty() && !emailList.isEmpty()){
                if(apiAccountList[0].Heroku_Connection_String__c != connectionString){
                    
                    //Send Email to emailList
                    String messageBody = 'Hi Team, \n\n Please use new Heroku connection string mentioned below: \n\n';

                    messageBody += 'Connection String : '+connectionString+'\n\n';
                    
                    messageBody += 'Thanks'+''+'\n';
                    
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = emailList;
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Heroku Connection String Changes';
                    message.plainTextBody = messageBody;
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }                    
                    //Update Heroku Connection string is Salesforce
                    
                    Update new API_Account__c(Id = apiAccountList[0].Id,Heroku_Connection_String__c = connectionString);
                }
            }
            
        }
        
        
    } 
    
  
}