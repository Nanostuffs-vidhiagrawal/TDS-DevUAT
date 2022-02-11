({
   
    validatingTheFile : function(component, event, helper) {
        
        helper.fetchScotlandPostalCodes(component, event, helper);
        /*var action = component.get("c.getSecureURI"); 
        action.setParams({
            scheme : 'SDS' //'Zero Deposite'
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();               
            
            if (state == "SUCCESS") {
                let ReturnValue = a.getReturnValue();
                component.set("v.secureURI", ReturnValue);  
                //alert("getSecureURI" + component.get("v.secureURI"));
                var files = component.get("v.fileList");
                if(!files[0]) {
                    alert('Add the file and then either Validate or Import it')
                } else {
                    let icon = files[0].name.toLowerCase();
                    component.set("v.fileName", files[0].name);
                    var today = new Date();
                    //var dd = today.getDate();
                    //var mm = today.getMonth()+1; //As January is 0.
                    //var yyyy = today.getFullYear();
                    //today = dd+'/'+mm+'/'+yyyy;
                    today = $A.localizationService.formatDate(today, "DD/MM/YYYY");
                    component.set("v.validatedDate", today);
                    component.set("v.uploadBar", "50");
                    helper.readFile(component,helper,files[0]);
                    
                    component.set("v.showChildSection",false);
                    component.set("v.isSummSecFileValidate",true);
                }
            }
        });
        $A.enqueueAction(action); 
        */
        helper.apex(component,'getSecureURI',{scheme : 'SDS'})
        .then(function(result){
            component.set("v.secureURI", result);
            var files = component.get("v.fileList");
            
            if(!files[0]) {
                alert('Add the file and then either Validate or Import it')
            } else {
                let icon = files[0].name.toLowerCase();
                component.set("v.fileName", files[0].name);
                
                var today = new Date();
                today = $A.localizationService.formatDate(today, "DD/MM/YYYY");
                component.set("v.validatedDate", today);
                component.set("v.uploadBar", "20");
                helper.readFile(component,helper,files[0]);
                
                component.set("v.showChildSection",false);
                component.set("v.isSummSecFileValidate",true);
            }
        });
	},
    
    handleImport : function(component, event, helper){
        component.set("v.isValidateOnly", false);
        component.set("v.isDisableImport", true);
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var action = component.get("c.importData");
        action.setParams({
            BranchId : branchId,
            ListOfTenancies : component.get("v.ListOfTenancies"),
            isValidateOnly : component.get("v.isValidateOnly"),
            FileName : component.get("v.fileName"),
            totalTenants : component.get("v.totalTenants"),
            totalLandlords : component.get("v.totalLandlords"),
            statusOfValidate : component.get("v.statusOfValidate"),
            contactId : component.get("v.currentUser").ContactId,
            accountID : component.get("v.currentUser").AccountId,
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var res = a.getReturnValue();
            if (state == "SUCCESS"){
                component.set("v.updatesucceessmessage", true);
            } 
        });
        $A.enqueueAction(action);
    },
    
    handleUnsuccessful : function(component, event, helper) {
        component.set("v.isSummSecFileValidate",false);
        component.set("v.showChildSection",true);
        
        var action = component.get('c.showErrors');
        $A.enqueueAction(action);
    },
    
    showErrors : function(component, event, helper) {
       
        var failures = component.get("v.validationErrorList");
        // Pagination
        var pageSize = component.get("v.pageSize");
        var totalLength = failures.length;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (failures.length > i) {
                PaginationList.push(failures[i]);
            }
        }
        component.set("v.showfailuresList", PaginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        
    },

    handleUpdateErrors : function(component, event, helper){
        component.set("v.isUpdateError", true);
    },
 
    handleUpdateFieldData : function(component, event, helper){
        const inputValue = event.getSource().get('v.value');
        var index = event.getSource().get("v.title");
        var pageSize = component.get("v.pageSize");
        var currentPage = component.get("v.currentPage") - 1;
        var indexNo = parseInt(index) + (parseInt(pageSize) * parseInt(currentPage));
            
        // edit field data in validationErrorList
        var totalFailures = component.get("v.validationErrorList");
        var error = totalFailures[indexNo]; 
        error.value.fieldValue = inputValue; // assign value to dataInField
        component.set("v.validationErrorList", totalFailures);
        
        // edit field data in ListOfTenancies
        var ListTenancies = component.get("v.ListOfTenancies");
        var fieldname = error.value.fieldName;
        var depoKey = error.value.depoKey;
        
        fieldname = fieldname.replaceAll(" ", "_");
        fieldname = fieldname.toLowerCase();
        for(var index in ListTenancies){
            var key = ListTenancies[index].key;
            var values = ListTenancies[index].value;
            if(key == depoKey){
                values[fieldname] = inputValue;
                break;
            }
        }
        
        component.set("v.ListOfTenancies", ListTenancies);
    },
   
    handleValidate : function(component, event, helper){
        var today = new Date();
        today = $A.localizationService.formatDate(today, "DD/MM/YYYY");
        component.set("v.validatedDate", today);
        
        var listOfDeposits = component.get("v.ListOfTenancies");
        var mapOfDeposits = new Map();
        var listDeposits =[];
        for(var i=0; i<listOfDeposits.length; i++) {
            var mapKey = i+1; //'row_'+(i+1);
            var values = listOfDeposits[i].value;
        
        
            mapOfDeposits[mapKey] = listOfDeposits[i].value;
            listDeposits.push({key: mapKey, value: values}) ;
        }
        component.set("v.ListOfTenancies", listDeposits);
        component.set("v.noOfDeposits", listDeposits.length);
        
        // Calling helper for validation of the deposit rows
        helper.checkValidationsForDeposits(component, helper, mapOfDeposits);
    
        component.set("v.showChildSection",false);
        component.set("v.isUpdateError", false);
        component.set("v.isSummSecFileValidate",true); 
    },

    navPage: function(component, event, helper) {
        var sObjectList = component.get("v.validationErrorList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (event.target.id == "nextId") {
          component.set("v.currentPage", component.get("v.currentPage") + 1);
          helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (event.target.id == "previousId") {
          component.set("v.currentPage", component.get("v.currentPage") - 1);
          helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },

    handleShowModel: function(component, event, helper) {    
        component.set("v.showModal", true);
        var indexNo = event.target.id;
        component.set("v.indextoRemove", indexNo);
    },
    
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
    },
    
    handleYes: function(component, event, helper) {
        var index = component.get("v.indextoRemove");
        var pageSize = component.get("v.pageSize");
        var currentPage = component.get("v.currentPage") - 1;
        var indexNo = parseInt(index) + (parseInt(pageSize) * parseInt(currentPage));
        var totalFailures = component.get("v.validationErrorList");
        // remove row contains error
        var error = totalFailures[indexNo];
        var ListTenancies = component.get("v.ListOfTenancies");
        var fieldname = error.value.fieldName;
        var depoKey = error.value.depoKey;
        
        // remove record from all tenancies list
        for(var index in ListTenancies){
            var key = ListTenancies[index].key;
            var values = ListTenancies[index].value;
        
            if(key == depoKey){
                ListTenancies.splice(index, 1);
                break;
            }
        }
        
        component.set("v.ListOfTenancies", ListTenancies);

        // remove record from failures list
        for(var i = 0; i < totalFailures.length; i++ ){
            if(totalFailures[i].value.depoKey == error.value.depoKey){
                totalFailures.splice(i, 1);
                i--;
            }
        }
        
        component.set("v.validationErrorList", totalFailures);

        //Pagination
        var totalLength = totalFailures.length; //total records = 8	15
        component.set("v.startPage", 0);
        component.set("v.endPage", (pageSize - 1));
        
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (totalFailures.length > i) {
                PaginationList.push(totalFailures[i]);
            }
        }
        
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.showfailuresList", PaginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        component.set("v.currentPage", 1);
        
        // hide model
        component.set("v.showModal", false);
        // show validate button visible
        component.set("v.isUpdateError", true);
    },
    
    downloadcsvData : function(component, helper, event){
        var url = 'https://sdsevidencedev.blob.core.windows.net/evidence/undefined-1630517969711-foo.txt?sp=rw&st=2021-06-18T15%3A27%3A12Z&se=2031-06-18T23%3A27%3A12Z&spr=https&sv=2020-02-10&sr=c&sig=ny8xLiSPlms%2FpN%2FtAIYuJaJI7VNQBqc9eqL7V%2BlrQLs%3D';        var hiddenElement = document.createElement('a');
        var fileName = component.get("v.fileName");
        hiddenElement.href = url; //'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = fileName;  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }

})