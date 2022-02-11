({
    doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 2200);
    },
    
    doInit : function(component, event, helper) { 
        
        component.set("v.SDS_InstId",$A.get("$Label.c.SDS_InstId"));
        component.set("v.SDS_MerchantCode",$A.get("$Label.c.SDS_MerchantCode"));
        component.set("v.SDS_WorldpayURL",$A.get("$Label.c.SDS_WorldpayURL"));  
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branch = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var status = urlParams.get('status');
        var topUpVal = urlParams.get('topUpVal');
        var topUpAmnt = urlParams.get('topUpAmnt');
        component.set("v.topUpAmt",topUpAmnt);
        if(topUpVal == true || topUpVal == 'true'){
            console.log('topUpVal '+topUpVal);
            component.set("v.isTopUp",true);
        }
        var action = component.get("c.getDepositsToPay");
        
        if(status == 'registered'){
            status = $A.get("$Label.c.Registered_not_paid");
        }else if(status == 'held'){
            status = "Deposits held by scheme";
        }else if(status == 'awaiting'){
            status = "Awaiting payment";
        }
        
        
        component.set("v.Status",status)
        console.log('log !! '+component.get("v.isTopUp"));
        action.setParams({
            depositId :depositId,
            status :status,
            branchid :branch,
            topUpVal:topUpVal,
            topUpAmnt:topUpAmnt
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                console.log('line-->17' + JSON.stringify(result));
                
                component.set("v.depositList" ,result);
            }
            else if (state === "INCOMPLETE") {
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                //alert('line 21');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    
    checkBoxSelection : function(component, event, helper) {
        var head = document.getElementById("headCheckbox").checked;
        var childCB = component.find("checkboxDeposit");

        for(var i = 0 ; i<=childCB.length;i++){
            component.find("checkboxDeposit")[i].set("v.value",head);
        }
        
    },
    selectBankTransfer : function(component, event, helper) {
        
        //helper.setDepositParameters(component, event, helper);
        //??? Set all values
        var depositList = component.get("v.depositList");
        var BLK_Number = '';
        var blkSelected = false;
        var selectedList = [];
        var isNullPayment = false;
        for (var element of depositList) {
            if(element.isSelected){
                if(element.paymentAmount == undefined || element.paymentAmount < 1 ){
                    isNullPayment = true;
                }
                selectedList.push(element)
            }
            
        }
        
        if(isNullPayment){
            helper.showToast('Error!','Please add a positive Payment Amount','error');
            // alert('Please add a positive Payment Amount');
            return;
        }
        if(selectedList.length < 1){
            helper.showToast('Error!','Please select a Deposit','error');
            // alert('Please select a Deposit');
            return ;
        }
        component.set("v.selectedList",selectedList);
        
        if(selectedList.length > 1){
            

            var action = component.get("c.getBulkNumber");
            action.setParams({});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    component.set("v.PaymentReferenceNumber", result);
                    BLK_Number = result;
                    
                    
                    
                }
                else if (state === "INCOMPLETE") {
                    helper.showToast('Warning!','Process incomplete','warning');
                    // alert('line 21');
                    
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                                
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
        
        
        
        
        
        var amountTobePaid = 0;
        var DepositsToBePaid = '';
        var PaymentReferenceNumber = '';
        var TotalDeposits = 0;
        for (var element of selectedList) {
            
            TotalDeposits += 1;
            amountTobePaid += element.paymentAmount;
            if(DepositsToBePaid === ''){
                DepositsToBePaid = element.objDeposit.Deposit_Account_Number__c;
            }else{
                DepositsToBePaid +=','+ element.objDeposit.Deposit_Account_Number__c;
            }
            
            
        }
        component.set("v.AmountToBePaid", amountTobePaid);
        component.set("v.DepositsToBeProtected",DepositsToBePaid );
        if(BLK_Number == ''){
            component.set("v.PaymentReferenceNumber", DepositsToBePaid);
        }else{
            component.set("v.PaymentReferenceNumber", BLK_Number);
        }
        
        component.set("v.TotalDeposits",TotalDeposits );
        if(TotalDeposits > 0){
            
            component.set("v.isPaymentTypeSelection", false);
            component.set("v.isBankTransferSelected", true);
        }
        
    },
    selectCheque : function(component, event, helper) {
        
        //helper.setDepositParameters(component, event, helper);
        //set all values
        
        var depositList = component.get("v.depositList");
        var BLK_Number = '';
        var blkSelected = false;
        var selectedList = [];
        var isNullPayment = false;
        for (var element of depositList) {
            if(element.isSelected){
                if(element.paymentAmount == undefined || element.paymentAmount < 1 ){
                    isNullPayment = true;
                } 
                
                selectedList.push(element)
            }
            
        }
        
        if(isNullPayment){
            helper.showToast('Error!','Please add a positive Payment Amount','error');
            // alert('Please add a positive Payment Amount');
            return;
        }
        
        if(selectedList.length < 1){
            helper.showToast('Error!','Please select a Deposit','error');
            //  alert('Please select a Deposit');
            return ;
        }
        
        component.set("v.selectedList",selectedList);
        if(selectedList.length > 1){
            
            var action = component.get("c.getBulkNumber");
            action.setParams({});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    component.set("v.PaymentReferenceNumber", result);
                    BLK_Number = result;
                    
                    
                    
                }
                else if (state === "INCOMPLETE") {
                    helper.showToast('Warning!','Process incomplete','warning'); 
                    
                    // alert('line 21');
                    
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " + 
                                                 errors[0].message,'error');
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
        
        
        var depositList = component.get("v.depositList");
        var amountTobePaid = 0;
        var DepositsToBePaid = '';
        var PaymentReferenceNumber = '';
        var TotalDeposits = 0;
        for (var element of selectedList) {
            
            TotalDeposits += 1;
            amountTobePaid += element.paymentAmount;
            if(DepositsToBePaid === ''){
                DepositsToBePaid = element.objDeposit.Deposit_Account_Number__c;
            }else{
                DepositsToBePaid +=','+ element.objDeposit.Deposit_Account_Number__c;
            }
            
            
        }
        component.set("v.AmountToBePaid", amountTobePaid);
        component.set("v.DepositsToBeProtected",DepositsToBePaid );
        if(BLK_Number == ''){
            component.set("v.PaymentReferenceNumber", DepositsToBePaid);
        }else{
            component.set("v.PaymentReferenceNumber", BLK_Number);
        }
        component.set("v.TotalDeposits",TotalDeposits );
        if(TotalDeposits > 0){
            component.set("v.isPaymentTypeSelection", false);
            component.set("v.isChequeSelected", true);
            
        } 
    },
    backToPaymentSelection : function(component, event, helper) {
        
        component.set("v.isPaymentTypeSelection", true);
        component.set("v.isChequeSelected", false);
        component.set("v.isBankTransferSelected", false);
        component.set("v.isWorldpaySelected", false);
        
    },
    ChequeConfirmed: function(component, event, helper) {
        //Installment Creation 
        //Update Deposit Staus
        
        console.log('depositList>>>>'+JSON.stringify(component.get("v.depositList")))
        
        var action = component.get("c.updateDepositsInstallments");
        action.setParams({
            depositInstallmentList :component.get("v.selectedList"),
            paymentMethod :'Cheque',
            referenceNumber : component.get("v.PaymentReferenceNumber")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.isPaymentTypeSelection", false);
                component.set("v.isChequeSelected", false);
                component.set("v.isChequeConfirmed", true);
                component.set("v.depositList",component.get("v.depositList"))
                
                
            }
            else if (state === "INCOMPLETE") {
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                //alert('line 21');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    BankTransferConfirmed: function(component, event, helper) {
        //Installment Creation 
        //Update Deposit Staus
        
        

        var action = component.get("c.updateDepositsInstallments");
        action.setParams({
            depositInstallmentList :component.get("v.selectedList"),
            paymentMethod :'Bank Transfer',
            referenceNumber : component.get("v.PaymentReferenceNumber")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.isPaymentTypeSelection", false);
                component.set("v.isBankTransferSelected", false);
                component.set("v.isBankTransferConfirmed", true);
                component.set("v.depositList",component.get("v.depositList"))
                
            }
            else if (state === "INCOMPLETE") {
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                //   alert('line 21');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    
    debitCardSelected : function(component, event, helper) {
        
        //helper.setDepositParameters(component, event, helper);
        //set all values
        
        var depositList = component.get("v.depositList");
          var topUpAmt = component.get("v.topUpAmt");
        var BLK_Number = '';
        var blkSelected = false;
        var selectedList = [];
        var isNullPayment = false;
        for (var element of depositList) {
            if(element.isSelected){
                if(element.paymentAmount == undefined || element.paymentAmount < 1 ){
                   if(topUpAmt == 0.0){
                        isNullPayment = true;
                    }
                }
                selectedList.push(element)
            }
            
        }
        
        if(isNullPayment){
            helper.showToast('Error!','Please add a positive Payment Amount','error');
            
            //alert('Please add a positive Payment Amount');
            return;
        }
        if(selectedList.length < 1){
            helper.showToast('Error!','Please select a Deposit','error');
            
            //  alert('Please select a Deposit');
            return ;
        }
        component.set("v.selectedList",selectedList);
        
        if(selectedList.length > 1){
            
            var action = component.get("c.getBulkNumber");
            action.setParams({});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    component.set("v.PaymentReferenceNumber", result);
                    BLK_Number = result;
                    
                    
                    
                }
                else if (state === "INCOMPLETE") {
                    helper.showToast('Warning!','Process incomplete','warning'); 
                    
                    alert('line 21');
                    
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                                
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
        
        var depositList = component.get("v.depositList");
        var amountTobePaid = 0;
        var DepositsToBePaid = '';
        var PaymentReferenceNumber = '';
        var TotalDeposits = 0;
        for (var element of selectedList) {
            
            TotalDeposits += 1;
            
            amountTobePaid += element.paymentAmount;
            
            if(DepositsToBePaid === ''){
                DepositsToBePaid = element.objDeposit.Deposit_Account_Number__c;
            }else{
                DepositsToBePaid +=','+ element.objDeposit.Deposit_Account_Number__c;
            }
            
            
        }
        component.set("v.AmountToBePaid", amountTobePaid);
        component.set("v.DepositsToBeProtected",DepositsToBePaid );
        if(BLK_Number == ''){
            component.set("v.PaymentReferenceNumber", DepositsToBePaid);
        }else{
            component.set("v.PaymentReferenceNumber", BLK_Number);
        }
        component.set("v.TotalDeposits",TotalDeposits );
        if(TotalDeposits > 0){
            component.set("v.isPaymentTypeSelection", false);
            component.set("v.isWorldpaySelected", true);
        } 
    },
    worldPayConfirmed: function(component, event, helper) {
        
        //Installment Creation 
        //Update Deposit Staus
        
        console.log('**== '+JSON.stringify(component.get("v.depositList")))
        debugger;
        var action = component.get("c.updateDepositsInstallments");
        action.setParams({
            depositInstallmentList :component.get("v.selectedList"),
            paymentMethod :'Debit Card',
            referenceNumber : component.get("v.PaymentReferenceNumber")
            
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.isPaymentTypeSelection", false);
                component.set("v.isBankTransferSelected", false);
                component.set("v.isWorldpayConfirmed", true);
                
                
            }
            else if (state === "INCOMPLETE") {
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                // alert('line 21');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            
                            console.log("Error message: " + 
                                        errors[0].message);
                            
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
        
    },
    cancelPayment: function(component, event, helper){
        var selectedList = [];
        var depositList = component.get("v.depositList");
        for (var element of depositList) {
            if(element.isSelected){
                
                selectedList.push(element)
            }
            
        }
        if(selectedList.length < 1){
            helper.showToast('Error!','Please select a Deposit','error');
            // alert('Please select a Deposit');
            return ;
        }
        
        component.set("v.selectedList",selectedList);
        component.set("v.isCancel",true);
    },
    closeModel:  function(component, event, helper){
        component.set("v.isCancel",false);
        
        return false;
    },
    yesCancel:  function(component, event, helper){
        
        var depositList = component.get("v.depositList");
        var selectedList = component.get("v.selectedList");
        
        
        if(selectedList.length > 0){
            
            var currentURL = window.location.href;
            var urlStr = currentURL.split("status=")[1];
            var status = urlStr.split("&")[0];
            var depositId = urlStr.split("id=")[1];
            var branch = currentURL.split("branchid=")[1];
            var action = component.get("c.cancelPaymentDeposit");
            if(status == 'registered'){
                status = $A.get("$Label.c.Registered_not_paid");
            }else if(status == 'held'){
                status = "Deposits held by scheme";
            }else if(status == 'awaiting'){
                status = "Awaiting payment";
            }
            action.setParams({
                depositInstallmentList :component.get("v.selectedList"), 
                depositId :depositId,
                status :status,
                branchid :branch
                
                
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    
                    component.set("v.isCancel",false);
                    component.set("v.isConfirmed",true);
                    
                    component.set("v.depositList",result)
                    return false;
                    
                }
                else if (state === "INCOMPLETE") {
                    helper.showToast('Warning!','Process incomplete','warning'); 
                    return false;
                    //alert('line 21');
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                                console.log("Error message: " + 
                                            errors[0].message);
                                return false;
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                            return false;
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
            return false;
        }
        return false;
        
    },
    downloadpitemplate : function(component, event, helper) {
        var depositid = event.target.id;
        
       // var customlbl ='https://uat-tds.cs87.force.com/';
        //var customlbl ='https://thedisputeservice--uat--c.visualforce.com';
        // alert(customlbl);
        //let currentURL = window.location.origin;
        //let redirectURL = currentURL +'/apex/EI_Prescribeinformation?id=a0L26000003qcDh';
       // var redirectURL = ''+customlbl+'/apex/EI_Prescribeinformation?id='+depositid+'';
         var redirectURL = '/EI_PrescribedInformationNew?id='+depositid;
        window.open(redirectURL);
    },
    
    
})