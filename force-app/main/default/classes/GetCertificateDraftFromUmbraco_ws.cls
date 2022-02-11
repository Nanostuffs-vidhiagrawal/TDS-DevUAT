@RestResource(urlMapping='/CreateCertificateDraft/*')
global with sharing class GetCertificateDraftFromUmbraco_ws {
	@HttpPost
    global static ID createDraft() {
        
        try{
            
            Certificate_Draft__c draft = new Certificate_Draft__c(
                Draft_JSON__c = RestContext.request.requestBody.toString()
            );
            insert draft;
            
            RestResponse res = RestContext.response;
            res.statusCode = 200;
            
            return draft.Id;
            
        }catch(Exception e){
            
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
            
            return null;
            
        }
    }
}