/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for SpringCM download document flow
 *
 * @when 20/11/2019
 */
@IsTest
private class FC_SpringCMDownloadDocumentTest {
    @IsTest
    static void testSuccessRequest() {
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.DocumentDownloadSuccessMock());

        FC_SpringCMDownloadDocument.DownloadDocumentResponse springCMResponse = (FC_SpringCMDownloadDocument.DownloadDocumentResponse) 
                new FC_SpringCMDownloadDocument('https://test.com',null).sendRequest();
        System.assertEquals(EncodingUtil.base64Encode(Blob.valueOf('testData')), springCMResponse.encodedDocumentBlob);
        System.assertEquals('test.txt', springCMResponse.fileName);
        System.assertEquals('text/plain', springCMResponse.contentType);
    }

    @IsTest
    static void testErrorRequest() {
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.DocumentDownloadErrorMock());

        FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse springCMResponse = (FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse)
                new FC_SpringCMDownloadDocument('https://test.com',null).sendRequest();
        System.assertEquals('Could not authenticate', springCMResponse.error.DeveloperMessage);
    }
}