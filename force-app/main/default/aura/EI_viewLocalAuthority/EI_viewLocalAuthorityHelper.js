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
         //    alert("Paginationlist => " +Paginationlist);
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
 
    
    convertArrayOfObjectsToCSV : function(component,objectRecords, typeofFile){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider,keys2;
       //console.log('line no 86=='+objectRecords);        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
            //console.log('line no 55=='+objectRecords);
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible 
        if(typeofFile == 'csv'){
            columnDivider = ',';
        }else if(typeofFile == 'xls'){
            columnDivider = '\t';
        }         
        lineDivider =  '\n';
        
         //console.log('line no 65=='+objectRecords);
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys  = ['Postal_Code__c','City__c','Property_Owner__r.Name','Landlord_Registration_Number__c','Property_Owner__r.Name','Property_Owner__r.Address__pc','Tenants_Name__c','Date_Deposit_Received__c' ];
        keys2 = ['Property postcode','Address','Agent','Landlord registration number','Landlord name','Landlord address','Tenants name','Deposit received date' ];
                
        csvStringResult = ' ';
        csvStringResult += keys2.join(columnDivider);
        csvStringResult += lineDivider;
 
       /* for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            var arr =[];            
            
            var postcode = objectRecords[i].Postal_Code__c != undefined ? objectRecords[i].Postal_Code__c : " ";
            postcode = postcode.replaceAll(',',' ');
            
            var address1 = objectRecords[i].House_No__c != undefined ? objectRecords[i].House_No__c:"";
            var address2 = objectRecords[i].City__c != undefined ? objectRecords[i].City__c:"";
            //var address = objectRecords[i].House_No__c + objectRecords[i].City__c != undefined ? objectRecords[i].House_No__c + objectRecords[i].City__c:""; 
            var address = address1 + address2 ;
            address = address.replaceAll(',',' ');
            
            let agentName = ' '; 
            console.log('line no 86=='+objectRecords[i].Property_Owner__r.RecordType.Name);
            if(objectRecords[i].Property_Owner__r.RecordType.Name =='Letting Agent' || objectRecords[i].Property_Owner__r.RecordType.Name =='Organization'){
                agentName = objectRecords[i].Property_Owner__r.Name;
                agentName = agentName.replaceAll(',',' ');
            }            
            var landlordRegNo = objectRecords[i].Landlord_Registration_Number__c != undefined ? objectRecords[i].Landlord_Registration_Number__c :  "";
            landlordRegNo = landlordRegNo.replaceAll(',',' ');
            
            let landlordName = ' ';
            if(objectRecords[i].Property_Owner__r.RecordType.Name =='Individual Landlord' || objectRecords[i].Property_Owner__r.RecordType.Name =='Corporate Landlord'){
                landlordName = objectRecords[i].Property_Owner__r.Name;
                landlordName = landlordName.replaceAll(',',' ');
            }
               console.log("property owner 91=>" +JSON.stringify(objectRecords[i].Property_Owner__r.Address__pc));
             var tempAddress = objectRecords[i].Property_Owner__r.Address__pc != undefined ? objectRecords[i].Property_Owner__r.Address__pc : "";
            console.log("tempAddress =>" + tempAddress.replaceAll('\n',' '));
            var landlordAddress = tempAddress.replaceAll('\n',' ');
            
            let tenantName = ' ';
            let depositRerceivedDate = ' ';            
          //  console.log(" tenant =>" +  objectRecords[i].Deposits__r);
            //console.log(" tenant 2=>" +  objectRecords[i].Deposits__r);
            
            if(objectRecords[i].Deposits__r && objectRecords[i].Deposits__r != 'undefined'){
                //console.log(" tenant 3=>" +  objectRecords[i].Deposits__r);
                 for(let t=0; t < objectRecords[i].Deposits__r.length; t++){
                    //var tenant = objectRecords[i].Deposits__r[t];
                    console.log(" tenant 4=>" +  objectRecords[i].Deposits__r[t]);
                    if(objectRecords[i].Deposits__r[t].Tenants_Name__c != 'undefined'){
                       // console.log("for tenant name =>" +  objectRecords[i].Deposits__r[t].Tenants_Name__c);
                       tenantName += objectRecords[i].Deposits__r[t].Tenants_Name__c != undefined ? objectRecords[i].Deposits__r[t].Tenants_Name__c : " ";
                        tenantName = tenantName.replaceAll(',',' '); 
                    }
                    if(objectRecords[i].Deposits__r[t].Date_Deposit_Received__c != 'undefined'){
                        console.log("for tenant date =>" + objectRecords[i].Deposits__r[t].Date_Deposit_Received__c);
                        depositRerceivedDate +=  objectRecords[i].Deposits__r[t].Date_Deposit_Received__c != undefined ? objectRecords[i].Deposits__r[t].Date_Deposit_Received__c : " "; 
                        depositRerceivedDate = depositRerceivedDate.replaceAll(',',' ');
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
            
			csvStringResult += postcode + columnDivider;     
            csvStringResult += address + columnDivider;     
            csvStringResult += agentName + columnDivider;     
            csvStringResult += landlordRegNo + columnDivider;     
            csvStringResult += landlordName + columnDivider;     
            csvStringResult += landlordAddress + columnDivider;     
            csvStringResult += tenantName + columnDivider;     
            csvStringResult += depositRerceivedDate + columnDivider;     
            
            console.log("All values => " + arr);
           // csvStringResult += ''+ postcode +','+address+','+agentName+','+landlordRegNo+','+landlordName+','+landlordAddress+','+tenantName+','+depositRerceivedDate+'';
             for(let k=0; k< arr.length; k++) {
                 console.log('line no 111'+ arr[k]);
                 
              // add,[comma] after every String value,.[except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               console.log('line no 116'+objectRecords[i]);
               csvStringResult += ' ' + arr[k] + ' '; 
                 counter++;
 
            } // inner for loop close 
            
             //csvStringResult += lineDivider;
         // } */
    // outer main for loop close 
     
    for(var i=0; i< objectRecords.length; i++){
        
        var postcode = objectRecords[i].postcode;
        postcode = postcode.replaceAll(',',' ');
        //console.log('postcode'+ postcode);
        
        var address = objectRecords[i].address;
        address = address.replaceAll(',',' ');
        //console.log('address '+ address);
        
        var agentName = objectRecords[i].agentName;
        agentName = agentName.replaceAll(',',' ');
        //console.log('agentName '+ agentName);
        
        var landlordRegNo = objectRecords[i].landlordRegNo;
        landlordRegNo = landlordRegNo.replaceAll(',',' ');
        //console.log('landlordRegNo '+ landlordRegNo);
        
        console.log('objectRecords[i].landlordName '+ objectRecords[i].landlordName);
        var landlordName = objectRecords[i].landlordName;
        landlordName = landlordName.replaceAll(',',' ');
        //console.log('landlordName '+ landlordName);
        
        console.log('objectRecords[i].landlordAddress '+ objectRecords[i].landlordAddress);
        var landlordAddress = objectRecords[i].landlordAddress;
        landlordAddress = landlordAddress.replaceAll(',',' ') ;
         landlordAddress = landlordAddress.replaceAll('\n',' ') ;
        console.log('landlordAddress '+JSON.stringify(landlordAddress));
        
        console.log('objectRecords[i].tenantName '+ objectRecords[i].tenantName);
         var tenantName = objectRecords[i].tenantName;
        tenantName = tenantName.replaceAll(',',' ');
        //console.log('tenantName '+ tenantName);
        
        //console.log('objectRecords[i].depositRerceivedDate '+ objectRecords[i].depositRerceivedDate);
        var depositRerceivedDate = objectRecords[i].depositRerceivedDate;
         console.log('line no 204 '+ objectRecords[i].depositRerceivedDate);
        depositRerceivedDate = depositRerceivedDate.replaceAll(',',' ');
        console.log('line no 206 '+ objectRecords[i].depositRerceivedDate);
       
        
       /* var now = objectRecords[i].depositRerceivedDate; 
        console.log('now '+ now);
       	var nowSlited = [];
        nowSlited = now.split('=');
        console.log('nowSlited '+ nowSlited + nowSlited.length);
        console.log('nowSlited[i] '+ nowSlited[1]);
        var dateString = "";
        for(var i = 0; i< nowSlited.length; i++){
            console.log('nowSlited[i] '+ nowSlited[i]);
            if(nowSlited[i] != ""){
                dateString +=  " " + nowSlited[i].toString("DD-MM-yyyy");
            }
        }
        //var dateString =  now.toString("DD-MM-yyyy"); //moment(now).format('YYYY-MM-DD');
        console.log('dateString '+ dateString);*/
        
        
        csvStringResult += postcode + columnDivider;     
        csvStringResult += address + columnDivider;     
        csvStringResult += agentName + columnDivider;     
        csvStringResult += landlordRegNo + columnDivider;     
        csvStringResult += landlordName + columnDivider;     
        csvStringResult += landlordAddress + columnDivider;     
        csvStringResult += tenantName + columnDivider;     
        csvStringResult += depositRerceivedDate + columnDivider;        
         csvStringResult += lineDivider;
}
    
       // return the CSV formate String 
        return csvStringResult;        
    }
    
    
   
})