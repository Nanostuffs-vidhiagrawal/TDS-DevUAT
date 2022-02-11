public class EI_ZD_azureSAS {
    public static  void deleteFileAzure(string fileName)
    {
        HttpRequest req = new HttpRequest();
        String endpoint = generateSASToken(fileName,'d');
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        Http http = new Http();
        HTTPResponse res = http.send(req);
    }
    
    
    public static string  generateSASToken(string filename,string signedpermissions)
    {
        string storageName = 'zdstorageaccount11';
        string storageContainer = 'zdcontainer';
        string storageKey = 'cNZQVz/4xQtrpKbHtGKJtz4Po361ljVmRsNKGamaQJ+0xuhjNWvLneIfG/iLFwjZx0rjwcr2FeOa0aFAZP3DHA==';
        string storageUrl ='https://zdstorageaccount11.blob.core.windows.net';
        Datetime sasExpiry = Datetime.now();
        sasExpiry = sasExpiry.addMinutes(15);
        Datetime sasStart = Datetime.now();
        sasStart = sasStart.addMinutes(-5);
        
        //string signedpermissions = 'd';
        String signedstart = sasStart.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedexpiry = sasExpiry.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedservice = 'b';
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
        sasToken = EncodingUtil.base64Encode(data);
        sasToken = EncodingUtil.urlEncode(sasToken, 'UTF-8');        
        String sasTokenString= '?sv=' + signedversion + '&se=' + signedexpiry +'&st='+signedstart+'&sr='+signedservice+'&sp=' + signedpermissions + '&sig=' + sasToken;
        string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+'/'+filename+sasTokenString;
        system.debug('sasURL==>>'+sasURL);
        return sasTokenString;
    }
    
    public static HTTPResponse uploadDocument( string file) {
        HTTPResponse res;
        try {
           // AzureUploadFunctionCredentialsPerScheme__mdt settings = getSettings(evidenceAttachment);
            //UploadDocumentRequest uploadDocumentRequest = new UploadDocumentRequest('TestFile','.png');

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('https://zdstorageaccount11.blob.core.windows.net/zdcontainer');
            req.setHeader('x-functions-key', 'cNZQVz/4xQtrpKbHtGKJtz4Po361ljVmRsNKGamaQJ+0xuhjNWvLneIfG/iLFwjZx0rjwcr2FeOa0aFAZP3DHA==');
            req.setBody(file);
            res = new Http().send(req);
        }
        catch(Exception exc) {
            FC_ErrorLogger.error(exc);
        }
        return res;
    }
    public class UploadDocumentRequest {
        public String fileName;
       // public String sourceContentURL;
        public String extension;
       // public String parentId;
        public String accountName;
        public String containerName;
        public String sasToken;

        public UploadDocumentRequest(/*Evidence_Attachment__c evidenceAttachment,*/String filename, string filetype/*, AzureUploadFunctionCredentialsPerScheme__mdt settings*/) {
            this.fileName = filename;
            //this.sourceContentURL = evidenceAttachment.Supplier_Location__c;
            this.extension = filetype;
           // this.parentId = evidenceAttachment.Dispute__c;
            this.accountName ='zdstorageaccount11';
            this.containerName = 'zdcontainer';
            this.sasToken = generateSASToken(filename,'w');
        }
    }
    
    
    public static string  generateSASTokenUpload(string filename,string signedpermissions)
    {
        string storageName = 'zdstorageaccount11';
        string storageContainer = 'zdcontainer';
        string storageKey = 'cNZQVz/4xQtrpKbHtGKJtz4Po361ljVmRsNKGamaQJ+0xuhjNWvLneIfG/iLFwjZx0rjwcr2FeOa0aFAZP3DHA==';
        string storageUrl ='https://zdstorageaccount11.blob.core.windows.net';
        Datetime sasExpiry = Datetime.now();
        sasExpiry = sasExpiry.addMinutes(15000);
        Datetime sasStart = Datetime.now();
        sasStart = sasStart.addMinutes(-5);
        
        //string signedpermissions = 'd';
        String signedstart = sasStart.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedexpiry = sasExpiry.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedservice = 'b';
        String canonicalizedresource = '/'+storageName+'/'+storageContainer;
        string signedidentifier = '';
        string signedIP = '';
        string signedProtocol = '';
        string signedversion = '2020-02-10';
        string rscc='';
        string rscd='';
        string rsce='';
        string rscl='';
        string rsct='';
        string signedResource ='c';
        string signedSnapshotTime ='';
        
        
        /*
        signedstart=2015-07-01T08:49Z  
signedexpiry=2015-07-02T08:49Z  
signedresource=c  
signedpermissions=w  
signedidentifier=YWJjZGVmZw==  
signedversion=2015-02-21   
		

         
        
      string  StringToSign = signedpermissions + '\n'+   
               signedstart + '\n'+  
               signedexpiry + '\n'+ 
               canonicalizedresource + '\n'+  
               storageKey + '\n'+  
               signedversion ;
        
        */
        
        
        
        
        
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
       // string abcd = EncodingUtil.urlEncode(StringToSign, 'UTF-8');
        
       // HMAC-SHA256(URL.Decode(UTF8.Encode(StringToSign)))
        string signedExpiryEncode = EncodingUtil.urlEncode(signedexpiry, 'UTF-8'); 
        string signedStartEncode = EncodingUtil.urlEncode(signedstart, 'UTF-8'); 
        String sasToken = '';
        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        sasToken = EncodingUtil.base64Encode(data);
       // sasToken = EncodingUtil.urlEncode(sasToken, 'UTF-8'); 
        String sasTokenString= '?sp='+signedpermissions+'&st='+signedstart+'&se='+signedexpiry+'&spr=https&sv='+signedversion+'&sr='+signedResource+'&sig='+sasToken;
       // String sasTokenString= '?sv=' + signedversion + '&se=' + signedexpiry +'&st='+signedstart+'&sr='+signedservice+'&sp=' + signedpermissions + '&sig=' + sasToken;
        string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+sasTokenString;
        system.debug('sasURL-->>'+sasURL);
        return sasTokenString;
    }
    
    
}