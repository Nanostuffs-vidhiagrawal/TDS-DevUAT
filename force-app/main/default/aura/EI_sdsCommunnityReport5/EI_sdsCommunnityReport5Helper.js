({
	convertArrayOfObjectsToCSV : function(component,objectRecords,typeofFile){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
       // columnDivider = ',';
        if(typeofFile == 'csv'){
            columnDivider = ',';
        }     
        
        lineDivider =  '\n';
        
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['Deposit_Account_Number__c','Property_Address__c','Deposit_Amount__c','Amount_paid_to_tenant__c','Amount_paid_to_Landlord__c','Member_s_Own_Deposit_Reference__c','Status__c'];
         keys2 = ['DAN','Tenancy address','Deposit amount','Amount to tenant(s)','Amount to agent/landlord'];
        
        csvStringResult = '';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;
        
      
        // outer main for loop close 
        for(var i=0; i< objectRecords.length; i++){
        
        var dan = objectRecords[i].dan;
        dan = dan.replaceAll(',',' ');
        console.log('dan'+ dan);
        
        var address = objectRecords[i].address;
        address = address.replaceAll(',',' ');
        console.log('address '+ address);        
        
        var depamount = objectRecords[i].depamount;
       // depamount = depamount.replaceAll(',',' ');
         console.log('depamount '+ depamount);
            
        var amttenant = objectRecords[i].amttenant;
       // amttenant = amttenant.replaceAll(',',' ');
        console.log('amttenant '+ amttenant);      
             
        var amtagll = objectRecords[i].amtagll;
        //amtagll = repaymentrequest.replaceAll(',',' ');
         console.log('amtagll '+ amtagll);     
        
       /* var intpaystatus = objectRecords[i].intpaystatus;
        intpaystatus = intpaystatus.replaceAll(',',' ');    
         console.log('intpaystatus '+ intpaystatus);
       
        var intstatus = objectRecords[i].intstatus;
        intpaystatus = intpaystatus.replaceAll(',',' ');    
         console.log('intpaystatus '+ intpaystatus);*/
            
                       
        csvStringResult += dan + columnDivider;     
        csvStringResult += address + columnDivider;      
        csvStringResult += depamount + columnDivider;     
        csvStringResult += amttenant + columnDivider;     
        csvStringResult += amtagll + columnDivider;
       //	csvStringResult += intpaystatus + columnDivider; 
		//csvStringResult += intstatus + columnDivider; 
            
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