({
    doInit : function(component, event, helper) {
        let currentURL = window.location.href;
        let AccessCode = currentURL.split("id=")[1];
        if(AccessCode =='SuccessMsg')
        {
            component.set("v.showSuccessMsg",true);
            let usrls = currentURL.split("id=")[0]+'id=1****3';
            history.pushState(null, '',usrls);
        }
        else
        {
            component.set("v.showSuccessMsg",false);
        }        
        
        component.set("v.showDeposits",true);
        
        // get branchId
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var action = component.get('c.getDepositInformationPIForm');
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                
                if(oRes.length > 0){
                    component.set("v.listOfAllDeposits", oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllDeposits").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }
                else{
                    component.set("v.bNoRecordsFound" , true);
                }
            }
            else{
                
            }
        });        
        $A.enqueueAction(action);
    },
    
    transferrabledeposits : function(component, event, helper) {
        component.set("v.showDeposits", true); 
        component.set("v.useremailsection",false);
    },
    
    viewtransffered : function(component, event, helper) {
        component.set("v.showDeposits",false);  
        component.set("v.useremailsection",false);
        component.set("v.showAwatingTransfered",false);
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllDeposits");
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
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
        
        var selectedDeposits = component.get("v.selectedDepositIds");
        var checkvalue = event.getSource(); //component.find("checkDeposit");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value")) {
                selectedDeposits.push({Id: checkvalue.get("v.text").Id, 
                                       DPCLink: checkvalue.get("v.text").PI_Certificate_Link__c,
                                       DPCName: checkvalue.get("v.text").PI_Certificate_Name__c
                                      });
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedDeposits.push({Id: checkvalue.get("v.text").Id, 
                                           DPCLink: checkvalue.get("v.text").PI_Certificate_Link__c,
                                           DPCName: checkvalue.get("v.text").PI_Certificate_Name__c
                                          });
                }
            }
        }
        component.set("v.selectedDepositIds",selectedDeposits);
        console.log("selectedDeposits => " + JSON.stringify(selectedDeposits));
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllDeposits = component.get("v.listOfAllDeposits");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllDeposits.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllDeposits[i].isChecked = true;
                component.set("v.selectedCount", listOfAllDeposits.length);
            } else {
                listOfAllDeposits[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllDeposits[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllDeposits", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
        
        var allRecords = component.get("v.listOfAllDeposits");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                console.log('allRecords['+i+'] => ' + JSON.stringify(allRecords[i].objDeposit));
                selectedRecords.push({Id: allRecords[i].objDeposit.Id, 
                                       DPCLink: allRecords[i].objDeposit.PI_Certificate_Link__c,
                                       DPCName: allRecords[i].objDeposit.PI_Certificate_Name__c
                                      });
            }
        }
        component.set("v.selectedDepositIds",selectedRecords);
        console.log("selectedRecords => " + selectedRecords);
    },
    
    transferMultipleDepositSubTabs : function(component, event, helper) {
        /*component.find("navServiceMyProperty").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "bulkactions"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {  }
            }); 
        }
    },
    
    regMultipleDepositSubTabs : function(component, event, helper) {
        $(".org-detail-list").slideToggle();
        /*component.find("navServiceMyProperty").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "registermultipledeposits"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "registermultipledeposits"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "registermultipledeposits"
                },
                state: { }
            }); 
        }
    },
    
    downloadMultiplecertificatesTabs : function(component, event, helper) {
        /*component.find("navServiceMyProperty").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "downloadbulkcertificates"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadbulkcertificates"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadbulkcertificates"
                },
                state: {  }
            }); 
        }
    },

    downloadPIFormsTabs : function(component, event, helper) {
        /*component.find("navServiceMyProperty").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "downloadpiforms"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadpiforms"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadpiforms"
                },
                state: {  }
            }); 
        }
    },
    
    downloadCertificates: function(component, event, helper) {
        if(component.get("v.selectedCount")==0 || component.get("v.selectedCount")==undefined)
        {
            component.set("v.nodepositSelected", true);
            
        }
        else{
            component.set("v.disbleDownloadButton", true);
            helper.ABC(component, event, helper);
            component.set("v.nodepositSelected", false);
            //component.set("v.showDeposits",false);
            component.set("v.useremailsection",true);
        }
    },
    
    handleSearch : function(component, event, helper){
        
        var searchVal = $("#searchValue").val();
        console.log("search text" + searchVal );
        
        component.set("v.showDeposits",true);
        
        // get branchId
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var action = component.get('c.getSearchDepositInformationPIForm');
        action.setParams({
            'searchText': searchVal,
            branchId: branchId
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                
                if(oRes.length > 0){
                    component.set("v.listOfAllDeposits", oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllDeposits").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }
                else{
                    component.set("v.bNoRecordsFound" , true);
                }
            }
            else{
                
            }
        });        
        $A.enqueueAction(action);
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "nodeposit":
                component.set("v.nodepositSelected", false);
                break;
            case "singleBlank":
                component.set("v.singleBlankValue", false);
                break;
        }
    },
    
})