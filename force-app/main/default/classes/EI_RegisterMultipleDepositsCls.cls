public without sharing class EI_RegisterMultipleDepositsCls {
     
    @AuraEnabled
    public static String insertNewBulkImport(Boolean isValidateOnly, String fileName, String azureFileName, String azureLink, 
                                             Integer totalTenancies, Integer totalTenants, Integer totalLandlords, Integer totalFailures, 
                                             String statusOfValidate, 
                                             String contactId, String accountID)  //, List<object> ListOfTenancies
    {
        try { 
            //system.debug('dffff => ' + ListOfTenancies);
            Bulk_Import__c bulkImp = new Bulk_Import__c(Validated_or_Imported_Date__c=System.today(), 
                                                        Is_Validated_Only__c=isValidateOnly, 
                                                        File_Name__c=fileName, 
                                                        Azure_File_Name__c = azureFileName,
                                                        Azure_File_Link__c = azureLink,
                                                        Total_tenancies__c= totalTenancies, 
                                                        Total_Tenants__c = totalTenants,
                                                        Total_Landlords__c = totalLandlords,
                                                        Total_failures__c=totalFailures, Status__c=statusOfValidate, 
                                                        Contact__c=contactId, Account__c=accountID);
            System.debug('bulkImp ' + bulkImp);
            insert bulkImp; 
        } catch(Exception e) {
            System.debug('catch apex ');
            String strError = 'The following exception has occurred: '+e.getMessage();
            System.debug('The following exception has occurred: ' + e.getMessage());
            return strError;
        }
        
        return 'Successful';
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
        Azure_Storage_Credentials_per_Scheme__mdt settings = EI_RegisterMultipleDepositsCls.getAzureMetadata(scheme);
        System.debug('Line 297 -> '+settings.Secure_URI_Sandbox__c);
        return settings.Secure_URI_Sandbox__c ;
    }
    
    @AuraEnabled
    public static List<String> getScotlandPostalCodes(String postcode){
        try {
            Schema.DescribeFieldResult fieldResult = Property__c.SDS_PropertyPostCodes__c.getDescribe();
            List<String> scotlandPostalCodes = new List<String>();
            // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pc : fieldResult.getPicklistValues())
            {
                if(pc.isActive()){
                    scotlandPostalCodes.add(pc.getValue());
                }    
            }
            return scotlandPostalCodes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void importData(String BranchId, List<object> ListOfTenancies, Boolean isValidateOnly, String FileName, Integer totalTenants, Integer totalLandlords, 
                                  String statusOfValidate, String contactId, String accountID)
    {
        System.debug('ListOfTenancies => ' + ListOfTenancies);
                            
        EI_SDS_BulkImportDepositsBatch bulkImpBatch = new EI_SDS_BulkImportDepositsBatch(BranchId, ListOfTenancies, isValidateOnly, FileName, 
                                                                                         totalTenants, totalLandlords, 
                                                                                         statusOfValidate, contactId, accountID);
        database.executeBatch(bulkImpBatch, 25);
    }
    
    @AuraEnabled
    public static String getguidanceDocument(){
        Document doc = [Select Id from Document where Name = 'BulkImportGuide' limit 1];
        return String.valueOf(doc.Id);
    }
   /* @auraenabled
    public static void runImportBatch(String fileRecords){
        Blob payload = EncodingUtil.base64Decode(fileRecords);
        system.debug('fileRecords '+payload);
     //   EI_SDS_BulkImportDepositsBatch bid = new EI_SDS_BulkImportDepositsBatch(fileRecords);
     //   database.executeBatch(bid,10);  
    }*/

}