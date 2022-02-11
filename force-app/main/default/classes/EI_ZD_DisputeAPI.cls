@RestResource(urlMapping='/disputeapi')
global class EI_ZD_DisputeAPI {
    
    @HttpPost
    global static void postMethod() {
        RestResponse res = RestContext.response;
       // res.addHeader(FC_Constant.HEADER_CONTENT_TYPE,FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
        res.addHeader('Content-Type','application/json');
        Map<String,String> headersMap =RestContext.request.headers;
        try {
            EI_RestAuthenticationUtility utility = new EI_RestAuthenticationUtility();
            utility.validateHeader(headersMap);
            string returnvalue = utility.validatePayloadexecute(RestContext.request.requestBody.toString());
            string accesscode= returnvalue.split('-')[0];
            string ZdReferenceNumber  = returnvalue.split('-')[1];
            res.statusCode = 201;
            string secureLink=System.Label.Azure_SecureLink+accesscode;
          //  string secureLink='https://staging-thedisputeservice.cs122.force.com/zd/s/agllhome?id='+accesscode;
            res.responseBody = Blob.valueOf(JSON.serialize(new successResponse(secureLink,ZdReferenceNumber)));
        }
        catch(FC_DisputeAPI_Exception exc) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(exc.getMessage())));
            res.statusCode = exc.statusCode;
        }
    }
    /**
* Error response class
*/
    public class ErrorResponse extends FC_DisputeAPI_Base.Response {
        public Boolean success;
        public String errors;
        
        public ErrorResponse(String errors) {
            this.success = false;
            this.errors = errors;
        }
    }
    public class successResponse extends FC_DisputeAPI_Base.Response {
        public Boolean success;
        public String secureLink;
        public String referenceID;
        
        public successResponse(String SecureLink,string ReferenceID ) {
            this.success = true;
            this.secureLink = SecureLink;
            this.referenceID = ReferenceID;
        }
    }
    
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
    
    public static Date calculateWorkingDaysBetweenTwoDates1(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay1(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    public static boolean checkifItisWorkingDay1(Date currentDate, List<Holiday> holidays)
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