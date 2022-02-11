public class EI_ViewBulkImportLogsCls {

     @AuraEnabled
    public static list <Bulk_Import__c> fetchBulkImports(Id contactId, Id accountID){      
        List <Bulk_Import__c> returnBIList = new List <Bulk_Import__c>();        
        for(Bulk_Import__c BI: [SELECT Validated_or_Imported_Date__c, Is_Validated_Only__c, File_Name__c, Status__c, 
                                Total_tenancies__c, Total_Tenants__c, Total_Landlords__c, Total_failures__c, 
                                Azure_File_Link__c, Azure_File_Name__c, Contact__c, Account__c 
                                From Bulk_Import__c WHERE Contact__c =: contactId and Azure_File_Name__c != '']) 
        {
            returnBIList.add(BI);
        }
        return returnBIList;
    }
    
     @AuraEnabled
    public static list <Bulk_Import__c> fetchFilteredBulkImports(Id contactId, Id accountID, String status){      
        List <Bulk_Import__c> returnBIList = new List <Bulk_Import__c>();        
        for(Bulk_Import__c BI: [SELECT Validated_or_Imported_Date__c, Is_Validated_Only__c, File_Name__c, Status__c, 
                                Total_tenancies__c, Total_Tenants__c, Total_Landlords__c, Total_failures__c, 
                                Azure_File_Link__c, Azure_File_Name__c, Contact__c, Account__c 
                                From Bulk_Import__c WHERE Contact__c =: contactId and Status__c =:status and Azure_File_Name__c != '']) 
        {
            returnBIList.add(BI);
        }
        return returnBIList;
    }
}