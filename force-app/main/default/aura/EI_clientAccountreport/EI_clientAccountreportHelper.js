({
	convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Deposit_Account_Number__c','Property_Address__c','Date_Paid_to_Landlord__c','Start_Date__c','Date_Received_by_Scheme__c','End_Date__c','Tenants_Name__c','Deposit_Amount__c','Member_s_Own_Deposit_Reference__c','Protected_Amount__c','Case_Status__c','Amount_paid_to_tenant__c','Amount_paid_to_Landlord__c' ];
        //keys = ['Deposit Account Number','Property Address','Deposit Amount','Scheme__r','Landlord' ];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                console.log('++++++skey++++++'+skey)
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }                
                //csvStringResult += '"'+ objectRecords[i][skey]+'"';                 
                //counter++;
                if(typeof objectRecords[i][skey]==='object' &&  skey==='Scheme__r'){
                    if(objectRecords[i][skey].Name != undefined){
                        csvStringResult+='"'+objectRecords[i][skey].Name+'"'; 
                    }else{
                        csvStringResult += '"'+ '' +'"';
                    }
                    counter ++;
                }
                else if(typeof objectRecords[i][skey]==='object' &&  skey==='Customer__r'){
                    if(objectRecords[i][skey].Name != undefined){
                        csvStringResult+='"'+objectRecords[i][skey].Name+'"'; 
                    }else{
                        csvStringResult += '"'+ '' +'"';
                    }                    
                    counter ++;
                }
                else{
                    if(objectRecords[i][skey] != undefined){
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }else{
                        csvStringResult += '"'+ '' +'"';
                    }
                    counter++;
                }
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    }
})