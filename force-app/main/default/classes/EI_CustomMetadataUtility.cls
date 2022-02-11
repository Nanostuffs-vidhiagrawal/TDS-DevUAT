/**
* @who  Ashish Singh
* @what Query Custom Metadata 
* @when 01/02/2021
**/
public class EI_CustomMetadataUtility {
    
    /**
* Query all the custom metadata
**/     
    public static List<API_Service__mdt> metaDataList(String metaDataLabel){
        List<API_Service__mdt> metaDataList = [SELECT EndPoint_URL__c, Username__c, Password__c, From_Name__c, From_Address__c,
                                               Template_Id__c, Scheme_Signatory__c, Scheme_Address__c,Scheme_Bank_Account_Number__c,
                                               Scheme_Sort_Code__c,Scheme_Bank_Name__c
                                               FROM API_Service__mdt 
                                               WHERE QualifiedApiName=:metaDataLabel];
        return metaDataList;
    }
}