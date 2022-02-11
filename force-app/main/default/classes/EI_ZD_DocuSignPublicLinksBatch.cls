global class   EI_ZD_DocuSignPublicLinksBatch implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    private List<Adjudication_Report__c> adjudicationReports;
    public EI_ZD_DocuSignPublicLinksBatch(list<Adjudication_Report__c> adjReportRec)
    {
        adjudicationReports = new list<Adjudication_Report__c>();
        this.adjudicationReports = adjReportRec;
    }
    
    global list<Adjudication_Report__c> start(Database.BatchableContext BC){
        return adjudicationReports;
    }
    global void execute(Database.BatchableContext BC, list<Adjudication_Report__c> AdjRecords){
        // genrate AccessToken To make call Out to Docusign for Public Url
        string AccessToken = getAccessToken();
        
        // process data back to store in salesforce with public Docusing url
        ProcessPublicLink(AccessToken,AdjRecords);        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    public string  getAccessToken()
    {
        string AccessToken;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        SpringCM_Settings__c mhc = SpringCM_Settings__c.getInstance();
        string client_secret =  mhc.API_User_Client_Secret__c;
        string client_id =  mhc.API_User_Client_Id__c;
        string EndpointUrl =  mhc.Auth_Endpoint__c;
        Http http = new Http();
        req.setEndpoint(EndpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        string Data='{"client_secret":'+'"'+client_secret+'"'+',"client_id":'+'"'+client_id+'"'+'}';
        req.setBody(Data);
        HTTPResponse httpResponse = new Http().send(req);
        if(httpResponse.getstatusCode() == 200 && httpResponse.getbody() != null){
            Object Response = (Object) JSON.deserializeUntyped(httpResponse.getBody());
            Map<String, Object> payment = (Map<String, Object>)Response;
            AccessToken = string.valueOf(payment.get('access_token'));
        }
        return AccessToken;
    }
    
    Public void ProcessPublicLink(string AccessToken,list<Adjudication_Report__c> adjReportRec){
        String Data;
        String PublicUrl;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        SpringCM_Settings__c mhc = SpringCM_Settings__c.getInstance();
        string client_secret =  mhc.API_User_Client_Secret__c;
        string client_id =  mhc.API_User_Client_Id__c;
        string EndpointUrl =  mhc.Sharelinks_Endpoint__c;
        Http http = new Http();
        req.setEndpoint(EndpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'bearer ' + AccessToken);
        
        
        // public url will be expire after 5 day for created date
        // string Data='{"PreviewBehavior":"DownloadPdf",'+'"ExpirationDate":'+'"'+system.now().AddDays(5)+'",'+'"Document":{"Href":"'+adjReportRec[0].Adjudication_Report_URL__c+'"},"AllowPdfDownload":true'+'}';
        system.debug('line-->64');
        if(adjReportRec[0].Case_Record_Type__c =='Dispute SDS Custodial'){
            system.debug('line-->66');
         Data='{"PreviewBehavior":"DownloadPdf",'+'	"ExpirationDate":'+'"'+system.now().AddDays(10)+'",'+'"Document":{"Href":"'+adjReportRec[0].Adjudication_Report_URL__c+'"},"AllowPdfDownload":true'+'}';   
        } 
        else{
            system.debug('line-->70');
         Data='{"PreviewBehavior":"DownloadPdf",'+'"ExpirationDate":'+'"'+system.now().AddDays(5)+'",'+'"Document":{"Href":"'+adjReportRec[0].Adjudication_Report_URL__c+'"},"AllowPdfDownload":true'+'}';
        }
        req.setBody(Data);
        HTTPResponse httpResponse = new Http().send(req);
        if(httpResponse.getstatusCode() == 201 && httpResponse.getbody() != null){
            Object Response = (Object) JSON.deserializeUntyped(httpResponse.getBody());
            Map<String, Object> payment = (Map<String, Object>)Response;
            PublicUrl = string.valueOf(payment.get('Url'));
        }
        if(PublicUrl !='')
        {
            Adjudication_Report__c adj = new Adjudication_Report__c(id=adjReportRec[0].id,Webhook_Report_Link__c =PublicUrl);
            database.update(adj);
        }
        
    }
    
}