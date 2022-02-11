public without sharing class EI_SDS_EvidenceUploadToAzure {
    
    /*@AuraEnabled
public static Attachment getProfilePicture(Id parentId) {

return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
ORDER BY LastModifiedDate DESC LIMIT 1];
}

@AuraEnabled
public static String getSessionId() {
String sessionId = getUserSessionId();
return sessionId;
}

public static String getUserSessionId(){
String sessionId = '';
// Refer to the Page
PageReference reportPage = Page.getSessionId;
// Get the content of the VF page
String vfContent = reportPage.getContent().toString();
System.debug('vfContent '+vfContent);
// Find the position of Start_Of_Session_Id and End_Of_Session_Id
Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
endP = vfContent.indexOf('End_Of_Session_Id');
// Get the Session Id
sessionId = vfContent.substring(startP, endP);
System.debug('sessionId '+sessionId);
// Return Session Id
return sessionId;
}*/
    
    @AuraEnabled
    public static Evidence_Attachment__c saveFile(Id parentId,string disputeId,string fileName,string azureLink,string userType,string fileType,
                                                  string fileSize, String fileLable,string evidenceCategories,
                                                  string fileNameInAzure,String source,String scheme)
    {
        Id EvidattachId = Schema.SObjectType.Evidence_Attachment__c.getRecordTypeInfosByName().get('SDS Evidence Attachment').getRecordTypeId();
        Evidence_Attachment__c recordToInsert = new Evidence_Attachment__c(Dispute__c =parentId,Recordtypeid =EvidattachId,Dispute_Item__c=(disputeId !='') ? disputeId :null,
                                                                           Filename__c =fileName,Thumbnail_Location__c='<a href="'+azureLink+'">'+azureLink+'</a>',
                                                                           User_Type__c=userType,Location__c=azureLink,
                                                                           File_Size__c=decimal.valueOf(fileSize),File_Type__c=fileType,
                                                                           Source__c=source,isUploaded__c=true,
                                                                           File_Description__c=fileLable,
                                                                           Evidence_Categories__c=evidenceCategories,
                                                                           Azure_File_Name__c =fileNameInAzure,
                                                                           created_date_external__c=System.now(),
                                                                           Scheme__c=scheme);
        insert recordToInsert;
        if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
           evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
        {
            case caseToUpdate;
            if(evidenceCategories=='Tenant obligations')
            {
                caseToUpdate  = new case(id =parentId,Tenant_obligations__c='Yes');
            }
            if(evidenceCategories=='Inventorycheck in report')
            {
                caseToUpdate  = new case(id =parentId,inventorycheck_in_report_AGLL__c='Yes');
            }
            if(evidenceCategories=='Check out report')
            {
                caseToUpdate  = new case(id =parentId,check_out_report_AGLL__c='Yes');
            }
            if(evidenceCategories=='Rent statement')
            {
                caseToUpdate  = new case(id =parentId,Rent_statement_AGLL__c='Yes');
            }
            update caseToUpdate;
            
        }
        
        
        /* Attachment attachment = new Attachment();
attachment.parentId = parentId;
attachment.body = EncodingUtil.base64Decode(base64Data);
attachment.name = fileName;
attachment.contentType = contentType;
insert attachment;
*/
        return recordToInsert;
        
        
        /*      String sessionId = getUserSessionId();
system.debug('ssss '+sessionId);
system.debug('UserInfo.getSessionID() '+UserInfo.getSessionID());
String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
string endpointuls = sfdcURL + '/services/data/v39.0/sobjects/Attachment';
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(endpointuls);
request.setMethod('POST');
request.setHeader('Content-Type', 'application/json;charset=UTF-8');
request.setHeader('Authorization', 'Bearer ' + sessionId);  


JSONGenerator gen = JSON.createGenerator(true);    
gen.writeStartObject();      
gen.writeStringField('parentId', parentId);
gen.writeBlobField('body',EncodingUtil.base64Decode(base64Data));
gen.writeStringField('name',fileName);
gen.writeStringField('contentType',contentType);
gen.writeEndObject();    

String jsonS = gen.getAsString();

Attachment attachment = new Attachment();
attachment.parentId = parentId;
attachment.body = EncodingUtil.base64Decode(base64Data);
attachment.name = fileName;
attachment.contentType = contentType;*/
        // String contentBody = string.valueOf(attachment);
        //system.debug('attachment '+attachment);
        // system.debug('contentBody '+contentBody);
        // Set the body as a JSON object
        /* request.setBody(jsonS);
// request.setBody('{"name":'+fileName+',"parentId":'+parentId+',"body":'+EncodingUtil.base64Decode(base64Data)+',"contentType":'+contentType+'}');
HttpResponse response = http.send(request);
// Parse the JSON response
if (response.getStatusCode() != 201) {
System.debug('The status code returned was not expected: ' +
response.getStatusCode() + ' ' + response.getStatus());
return JSON.serializePretty( JSON.deserializeUntyped(response.getBody()) );
} else {
System.debug(response.getBody());
return response.getBody();
} 
*/        
        
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        /*ContentVersion contentVersion = new ContentVersion(
versionData = EncodingUtil.base64Decode(base64Data),
title = fileName,
ContentLocation = 'S',
FirstPublishLocationId = parentId,
pathOnClient =  fileName); 	
insert contentVersion;
return contentVersion.id;
Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;


ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = contentDocId;
cdl.ShareType = 'I';
cdl.LinkedEntityId=parentId;
cdl.Visibility = 'AllUsers';
insert cdl;
return cdl.id; */
    }
    
    /* @AuraEnabled
public static void deleteFiles(Id recordId) {
Attachment getAttachment = [SELECT Id, Name FROM Attachment WHERE id=:recordId limit 1]; 
delete getAttachment;
}*/
    
    @AuraEnabled
    public static  void deleteFileAzure(string fileNameInAzure,string RecordId,string evidenceCategories,string claimId,string scheme)
    {
        HttpRequest req = new HttpRequest();
        String endpoint = generateSASToken(fileNameInAzure,'d',scheme);
        system.debug('endpoint--->>'+endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        Http http = new Http();
        if(!test.isRunningTest())
            HTTPResponse res = http.send(req);
        
        // Evidence_Attachment__c EA = [select id, Evidence_Categories__c,Dispute__c from Evidence_Attachment__c where id=:RecordId limit 1];
        if(evidenceCategories =='Tenant obligations' || evidenceCategories =='Inventorycheck in report'||
           evidenceCategories =='Check out report'|| evidenceCategories =='Rent statement')
        {
            case caseToUpdate;
            
            if(evidenceCategories=='Tenant obligations')
            {
                caseToUpdate  = new case(id =claimId,Tenant_obligations__c='');
            }
            if(evidenceCategories=='Inventorycheck in report')
            {
                caseToUpdate  = new case(id =claimId,inventorycheck_in_report_AGLL__c='');
            }
            if(evidenceCategories=='Check out report')
            {
                caseToUpdate  = new case(id =claimId,check_out_report_AGLL__c='');
            }
            if(evidenceCategories=='Rent statement')
            {
                caseToUpdate  = new case(id =claimId,Rent_statement_AGLL__c='');
            }
            update caseToUpdate;
        }
        Database.delete(RecordId); 
        
    }
    
    
    public static string  generateSASToken(string filename,string signedpermissions,string scheme)
    {
        Azure_Storage_Credentials_per_Scheme__mdt settings = EI_SDS_EvidenceUploadToAzure.getAzureMetadata(scheme);
        //string storageName = 'zdstoragetest';
        string storageName = EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Account_Name_Sandbox__c : settings.Account_Name_Production__c;
        //string storageContainer = 'agll';
        string storageContainer = EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Container_Name_Sandbox__c : settings.Container_Name_Production__c;
        //string storageKey = '0mBPl+vHVElpuWjuvycD4lcun8MM78MRZ2Hop8GOZeoXxE7Us14cXPFEvvX4m8mh91aKuPd0Bx7LNlTFVpdhZw==';
        string storageKey = EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Storage_Key_Sandbox__c : settings.Storage_Key_Production__c;
        //string storageUrl ='https://zdstoragetest.blob.core.windows.net';
        string storageUrl =EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Endpoint_Sandbox__c : settings.Endpoint_Production__c;
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
        return sasURL;
    }
    
    private static Boolean isRunningOnSandbox;
    
    public static Boolean isRunningOnSandbox() {
        if(isRunningOnSandbox == null) {
            isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        }
        return isRunningOnSandbox;
    }
    
    private static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
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
    
    @AuraEnabled
    public static String getSecureURI(String scheme){
        System.debug('Line 296 -> '+scheme);
        Azure_Storage_Credentials_per_Scheme__mdt settings = EI_SDS_EvidenceUploadToAzure.getAzureMetadata(scheme);
        System.debug('Line 297 -> '+(EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c));
        return EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getPicklistvalues(String objectName, String category_apiname,String userType_apiname){
        List<String> catOptionList = new List<String>(); 
        List<String> usrOptionList = new List<String>(); 
        Map<String,list<string>> finalResult = new Map<String,list<string>>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> catPicklistValues = field_map.get(category_apiname).getDescribe().getPickListValues();
        List<Schema.PicklistEntry> usrPicklistValues = field_map.get(userType_apiname).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry cpv : catPicklistValues) {
            catOptionList.add(cpv.getValue());
        }         
        for (Schema.PicklistEntry upv : usrPicklistValues) {
            usrOptionList.add(upv.getValue());
        }
        
        finalResult.put('category', catOptionList);
        finalResult.put('userType', usrOptionList);
        return finalResult;
    }
    
    public list<Evidence_Attachment__c> AzureUrl{get; set;}
    public list<Evidence_Attachment__c> AzureUrl2 {get; set;}
    public list<Evidence_Attachment__c> AzureUrl3 {get; set;}
    public Boolean showAgent {get; set;}
    public Boolean showLandlord {get; set;}
    public Boolean showTenant {get; set;}
    
    public void fetchAzureLink(){
        string recId = ApexPages.CurrentPage().getParameters().get('id');
        AzureUrl = new list<Evidence_Attachment__c>();
        AzureUrl2 = new list<Evidence_Attachment__c>();
        AzureUrl3 = new list<Evidence_Attachment__c>();
        //system.debug('Line 325 recId -> '+recId);
        //string type = ApexPages.CurrentPage().getParameters().get('type');
        //system.debug('Line 327 type -> '+type);
        /*if(type=='evidenceAttach'){
AzureUrl = [select id,Location__c,Filename__c from Evidence_Attachment__c where id=:recId limit 1];
}
if(type=='case'){*/
        //AzureUrl = [select id,Location__c,Filename__c, Azure_File_Name__c from Evidence_Attachment__c where Dispute__c=:recId AND User_Type__c = 'Agent'];
        //AzureUrl2 = [select id,Location__c,Filename__c, Azure_File_Name__c from Evidence_Attachment__c where Dispute__c=:recId AND User_Type__c = 'Landlord'];
        //AzureUrl3 = [select id,Location__c,Filename__c, Azure_File_Name__c from Evidence_Attachment__c where Dispute__c=:recId AND User_Type__c = 'Tenant'];
        
        for(Evidence_Attachment__c att : [select id,Location__c,File_Size__c,User_Type__c,Filename__c, Azure_File_Name__c from Evidence_Attachment__c where Dispute__c=:recId]){
            if(att.User_Type__c == 'Tenant'){
                AzureUrl3.add(att);
            }else if(att.User_Type__c == 'Landlord'){
                AzureUrl2.add(att);
            }else{
                AzureUrl.add(att);
            }
        }
        system.debug('>>>>>>AzureUrl  '+JSON.serializePretty(AzureUrl));
        system.debug('>>>>>>AzureUrl2  '+JSON.serializePretty(AzureUrl2));
        system.debug('>>>>>>AzureUrl3  '+JSON.serializePretty(AzureUrl3));
        if(AzureUrl != null && !AzureUrl.isEmpty()){
            showAgent = true;
        }
        if(AzureUrl2 != null && !AzureUrl2.isEmpty()){
            showLandlord = true;
        }
        if(AzureUrl3 != null && !AzureUrl3.isEmpty()){
            showTenant = true;
        }
        //}
    }
    
    
    @AuraEnabled
    public static String getDisputeItem(String recordId, String catName){
        return [select id,name from Dispute_Item__c where Dispute__c=:recordId and Type__c=:catName limit 1].id;
    }
    
}