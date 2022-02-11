@isTest
public class EI_DPCCertificateTest {
	
    @isTest
    public static void method1(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c = property.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;      
        deposit.Deposit_Amount_Amend__c = true;
        deposit.Deposit_Certificate_Link__c = 'https://sdsevidencedev.blob.core.windows.net/evidence/a0L3H000000ZSVNUA4.pdf?sp=rw&st=2021-06-18T15:27:12Z&se=2031-06-18T23:27:12Z&spr=https&sv=2020-02-10&sr=c&sig=ny8xLiSPlms%2FpN%2FtAIYuJaJI7VNQBqc9eqL7V%2BlrQLs%3D';
        insert deposit;
        
        List<Deposit__c> depoList = [Select Id, Name, Customer__r.Name, Customer__r.RecordTypeId, Customer__r.PersonEmail,Deposit__c.Protected_Amount__c, Property_Address__c, 
                                     Customer__r.Email__c from Deposit__c where Id=:deposit.Id limit 1];
        
         String testString='test string';
        Blob myBlob=blob.valueOf(testString);
        //Blob pdfContent = getContentAsPDF(myBlob);
        string dpcCertificateBase64 = EncodingUtil.base64Encode(myBlob);
        
		EI_DPCCertificate.fileName='test.pdf';   
        EI_DPCCertificate.generateSASToken('XYZ','rw','SDS');
        EI_DPCCertificate.getAzureMetadata('SDS');
        EI_DPCCertificate.uploadBlob(myBlob,60,'pdf','test.pdf');
        String strSharedKey  = EI_DPCCertificate.getBlobSharedKey();
        EI_DPCCertificate.saveDpcAzureLink(deposit);
        EI_DPCCertificate.getSecureURI(scheme.id);
        //EI_DPCCertificate.sendDpccertificateMail(depoList[0],'JVBERi0xLjQKJeLjz9MKMiAwIG9iaiA8PC9Db2xvclNwYWNlWy9JbmRleGVkL0RldmljZVJHQiAyNTUo////');
    	//EI_DPCCertificate.sendDpccertificateMail(depoList[0],dpcCertificateBase64);
    }
}