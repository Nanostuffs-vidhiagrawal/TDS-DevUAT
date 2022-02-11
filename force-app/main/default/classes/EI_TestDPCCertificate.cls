@isTest
public class EI_TestDPCCertificate {
    
    @isTest
    public static void method1(){ 
        Account a = new account();
        a.Name='swaTI AHIRKAR';
        // a.PersonEmail ='raamkapoor@gmail.com';
        a.Email__c ='raamcooler@yahoo.com';
        //a.PersonEmail ='raamcooler@yahoo.com';
        a.RecordTypeId='0124J0000001E9B';   	//'0124J000000I8KB';
        insert a;
        
        Property__c p = new Property__c();
        p.House_No__c='35';
        p.City__c='nagpur';
        p.Postal_Code__c ='45322';
        p.Country__c='india';
        p.County__c ='jila';
        p.Street__c='frdghj';
        p.Property_Owner__c= a.id;
        insert p;
        
        Scheme__c s = new Scheme__c();
        s.Region__c = 'Scotland';
        s.Deposit_Account_Number_Prefix__c = 'Test Pre';
        insert s;
        
        Deposit__c d = new Deposit__c();
        //d.Name='DAN000270';
        d.Customer__c = a.id;
        d.Deposit_Amount__c= 300;
        d.Scheme__c= s.id;
        d.Property__c = p.id;
        insert d;
        List<Deposit__c> depoList = [Select Id, Name, Customer__r.Name, Customer__r.RecordTypeId, Customer__r.PersonEmail,Deposit__c.Protected_Amount__c, Property_Address__c, 
                                     Customer__r.Email__c from Deposit__c where Id=:d.Id limit 1];
        // EI_DPCCertificate.saveDpcCertificate(d);
        
        String testString='test string';
        Blob myBlob=blob.valueOf(testString);
        //Blob pdfContent = getContentAsPDF(myBlob);
        string dpcCertificateBase64 = EncodingUtil.base64Encode(myBlob);
        
		EI_DPCCertificate.fileName='test.pdf';   
        EI_DPCCertificate.generateSASToken('XYZ','rw','SDS');
        EI_DPCCertificate.getAzureMetadata('SDS');
        EI_DPCCertificate.uploadBlob(myBlob,60,'pdf','test.pdf');
         String strSharedKey  = EI_DPCCertificate.getBlobSharedKey();
        //EI_DPCCertificate.sendDpccertificateMail(depoList[0],'JVBERi0xLjQKJeLjz9MKMiAwIG9iaiA8PC9Db2xvclNwYWNlWy9JbmRleGVkL0RldmljZVJHQiAyNTUo////');
    	EI_DPCCertificate.sendDpccertificateMail(depoList[0],dpcCertificateBase64);
        
       // EI_DPCCertificate.httpPutRequest(myBlob,strSharedKey);
    }
}