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
        
        // get branchId
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var action = component.get('c.getDepositInformation');
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set("v.showDeposits",true);
                    component.set("v.viewtransferred",false);
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
        
        // open sub tabs
        var regMultDepTab =  component.find("leftSideSubTabs");
        console.log('weird regMultDepTab -> '+regMultDepTab);
        $A.util.addClass(regMultDepTab, "openSubTab");
    },
    
    
    transferrabledeposits : function(component, event, helper) {
        component.set("v.showDeposits", true); 
        component.set("v.useremailsection",false);
        component.set("v.showAwatingTransfered",false);
        component.set("v.viewtransferred",false);
    },
    viewtransffered : function(component, event, helper) {
        component.set("v.showDeposits",false);  
        component.set("v.useremailsection",false);
        component.set("v.showAwatingTransfered",false);
        component.set("v.viewtransferred",true);
    },
    
    
    transferMultipleDepositSubTabs : function(component, event, helper) {
        component.set("v.showDeposits", true);
        component.set("v.viewtransferred",false);
        component.set("v.passSuccessMessage", false);
        //$(".org-detail-list").slideToggle();
        if(component.get("v.showSubTabs")) {
            var regMultDepTab =  component.find("leftSideSubTabs");
            $A.util.removeClass(regMultDepTab, "openSubTab");
            $A.util.addClass(regMultDepTab, "closeSubTab");
            component.set("v.showSubTabs", false);
        } else {
            var regMultDepTab =  component.find("leftSideSubTabs");
            $A.util.removeClass(regMultDepTab, "closeSubTab");
            $A.util.addClass(regMultDepTab, "openSubTab");
            component.set("v.showSubTabs", true);
        }
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
        
        var selectedDeposits = [];
        var checkvalue = component.find("checkDeposit");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value")) {
                selectedDeposits.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedDeposits.push(checkvalue[i].get("v.text"));
                }
            }
        }
        component.set("v.selectedDepositIds",selectedDeposits);
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
                selectedRecords.push(allRecords[i].objDeposit.Id);
            }
        }
        component.set("v.selectedDepositIds",selectedRecords);
    },
    
    regMultipleDepositSubTabs : function(component, event, helper) {
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
                state: {  }
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
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "nodeposit":
                component.set("v.nodepositSelected", false);
                break;
            case "singleBlank":
                component.set("v.singleBlankValue", false);
                break;
            case "showSuccessMsg":
                component.set("v.passSuccessMessage", false);
                break;
        }
    },
    
    submitTransfers: function(component, event, helper) {
        if(component.get("v.selectedCount")==0 || component.get("v.selectedCount")==undefined)
        {
            component.set("v.nodepositSelected", true);
            
        }
        else{
            component.set("v.nodepositSelected", false);
            component.set("v.showDeposits",false);
            component.set("v.useremailsection",true);
            
        }
    },
    
    backtodeposits : function(component, event, helper) {
        component.set("v.showDeposits",true);
        component.set("v.useremailsection",false);        
        
    },
    
    //Process the selected deposits
    transferdeposits: function(component, event, helper) {
        
        var emailFieldValue = component.get("v.emailValue");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        
        if(!$A.util.isEmpty(emailFieldValue)){
            component.set("v.emailValidationError", false);
            if(emailFieldValue.match(regExpEmailformat)){
                component.set("v.emailNotValid", false);
            }else{
                component.set("v.emailNotValid", true);
            }
        }
        else{
            component.set("v.emailValidationError", true);
        }
        
        
        if ((component.get("v.emailNotValid") ||  component.get("v.emailValidationError") ))
        {
            component.set("v.openconfirmbox",false);
        }
        else
        {
            component.set("v.openconfirmbox",true);
        }
        
    },
    
    cancelTransfer: function(component, event, helper) {
        component.set("v.openconfirmbox",false);
        
    },
    confirmTransfer:function(component, event, helper) 
    {
        let selectedDepositID = component.get("v.selectedDepositIds");
        let emailValue = component.get("v.emailValue");
        
        var action = component.get("c.transferDeposit");
        action.setParams({
            selectedDepositID: selectedDepositID,
            emailValue: emailValue
            
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                var returnValue = a.getReturnValue();
                if(returnValue=='Email is exists for Tenant')
                {
                    component.set("v.emailBelongToTenant",true);
                    component.set("v.openconfirmbox",false);
                }
                else if (returnValue=='deposit transferred')
                {
                    component.set("v.emailBelongToTenant",false);
                    component.set("v.openconfirmbox",false);
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    let currentURL = window.location.href;
                    let prefix = currentURL.split("?id=")[0];
                    let finalUrl;
                    if(prefix)
                    {
                        finalUrl = prefix;
                    }
                    else
                    {
                       finalUrl= currentURL;
                    }
                    
                    urlEvent.setParams({
                        
                        "url": finalUrl + '?id=SuccessMsg'
                    });
                    urlEvent.fire()
                }
                else
                {
                   component.set("v.emailBelongToTenant",false);
                   alert('unexpeted Error'); 
                   console.log('unexpeted Error' + returnValue ); 
                }
                
            }
            
            });
        $A.enqueueAction(action);
    },
    
    transferAwatingApproval:function(component, event, helper)
    {
        component.set("v.showDeposits",false);  
        component.set("v.useremailsection",false);
        component.set("v.viewtransferred",false);
        component.set("v.showAwatingTransfered",true);
        
    }
    
    
   
    
})