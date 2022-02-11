({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
        helper.getError(component, event, helper);
    },
    
    closeModelCancel: function(component, event, helper){
        component.set("v.enterTenantNameMultiple", false);
        component.set("v.tenantValidationError",false);
        component.set("v.errors",'');
    },
    
    
    closeModel: function(component, event, helper) { 
        component.set("v.enterTenantName", false);
        component.set("v.tenantValue", '');
        component.set("v.acceptSingleDeposit", false);
        component.set("v.tenantValidationError",false);
        component.set("v.errors",'');
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
        console.log('55555 ' + component.get("v.selectedDepositIds"));
        // alert(JSON.stringify(selectedRecords));
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
        //alert('+++++102+'+selectedDeposits);
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value")) {
                //alert('+++++105+'+checkvalue.get("v.text"));
                selectedDeposits.push(checkvalue.get("v.text"));
            }//alert('+++++107+'+selectedDeposits);
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedDeposits.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedDeposits-' + selectedDeposits);
        component.set("v.selectedDepositIds",selectedDeposits);
        console.log('11111111111111 ' + component.get("v.selectedDepositIds"));
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
    
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllDeposits");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objDeposit);
            }
        }
        //alert(JSON.stringify(selectedRecords));
    },
    
    
    handleAccept: function(component, event, helper) {
        component.set("v.enterTenantNameMultiple",false);
        if(component.get("v.selectedCount")==0 
           || component.get("v.selectedCount")==undefined){
            alert('Please select one deposit.');
        }
        else if(component.get("v.selectedCount")>1){
            alert('Please select one deposit.');
        }
            else{
                component.set("v.enterTenantName",true);
            }
    },
    
    goBackTransferPage: function(component, event, helper) {
        component.set("v.displayDepositTable",true);
        component.set("v.enterTenantNameMultiple",false);
    },
    
    handleAcceptMultipleDeposits: function(component, event, helper) {
        component.set("v.displayDepositTable",false);
        console.log('component.get("v.selectedCount")--> '+component.get("v.selectedCount"));
        if(component.get("v.selectedCount")==0 
           || component.get("v.selectedCount")==undefined){
                //alert('Please select atleast one deposit.');
            component.set("v.nodepositSelected", true);
            component.set("v.displayDepositTable",true);
            component.set("v.enterTenantNameMultiple",false);
        }
        else{
            component.set("v.tenantValidationError", false);
            component.set("v.nodepositSelected", false);
            component.set("v.enterTenantNameMultiple",true);
            helper.handleAcceptMultipleDeposits(component, event);
        }
    },
    
    handleAcceptSingleDeposit: function(component, event, helper) {
        // component.get("v.selectedDeposits")
        console.log('SD>>> ' + component.get("v.selectedDepositIds"));
        helper.acceptSingleDeposit(component, event);
    },
    
    handleReject: function(component, event, helper) {
        if(component.get("v.selectedCount")==0 || component.get("v.selectedCount")==undefined){
            alert('Please select one deposit.');
        }
        else if(component.get("v.selectedCount")>1){
            alert('Please select one deposit.');
        }
            else{
                helper.rejectDeposit(component, event);
            }
    },
    
    handleRejectMultipleDeposits: function(component, event, helper) {
        if(component.get("v.selectedCount")==0 
           || component.get("v.selectedCount")==undefined){
            //alert('Please select atleast one deposit.');
        }
        else{
            helper.rejectDeposit(component, event);
        }
    },
    
    acceptedDepositSummaryPage: function(component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "viewdeposit"
            },
            state: {}
        });
    },
    
    rejectedDepositSummaryPage: function(component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "viewdeposit"
            },
            state: {}
        });
    },
    
    tenantCheck: function(component, event, helper) {
        var getTenantValue = component.find("tenantId").get("v.value");
        if(getTenantValue== undefined || getTenantValue == null
           || getTenantValue==''){
            component.set("v.tenantValidationError",true);
            component.set("v.errors", "This field is required and cannot be left empty.");
        }
        else{
            component.set("v.tenantValidationError",false);
            helper.checkTenantName(component, event,getTenantValue);
        }        
    }, 
    
    multipleTenantCheck: function(component, event, helper) {
        var getTenantValue = component.find("tenantMultipleId").get("v.value");
        if(getTenantValue== undefined || getTenantValue == null
           || getTenantValue==''){
            component.set("v.tenantValidationError",true);
            component.set("v.singleBlankValue", true);
        }
        else{
            component.set("v.tenantValidationError",false);
            helper.checkTenantName(component, event,getTenantValue);
        }        
    }, 
    
    
    handleYesCase: function(component, event, helper) {
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"depositsummarypage?id="+component.get("v.selectedDepositIds");
        window.location.replace(urlRedirect);
        return false;
    }, 
    
    handleNoCase: function(component, event, helper) {
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"reviewtransfer";
        window.location.replace(urlRedirect);
        return false;
        //var action = component.get('c.closeModelCancel');
        //$A.enqueueAction(action);
    },
    
    multipleTenantCheckValue: function(component, event, helper) {
        component.set("v.tenantValidationError",false);
        console.log(' deposits'+JSON.stringify(component.get("v.deposits")));
        var tenantValue = event.getSource().get('v.value');//alert(tenantValue);
        var tenantId = event.getSource().get("v.title");//alert(tenantId);
        var jsonArrayData = component.get("v.depositInfo");
        let keyfound=false;
        if(jsonArrayData == undefined || jsonArrayData == null)
        {	console.log(' 11111');
         jsonArrayData=[];
         jsonArrayData.push({key:tenantId,value:tenantValue}); 
        }
        else
        {	console.log(' 1111jsonArrayData1'+jsonArrayData);
         if(jsonArrayData.length>0)
         {
             for(let i=0;i<jsonArrayData.length;i++)
             {	console.log(' 222333333333333333333333322');
              //let tempobj= jsonArrayData[i];console.log(' tempobj[tenantId]'+tempobj[tenantId]);
              console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
              if(jsonArrayData[i].key == tenantId){
                  jsonArrayData[i].value = tenantValue;
                  keyfound=true;
                  break;
              }
             }
             if(!keyfound)
             {console.log(' 25333333333333');
                 jsonArrayData.push({key:tenantId,value:tenantValue}); 
             }
         }
         else
         {console.log(' 4444444444444444'+jsonArrayData);
          jsonArrayData=[];
          jsonArrayData.push({key:tenantId,value:tenantValue});          
         }
        }
        //jsonArrayData.push({key:keyName,value:tenAmt});
        console.log(' 26333333333333'+jsonArrayData);
        component.set("v.depositInfo" , jsonArrayData);
        //helper.checkMultipleTenantName(component, event,tenantValue,tenantId);
    },
    
    acceptMultipleDeposit: function(component, event, helper){
        helper.processMultipleDepositData(component, event);
    },
    
    acceptMultipleDepositData: function(component, event, helper){
        helper.processMultipleData(component, event);
    },
})