public without sharing class EI_PICertificateToAzure {
    
    public static String storageKey;
    public static String storageName;
    public static String storageContainer;
    public static String storageUrl;
    public static String blobName;
    public static String requestURL;
    public static String fileLength;
    public static String formattedDate ;
    public static String timeStamp;
    public static String fileType;
    public static String fileName;
    
    //  private final static String INDIVIDUAL_OWNER_ID;
    //  private final static String CORPORATE_OWNER_ID;
    public final static string DATEFORMAT = 'EEE, dd MMM yyyy HH:mm:ss z';
    public final  static string VERSION = '2015-12-11';
    public final  static string BLOB_TYPE = 'BlockBlob';
    
    public EI_PICertificateToAzure(){
      
    }
    
    @future(callout=true)
    public static void savePICertificate(String depoId) {
        System.debug('depoId='+depoId);
        List<Deposit__c> depList = [select id,PI_Certificate_Link__c,Name,Customer__r.Name,Property_Address__c,Customer__r.Email__c,Customer__r.PersonEmail from Deposit__c where id=:depoId];
        System.debug('ListSize='+depList.size());
        PageReference pdf = new PageReference('/apex/EI_PrescribedInformationNew');
     pdf.getParameters().put('id',depList[0].Id);
     Blob bodyAsBlob;                
    // try {
        	bodyAsBlob = pdf.getContentAsPDF();
            Datetime dt = Datetime.now();
            timeStamp = String.valueOf(dt.getTime());
            formattedDate = dt.formatGMT(DATEFORMAT);
            string PIName = 'PI-'+timestamp+'-'+depList[0].Id+'.pdf';
        
        	boolean result = uploadBlob(bodyAsBlob,bodyAsBlob.size(),'application/pdf', PIName);
             if(result == true) {
              // save this.requestURL code goes here
               system.debug(' result ='+result);
              // call mailjet
              string PICertificateBase64 = EncodingUtil.base64Encode(bodyAsBlob);
        	  system.debug('File64='+PICertificateBase64);
             // sendDpccertificateMail(depo, PICertificateBase64);
              // call Save link to org
              savePIAzureLink(depList[0]);
                 
             }
        
         	
   /* }catch(Exception e) {
         system.debug('Unknown Exception '+e);
    }*/
                   
    }

   /* public  static void sendDpccertificateMail(Deposit__c depo, string PICertificateBase64) {
        
       system.debug(':::::Check dpcCertificateMail::::::'+PICertificateBase64);
       system.debug('::RecordType='+depo.Customer__r.RecordTypeId);
       string DAN = depo.Name;
       string username  = depo.Customer__r.Name;
       string Address = depo.Property_Address__c;
       string userpersonemail = depo.Customer__r.PersonEmail;
       string userbusinessmail = depo.Customer__r.Email__c;
       string INDIVIDUAL_OWNER_ID;
       string CORPORATE_OWNER_ID;

        
        
         string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        
         INDIVIDUAL_OWNER_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
         CORPORATE_OWNER_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Corporate Landlord').getRecordTypeId();
        
         if(depo.Customer__r.RecordTypeId == CORPORATE_OWNER_ID){
             system.debug('corporate='+depo.Customer__r.RecordTypeId+'OwnerId='+CORPORATE_OWNER_ID);
             gen.writeStringField('Email', userbusinessmail);
             system.debug('mail='+userbusinessmail);
         }
        
             if(depo.Customer__r.RecordTypeId == INDIVIDUAL_OWNER_ID){
                  system.debug('individual='+depo.Customer__r.RecordTypeId+'OwnerId='+INDIVIDUAL_OWNER_ID);
                  system.debug('::mail='+userpersonemail);
             gen.writeStringField('Email', userpersonemail);
                
             
            
        }
       
        system.debug('::Name='+username);
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 3100398);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'DPC Certificate');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
         system.debug('::name='+username);
        gen.writeStringField('name', username);
        
         system.debug('::DAN='+DAN);
        gen.writeStringField('DAN', DAN);
        
         system.debug('::Address='+Address);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
       system.debug('var='+PICertificateBase64);
        gen.writeFieldName('Attachments');
                        
                        gen.writeStartArray();
                        gen.writeStartObject(); 
       
                            gen.writeStringField('ContentType','application/pdf' ); 
                            system.debug('::Filename='+fileName);
                            gen.writeStringField('Filename',fileName);
        					system.debug('::Base64Content='+PICertificateBase64);
                            gen.writeStringField('Base64Content', PICertificateBase64);
                        gen.writeEndObject();
                        gen.writeEndArray();   
        
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
            
    }*/ 
    
    public static void savePIAzureLink(Deposit__c depo){
        string sasTokenString = storageUrl.substringAfter('?');
        system.debug(' sasTokenString '+sasTokenString);
        depo.PI_Certificate_Link__c = requestURL+'?'+sasTokenString;
        depo.PI_Certificate_Name__c = requestURL.substringAfter('/evidence/');
        system.debug('####link=' +depo.PI_Certificate_Link__c);
        system.debug('####Name=' +  depo.PI_Certificate_Name__c);
        update depo;
    }
    
    public  static Boolean uploadBlob( Blob fileBody, Integer intFileLength, String strFileType, String strFileName)
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


    public static String getBlobSharedKey()
    {
        System.debug('getBlobSharedKey--->Start');
       
        String sharedKey;
        String signature;
        String stringToSign = 'PUT\n\n\n'+fileLength+'\n\n'+fileType+'\n\n\n\n\n\n\nx-ms-blob-type:BlockBlob\nx-ms-date:'+formattedDate+'\nx-ms-version:2015-12-11\n'+blobName;

        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        signature = EncodingUtil.base64Encode(data);
       
        sharedKey = 'SharedKey '+storageName+':' + signature;
       
        return sharedKey;
    }
    
    public static HttpRequest buildRequest(Blob fileBody, String sharedKey){
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

   public static void httpPutRequest(Blob fileBody, String sharedKey)
   {
      
 		HttpRequest  req = buildRequest(fileBody, sharedKey);
       Http http = new Http();
       HTTPResponse res = http.send(req);
       // in the response body you have your blob
       System.debug('Response Body--->'+res.getBody());
       System.debug('Status--->'+res.getStatus());
       system.debug('Data-->'+res.getStatusCode());

   }
    
    public static string  generateSASToken(string filename,string signedpermissions,string scheme)
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
    
    private static Boolean isRunningOnSandbox;
    
    public static Boolean isRunningOnSandbox() {
        if(isRunningOnSandbox == null) {
            isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        }
        return isRunningOnSandbox;
    }
    
    public static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
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
    
    
	public static String getSecureURI(String scheme){
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata(scheme);
        return isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
       
    }

}