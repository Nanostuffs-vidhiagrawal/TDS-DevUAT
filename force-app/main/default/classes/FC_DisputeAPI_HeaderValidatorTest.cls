/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_HeaderValidator
 *
 * @when 18/12/2019
 */
@IsTest
public with sharing class FC_DisputeAPI_HeaderValidatorTest {

    @IsTest
    private static void test_successful_validation() {
        Map<String,String> headerMap = new Map<String, String>();
        headerMap.put('accessToken','test');

        new FC_DisputeAPI_HeaderValidator(headerMap).validateHeader();
        System.assert(true, 'No exceptions occured');
    }

    @IsTest
    private static void test_noAccessToken() {
        Map<String,String> headerMap = new Map<String, String>();

        try {
            new FC_DisputeAPI_HeaderValidator(headerMap).validateHeader();
            System.assert(false);
        }
        catch(Exception e) {
            System.assertEquals('No accessToken provided.', e.getMessage());
        }
    }
    
    @IsTest
    private static void test_wrongContentType() {
        Map<String,String> headerMap = new Map<String, String>();
        headerMap.put('content-type',FC_Constant.CONTENT_TYPE_APPLICATION_XML);

        try {
            new FC_DisputeAPI_HeaderValidator(headerMap).validateHeader();
            System.assert(false);
        }
        catch(Exception e) {
            System.assertEquals('Content Type not supported: application/xml', e.getMessage());
        }
    }

    @IsTest
    private static void test_wrongAccess() {
        Map<String,String> headerMap = new Map<String, String>();
        headerMap.put('accept',FC_Constant.CONTENT_TYPE_APPLICATION_XML);

        try {
            new FC_DisputeAPI_HeaderValidator(headerMap).validateHeader();
            System.assert(false);
        }
        catch(Exception e) {
            System.assertEquals('Accept not supported: application/xml', e.getMessage());
        }
    }
}