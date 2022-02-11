({
	convertArrayOfObjectsToCSV : function(component,objectRecords,typeofFile){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;   
       
        if (objectRecords == null || objectRecords.length<=0) {
            return null;
        }       
         if(typeofFile == 'csv'){
            columnDivider = ',';
        }   
      
        lineDivider =  '\n';
        
        
        
       // keys = ['Deposit_Account_Number__c','Property_Address__c','Status__c','Protection_Start_Date__c','Deposit_Amount__c','Protected_Amount__c','Number_of_Tenants__c' ];
        //keys = ['Deposit Account Number','Property Address','Deposit Amount','Scheme__r','Landlord' ];
        keys2 =['DAN','Tenancy address','Current status','Number of days in current status','Deposit protection start date','Deposit amount','Amount protected by scheme','Number of tenants']; 
        
        csvStringResult = '';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;
        
     
       for(var i=0; i< objectRecords.length; i++){
        
        var dan = objectRecords[i].dan;
        dan = dan.replaceAll(',',' ');        
        
        var address = objectRecords[i].address;
        address = address.replaceAll(',',' ');       
                     
        var depositstatus = objectRecords[i].depositstatus;
        depositstatus = depositstatus.replaceAll(',',' ');
           
        var daystatus = objectRecords[i].daystatus;        
        var startdate = objectRecords[i].startdate;
        startdate = startdate.replaceAll(',',' ');
           
        var depamount = objectRecords[i].depamount;                     
        var depprotectedamount = objectRecords[i].depprotectedamount;                    
       var depnooftenant = objectRecords[i].depnooftenant;              
             
		     
        csvStringResult += dan + columnDivider;     
        csvStringResult += address + columnDivider;     
        csvStringResult += depositstatus + columnDivider;     
        csvStringResult += daystatus + columnDivider;     
        csvStringResult += startdate + columnDivider;     
        csvStringResult += depamount + columnDivider;  
        csvStringResult += depprotectedamount + columnDivider;    
        csvStringResult += depnooftenant + columnDivider;          
         csvStringResult += lineDivider;
}
   
        return csvStringResult;        
    },
    
    next: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
    
    
   previous: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  } 
     
        
    
})