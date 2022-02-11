/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests of Spring CM Share Links service  
 *
 * @when 28/01/2020
 */
@IsTest
public class FC_SpringCMShareLinksTest {
    @TestSetup
    static void setup() {
        FC_TestFactory.createSObject(new SpringCM_Settings__c(), 'FC_TestFactoryDefaults.SpringCMSettingsDefaults', true);
    }
    
    @IsTest
    static void testSuccessRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.ShareLinksSuccessMock());

        FC_SpringCMShareLinks.ShareLinksResponse springCMResponse = (FC_SpringCMShareLinks.ShareLinksResponse)
                new FC_SpringCMShareLinks('https://test.com',null).sendRequest();
        Test.stopTest();

        System.assertEquals('https://test.com', springCMResponse.Href);
        System.assertEquals('true', springCMResponse.AllowPdfDownload);
        System.assertEquals(FC_SpringCMShareLinks.PREVIEW_BEHAVIOR_DOWNLOADPDF, springCMResponse.PreviewBehavior);
        System.assertEquals('test@test.com', springCMResponse.UpdatedBy);    
    }

    @IsTest
    static void testErrorRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.ShareLinksErrorMock());

        FC_SpringCMShareLinks.ShareLinksErrorResponse springCMResponse = (FC_SpringCMShareLinks.ShareLinksErrorResponse)
                new FC_SpringCMShareLinks('https://test.com',null).sendRequest();
        Test.stopTest();

        System.assertEquals('Could not authenticate', springCMResponse.error.DeveloperMessage);
    }
}