({
    doInit : function(component, event, helper) {
        // get branchId
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var action = component.get("c.viewAwatingTransferredDeposits");
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            console.log("awaiting data => " + JSON.stringify(response.getReturnValue()));
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
                console.log('awaiting error => '+ JSON.stringify(response.getError()));
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
        console.log("indexValue => " + indexValue);
        console.log("depositId => " + depositId);

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
        
       // var datecheck = event.getSource().get("v.text");
        
        
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
                    if(depositRecords[i].Depositlistwrapper[k].isChecked)
                    {
                        selectedDeposit.push(depositRecords[i].Depositlistwrapper[k].objDeposit.Id);
                        amountToShow = amountToShow + depositRecords[i].Depositlistwrapper[k].objDeposit.Protected_Amount__c;
                    } 
                }
            }
        }
        if(selectedDeposit.length < 1)
        {
            component.set("v.nodepositSelected",true);
            
        }
        else
        {
            component.set("v.nodepositSelected",false);
            component.set("v.amountToShowOnPopup",amountToShow);
            component.set("v.SelectedDepositListOnConfirm",selectedDeposit);
            component.set("v.openConfirmBoxMultipleReject",true);
            component.set("v.IndexNumberMulitipleRemove",indexValue);
            
        }
           
    },
    closePopup: function(component, event, helper) {
        component.set("v.ShowVerifyPopup",false);
        component.set("v.openConfirmBoxMultipleReject",false);
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
    
    confirmRejectMultipleDeposit: function(component, event) {
        let selectedDeposit= component.get("v.SelectedDepositListReject");
        let indexValue= component.get("v.IndexNumberMulitipleRemove");
        component.set("v.openConfirmBoxMultipleReject",false);
        var action = component.get("c.rejectMultipleDeposit");
        action.setParams({
            selectedDepositId: selectedDeposit
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                var returnValue = a.getReturnValue();
                if(returnValue=='Successfully rejected')
                {
                    let depositRecords  = component.get("v.mapValues");
                    for(let i =0; i<depositRecords.length;i++ )
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
                                        break;
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
                    component.set("v.successmessage",'Thank you for your response. We have notified the other agent/landlord that you have rejected the transfer of the selected deposit(s).');   
                }
                else
                {
                    alert('Looks like something went wrong, please try again later.');
                }
                
            }
        });
        $A.enqueueAction(action);
        
    },
    acceptSelectedDeposits :  function(component, event)
    {
        let depositRecords  = component.get("v.mapValues");
        let selectedDepositIds=[];
        let  indexnumber=[]; 
        let  indexwithvalue = [];
        
        for(let i =0; i<depositRecords.length;i++ )
        {
            let depositIdfrombatch = [];
            var verificationobject = new Object();
            for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
            {
                if(depositRecords[i].Depositlistwrapper[k].isChecked==true)
                {
                    //alert("if ticked => " + depositRecords[i].Depositlistwrapper[k].objDeposit.Name + depositRecords[i].Depositlistwrapper[k].isChecked);
                    if(indexnumber.length >0)
                    {
                        if( !(indexnumber.includes(depositRecords[i].indexNumber)))
                        {
                            indexnumber.push(depositRecords[i].indexNumber);
                        } 
                    }
                    else
                    {
                        indexnumber.push(depositRecords[i].indexNumber);
                    }
                    selectedDepositIds.push(depositRecords[i].Depositlistwrapper[k].objDeposit.Id);
                	depositIdfrombatch.push(depositRecords[i].Depositlistwrapper[k].objDeposit);
                }
            }
            if(depositIdfrombatch.length > 0)
            {
                let randomnumber = Math.floor(Math.random() * (depositIdfrombatch.length - 0) + 0);
                console.log("depo Details => " + JSON.stringify(depositRecords[i].Depositlistwrapper[randomnumber].objDeposit));
                verificationobject.indexNumber = depositRecords[i].indexNumber;
                verificationobject.danNumber = depositIdfrombatch[randomnumber].Name; //depositRecords[i].Depositlistwrapper[randomnumber].objDeposit.Name;
                verificationobject.propertyAddress = depositIdfrombatch[randomnumber].Property_Address__c; //depositRecords[i].Depositlistwrapper[randomnumber].objDeposit.Property_Address__c;
                verificationobject.depositId = depositIdfrombatch[randomnumber].Id;
                verificationobject.attemptsLeft = depositIdfrombatch[randomnumber].No_of_attempt__c; //depositRecords[i].Depositlistwrapper[randomnumber].objDeposit.No_of_attempt__c;
                verificationobject.isVerifyBlocked = depositIdfrombatch[randomnumber].Bulk_transfer_attempts__c; //depositRecords[i].Depositlistwrapper[randomnumber].objDeposit.Bulk_transfer_attempts__c;
                indexwithvalue.push(verificationobject);
            }
        }
        if(selectedDepositIds.length > 0)
        {
            component.set("v.SelectedDepositListAccept",selectedDepositIds);
            component.set("v.SelectedDepositMapAccept",indexwithvalue);
            component.set("v.currentIndexNumber",1);
            component.set("v.totalVerificationBatchNumber",indexwithvalue.length);
            component.set("v.ShowVerifyPopup",true);
            
            console.log("indexwithvalue[0] => " + JSON.stringify(indexwithvalue[0]));
            var attemptsLeft = indexwithvalue[0].attemptsLeft;
            var isVerifyBlocked = indexwithvalue[0].isVerifyBlocked;
            if(isVerifyBlocked){
                component.set("v.currentAttempt", 0);
            }
            else if(attemptsLeft >= 1){
                component.set("v.currentAttempt", attemptsLeft);
            }else{
                component.set("v.currentAttempt", 3);
            }
        }
        else
        {
            component.set("v.nodepositSelected",true);
            component.set("v.ShowVerifyPopup",false);
        }
        
    },
    rejectSelectedDeposits :  function(component, event)
    {
        
        let depositRecords  = component.get("v.mapValues");
        let selectedDepositIds=[];
        for(let i =0; i<depositRecords.length;i++ )
        {
                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                {
                    if(depositRecords[i].Depositlistwrapper[k].isChecked==true)
                    {
                        selectedDepositIds.push(depositRecords[i].Depositlistwrapper[k].objDeposit.Id);
                    }   
                }
        }
        
        if(selectedDepositIds.length < 1)
        {
            component.set("v.nodepositSelected",true);
            component.set("v.openConfirmBoxMultipleReject",false);
            
        }
        else
        {
            component.set("v.openConfirmBoxMultipleReject",true);
            component.set("v.SelectedDepositListReject",selectedDepositIds);
            
            
        }
        
        
    },
    goToNextVerificationStep :  function(component, event)
    {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        let totalLength =component.get("v.totalVerificationBatchNumber");
        let indexvalue =component.get("v.currentIndexNumber");
        let currentAttempt = component.get("v.currentAttempt");
        let currentDepositId = event.getSource().get("v.value").split("-")[0];
        let BatchNumber =event.getSource().get("v.value").split("-")[1];
        let selectedDepositIds=[];
        let depositRecords  = component.get("v.mapValues");
        let tenantSurname  = ((component.get("v.tenantSurname")).replace(/[^a-zA-Z ]/g, "")).toLowerCase();
        
        let tenantSurnameList =[];
        for(let i =0; i<depositRecords.length;i++ )
        {
            if(depositRecords[i].indexNumber == BatchNumber)
            {
                for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                {
                    if(depositRecords[i].Depositlistwrapper[k].isChecked==true)
                    {
                        if(currentDepositId== depositRecords[i].Depositlistwrapper[k].objDeposit.Id)
                        {
                            for(let a =0; a<depositRecords[i].Depositlistwrapper[k].objDeposit.Deposit_Allocations__r.length;a++)
                            {
                                tenantSurnameList.push((((depositRecords[i].Depositlistwrapper[k].objDeposit.Deposit_Allocations__r[a].Deposit_Holder__r.LastName).trim()).replace(/[^a-zA-Z ]/g, "")).toLowerCase());
                            }
                            
                        }
                        selectedDepositIds.push(depositRecords[i].Depositlistwrapper[k].objDeposit.Id);
                    }    
                }
            }
        }
        
        console.log('selectedDepositIds => ' + selectedDepositIds);
        
        if(tenantSurnameList.includes(tenantSurname))
        {
            console.log('Found');
            var action = component.get("c.validateTenantNameAndAccept");
            action.setParams({
                listDepositId : selectedDepositIds,
                tenantValue : tenantSurname,
                branchId : branchId
            });
            action.setCallback(this, function(response){
                console.log("state => " + response.getState());
                var returnValue = response.getReturnValue();
                console.log("state => " + returnValue); 
                
                if(returnValue=='Successfully accepted')
                {
                    let depositRecords  = component.get("v.mapValues");
                    for(let i =0; i<depositRecords.length;i++ )
                    {
                        
                        for(let j=0; j< selectedDepositIds.length ;j++)
                        {
                            
                            for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ )
                            {
                                
                                if(depositRecords[i].Depositlistwrapper[k].objDeposit.Id == selectedDepositIds[j])
                                {
                                    let lengthFlag = depositRecords[i].Depositlistwrapper.length;
                                    var totalAmount =  (depositRecords[i].totalamount);
                                    var subsAmount=(depositRecords[i].Depositlistwrapper[k].objDeposit.Protected_Amount__c);
                                    depositRecords[i].Depositlistwrapper.splice(k, 1);
                                    if(lengthFlag ==1)
                                    {
                                        depositRecords.splice(i, 1);
                                        break;
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
                    component.set("v.mapValues", depositRecords);
                    console.log("depositRecords after accepted => " + JSON.stringify(depositRecords));
                    var pageSize = component.get("v.pageSize");
                    var PaginationLst = [];
                    var  oRes = component.get("v.mapValues");
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.mapValues").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    console.log("PaginationLst after accepted => " + JSON.stringify(PaginationLst));
                    component.set('v.totalRecordsCount', component.get("v.mapValues").length);
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.Showsuccessmessage",true);
                    component.set("v.successmessage",'Transfer successful.');   
                }
                else
                {
                    alert('Looks like something went wrong, please try again later.');
                }
                
            });
            $A.enqueueAction(action);
            
            if(totalLength != indexvalue)
            {
                component.set("v.currentIndexNumber",indexvalue+1);
                var SelectedDepositMapAccept = component.get("v.SelectedDepositMapAccept");
                console.log("SelectedDepositMapAccept => " + SelectedDepositMapAccept);
                var attemptsLeft = SelectedDepositMapAccept[indexvalue].attemptsLeft;
                var isVerifyBlocked = SelectedDepositMapAccept[indexvalue].isVerifyBlocked;
                
                if(isVerifyBlocked){
                    component.set("v.currentAttempt", 0);
                }
                else if(attemptsLeft >= 1){
                    component.set("v.currentAttempt", attemptsLeft);
                }else{
                    component.set("v.currentAttempt", 3);
                }
            }
            else
            {
                component.set("v.ShowVerifyPopup", false);
                //alert("All Verified");
            }
        }
        else
        { 
            currentAttempt--;
            console.log('increase  1 poniter', currentAttempt);
            component.set("v.currentAttempt", currentAttempt);
            let depositRecords  = component.get("v.mapValues");
            for(let i =0; i<depositRecords.length;i++ ){ 

                for(let j=0; j< selectedDepositIds.length ;j++){

                    for(let k=0; k< depositRecords[i].Depositlistwrapper.length; k++ ){

                        if(depositRecords[i].Depositlistwrapper[k].objDeposit.Id == selectedDepositIds[j]){
                            depositRecords[i].Depositlistwrapper[k].objDeposit.No_of_attempt__c = currentAttempt;
                            depositRecords[i].Depositlistwrapper[k].objDeposit.Bulk_transfer_attempts__c = true;
                        } 
                    }
                }
            }
            if(currentAttempt == 0){
                var action = component.get("c.checkBulkTransferAttempts");
                action.setParams({
                    listDepositId : selectedDepositIds,
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    //alert("Blocked" + state);
                });
                $A.enqueueAction(action);
            }
            
            var action = component.get("c.updateNoOfAttemptsLeft");
            action.setParams({
                listDepositId : selectedDepositIds,
                attemptsLeft : component.get("v.currentAttempt")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
            });
            $A.enqueueAction(action);
            
        }
        
        
         
        
        
        
        
        
        /*
        if(totalLength != indexvalue)
        {
            component.set("v.currentIndexNumber",indexvalue+1);
            //component.set("v.currentAttempt",2);
        }
        else
        {
            console.log('=====');
        }*/
        
        
    }
    
})