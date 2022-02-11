public without sharing class EI_PICetificateToAzureQueueable implements Queueable,Database.AllowsCallouts {

    public List<Id> depoIDListForPI = new List<Id>();
    public String storageKey;
    public String storageName;
    public String storageContainer;
    public String storageUrl;
    public String blobName;
    public String requestURL;
    public String fileLength;
    public String formattedDate ;
    public string timeStamp;
    public String fileType;
    public String fileName;
    
    //  private final static String INDIVIDUAL_OWNER_ID;
    //  private final static String CORPORATE_OWNER_ID;
    public final string DATEFORMAT = 'EEE, dd MMM yyyy HH:mm:ss z';
    public final string VERSION = '2015-12-11';
    public final string BLOB_TYPE = 'BlockBlob';
    
    public EI_PICetificateToAzureQueueable(List<Id> depoIDListForPI){
      this.depoIDListForPI = depoIDListForPI;
    }
    
    public void execute(QueueableContext QU) {
        List<Deposit__c> depositListToUpdate = new List<Deposit__c> ();
        
        for(Deposit__c deposit : [select id,PI_Certificate_Link__c, PI_Certificate_Name__c,Name,Customer__r.Name,Property_Address__c,Customer__r.Email__c,Customer__r.PersonEmail from Deposit__c where id IN :depoIDListForPI]){
            System.debug('deposit='+deposit);
            
            PageReference pdf = new PageReference('/apex/EI_PrescribedInformationNew');
            pdf.getParameters().put('id',deposit.Id);
            Blob bodyAsBlob;                
            bodyAsBlob = pdf.getContentAsPDF();
            Datetime dt = Datetime.now();
            timeStamp = String.valueOf(dt.getTime());
            formattedDate = dt.formatGMT(DATEFORMAT);
            string PIName = 'PI-'+timestamp+'-'+deposit.Id+'.pdf';
            boolean result = uploadBlob(bodyAsBlob,bodyAsBlob.size(),'application/pdf', PIName);
            if(result == true) {
                // save this.requestURL code goes here
                system.debug(' result ='+result);
                // call mailjet
                string PICertificateBase64 = EncodingUtil.base64Encode(bodyAsBlob);
                system.debug('File64='+PICertificateBase64);
                // call Save link to org
                Deposit__c depositToUpdate = savePIAzureLink(deposit); 
                depositListToUpdate.add(depositToUpdate);
            }
        }
        if(depositListToUpdate.size()>0){
            update depositListToUpdate;
        }
    }
    
    /*public void savePICertificate(String depoId) {
        System.debug('depoId='+depoId);
        List<Deposit__c> depList = [select id,PI_Certificate_Link__c,Name,Customer__r.Name,Property_Address__c,Customer__r.Email__c,Customer__r.PersonEmail from Deposit__c where id=:depoId];
        System.debug('ListSize='+depList.size());
        PageReference pdf = new PageReference('/apex/EI_PrescribedInformationNew');
        pdf.getParameters().put('id',depList[0].Id);
        Blob bodyAsBlob;                
        bodyAsBlob = pdf.getContentAsPDF();
        string PIName = depList[0].Id+'.pdf';
        boolean result = uploadBlob(bodyAsBlob,bodyAsBlob.size(),'application/pdf', PIName);
        if(result == true) {
            // save this.requestURL code goes here
            system.debug(' result ='+result);
            // call mailjet
            string PICertificateBase64 = EncodingUtil.base64Encode(bodyAsBlob);
            system.debug('File64='+PICertificateBase64);
            // call Save link to org
            savePIAzureLink(depList[0]);   
        }
        
    }*/
    
    public deposit__c savePIAzureLink(Deposit__c depo){
        string sasTokenString = storageUrl.substringAfter('?');
        system.debug(' sasTokenString '+sasTokenString);
        depo.PI_Certificate_Link__c = requestURL+'?'+sasTokenString;
        depo.PI_Certificate_Name__c = requestURL.substringAfter('/evidence/');
        system.debug('####link=' +depo.PI_Certificate_Link__c);
        return depo;
    }
    
    public Boolean uploadBlob( Blob fileBody, Integer intFileLength, String strFileType, String strFileName)
    {
        
        Boolean isUploaded= false;
        fileName = EncodingUtil.urlEncode(strFileName, 'UTF-8');
        fileType = strFileType;
        fileLength = String.valueof(intFileLength);
        requestURL = generateSASToken(fileName,'rw','SDS');
        system.debug('requestURL--->>'+ requestURL);
        String strSharedKey = getBlobSharedKey();
        try {
            httpPutRequest(fileBody, strSharedKey);
            isUploaded = true;
        } catch(Exception exp) {
            //System.debug('Exception occur while uploading the Blob-->'+exp.getMessage());
            isUploaded = false;
        }
        return isUploaded;
    }
    
    
    public String getBlobSharedKey()
    {
        System.debug('getBlobSharedKey--->Start');
        
        String sharedKey;
        String signature;
        /*Datetime dt = Datetime.now();
        timeStamp = String.valueOf(dt.getTime());
        formattedDate = dt.formatGMT(DATEFORMAT);*/
        String stringToSign = 'PUT\n\n\n'+fileLength+'\n\n'+fileType+'\n\n\n\n\n\n\nx-ms-blob-type:BlockBlob\nx-ms-date:'+formattedDate+'\nx-ms-version:2015-12-11\n'+blobName;
        
        
        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        signature = EncodingUtil.base64Encode(data);
        
        sharedKey = 'SharedKey '+storageName+':' + signature;
        
        return sharedKey;
    }
    
    public HttpRequest buildRequest(Blob fileBody, String sharedKey){
        HttpRequest req = new HttpRequest();
        
        
        req.setMethod('PUT');
        
        req.setHeader('x-ms-blob-type', BLOB_TYPE);
        req.setHeader('x-ms-version', VERSION);
        req.setHeader('x-ms-date', formattedDate);
        req.setHeader('Authorization', sharedKey);
        req.setHeader('Content-Type', fileType);
        req.setHeader('Content-Length', fileLength);
        
        req.setEndpoint(requestURL);
        
        req.setBodyAsBlob(fileBody);
        return req;
        
        
    }
    
    public void httpPutRequest(Blob fileBody, String sharedKey)
    {
        
        HttpRequest  req = buildRequest(fileBody, sharedKey);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        // in the response body you have your blob
        System.debug('Response Body--->'+res.getBody());
        System.debug('Status--->'+res.getStatus());
        system.debug('Data-->'+res.getStatusCode());
        
    }
    
    public string  generateSASToken(string filename,string signedpermissions,string scheme)
    {
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata(scheme);
        storageName = isRunningOnSandbox() ? settings.Account_Name_Sandbox__c : settings.Account_Name_Production__c;
        storageContainer = isRunningOnSandbox() ? settings.Container_Name_Sandbox__c : settings.Container_Name_Production__c;
        storageKey = isRunningOnSandbox() ? settings.Storage_Key_Sandbox__c : settings.Storage_Key_Production__c;
        storageUrl = isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        blobName = '/'+storageName+'/'+storageContainer+'/'+fileName;
        
        Datetime sasExpiry = Datetime.now();
        sasExpiry = sasExpiry.addMinutes(15);
        Datetime sasStart = Datetime.now();
        sasStart = sasStart.addMinutes(-5);
        
        //string signedpermissions = 'd';
        String signedstart = sasStart.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        //string signedexpiry = sasExpiry.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedexpiry ='2031-09-02T15:44:13Z';
        system.debug(' signedexpiry '+signedexpiry);
        string signedservice = 'c';
        String canonicalizedresource = '/blob/'+storageName+'/'+storageContainer+'/'+filename;
        string signedidentifier = '';
        string signedIP = '';
        string signedProtocol = '';
        string signedversion = '2020-08-04';
        string rscc='';
        string rscd='';
        string rsce='';
        string rscl='';
        string rsct='';
        string signedResource ='b';
        string signedSnapshotTime ='';
        
        string stringToSign = signedpermissions + '\n' +  
            signedstart + '\n' +  
            signedexpiry + '\n' +  
            canonicalizedResource + '\n' +  
            signedIdentifier + '\n' +  
            signedIP + '\n' +  
            signedProtocol + '\n' +  
            signedVersion + '\n' +  
            signedResource + '\n' +
            signedSnapshotTime + '\n' +
            rscc + '\n' +  
            rscd + '\n' +  
            rsce + '\n' +  
            rscl + '\n' +  
            rsct;
        string signedExpiryEncode = EncodingUtil.urlEncode(signedexpiry, 'UTF-8'); 
        string signedStartEncode = EncodingUtil.urlEncode(signedstart, 'UTF-8'); 
        String sasToken = '';
        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        system.debug(':::::data--->'+data);
        sasToken = EncodingUtil.base64Encode(data);
        system.debug(':::::sasToken--->'+sasToken);
        sasToken = EncodingUtil.urlEncode(sasToken, 'UTF-8'); 
        system.debug(':::::sasToken1--->'+data);
        String sasTokenString= '?sv=' + signedversion + '&se=' + signedexpiry +'&st='+signedstart+'&sr='+signedservice+'&sp=' + signedpermissions + '&sig=' + sasToken+ '&spr=https';
        
        
        //string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+'/'+filename+'?'+sasTokenString;
        string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+'/'+filename;
        system.debug('sasURL==>>'+sasURL);
        return sasURL;
    }
    
    private Boolean isRunningOnSandbox;
    
    public Boolean isRunningOnSandbox() {
        if(isRunningOnSandbox == null) {
            isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        }
        return isRunningOnSandbox;
    }
    
    public Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
        Azure_Storage_Credentials_per_Scheme__mdt settings;
        try {
            settings = [
                SELECT Account_Name_Production__c,
                Account_Name_Sandbox__c,
                Container_Name_Production__c,
                Container_Name_Sandbox__c,
                Endpoint_Production__c,
                Endpoint_Sandbox__c,
                Secure_URI_Production__c,
                Secure_URI_Sandbox__c,
                Storage_Key_Production__c,
                Storage_Key_Sandbox__c
                FROM Azure_Storage_Credentials_per_Scheme__mdt
                WHERE Label = :scheme
            ];
        }
        catch(QueryException exc) {
            //throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ');
        }
        return settings;
    }
    
    
    public String getSecureURI(String scheme){
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata(scheme);
        return isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        
    }
}