({    
    readFile: function(component, helper, file) {
        if (!file) return;
        console.log('file'+file.name);
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('only support csv files');
        } 
        else {
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+')- '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                //component.set("v.filename",file.name);
                component.set("v.TargetFileName",output);
               
            };
            reader.onload = function(e) {
                var data=e.target.result;
                component.set("v.fileContentData",data);
                console.log("file data"+JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                console.log("allTextLines -> "+allTextLines);
                var dataRows=allTextLines.length-1;
                console.log("dataRows -> "+dataRows);
                // Getting all the fields in the csv file
                var headers = allTextLines[0].split(',');
                
                // Setting the fieldNames and number of deposit rows
                component.set("v.fieldNames",headers);
                component.set("v.noOfDeposits",dataRows);
                
                console.log("headers -> "+headers);
                console.log("fieldNames -> "+component.get("v.fieldNames"));
                
                console.log("Rows length::"+dataRows)
                
                var listOfDeposits = [];
                var mapOfDeposits = new Map();
                
                // Creating the list of Object type for Deposit from the file rows
                for(var i=0;i<allTextLines.length;i++) {
                    if(i!=0) {
                        var currentDepositObj = new Object();
                        var fieldToDataMap = new Map();
                        // Pulling the data for each column of a row into a map of the 'field name' and 'row data'
                        console.log("Line 58 allTextLines -> "+allTextLines[i]);
                        var currentRowData = allTextLines[i].split(',');
                        console.log("Line 60 typeof -> "+ typeof currentRowData);
                        console.log("Line 61 allTextLines -> "+currentRowData.length);
                        for(var j=0;j<currentRowData.length; j++) {
                            //fieldToDataMap.set(headers[i], row_Data);
                            //var currentField = headers[i];
                            //currentDepositObj.currentField = row_Data;
                            console.log("Line 62 currentMap -> "+currentRowData[j]);
                            currentDepositObj[headers[j].trim()] = currentRowData[j].trim();
                        }
                        
                        /*var currentDepositObj =  {Tenancy_Start_Date: fieldToDataMap.get('Tenancy_Start_Date'), 
                                               Deposit_Amount: fieldToDataMap.get('Deposit_Amount'), 
                                               Deposit_Amount_to_Protect: fieldToDataMap.get('Deposit_Amount'), 
                                               Deposit_Received_Date: fieldToDataMap.get('Deposit_Amount'), 
                                               Primary_Landlord_Email: fieldToDataMap.get('Deposit_Amount') 
                                              }; */
                        
                        listOfDeposits.push(currentDepositObj);
                    }
                }
                listOfDeposits.pop();
                component.set("v.ListOfTenancies",listOfDeposits);
                // Creating a Map/Object of Deposit from the listOfDeposits
                for(var i=0; i<listOfDeposits.length; i++) {
                    var mapKey = 'row_'+i;
                    console.log("Line 88 mapKey -> "+mapKey);
                	mapOfDeposits[mapKey] = listOfDeposits[i];
                }
                
                console.log("Line 93 values -> "+JSON.stringify(mapOfDeposits));
                console.log("Line 94 typeof -> "+typeof mapOfDeposits);
                
                // Calling helper for validation of the deposit rows
                helper.checkValidationsForDeposits(component, helper, mapOfDeposits, file, dataRows);
                //console.log("Line 75 listOfDeposits -> "+JSON.stringify(listOfDeposits));
                
                 //vidhi start
                var listDeposits =[];
                for(var i=0; i<listOfDeposits.length; i++) {
                    var mapKey = 'row_'+i;
                    var values = listOfDeposits[i]; //[];
                   // values.push(listOfDeposits[i]);
                    console.log("Line 88 mapKey -> "+mapKey);
                    listDeposits.push({key: mapKey, value: values}) ;
                }
                
                component.set("v.ListOfTenancies", listDeposits);
                //vidhi end
                
                var numOfRows=component.get("v.noOfDeposits");
                if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0) {
                    alert("File Rows between 1 to "+numOfRows+" .");
                    component.set("v.showMain",true);
                } 
                else {
                    var lines = [];
                    var filecontentdata;
                    var content = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                    content += "<thead><tr class=\"slds-text-title--caps\">";
                    for(i=0;i<headers.length; i++){
                        content += '<th scope=\"col"\>'+headers[i]+'</th>';
                    }
                    content += "</tr></thead>";
                    for (var i=1; i<allTextLines.length; i++) {
                        filecontentdata = allTextLines[i].split(',');
                        if(filecontentdata[0]!=''){
                            content +="<tr>";
                            
                            for(var j=0;j<filecontentdata.length;j++){
                                content +='<td>'+filecontentdata[j]+'</td>';
                            }
                            content +="</tr>";
                        }
                    }
                    content += "</table>";
                    
                    component.set("v.TableContent",content);
					component.set("v.showMain",false);                   
                }
            }
            reader.readAsText(file);
            
        }
        
        var reader = new FileReader();
        reader.onloadend = function() {
         
        };
        reader.readAsDataURL(file);
    },
    
    readFile1: function(component, helper, file) {
        if (!file) return;
        console.log('file'+file.name);
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('only support csv files');
        } else {
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+')- '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                component.set("v.filename",file.name);
                component.set("v.TargetFileName",output);
               
            };
            reader.onload = function(e) {
                var data=e.target.result;
                component.set("v.fileContentData",data);
                console.log("file data"+JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                console.log("allTextLines -> "+allTextLines);
                var dataRows=allTextLines.length-1;
                console.log("dataRows -> "+dataRows);
                var headers = allTextLines[0].split(',');
                component.set("v.fieldNames",headers);
                console.log("headers -> "+headers);
                console.log("fieldNames -> "+component.get("v.fieldNames"));
                
                console.log("Rows length::"+dataRows);
               
              
                	var numOfRows=component.get("v.NumOfRecords");
                    if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0){
                   
                     alert("File Rows between 1 to "+numOfRows+" .");
                    component.set("v.showMain",true);
                    
                } 
                else {
                    var lines = [];
                    var filecontentdata;
                    var content = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                    content += "<thead><tr class=\"slds-text-title--caps\">";
                    for(i=0;i<headers.length; i++){
                        content += '<th scope=\"col"\>'+headers[i]+'</th>';
                    }
                    content += "</tr></thead>";
                    for (var i=1; i<allTextLines.length; i++) {
                        filecontentdata = allTextLines[i].split(',');
                        if(filecontentdata[0]!=''){
                            content +="<tr>";
                            
                            for(var j=0;j<filecontentdata.length;j++){
                                content +='<td>'+filecontentdata[j]+'</td>';
                            }
                            content +="</tr>";
                        }
                    }
                    content += "</table>";
                    
                    component.set("v.TableContent",content);
					component.set("v.showMain",false);                   
                }
            }
            reader.readAsText(file);
            
        }
        var reader = new FileReader();
        reader.onloadend = function() {
         
        };
        reader.readAsDataURL(file);
    },
    
    saveRecords : function(component,event){
        var action = component.get("c.processData");
        var fieldsList=['Name','Phone','AccountNumber']; //Please write your code dynamic fields
        action.setParams({ fileData : component.get("v.fileContentData"),
                          sobjectName:'Account', //Any object
                          fields:fieldsList});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showMain",true);
                alert('saved successfully');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }, 
    
    checkValidationsForDeposits : function(component, helper, mapOfDeposits, file, dataRows) {
        console.log('In Validation helper');
        console.log('Line 267 mapOfDeposits -> ',mapOfDeposits.length);
        var count=0;
        for(var depo in mapOfDeposits) {
            count++;
            //console.log('Line 269 count -> ',depo.Deposit_Amount);
        }
        console.log('Line 269 count -> ',count);
        
        var mapOfErrorsWithDepo = new Map();
        var errorCount = 0;
		var errKey;
        //vidhi start
        var listErrors =[];
        // vidhi end
        
        // Creating a Map/Object of errors linked with Deposit
        for(var i=0; i<count; i++) {
            var str = 'row_'+i;
            console.log('Line 269 count -> ',JSON.stringify(mapOfDeposits[str]));
            //console.log('Line 270 count -> ',mapOfDeposits[str].Primary_Landlord_Email);
            console.log('Line 271 str -> ',str);
            console.log('Line 272 Tenancy_Start_Date -> ',mapOfDeposits[str].Tenancy_Start_Date);
            console.log('Line 298 Deposit_Amount -> ',parseFloat(mapOfDeposits[str].Deposit_Amount));
            console.log('Line 298 Deposit_Amount_to_Protect -> ',parseFloat(mapOfDeposits[str].Deposit_Amount_to_Protect));
            
            
            if(mapOfDeposits[str].Tenancy_Start_Date=='' || mapOfDeposits[str].Tenancy_Start_Date==undefined || 
               mapOfDeposits[str].Tenancy_Start_Date==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['fieldName']='Tenancy_Start_Date';
                currentErrorObj['errorMessage']='Tenancy_Start_Date cannot be null';
                mapOfErrorsWithDepo[errKey]=currentErrorObj;
                errorCount++;
                
                console.log('Line 295 errKey 2 -> ',errKey);
                
                 //Vidhi Start
                var values = [];
                values.push(currentErrorObj);
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                // Vidhi end
            }
            if(parseFloat(mapOfDeposits[str].Deposit_Amount)<=0) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['fieldName']='Tenancy_Start_Date';
                currentErrorObj['errorMessage']='Tenancy_Start_Date cannot be null';
                mapOfErrorsWithDepo[errKey]=currentErrorObj;
                errorCount++;
                
                console.log('Line 305 errKey 2 -> ',errKey);
                console.log('Line 306 errorMessage -> ',mapOfErrorsWithDepo[errKey].errorMessage);
                
                //Vidhi Start
                var values = [];
                values.push(currentErrorObj);
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                // Vidhi end
            }
            if(parseFloat(mapOfDeposits[str].Deposit_Amount_to_Protect)<=0) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                console.log('Line 304 errKey -> ',errKey);
                currentErrorObj['depoKey']=str;
                currentErrorObj['fieldName']='Tenancy_Start_Date';
                currentErrorObj['errorMessage']='Tenancy_Start_Date cannot be null';
                mapOfErrorsWithDepo[errKey]=currentErrorObj;
                errorCount++;
                
                console.log('Line 317 errKey 2 -> ',errKey);
                
                //Vidhi Start
                var values = [];
                values.push(currentErrorObj);
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                // Vidhi end
            }
            if(mapOfDeposits[str].Deposit_Received_Date=='' || mapOfDeposits[str].Deposit_Received_Date==undefined || 
               mapOfDeposits[str].Deposit_Received_Date==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['fieldName']='Deposit_Received_Date';
                currentErrorObj['errorMessage']='Deposit_Received_Date cannot be null';
                mapOfErrorsWithDepo[errKey]=currentErrorObj;
                errorCount++;
                
                console.log('Line 295 errKey 2 -> ',errKey);
                
                //Vidhi Start
                var values = [];
                values.push(currentErrorObj);
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                // Vidhi end
            }
            if(mapOfDeposits[str].Primary_Landlord_Email=='' || mapOfDeposits[str].Primary_Landlord_Email==undefined || 
               mapOfDeposits[str].Primary_Landlord_Email==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['fieldName']='Primary_Landlord_Email';
                currentErrorObj['errorMessage']='Primary_Landlord_Email cannot be null';
                mapOfErrorsWithDepo[errKey]=currentErrorObj;
                errorCount++;
                
                console.log('Line 295 errKey 2 -> ',errKey);
                
                //Vidhi Start
                var values = [];
                values.push(currentErrorObj);
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                // Vidhi end
            }
           
        }
        
        console.log('Line 326 errorCount-> ',errorCount);
        component.set("v.validationErrorList",mapOfErrorsWithDepo);
        component.set("v.totalFailures",errorCount);
        
        //vidhi start
        component.set("v.validationErrorList", listErrors);
        //vidhi end
        
        // Consoling the errors
        for(var i=0; i<errorCount; i++) {
            errKey='error_'+i;
            console.log(`Line 308 errors : Error Key -> ${errKey} : Deposit Key -> ${mapOfErrorsWithDepo[errKey].depoKey} : 
                        Error Message -> ${mapOfErrorsWithDepo[errKey].errorMessage} `);
        }
        
        if(component.get("v.totalFailures")==0) {
            component.set("v.statusOfValidate",'Successful');
        } else {
            component.set("v.statusOfValidate",'Failed');
        }
        
        // Server call for inserting the 'Bulk Import' object's record
        var action = component.get('c.insertNewBulkImport')
        action.setParams({
            fileName : component.get("v.flName"),
            totalTenancies : component.get("v.noOfDeposits"),
            totalFailures : component.get("v.totalFailures"),
            statusOfValidate : component.get("v.statusOfValidate"),
            contactId: component.get("v.currentUser").ContactId,
            accountID: component.get("v.currentUser").AccountId
        });
        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Console log the user with the value returned from the server
                console.log("From server: " + response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            // We create a helper method for displaying errors through toast messages 
                            helper.handleErrors(errors);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    }, 
    
    // helper to show errors in the form of toast messages
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire(); 
    },
    
});