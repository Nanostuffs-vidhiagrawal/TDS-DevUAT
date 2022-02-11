({
    nextLandlord: function(component, event, sObjectList, end, start, pageSize) {
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
     //    alert("Paginationlist => " + Paginationlist );
    start = start + counter;
    end = end + counter;
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
    //alert("helper PaginationLandlord => " + component.get("v.PaginationLandlordList"));
  },
     previousLandlord: function(component, event, sObjectList, end, start, pageSize) {
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
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  }, 
    
    // navigate to next pagination record set
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
    component.set("v.PaginationLandlordList", Paginationlist);
  },
  // navigate to previous pagination record set

    
    convertArrayOfObjectsToCSV : function(component,objectRecords, typeofFile){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;
       console.log('line no 86=='+objectRecords);
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible 
        if(typeofFile == 'csv'){
            columnDivider = ', ';
        }else if(typeofFile == 'xls'){
            columnDivider = '\t ';
        } 
        
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys  = ['Postal_Code__c','City__c','Property_Owner__r.Name','Landlord_Registration_Number__c','Property_Owner__r.Name','Property_Owner__r.Address__pc','Tenants_Name__c','Date_Deposit_Received__c' ];
        keys2 = ['postalcode','Address','Agent','Landlord registration number','Landlord Name','Landlord address','Tenants Name','Deposit Received Date' ];
        
        
        csvStringResult = '';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            var arr =[];
            var postcode = objectRecords[i].Postal_Code__c;
            var address = objectRecords[i].House_No__c + objectRecords[i].City__c;
            let agentName = ' ';
            console.log('line no 86=='+objectRecords[i].Property_Owner__r.RecordType.Name);
            if(objectRecords[i].Property_Owner__r.RecordType.Name =='Letting Agent' || objectRecords[i].Property_Owner__r.RecordType.Name =='Organization'){
                agentName = objectRecords[i].Property_Owner__r.Name;
            }
            
            var landlordRegNo = objectRecords[i].Landlord_Registration_Number__c;
            let landlordName = ' ';
            if(objectRecords[i].Property_Owner__r.RecordType.Name =='Individual Landlord' || objectRecords[i].Property_Owner__r.RecordType.Name =='Corporate Landlord'){
                landlordName = objectRecords[i].Property_Owner__r.Name;
            }
            var landlordAddress = objectRecords[i].Property_Owner__r.Address__pc;
            let tenantName = ' ';
            let depositRerceivedDate = ' ';
            console.log(" tenant =>" +  objectRecords[i].Deposits__r);
            console.log(" tenant 2=>" +  objectRecords[i].Deposits__r);
            if(objectRecords[i].Deposits__r && objectRecords[i].Deposits__r != 'undefined'){
                console.log(" tenant 3=>" +  objectRecords[i].Deposits__r);
                 for(let t=0; t < objectRecords[i].Deposits__r.length; t++){
                    //var tenant = objectRecords[i].Deposits__r[t];
                    console.log(" tenant 4=>" +  objectRecords[i].Deposits__r[t]);
                    if(objectRecords[i].Deposits__r[t].Tenants_Name__c != 'undefined'){
                        console.log("for tenant name =>" +  objectRecords[i].Deposits__r[t].Tenants_Name__c);
                       tenantName += objectRecords[i].Deposits__r[t].Tenants_Name__c;
                    }
                    if(objectRecords[i].Deposits__r[t].Date_Deposit_Received__c != 'undefined'){
                        console.log("for tenant date =>" + objectRecords[i].Deposits__r[t].Date_Deposit_Received__c);
                        depositRerceivedDate +=  objectRecords[i].Deposits__r[t].Date_Deposit_Received__c;  
                    }
                }
            }
            
            arr.push(postcode);
            arr.push(address);
            arr.push(agentName);
            arr.push(landlordRegNo);
            arr.push(landlordName);
            arr.push(landlordAddress);
            arr.push(tenantName);
            arr.push(depositRerceivedDate);
            
            console.log("All values => " + arr);
           // csvStringResult += ''+ postcode +','+address+','+agentName+','+landlordRegNo+','+landlordName+','+landlordAddress+','+tenantName+','+depositRerceivedDate+'';
             for(let k=0; k< arr.length; k++) {
                 console.log('line no 111'+ arr[k]);
                 
              // add,[comma] after every String value,.[except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               console.log('line no 116'+objectRecords[i]);
               csvStringResult += ''+ arr[k] +''; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
    
    
   
})