// v8 //services/apexrest/DAN/v1/collectALL/LU1 1YB/200/2021-04-13 00:00:00/Singh
// // v8 //services/apexrest/DAN/v1/collectALL/postCode/amount/startDate/surname
@RestResource(UrlMapping='/DAN/v1/collectALL/*/*/*/*')
global class DepositSearchAPI {
    
    @HttpGet
    global static ResponseClass doGet()
    {
        Map<String, Integer> mapStatusToCodes = fillCodesBasedOnStatus();
        System.debug(mapStatusToCodes);
        
        String[] uriKeys = RestContext.request.requestURI.split('/'); 
        String postCode= uriKeys.get(uriKeys.size()-4);  
        Decimal amount= Decimal.valueOf(uriKeys.get(uriKeys.size()-3));  
        
        String startDay = uriKeys.get(uriKeys.size()-2);
    //    Date startDate= parseDate(startDay); 
    //    Date endDate= parseDate(startDay); 
         String[] datecomps = startDay.split('-');
Integer monthStartDay = Integer.valueOf(datecomps[1]);
        Integer yearStartDay = Integer.valueOf(datecomps[2]);
        String surname= uriKeys.get(uriKeys.size()-1);  
        
        // earlier code was expecting postcode in the url to mandatorily have spaces. Removed that mandatory condition.
        String postCode2 ;
        if(postCode.contains('%20')){
            postCode2 = postCode.replace('%20',' ');
        }else{
            postCode2 = postCode;
        }
        
        // String postCode2 = postCode.substring(0,postCode.indexof('%201')) +' '+postCode.substring(postCode.indexof('%201')+3,postCode.length());
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');      
        // string tempInput = '%' + surname + '%';
        try{  
            system.debug('SOQL '+postCode2 +' '+ amount +' '+ monthStartDay +' '+yearStartDay+' '+ surname);     
            List<Deposit__c > tsData = [select id,Status__c  from Deposit__c where Property__r.Postal_Code__c=: postCode2 and Protected_Amount__c=: amount and  CALENDAR_MONTH(Start_Date__c) =: monthStartDay and CALENDAR_YEAR(Start_Date__c) =: yearStartDay and id in (Select Deposit__c from Deposit_Allocation__c where Deposit_Holder__r.LastName =: surname) limit 1];
            if(tsData.size()>0){
                Boolean success = (tsData[0].Status__c == 'Deposits held by scheme');
                return new ResponseClass(success+'', 'Deposit Found', tsData[0].Status__c, mapStatusToCodes.get(tsData[0].Status__c)); 
                
                
                /*if(tsData[0].Status__c == 'Deposits held by scheme')
                    return new ResponseClass('true', 'Deposit Found', tsData[0].Status__c,204); 
                else
                    return new ResponseClass('false', 'Deposit Found',tsData[0].Status__c,203);  */ 
            }else{
                
                return new ResponseClass('false', 'Deposit Not Found',null,404);    
            } 
        }
        
        
        catch (Exception e) {
            return new ResponseClass('false', 'Deposit Not Found',null,400);
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
    
    
    private static Date parseDate(String dateStr){ //dd-mm-yyyy
        //String[] datecomps = dateStr.split('-');
        String[] datecomps = dateStr.split('-');
        
        if(dateComps.size() != 3)
            throw new AuraHandledException('Wrong Date Format!');
            
        return Date.newInstance(Integer.valueOf(datecomps[2]), Integer.valueOf(datecomps[1]), Integer.valueOf(datecomps[0]));
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