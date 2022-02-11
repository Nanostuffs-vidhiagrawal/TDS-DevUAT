/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Exception handling for Dispute API. Covers all the possible status codes to be returned through API 
 *
 * @when 09/12/2019
 */
public abstract class FC_DisputeAPI_Exception extends Exception {
    //workaround for empty stack trace string that become empty after 09.01.2020 17.50GMT
    {
        if(super.getCause() == null) {
            try {
                Integer a = 1 / 0;
            }
            catch(Exception e) {
                super.initCause(e);
            }
        }
    }
    public Integer statusCode;
    /**
     * Headers and Authorization Exceptions
     */
    public class AuthenticationException    extends FC_DisputeAPI_Exception {{ this.statusCode = 400;}}
    public class AuthorizationException     extends FC_DisputeAPI_Exception {{ this.statusCode = 401;}}
    public class TimestampTooOldException   extends FC_DisputeAPI_Exception {{ this.statusCode = 401;}}
    public class ForbiddenException         extends FC_DisputeAPI_Exception {{ this.statusCode = 403;}}
    public class AcceptException            extends FC_DisputeAPI_Exception {{ this.statusCode = 406;}}
    public class ContentTypeException       extends FC_DisputeAPI_Exception {{ this.statusCode = 415;}}
    /**
     * Payload Exceptions
     */
    public class JSONException              extends FC_DisputeAPI_Exception {{ this.statusCode = 400;}}
    public class DuplicatedExtIdException   extends FC_DisputeAPI_Exception {{ this.statusCode = 409;}}
    public class PayloadException           extends FC_DisputeAPI_Exception {{ this.statusCode = 200;}}
    public class MissingParamException      extends FC_DisputeAPI_Exception {{ this.statusCode = 400;}}
    public class InvalidStatusException     extends FC_DisputeAPI_Exception {{ this.statusCode = 400;}}
    public class CaseNotFoundException      extends FC_DisputeAPI_Exception {{ this.statusCode = 404;}}
    public class TenantDuplicatedExtIdException   extends FC_DisputeAPI_Exception {{ this.statusCode = 400;}}
    /**
     * Internal Exceptions
     */
    public class InternalException          extends FC_DisputeAPI_Exception {{ this.statusCode = 500;}}

    /**
     * workaround for empty stack trace string that become empty after 09.01.2020 17.50GMT
     *
     * @return
     */
    public override String getStackTraceString() {
        Exception causeException = super.getCause();
        if(causeException != null) {
            String customExceptionPrefix = 'Class.FC_DisputeAPI_Exception.<init>: line 12, column 1';
            if(causeException.getStackTraceString().startsWith(customExceptionPrefix)) {
                return causeException.getStackTraceString().substringAfter(customExceptionPrefix);
            }
            else {
                return causeException.getStackTraceString();
            }
        }
        else {
            return super.getStackTraceString();
        }
    }
    /*
     * 
     * 
     * testclass only 
     * 
     */
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
}