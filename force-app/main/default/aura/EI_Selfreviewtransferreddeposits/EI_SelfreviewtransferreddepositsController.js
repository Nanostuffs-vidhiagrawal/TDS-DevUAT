({
    doInit : function(component, event, helper) {
        // get branchId
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var action = component.get("c.viewtransferreddeposits");
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set("v.mapValues", oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.mapValues").length > i){
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
    
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.mapValues");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        if (event.target.id == "nextId") {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        else if (event.target.id == "previousId") {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    checkboxSelect: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var indexValue = event.getSource().get("v.name");  
        var depositId = event.getSource().get("v.text");
        
        let depositRecords  = component.get("v.mapValues");
        for(let i =0; i<depositRecords.length;i++ )
        {
            if(depositRecords[i].indexNumber == indexValue)
            {
                var isAllSelected = true;
                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                {
                    if(!depositRecords[i].Depositlistwrapper[k].isChecked){
                        isAllSelected = false;
                        break;
                    }
                    //depositRecords[i].Depositlistwrapper[k].isChecked = selectedHeaderCheck ;     
                }
                if(isAllSelected){
                    depositRecords[i].isSelectAll = true;
                }else{
                    depositRecords[i].isSelectAll = false;
                }
            }
        }
        component.set("v.mapValues", depositRecords);
        var pageSize = component.get("v.pageSize");
        var PaginationLst = [];
        var  oRes = component.get("v.mapValues");
        for(var i=0; i < pageSize; i++){
            if(component.get("v.mapValues").length > i){
                PaginationLst.push(oRes[i]);    
            } 
        }
        component.set('v.PaginationList', PaginationLst);
        
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var indexValue = event.getSource().get("v.name");  
        
        let depositRecords  = component.get("v.mapValues");
        for(let i =0; i<depositRecords.length;i++ )
        {
            if(depositRecords[i].indexNumber == indexValue)
            {
                depositRecords[i].isSelectAll = selectedHeaderCheck;
                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                {
                    depositRecords[i].Depositlistwrapper[k].isChecked = selectedHeaderCheck ;     
                }
            }
        }
        component.set("v.mapValues", depositRecords);
        var pageSize = component.get("v.pageSize");
        var PaginationLst = [];
        var  oRes = component.get("v.mapValues");
        for(var i=0; i < pageSize; i++){
            if(component.get("v.mapValues").length > i){
                PaginationLst.push(oRes[i]);    
            } 
        }
        component.set('v.PaginationList', PaginationLst);
        
    },

    cancelTransferBtn: function(component, event, helper){
        let indexValue = event.target.id;
        let depositRecords = component.get("v.mapValues");
        let amountToShow =0;
        let selectedDeposit = []; 
        for(let i =0; i<depositRecords.length;i++ )
        {
            if(depositRecords[i].indexNumber == indexValue)
            {
                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                {
                     console.log('depositRecords[i].Depositlistwrapper[k].isChecked => ' + depositRecords[i].Depositlistwrapper[k].isChecked);
                    if(depositRecords[i].Depositlistwrapper[k].isChecked)
                    {
                        selectedDeposit.push(depositRecords[i].Depositlistwrapper[k].objDeposit.Id);
                        amountToShow = amountToShow + depositRecords[i].Depositlistwrapper[k].objDeposit.Protected_Amount__c;
                    } 
                }
            }
        }
        console.log('selectedDeposit => ' + selectedDeposit);
        if(selectedDeposit.length < 1)
        {
            component.set("v.nodepositSelected",true);
            
        }
        else
        {
            component.set("v.nodepositSelected",false);
            component.set("v.amountToShowOnPopup",amountToShow);
            component.set("v.SelectedDepositListOnConfirm",selectedDeposit);
            component.set("v.openConfirmBoxMultiple",true);
            component.set("v.IndexNumberMulitipleRemove",indexValue);
            
        }
           
    },
    removeFromTransferBtn: function(component, event, helper){
        let depositId = event.target.id;
        component.set("v.selectedDeposit",depositId);
        component.set("v.openconfirmbox",true);  
    },
    closePopup: function(component, event, helper) {
        component.set("v.openconfirmbox",false);
        component.set("v.openConfirmBoxMultiple",false);
    },
    confirmRemoveDeposit: function(component, event, helper) {
        let eventvalue = component.get("v.selectedDeposit");
        let selectedDepositId= eventvalue.split("-")[0];
        let indexValue= eventvalue.split("-")[1];
        component.set("v.openconfirmbox",false); 
        var action = component.get("c.cancelSingleDeposit");
        action.setParams({
            selectedDepositId: selectedDepositId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                var returnValue = a.getReturnValue();
                if(returnValue=='Successfully removed')
                {
                    let depositRecords  = component.get("v.mapValues");
                    for(let i =0; i<depositRecords.length;i++ )
                    {
                        if(depositRecords[i].indexNumber == indexValue)
                        {
                            for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                            {
                                if(depositRecords[i].Depositlistwrapper[k].objDeposit.Id ==selectedDepositId)
                                {
                                    let lengthFlag = depositRecords[i].Depositlistwrapper.length;
                                    var totalAmount =  (depositRecords[i].totalamount);
                                    var  subsAmount=(depositRecords[i].Depositlistwrapper[k].objDeposit.Protected_Amount__c);
                                    depositRecords[i].Depositlistwrapper.splice(k, 1);
                                    if(lengthFlag ==1)
                                    {
                                        depositRecords.splice(i, 1);
                                    }
                                    else
                                    {
                                        var finalAmount = totalAmount-subsAmount;
                                        depositRecords[i].totalamount = finalAmount;  
                                        depositRecords[i].countdeposit = depositRecords[i].countdeposit-1;
                                    }
                                    break;
                                } 
                            }
                        }
                    }
                    
                    component.set("v.mapValues", depositRecords);
                    var pageSize = component.get("v.pageSize");
                    var PaginationLst = [];
                    var  oRes = component.get("v.mapValues");
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.mapValues").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    
                    component.set('v.totalRecordsCount', component.get("v.mapValues").length);
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.Showsuccessmessage",true);
                    component.set("v.successmessage",'This deposit transfer has been cancelled as requested.');
                    
                }
                else
                {
                    alert('Something wents wrong');
                }
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
    confirmRemoveMultipleDeposit: function(component, event) {
        let selectedDeposit= component.get("v.SelectedDepositListOnConfirm");
        let indexValue= component.get("v.IndexNumberMulitipleRemove");
        component.set("v.openConfirmBoxMultiple",false);
        var action = component.get("c.cancelMultipleDeposit");
        action.setParams({
            selectedDepositId: selectedDeposit
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            debugger;
            
                var returnValue = a.getReturnValue();
                console.log("confirmRemoveMultipleDeposit returnValue => " + returnValue);
            if (state == "SUCCESS") {
                if(returnValue=='Successfully removed')
                {
                    let depositRecords  = component.get("v.mapValues");
                    
                    for(let i =0; i<depositRecords.length;i++ )
                    {
                        if(depositRecords[i].indexNumber == indexValue)
                        {
                            for(let j=0; j< selectedDeposit.length ;j++)
                            {
                                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                                {
                                    if(depositRecords[i].Depositlistwrapper[k].objDeposit.Id ==selectedDeposit[j])
                                    {
                                        let lengthFlag = depositRecords[i].Depositlistwrapper.length;
                                        var totalAmount =  (depositRecords[i].totalamount);
                                        var  subsAmount=(depositRecords[i].Depositlistwrapper[k].objDeposit.Protected_Amount__c);
                                        depositRecords[i].Depositlistwrapper.splice(k, 1);
                                        if(lengthFlag ==1)
                                        {
                                            depositRecords.splice(i, 1);
                                        }
                                        else
                                        {
                                            var finalAmount = totalAmount-subsAmount;
                                            depositRecords[i].totalamount = finalAmount;  
                                            depositRecords[i].countdeposit = depositRecords[i].countdeposit-1;
                                        }
                                    } 
                                }
                                
                            }
                            
                        }
                    }
                    
                    component.set("v.mapValues", depositRecords);
                    var pageSize = component.get("v.pageSize");
                    var PaginationLst = [];
                    var  oRes = component.get("v.mapValues");
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.mapValues").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.totalRecordsCount', component.get("v.mapValues").length);
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.Showsuccessmessage",true);
                    component.set("v.successmessage",'This deposit transfer has been cancelled as requested.');   
                }
                
            }
            debugger;
        });
        $A.enqueueAction(action);
        
    }
    
})