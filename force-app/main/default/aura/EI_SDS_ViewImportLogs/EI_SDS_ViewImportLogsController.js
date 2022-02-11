({
	doInit : function (component, event, helper){        
        console.log('contact Id => ' + component.get("v.currentUser").ContactId);
        console.log('Account Id => ' + component.get("v.currentUser").AccountId);
        // Server call for feching the 'Bulk Import' object's record
        var action = component.get('c.fetchBulkImports');
        action.setParams({
            contactId: component.get("v.currentUser").ContactId,
            accountID: component.get("v.currentUser").AccountId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                //console.log("From server: " + JSON.stringify(response.getReturnValue()) );
                component.set("v.totalImportLogsList", response.getReturnValue());
                
                var importLogs = component.get("v.totalImportLogsList");
                console.log('importLogs => ' + JSON.stringify(importLogs));
                
                if(importLogs.length > 0){
                    // Pagination
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = importLogs;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    
                    var statusRecord = [];
                    for (var i = 0; i < importLogs.length; i++) {
                        console.log(importLogs[i].Status__c + " == Successful >>>" + importLogs[i].Status__c == "Successful");
                        if(importLogs[i].Status__c == "Successful"){
                            importLogs[i].Validated_or_Imported_Date__c = $A.localizationService.formatDate(importLogs[i].Validated_or_Imported_Date__c, "DD/MM/YYYY");
                            statusRecord.push(importLogs[i]);
                        }
                    }
                    component.set("v.statusImportLogsList", statusRecord);
                    component.set("v.totalRecordsCount", statusRecord.length);
                    
                    var PaginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (statusRecord.length > i) {
                            PaginationList.push(statusRecord[i]);
                        }
                    }
                    component.set("v.showImportLogsList", PaginationList);
                    
                    if(PaginationList.length > 0){
                        component.set("v.totalPagesCount", Math.ceil(statusRecord.length / pageSize));
                    }else{
                        component.set("v.totalPagesCount", 1);
                    }
                    
                    component.set("v.showImportDetails", false);
                    component.set("v.isViewBulkImportLog", true);
                }else{
                    component.set("v.noRecordsToShow", true);
                }
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
        
        console.log('end of do init');
    },

    navPage : function(component, event, helper) {
        var sObjectList = component.get("v.statusImportLogsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        //var whichBtn = event.getSource().get("v.name");
        //
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

    handleViewImport : function(component, event, helper) {
        var index = event.target.id;
        console.log('index => ' + index);
        var pageSize = component.get("v.pageSize");
        console.log('pageSize => ' + pageSize);
        var currentPage = component.get("v.currentPage") - 1;
        var indexNo = parseInt(index) + (parseInt(pageSize) * parseInt(currentPage));
        console.log('indexNo => ' + indexNo);
        var importLogs = component.get("v.statusImportLogsList");
        console.log('importLogs => ' + JSON.stringify(importLogs));
        var viewImpDetails = importLogs[indexNo];
        component.set("v.viewImportDetails", viewImpDetails);
        console.log('viewImportDetails => ' + JSON.stringify(component.get("v.viewImportDetails")) );
        component.set("v.isViewBulkImportLog", false);
        component.set("v.showImportDetails", true);
        
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
    
    handleChangeFilter : function(component, helper, event){
       // alert(component.get("v.statusSelVal"));
       
        var importLogs = component.get("v.totalImportLogsList");
        var status = component.get("v.statusSelVal");
        console.log('importLogs => ' + JSON.stringify(importLogs));
        console.log('status => ' + status);
        
        // Pagination
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = importLogs;
        var totalLength = totalRecordsList.length;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        
        var statusRecord = [];
        for (var i = 0; i < importLogs.length; i++) {
            console.log(importLogs[i].Status__c + " == "+status+" >>>" + importLogs[i].Status__c == status);
            if(importLogs[i].Status__c == status){
                statusRecord.push(importLogs[i]);
            }
        }
        component.set("v.statusImportLogsList", statusRecord);
        component.set("v.totalRecordsCount", statusRecord.length);
        
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (statusRecord.length > i) {
                PaginationList.push(statusRecord[i]);
            }
        }
        component.set("v.showImportLogsList", PaginationList);
        
        if(PaginationList.length > 0){
            component.set("v.totalPagesCount", Math.ceil(statusRecord.length / pageSize));
        }else{
            component.set("v.totalPagesCount", 1);
        }
      	component.set("v.currentPage", 1);
        component.set("v.showImportDetails", false);
        component.set("v.isViewBulkImportLog", true);
        
    },
    
    handleDownloadCSV : function(component, helper, event){
        var url = component.get("v.viewImportDetails").Azure_File_Link__c ;//'https://sdsevidencedev.blob.core.windows.net/evidence/undefined-1630517969711-foo.txt?sp=rw&st=2021-06-18T15%3A27%3A12Z&se=2031-06-18T23%3A27%3A12Z&spr=https&sv=2020-02-10&sr=c&sig=ny8xLiSPlms%2FpN%2FtAIYuJaJI7VNQBqc9eqL7V%2BlrQLs%3D';        
        var hiddenElement = document.createElement('a');
        console.log('viewImportDetails => ' + JSON.stringify(component.get("v.viewImportDetails")) );
        
        hiddenElement.href = url; //'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        //hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
    
})