({
	convertArrayOfObjectsToCSV : function(component,objectRecords,typeofFile){
       
       
        var csvStringResult, counter, keys, columnDivider,lineDivider,keys2;        
       
        if (objectRecords == null || objectRecords.length<=0) {
             alert("download CSV" + objectRecords.length);
            return null;
        }  
        
        if(typeofFile == 'csv'){
            columnDivider = ',';
        }  
        //columnDivider = ',';
        lineDivider =  '\n';
        
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
       // keys = ['Deposit_Account_Number__c','Property_Address__c','Date_Paid_to_Landlord__c','Start_Date__c','Date_Received_by_Scheme__c','End_Date__c','Tenants_Name__c','Deposit_Amount__c','Member_s_Own_Deposit_Reference__c','Protected_Amount__c','Case_Status__c','Amount_paid_to_tenant__c','Amount_paid_to_Landlord__c' ];
        
       keys2 =['DAN','Tenancy address','Deposit protection start date','Deposit protection end date','Repaid reason','Deposit Amount','Amount request by agent/landlord','Amount to tenant(s)','Amount to agent/landlord'];
        
        csvStringResult = '';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;
        
    //console.log(JSON.stringify(objectRecords));
         for(var i=0; i< objectRecords.length; i++){
        
        var dan = objectRecords[i].dan;
        dan = dan.replaceAll(',',' ');
        //console.log('dan'+ dan);
        
        var address = objectRecords[i].address;
        address = address.replaceAll(',',' ');
        //console.log('address '+ address);
        
        var startdate = objectRecords[i].startdate;
        startdate = startdate.replaceAll(',',' ');
        //console.log('startdate '+ startdate);
        
        var enddate = objectRecords[i].enddate;
        enddate = enddate.replaceAll(',',' ');
        //console.log('enddate '+ enddate);
       
        var repaidreason = objectRecords[i].repaidreason;
        repaidreason = repaidreason.replaceAll(',',' ');
         //console.log('repaidreason '+ repaidreason);
             
        var depamount = objectRecords[i].depamount;      
        //console.log('depamount '+ depamount); 
             
		var repaymentrequest = objectRecords[i].repaymentrequest;
        repaymentrequest = repaymentrequest.replaceAll(',',' ');
         //console.log('repaymentrequest '+ repaymentrequest);     
        
        var amttenant = objectRecords[i].amttenant;      
        //console.log('amttenant '+ amttenant);      
             
        var amtagll = objectRecords[i].amtagll;       
         //console.log('amtagll '+ amtagll);        
             
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