// v8 //services/apexrest/Dan/v1/collect/DAN0000044
@RestResource(UrlMapping='/Dan/v1/collect/*')
global class DanCollectRestAPI {
    
    @HttpGet
    global static ResponseClass doGet()
    {
        Map<String, Integer> mapStatusToCodes = fillCodesBasedOnStatus();
        
        String[] uriKeys = RestContext.request.requestURI.split('/'); 
        String Dan= uriKeys.get(uriKeys.size()-1);  
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');      
        
        try{  
            
            List<Deposit__c > tsData = [select id,Status__c from Deposit__c where Deposit_Account_Number__c = : Dan limit 1];
            if(tsData.size()>0){
                Boolean success = (tsData[0].Status__c == 'Deposits held by scheme');
                return new ResponseClass(success+'', 'Deposit Found', tsData[0].Status__c, mapStatusToCodes.get(tsData[0].Status__c)); 
                
                /*if(tsData[0].Status__c == 'Deposits held by scheme')
                    return new ResponseClass('true', 'Deposit Found', tsData[0].Status__c,204); 
                else
                    return new ResponseClass('false', 'Deposit Found',tsData[0].Status__c,203);*/    
            }
            else{
                return new ResponseClass('false', 'Deposit Not Found',null,404);    
            }
        }
        
        catch (Exception e) {
            return new ResponseClass('false', 'DAN Not Found',null,400);
        }  
    }
    
    global class ResponseClass 
    {
        
        global String success;
        global String message;
        global Integer statusCode;
        global String Status;
        
        global ResponseClass(String success, String message,String Status, Integer StatusCode) 
        {
            this.success = success;
            this.message = message;
            this.status = Status;
            this.statusCode = StatusCode;
            
        }
        //statusCode
        //404 -- Dan not found
        //400 -- SF Exception	
        //204 -- Deposits held by scheme	
        //203 -- DAN found, status
    }
    
     
    public static Map<String,Integer> fillCodesBasedOnStatus(){
        Map<String,Integer> mapCodes = new Map<String,Integer>();
        Integer code = 203;
        for(String pickVal : getPickListValuesIntoList()){
            mapCodes.put(pickVal, code++);
        }
        
        return mapCodes;
    }
    public static List<String> getPickListValuesIntoList(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Deposit__c.status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
		return pickListValuesList;
    }
}