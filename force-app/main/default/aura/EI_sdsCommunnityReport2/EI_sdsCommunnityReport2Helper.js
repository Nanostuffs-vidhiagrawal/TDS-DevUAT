({
	convertArrayOfObjectsToCSV : function(component,objectRecords,typeofFile){
        
        var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;
        console.log('line no 86=='+JSON.stringify(objectRecords)); 
        
        if (objectRecords == null || objectRecords.length <= 0) {
            return null;
        }
        
       
        if(typeofFile == 'csv'){
            columnDivider = ',';
        }  
      
        lineDivider =  '\n';        
         
       // keys = ['Deposit_Account_Number__c','Property_Address__c','Deposit_Amount__c','Amount_paid_to_tenant__c','Amount_paid_to_Landlord__c','Status__c' ];
        
        keys2=['DAN','Tenancy address','Repaid reason','Deposit amount','Amount to tenant(s)','Amount to agent/landlord'];
        
        csvStringResult = ' ';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;         
        
    
        // return the CSV formate String 
        for(var i=0; i< objectRecords.length; i++){
            
            var dan = objectRecords[i].dan;
            dan = dan.replaceAll(',',' ');      
            
            var address = objectRecords[i].address;
            address = address.replaceAll(',',' ');
            
             var repaidreason = objectRecords[i].repaidreason;
       		 repaidreason = repaidreason.replaceAll(',',' ');
         	console.log('repaidreason '+ repaidreason);
            
            var depamount = objectRecords[i].depamount;  
            var amttenant = objectRecords[i].amttenant;             
            var amtagll = objectRecords[i].amtagll;     
            
            
            
            csvStringResult += dan + columnDivider;     
            csvStringResult += address + columnDivider;
            csvStringResult += repaidreason + columnDivider; 
            csvStringResult += depamount + columnDivider;
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