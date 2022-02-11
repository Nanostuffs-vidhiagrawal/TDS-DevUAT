/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Error logging framework for storing apex logs in custom object Error Logs
 *
 * @when 25/11/2019
 */
public with sharing class FC_ErrorLogger {
    private static List<Error_Log_Event__e> errorLogEvents = new List<Error_Log_Event__e>();
    private static String className, methodName, stackTrace, recordId;
    private static String DEBUG='Debug',WARN='Warning',INFO='Info',ERROR='Error';
    private static Integer startMethodCounter = 0;

    /**
     * Crate error log with different severities
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void debug(Object obj) { createLog(obj,DEBUG);}
    /**
     * Crate error log with DEBUG severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void warn (Object obj) { createLog(obj,WARN);}
    /**
     * Crate error log with INFO severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void info (Object obj) { createLog(obj,INFO);}
    /**
     * Crate error log with ERROR severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void error(Object obj) { createLog(obj,ERROR);}
    /**
     * Crate error log with different severities with recordId
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void debug(Object obj, Id inputrecordId) { recordId = inputrecordId; createLog(obj,DEBUG); }
    /**
     * Crate error log with DEBUG severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void warn (Object obj, Id inputrecordId) { recordId = inputrecordId; createLog(obj,WARN); }
    /**
     * Crate error log with INFO severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void info (Object obj, Id inputrecordId) { recordId = inputrecordId; createLog(obj,INFO); }
    /**
     * Crate error log with ERROR severity
     *
     * @param obj Any object type can be provided here
     */
    @AuraEnabled
    public static void error(Object obj, Id inputrecordId) { recordId = inputrecordId; createLog(obj,ERROR);}

    /**
     * Use start method to start()) storing Error Logs in a buffer, use stop() to insert the logs
     */
    public static void start() {
        startMethodCounter++;
    }
    /**
     * Use start method to start()) storing Error Logs in a buffer, use stop() to insert the logs
     * 
     * @param inputClassName Use if you want to specify the method name
     * @param inputMethodName Use if you want to specify the class name
     */
    public static void start(String inputClassName, String inputMethodName) {
        start();
        setClassName(inputClassName);
        setMethodName(inputMethodName);
    }
    /**
     * Log events created by services
     *
     * @param logEvents
     */
    public static void publishLogs(List<Error_Log_Event__e> logEvents) {
        errorLogEvents.addAll(logEvents);
        publishLogs();
    }
    /**
     * Use to insert the logs into DB if number of starts equals number of stops
     */
    public static void stop() {
        startMethodCounter--;
        publishLogs();
    }
    /**
     * Allows the programmer to force sending the logs into DB, even if the transaction is not properly finished.
     *
     * @param forceDML
     */
    public static void stop(Boolean forceDML) {
        if(forceDML) {
            startMethodCounter = 0;
            publishLogs();
        }
        else {
            stop();
        }
    }
    /**
     * Use to set the class name for the following logs
     *
     * @param inputClassName
     */
    public static void setClassName(String inputClassName) {
        className = inputClassName;
    }
    /**
     * Use to set the method name for the following logs
     *
     * @param inputMethodName
     */
    public static void setMethodName(String inputMethodName) {
        methodName = inputMethodName;
    }
    /**
     * Parses the stacktrace to calling classname and recordname
     *
     * @param stackTrace
     */
    private static void parseStackTrace(String stackTrace) {
        String classNameStackTrace;
        if(stackTrace.contains('Class')) {
            classNameStackTrace = stackTrace.substringAfter('Class.').substringBefore('.');
            setClassName(classNameStackTrace);
        }
        if(String.isNotBlank(classNameStackTrace)) {
            setMethodName(stackTrace.substringAfter(classNameStackTrace + '.').substringBefore(':'));
        }
    }
    /**
     * Common method for creating and sending the error log event to bus 
     *
     * @param obj
     * @param severity
     */
    private static void createLog(Object obj, String severity) {
        Error_Log_Event__e errorLogEvent = new Error_Log_Event__e();
        errorLogEvent.Severity__c = severity;

        if(obj != null) {
            if (obj instanceof Exception) {
                errorLogEvent = parseException(errorLogEvent, (Exception) obj);
            }
            else if (obj instanceof HttpResponse) {
                errorLogEvent = parseHttpResponse(errorLogEvent, (HttpResponse) obj);
            }
            else {
                errorLogEvent.put('Message__c',String.valueOf(obj).left(131072));
            }
        }
        errorLogEvent.SObject_ID__c = recordId;
        errorLogEvent.Class_Name__c = className != null ? className.left(255) : '';
        errorLogEvent.Method_Name__c = methodName != null ? methodName.left(255) : '';
        errorLogEvents.add(errorLogEvent);
        publishLogs();
    }
    /**
     * Parse excetion to error log
     *
     * @param errorLogEvent
     * @param exc
     *
     * @return
     */
    private static Error_Log_Event__e parseException(Error_Log_Event__e errorLogEvent, Exception exc) {
        parseStackTrace(exc.getStackTraceString());
        if (exc instanceof DmlException && recordId == null) {
            DmlException dmlException = (DmlException) exc;
            recordId = dmlException.getDmlId(0);
        }

        errorLogEvent.Message__c = exc.getMessage().left(131072);
        errorLogEvent.StackTrace__c = exc.getStackTraceString().left(131072);
        return errorLogEvent;
    }
    /**
     * Parse HTTPResponse
     *
     * @param errorLogEvent
     * @param httpResponse
     *
     * @return
     */
    private static Error_Log_Event__e parseHttpResponse(Error_Log_Event__e errorLogEvent, HttpResponse httpResponse) {
        errorLogEvent.Message__c = httpResponse.getStatusCode() + ' - ' + httpResponse.getBody().left(131072);
        errorLogEvent.HttpStatusCode__c = httpResponse.getStatusCode();
        return errorLogEvent;
    }
    /**
     * Method publishes the logs into database
     */
    private static void publishLogs() {
        if(startMethodCounter <= 0 && !errorLogEvents.isEmpty()) {
            EventBus.publish(errorLogEvents);
            errorLogEvents = new List<Error_Log_Event__e>();
            className = null;
            methodName = null;
            stackTrace = null;
            startMethodCounter = 0;
        }
    }
    
}