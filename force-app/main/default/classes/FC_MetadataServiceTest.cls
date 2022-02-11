/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what FC_Metadata API web service mock class 
 *
 * @when 14/01/2020
 */
@IsTest
public with sharing class FC_MetadataServiceTest {
    /**
     * Dummy Metadata API web service mock class
     **/
    public class WebServiceMockImpl implements WebServiceMock {
        @SuppressWarnings('PMD')
        public void doInvoke(
                Object stub, Object request, Map<String, Object> response,
                String endpoint, String soapAction, String requestName,
                String responseNS, String responseName, String responseType)
        {
            response.put('response_x', new FC_MetadataService.upsertMetadataResponse_element());
        }
    }
    
    @IsTest
    private static void coverGeneratedCodeTypes() {
        new FC_MetadataService.upsertMetadata_element();
        new FC_MetadataService.upsertMetadataResponse_element();
        new FC_MetadataService.UpsertResult();
        new FC_MetadataService.Error();
        new FC_MetadataService.ExtendedErrorDetails();
        new FC_MetadataService.DebuggingHeader_element();
        new FC_MetadataService.LogInfo();
        new FC_MetadataService.Metadata();
        new FC_MetadataService.SessionHeader_element();
        new FC_MetadataService.DebuggingInfo_element();
        new FC_MetadataService.CallOptions_element();
        new FC_MetadataService.RemoteSiteSetting();
        System.assert(true);
    }

    @IsTest
    private static void coverGeneratedOperations() {
        System.Test.setMock(WebServiceMock.class, new FC_MetadataServiceTest.WebServiceMockImpl());
        Test.startTest();
        FC_MetadataService.MetadataPort metaDataPort = new FC_MetadataService.MetadataPort();
        metaDataPort.upsertMetadata(null);
        Test.stopTest();
        System.assert(true);
    }

}