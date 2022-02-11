/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for Error logging framework 
 *
 * @when 26/11/2019
 */
@IsTest
private class FC_ErrorLoggerTest {
    @IsTest static void testExceptionError() {
        Test.startTest();
        try {
            Integer a = 1 / 0;
        }
        catch(Exception e) {
            FC_ErrorLogger.error(e);
        }
        Test.getEventBus().deliver();
        Test.stopTest();

        Error_Log__c errorLog = [SELECT Id, Severity__c, StackTrace__c, Class_Name__c, Method_Name__c FROM Error_Log__c];
        System.assertEquals('Error', errorLog.Severity__c);
        System.assertEquals('FC_ErrorLoggerTest', errorLog.Class_Name__c);
        System.assertEquals('testExceptionError', errorLog.Method_Name__c);
        System.assertEquals(true, errorLog.StackTrace__c.startsWith('Class.FC_ErrorLoggerTest.testExceptionError:'));
    }    

    @IsTest static void testExceptionDebug() {
        Test.startTest();
        try {
            Integer a = 1 / 0;
        }
        catch(Exception e) {
            FC_ErrorLogger.debug(e);
        }
        Test.stopTest();

        Error_Log__c errorLog = [SELECT Id, Severity__c, StackTrace__c FROM Error_Log__c];
        System.assertEquals('Debug', errorLog.Severity__c);
        System.assertEquals(true, errorLog.StackTrace__c.startsWith('Class.FC_ErrorLoggerTest.testExceptionDebug:'));
    }

    @IsTest static void testExceptionInfo() {
        Test.startTest();
        try {
            Integer a = 1 / 0;
        }
        catch(Exception e) {
            FC_ErrorLogger.info(e);
        }
        Test.stopTest();

        Error_Log__c errorLog = [SELECT Id, Severity__c, StackTrace__c FROM Error_Log__c];
        System.assertEquals('Info', errorLog.Severity__c);
        System.assertEquals(true, errorLog.StackTrace__c.startsWith('Class.FC_ErrorLoggerTest.testExceptionInfo:'));
    }

    @IsTest static void testExceptionWarning() {
        Test.startTest();
        try {
            Integer a = 1 / 0;
        }
        catch(Exception e) {
            FC_ErrorLogger.warn(e);
        }
        Test.stopTest();

        Error_Log__c errorLog = [SELECT Id, Severity__c, StackTrace__c FROM Error_Log__c];
        System.assertEquals('Warning', errorLog.Severity__c);
        System.assertEquals(true, errorLog.StackTrace__c.startsWith('Class.FC_ErrorLoggerTest.testExceptionWarning:'));
    }

    @IsTest static void testDmlException() {
        Case newDispute = (Case) FC_TestFactory.createSObject(
                new Case(), 'FC_TestFactoryDefaults.CaseDefaults', true);

        Test.startTest();
        try {
            //dummy accountId
            newDispute.AccountId = '0018E00001FgJuCZZZ';
            //this should generate DML exception due to malformed accountId
            update newDispute;
        }
        catch(Exception dmle) {
            FC_ErrorLogger.error(dmle);
        }
        Test.stopTest();

        //Log might get generated for the MassmailerOrchestrationFlow - we don't want to check this log
        System.assertEquals(newDispute.Id, [SELECT SObject_ID__c FROM Error_Log__c WHERE Method_Name__c != 'runMassmailerOrchestrationFlow'].SObject_ID__c);
    }

    @IsTest static void testSeverities() {
        Test.startTest();
        FC_ErrorLogger.error('error');
        FC_ErrorLogger.warn('warn');
        FC_ErrorLogger.info('info');
        FC_ErrorLogger.debug('debug');
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Error_Log__c WHERE Message__c = 'error' AND Severity__c = 'Error']);
        System.assertEquals(1, [SELECT count() FROM Error_Log__c WHERE Message__c = 'warn' AND Severity__c = 'Warning']);
        System.assertEquals(1, [SELECT count() FROM Error_Log__c WHERE Message__c = 'info' AND Severity__c = 'Info']);
        System.assertEquals(1, [SELECT count() FROM Error_Log__c WHERE Message__c = 'debug' AND Severity__c = 'Debug']);
    }

    @IsTest static void testStartStop() {
        Test.startTest();
        FC_ErrorLogger.start('TestClass','TestMethod');
        FC_ErrorLogger.debug('test string');
        FC_ErrorLogger.debug('test string2');
        FC_ErrorLogger.stop();
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Error_Log__c]);
    }

    @IsTest static void testWithoutStartStop() {
        Test.startTest();
        FC_ErrorLogger.debug('test string');
        FC_ErrorLogger.debug('test string2');
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Error_Log__c]);
    }

    @IsTest static void testMultipleStartStop() {
        Test.startTest();
        FC_ErrorLogger.start('TestClass','TestMethod');
        FC_ErrorLogger.start();
        FC_ErrorLogger.debug('test string');
        FC_ErrorLogger.debug('test string2');
        FC_ErrorLogger.stop();
        System.assertEquals(0, [SELECT count() FROM Error_Log__c]);
        FC_ErrorLogger.stop();
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Error_Log__c]);
    }

    @IsTest static void testForceStop() {
        Test.startTest();
        FC_ErrorLogger.start('TestClass','TestMethod');
        FC_ErrorLogger.start();
        FC_ErrorLogger.debug('test string');
        FC_ErrorLogger.debug('test string2');
        FC_ErrorLogger.stop(true);
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Error_Log__c]);
    }
}