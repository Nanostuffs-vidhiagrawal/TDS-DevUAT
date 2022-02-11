@isTest
public class EI_ZD_DisputeAPI_Exception_test {
    class MyException extends FC_DisputeAPI_Exception {
        public override String getMessage() {
            return null;
        }
    }
     @IsTest static void testGetErrorMessageWrapped() {
        Exception testException;

        try {
            try {
                insert new Contact();
            } catch (Exception e) {
                throw new MyException(e);
            }
        } catch (MyException e) {
            testException = e;
        }
     }
@istest
    public static void testMethod1(){
        Test.startTest();
        new FC_DisputeAPI_Exception.AuthenticationException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.AuthorizationException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.TimestampTooOldException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.ForbiddenException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.AcceptException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.ContentTypeException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.JSONException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.DuplicatedExtIdException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.PayloadException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.MissingParamException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.InvalidStatusException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.CaseNotFoundException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.TenantDuplicatedExtIdException('abc' +' Object does not Match with the Requested Object ');
        new FC_DisputeAPI_Exception.InternalException('abc' +' Object does not Match with the Requested Object ');
        FC_DisputeAPI_Exception.calculateWorkingDaysBetweenTwoDates(system.today(),5);
        Test.stopTest();

    }
}