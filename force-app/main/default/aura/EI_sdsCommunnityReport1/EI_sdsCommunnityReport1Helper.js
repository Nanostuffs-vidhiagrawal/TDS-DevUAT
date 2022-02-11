({
	convertArrayOfObjectsToCSV : function(component,objectRecords,typeofFile){   
              
         var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;       
        if (objectRecords == null || objectRecords.length <= 0) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        if(typeofFile == 'csv'){
            columnDivider = ',';
        }       
        lineDivider = '\n';        
        
         
        //keys=['Deposit_Account_Number__c','Property_Address__c','Protection_Start_Date__c','End_Date__c','Deposit_repaid_reason_status__c','Deposit_Amount__c','Repayment_Requests__r.Total_Amount_Requested_AL__c','Case_Status__c'];
      
        keys2 =['DAN','Tenancy address','Deposit protection start date','Deposit protection end date','Repaid reason','Deposit amount','Amount request by agent/landlord','Amount to tenant(s)','Amount to agent/landlord'];
        
        csvStringResult = ' ';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;        
   
         for(var i=0; i< objectRecords.length; i++){
        
        var dan = objectRecords[i].dan;
        dan = dan.replaceAll(',',' ');
        console.log('dan'+ dan);
        
        var address = objectRecords[i].address;
        address = address.replaceAll(',',' ');
        console.log('address '+ address);
        
        var startdate = objectRecords[i].startdate;
        startdate = startdate.replaceAll(',',' ');
        console.log('startdate '+ startdate);
        
        var enddate = objectRecords[i].enddate;
        enddate = enddate.replaceAll(',',' ');
        console.log('enddate '+ enddate);
       
        var repaidreason = objectRecords[i].repaidreason;
        repaidreason = repaidreason.replaceAll(',',' ');
         console.log('repaidreason '+ repaidreason);
             
        var depamount = objectRecords[i].depamount;
       // depamount = depamount.replaceAll(',',' ');
         console.log('depamount '+ depamount); 
             
		var repaymentrequest = objectRecords[i].repaymentrequest;
        repaymentrequest = repaymentrequest.replaceAll(',',' ');
         console.log('repaymentrequest '+ repaymentrequest);     
        
        var amttenant = objectRecords[i].amttenant;
       // amttenant = amttenant.replaceAll(',',' ');
        console.log('amttenant '+ amttenant);      
             
        var amtagll = objectRecords[i].amtagll;
        //amtagll = repaymentrequest.replaceAll(',',' ');
         console.log('amtagll '+ amtagll);   
             
        csvStringResult += dan + columnDivider;     
        csvStringResult += address + columnDivider;     
        csvStringResult += startdate + columnDivider;     
        csvStringResult += enddate + columnDivider;     
        csvStringResult += repaidreason + columnDivider;     
        csvStringResult += depamount + columnDivider;  
        csvStringResult += repaymentrequest + columnDivider;    
        csvStringResult += amttenant + columnDivider;     
        csvStringResult += amtagll + columnDivider;
                   
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