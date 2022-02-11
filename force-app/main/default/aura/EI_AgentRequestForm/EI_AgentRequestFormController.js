({
    doInit: function (component, event, helper) {
        
        helper.getError(component, event, helper);
        var currentURL = window.location.href;
        var depositId = currentURL.split("depositId=")[1];

        component.set("v.showInitialform",true);
        var action = component.get("c.fetchRepaymentrecord");
        action.setParams({ depositId: depositId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.find("goBackBtn").set("v.name", "parentPage");
                var result = response.getReturnValue();
                let totalRepayments = result[0].Total_Amount_By_Agent_Landlord__c;
				
                let totalDepositsHeld = result[0].Deposit__r.Protected_Amount__c;/*+result[0].Total_Amount_By_Agent_Landlord__c*/
                let remainderToAllocateBttn2 = parseFloat(result[0].Total_Amount_Offer_from_AALL_To_Tenant__c)-parseFloat(totalRepayments);
                
                component.set("v.totalDepositsHeld", totalDepositsHeld);
                component.set("v.totalRepayments", totalRepayments);
                component.set("v.remainderToAllocateBttn2", remainderToAllocateBttn2);
                component.set("v.remainderToAllocateBttn3", totalDepositsHeld);
                component.set("v.totalDepRepaymentBttn2", totalRepayments);
                component.set("v.agentLLName", result[0].Account__r.Name);
				component.set("v.agentAccountId",result[0].Account__c);
                
                for(var i=0; i<result[0].Repayment_Request_Lines__r.length;i++) 
                {
                    if(isNaN(result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c)) {
                        result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c=parseFloat(0);
                    }
                }
                component.set("v.repaymentRec", result);
                
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("result:", result);
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
        helper.checkBankDetails(component, event, helper);
        
        helper.getLoggedUserAccountId(component, event, helper);

    },
   
    removeZero: function (component, event, helper) {
        
        var edValue = event.getSource().get("v.value");
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>=1 && !s.includes(".")) { s = s.substring(1,9999); }
            return s;
        }
        var trimeVal = trimNumber(edValue);
        
        event.getSource().set("v.value",trimeVal);
        
    },
    
    checkTenancyEndDate: function (component, event, helper) {
        
        component.set("v.isTenEndDateValid",false);
        component.set("v.isFutureDateError",false);
        component.set("v.renderAgreeButton",false);
        
        var endDate = document.getElementById("endDateId").value;
        var endMonth = document.getElementById("endMonthId").value;
        var endYear = document.getElementById("endYearId").value;
        
        if(endDate!="" && endMonth!="" && endYear!="" && 
           endDate!=null && endMonth!=null && endYear!=null
           && endDate!=undefined && endMonth!=undefined && endYear!=undefined) 
        {
            component.set("v.tenancyEndDate",endDate);
            component.set("v.tenancyEndMonth",endMonth);
            component.set("v.tenancyEndYear",endYear);
            
            let tenancyEndDate = endDate+'-'+endMonth+'-'+endYear;
            let isValidDate = validatedate(tenancyEndDate);
            
            var today = new Date();
            var todayDate = today.getDate();
            var todayMonth = today.getMonth()+1;
            var todayYear = today.getFullYear();
            
            
            if(isValidDate)
            {
                let setEndDate = endYear+'-'+endMonth+'-'+endDate;
                if(endYear == todayYear)
                {
                    if(endMonth == todayMonth)
                    {
                        if(endDate<=todayDate)
                        {
                            component.set("v.renderAgreeButton",true);
                            component.set("v.endDateByTenant",setEndDate);
                        } else {
                            component.set("v.isFutureDateError",true);
                        }
                    } else if(endMonth < todayMonth) {
                        component.set("v.renderAgreeButton",true);
                        component.set("v.endDateByTenant",setEndDate);
                    } else {
                        component.set("v.isFutureDateError",true);
                    }
                } else if(endYear < todayYear) {
                    component.set("v.renderAgreeButton",true);
                    component.set("v.endDateByTenant",setEndDate);
                } else {
                    component.set("v.isFutureDateError",true);
                }
                
            } else {
                component.set("v.isTenEndDateValid",true);
            }
            
            if(!isValidDate || component.get("v.isFutureDateError"))
            {
                component.set("v.buttonClicked","");
            }
            
            //GOD class to check date validity
            function validatedate(d)
            {
                var dateformat = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
                // Match the date format through regular expression
                if(d.match(dateformat))
                {     
                    var splittedDate = d.split('-');
                    var splittedDateLength = splittedDate.length;
                    if (splittedDateLength>1)
                    {
                        var pdate = d.split('-');
                    }
                    var dd = parseInt(pdate[0]);
                    var mm  = parseInt(pdate[1]);
                    var yy = parseInt(pdate[2]);
                    
                    // Create list of days of a month [assume there is no leap year by default]
                    var ListofDays = [31,28,31,30,31,30,31,31,30,31,30,31];
                    if (mm==1 || mm>2)
                    {
                        if (dd>ListofDays[mm-1])
                        {
                            return false;
                        }
                    }
                    if (mm==2)
                    {
                        var lyear = false;
                        if ( (!(yy % 4) && yy % 100) || !(yy % 400)) 
                        {
                            lyear = true;
                        }
                        if ((lyear==false) && (dd>=29))
                        {
                            return false;
                        }
                        if ((lyear==true) && (dd>29))
                        {
                            return false;
                        }
                    }
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        
    },
    
    updateDate: function (component, event, helper) {
        var selectedDate = event.getParam("value");
        var browserDate = new Date(selectedDate);
        var serverDate = new Date();
        var inputbrowserDate = component.find("browserDate");
        if (browserDate.getTime() > serverDate.getTime()) {
            inputbrowserDate.setCustomValidity("Date cannot be in Future");
            component.find("renderAgreeBtn").set("v.isTrue", false);
        } 
        else {  
            inputbrowserDate.setCustomValidity("");
            //component.find("renderAgreeBtn").set("v.isTrue", true);
            component.set("v.renderAgreeButton",true);
        }
    },
    
    userTypeHandler: function (component, event, helper) {
        
        // NEW CODE START
        var buttonName = event.getSource().getLocalId();
        var currentButton = component.get("v.buttonClicked");
        
        var tenantTotalRecievingAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
        
        if (buttonName == "I agree with the repayment request" && tenantTotalRecievingAmount > 0 &&
        	currentButton != "I agree with the repayment request" ) 
        {
            component.set("v.showNextBtn", true);
            component.set("v.showAmountAmendmentForm", false);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.noBankDetailsFoundError",false);
            
            component.set("v.disableBankEdit", false);
            component.set("v.disableInterBankEdit", false);
            component.set("v.showEditBankDetailsSect", false);
            //isButton1Clicked
        } else if (buttonName == "AgreeButSplit" && currentButton != "AgreeButSplit") {
            component.set("v.showAmountAmendmentForm", true);
            component.set("v.showNextBtn", false);
            //component.set("v.showInitialform", false);
            component.set("v.showResolveByTds", false);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.noBankDetailsFoundError",false);
            component.set("v.isMoreThanDepAmt",false);
            
            component.set("v.disableBankEdit", false);
            component.set("v.disableInterBankEdit", false);
            component.set("v.showEditBankDetailsSect", false);
        } else if (buttonName == "resolveByTds" && currentButton != "resolveByTds") {
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm",false);
            component.set("v.resolvedWithoutScheme", false);
            
            component.set("v.disableBankEdit", false);
            component.set("v.disableInterBankEdit", false);
            component.set("v.showEditBankDetailsSect", false);
        } else if (buttonName == "resolveWithoutTDS" && currentButton != "resolveWithoutTDS") {
            component.set("v.showResolveByTds", false);
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm", false);
            component.set("v.resolvedWithoutScheme", true);
            component.set("v.noBankDetailsFoundError",false);
            
            component.set("v.disableBankEdit", false);
            component.set("v.disableInterBankEdit", false);
            component.set("v.showEditBankDetailsSect", false);
        }
        component.set("v.buttonClicked",buttonName);
        // NEW CODE END
        
    },
    
    goTo3rdBttnSection: function (component, event, helper) {
        if (component.get("v.buttonClicked") == "resolveByTds" /*&& currentButton != "resolveByTds"*/) {
        	/*component.set("v.isUpperSection", false);
            component.set("v.showResolveByTds", true);
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm", false);
            //component.set("v.showInitialform", false);
            component.set("v.renderAgreeButton", false);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.noBankDetailsFoundError",false);
            component.set("v.isMoreThanDepAmt",false);*/
            component.set("v.isUpperSection",false);
            component.set("v.renderAgreeButton",false);
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm",false);
            component.set("v.showResolveByTds", true);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.noBankDetailsFoundError",false);
            component.set("v.isMoreThanDepAmt",false);
        }
    },
    
    onChangeResolveByTds: function (component, event, helper) {
        console.log('TEST');
		function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>1) { s = s.substring(1,9999); }
            return s;
        }
        let buttonName = component.get("v.buttonClicked");
         console.log('buttonName ' +buttonName);
        if(buttonName=="resolveByTds") {
            console.log('damage' + component.get("v.repaymentRec[0].Tenant_Dmg_to_Property__c"));
            component.set("v.errorToBeDisplayed",false);
            component.set("v.isLessThanDepAmtBttn3",false);
            component.set("v.isMoreThanDepAmtBttn3",false);
            var tenantTotalRecievingAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
            /*if(!component.get("v.isBankDetailsPresent"))
            {
                component.set("v.noBankDetailsFoundError",true);
            }*/
            
            var TenantAmoutRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
            var TotalOldAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
            var totalAmtToTenant = 0;
            var sumOfTenantRepaymentsToAGLL = 0;
            
            if(component.get("v.repaymentRec[0].AL_CleaningAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Cleaning__c")>0)
            {
                var cleaningAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Cleaning__c")).toFixed(2);
                if(cleaningAmt=='' || cleaningAmt==undefined || isNaN(cleaningAmt) || cleaningAmt<0) {
                    component.set("v.repaymentRec[0].Tenant_Cleaning__c",0);
                } else if(cleaningAmt > component.get("v.repaymentRec[0].AL_CleaningAmt__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +parseFloat(cleaningAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(cleaningAmt);
                }
            }
        	
            if(component.get("v.repaymentRec[0].AL_DmgPropAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Dmg_to_Property__c")>0)
            {
                var damageAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Dmg_to_Property__c")).toFixed(2);
                
                if(damageAmt=='' || damageAmt==undefined || isNaN(damageAmt) || damageAmt<0) {
                    component.set("v.repaymentRec[0].Tenant_Dmg_to_Property__c",0);
                } else if(damageAmt > component.get("v.repaymentRec[0].AL_DmgPropAmt__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL + parseFloat(damageAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(damageAmt);
                }
            }
        
            if(component.get("v.repaymentRec[0].AL_GardeningAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Gardening__c")>0)
            {
                var gardeningAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Gardening__c")).toFixed(2);
    			
                if(gardeningAmt=='' || gardeningAmt==undefined || isNaN(gardeningAmt) || gardeningAmt<0) {
    				component.set("v.repaymentRec[0].Tenant_Gardening__c",0);
                } else if(gardeningAmt > component.get("v.repaymentRec[0].AL_GardeningAmt__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL + parseFloat(gardeningAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL + parseFloat(gardeningAmt);
                }
            }
            
            if(component.get("v.repaymentRec[0].AL_RedecorationAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Redecoration__c")>0)
            {
                var redecorationAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Redecoration__c")).toFixed(2); 
                if(redecorationAmt=='' || redecorationAmt==undefined || isNaN(redecorationAmt) || redecorationAmt<0 ) {
                    component.set("v.repaymentRec[0].Tenant_Redecoration__c",0);
                } else if(redecorationAmt > component.get("v.repaymentRec[0].AL_RedecorationAmt__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(redecorationAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(redecorationAmt);
                }
            }
            
            if(component.get("v.repaymentRec[0].AL_Rent_Arrears__c")>0 || component.get("v.repaymentRec[0].Tenant_Rent_Arrears__c")>0)
            {
                var rentArrearsAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Rent_Arrears__c")).toFixed(2); 
                if(rentArrearsAmt=='' || rentArrearsAmt==undefined || isNaN(rentArrearsAmt) || rentArrearsAmt<0) {
                    component.set("v.repaymentRec[0].Tenant_Rent_Arrears__c",0);
                } else if(rentArrearsAmt > component.get("v.repaymentRec[0].AL_Rent_Arrears__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(rentArrearsAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(rentArrearsAmt);
                }
            }
            
            if(component.get("v.repaymentRec[0].AL_OtherAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Other__c")>0)
            {
                var otherAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Other__c")).toFixed(2);
                if(otherAmt=='' || otherAmt==undefined || isNaN(otherAmt) || otherAmt<0) {
                    component.set("v.repaymentRec[0].Tenant_Other__c",0);
                } else if(otherAmt > component.get("v.repaymentRec[0].AL_OtherAmt__c")) {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(otherAmt);
                    component.set("v.errorToBeDisplayed",true);
                } else {
                    sumOfTenantRepaymentsToAGLL = sumOfTenantRepaymentsToAGLL +  parseFloat(otherAmt);
                }
            }
			
            for (let i = 0; i < TenantAmoutRec.length; i++) {
                if(TenantAmoutRec[i].Account__c==TenantAmoutRec[i].Repayment_Request__r.Deposit__r.Customer__c) {
                    TenantAmoutRec[i].Tenant_ReqAmt__c=parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2);
                }
                if(!isNaN(TenantAmoutRec[i].Tenant_ReqAmt__c) && TenantAmoutRec[i].Tenant_ReqAmt__c >= 0 
                   && TenantAmoutRec[i].Tenant_ReqAmt__c!='' && TenantAmoutRec[i].Tenant_ReqAmt__c!=undefined)
                {
                    if(TenantAmoutRec[i].Account__c!=TenantAmoutRec[i].Repayment_Request__r.Deposit__r.Customer__c) {
                        totalAmtToTenant = parseFloat(totalAmtToTenant) + parseFloat(TenantAmoutRec[i].Tenant_ReqAmt__c);
                    }
                    
                } else {
                    //console.log('Line 492');
                    //component.set("v.errorToBeDisplayed",true);
                }
            }
            for (let i = 0; i < component.get("v.repaymentRec[0].Repayment_Request_Lines__r").length; i++) {
                var repReqItem=component.get("v.repaymentRec[0].Repayment_Request_Lines__r")[i];
            }
			
            component.set("v.sumOfTotalAmountToTenant",parseFloat(totalAmtToTenant).toFixed(2));
            let tempSum=parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2);
			
            component.set("v.sumOfTenantRepaymentsToAGLL",parseFloat(tempSum));
            var remainderToAllocate = parseFloat(component.get("v.totalDepositsHeld")) - parseFloat(tempSum) - parseFloat(totalAmtToTenant);
            
            console.log('*** '+parseFloat(remainderToAllocate).toFixed(2));
            
            component.set("v.remainderToAllocateBttn3",parseFloat(remainderToAllocate).toFixed(2));
            var totalDepRepayment = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(totalAmtToTenant);
            component.set("v.totalDepRepaymentBttn3",parseFloat(totalDepRepayment).toFixed(2));
            
			var newRemainderToAllocate=parseFloat(remainderToAllocate.toFixed(2));
            if (newRemainderToAllocate < 0) {
                component.set("v.isMoreThanDepAmtBttn3",true);
            }
            if (newRemainderToAllocate > 0) {
                component.set("v.isLessThanDepAmtBttn3",true);
            }
            
        }
    },
    
    validateOtherAmt : function(component, event, helper) {
        var othAmt= Number(component.get("v.repaymentRec[0].Tenant_Other__c"));
        var othAmtReason = component.get("v.repaymentRec[0].Tenant_Other_Reason__c");
        
        if(component.get("v.repaymentRec[0].Tenant_Other__c") != "" && othAmt > 0
           && (othAmtReason == undefined || othAmtReason == "" || othAmtReason.length > 300)){
            component.set("v.otherAmtValidationError" , true);
        } else {
            component.set("v.otherAmtValidationError" , false);
        }
        $A.enqueueAction(component.get('c.onChangeResolveByTds'));
    },
    
    goToSummarySection: function (component, event, helper) {
        console.log('testclick');
        let buttonName = component.get("v.buttonClicked");
        
        if(buttonName!="" && buttonName!=null && buttonName!=undefined)
        {
            if(buttonName=="I agree with the repayment request") {
                if(!component.get("v.isBankDetailsPresent"))
                {
                    component.set("v.noBankDetailsFoundError",true);
                } else {
                    
                    let TenantRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
                    for(var i=0; i<TenantRec.length; i++) {
                        TenantRec[i].Tenant_ReqAmt__c=0;
                    }
                    component.set("v.sumOfTotalAmountToTenant",0);
                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",true);
                    
                    /*component.set("v.sumOfTenantRepaymentsToAGLL",component.get("v.repaymentRec[0].Total_Amount_By_Tenant__c"));
                    let sumOfTotalAmountToTenant = parseFloat(component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c"))
                    								- parseFloat(component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c"));
                    component.set("v.sumOfTotalAmountToTenant",sumOfTotalAmountToTenant);*/
                }
            } 
            else if(buttonName=="AgreeButSplit") {
                //debugger;
                component.set("v.noBankDetailsFoundError",false);
                component.set("v.isMoreThanDepAmt",false);
                component.set("v.isLessThanDepAmt",false);
				
				if(!component.get("v.isBankDetailsPresent"))
                {
					component.set("v.noBankDetailsFoundError",true);
                }
                
                var tenantTotalRecievingAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
                var TenantAmoutRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
                var TotalOldAmount = parseFloat(component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c"))
                					 - parseFloat(component.get("v.repaymentRec[0].Total_Amount_By_Agent_Landlord__c"));
                var TotalnewAmount = 0;
                
                for (let i = 0; i < TenantAmoutRec.length; i++) {
                    if(!isNaN(TenantAmoutRec[i].Tenant_ReqAmt__c) && TenantAmoutRec[i].Tenant_ReqAmt__c >= 0 )
                    {
                        if(TenantAmoutRec[i].Account__c==TenantAmoutRec[i].Repayment_Request__r.Deposit__r.Customer__c) {

                            TenantAmoutRec[i].Tenant_ReqAmt__c=parseFloat(sumOfTenantRepaymentsToAGLL);
                        } else {
                            TotalnewAmount = parseFloat(TotalnewAmount) + parseFloat(TenantAmoutRec[i].Tenant_ReqAmt__c);
                        }
                    }
                    //if(!isNaN(TenantAmoutRec[i].Tenant_ReqAmt__c))
                    	//TotalnewAmount = parseFloat(TotalnewAmount) + parseFloat(TenantAmoutRec[i].Tenant_ReqAmt__c);
                }
                component.set("v.sumOfTotalAmountToTenant",parseFloat(TotalnewAmount).toFixed(2));
                
                var remainderToAllocate = parseFloat(component.get("v.totalDepositsHeld"))-parseFloat(TotalnewAmount)-
                    					  parseFloat(component.get("v.totalRepayments"));
                component.set("v.remainderToAllocateBttn2",parseFloat(remainderToAllocate).toFixed(2));
                var totalDepRepayment = parseFloat(component.get("v.totalRepayments"))+parseFloat(TotalnewAmount);
				component.set("v.totalDepRepaymentBttn2",parseFloat(totalDepRepayment).toFixed(2));
                
                if (parseFloat(TotalnewAmount) > parseFloat(TotalOldAmount)) {
                    component.set("v.isMoreThanDepAmt",true);
                } else if (parseFloat(TotalnewAmount) < parseFloat(TotalOldAmount)) {
                    component.set("v.isLessThanDepAmt",true);
                }
                if(TotalOldAmount == TotalnewAmount && component.get("v.isBankDetailsPresent")) {
                    component.set("v.sumOfTenantRepaymentsToAGLL",component.get("v.repaymentRec[0].Total_Amount_By_Tenant__c"));
                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",true);
                }
                
            }
			else if(buttonName=="resolveByTds") {
                console.log('Test517');
                component.set("v.errorToBeDisplayed",false);
                component.set("v.isLessThanDepAmtBttn3",false);
                component.set("v.isMoreThanDepAmtBttn3",false);
                var tenantTotalRecievingAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
                if(!component.get("v.isBankDetailsPresent"))
                {
                    component.set("v.noBankDetailsFoundError",true);
                }
                
                var TenantAmoutRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
                var TotalOldAmount = component.get("v.repaymentRec[0].Total_Amount_Offer_from_AALL_To_Tenant__c");
                var totalAmtToTenant = 0;
                var sumOfTenantRepaymentsToAGLL = 0;
                
                if(component.get("v.repaymentRec[0].AL_CleaningAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Cleaning__c")>0)
                {
                	var cleaningAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Cleaning__c")).toFixed(2);
                	if(cleaningAmt == undefined || isNaN(cleaningAmt) || cleaningAmt<0) {
                    	component.set("v.errorToBeDisplayed",true);
            		} else if(cleaningAmt > component.get("v.repaymentRec[0].AL_CleaningAmt__c")) {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(cleaningAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                    	sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(cleaningAmt);
            		}
                    console.log('sumOfTenantRepaymentsToAGLL Cln '+sumOfTenantRepaymentsToAGLL);
                }
                
                if(component.get("v.repaymentRec[0].AL_DmgPropAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Dmg_to_Property__c")>0)
                {
                     console.log('sumOfTenantRepaymentsToAGLL DMG bef '+sumOfTenantRepaymentsToAGLL);
                	var damageAmt = parseFloat(component.get("v.repaymentRec[0].Tenant_Dmg_to_Property__c")).toFixed(2);
                	if(damageAmt == undefined || isNaN(damageAmt) || damageAmt<0) {
                    	component.set("v.errorToBeDisplayed",true);
                    } else if(damageAmt > component.get("v.repaymentRec[0].AL_DmgPropAmt__c")) {
                         console.log('elseif');
                        sumOfTenantRepaymentsToAGLL =parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(damageAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                         console.log('else '+damageAmt);
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(damageAmt);
            		}
                     console.log('sumOfTenantRepaymentsToAGLL DMG '+sumOfTenantRepaymentsToAGLL);
                }
                
                if(component.get("v.repaymentRec[0].AL_GardeningAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Gardening__c")>0)
                {
                	var gardeningAmt = component.get("v.repaymentRec[0].Tenant_Gardening__c")
                	if(gardeningAmt == undefined || isNaN(gardeningAmt) || gardeningAmt<0) {
                    	component.set("v.errorToBeDisplayed",true);
            		} else if(gardeningAmt > component.get("v.repaymentRec[0].AL_GardeningAmt__c")) {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(gardeningAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) + parseFloat(gardeningAmt);
            		}
                }
                
                if(component.get("v.repaymentRec[0].AL_RedecorationAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Redecoration__c")>0)
                {
                	var redecorationAmt = component.get("v.repaymentRec[0].Tenant_Redecoration__c")
                	if(redecorationAmt == undefined || isNaN(redecorationAmt) || redecorationAmt<0 ) {
                    	component.set("v.errorToBeDisplayed",true);
            		} else if(redecorationAmt > component.get("v.repaymentRec[0].AL_RedecorationAmt__c")) {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(redecorationAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                    	sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(redecorationAmt);
            		}
                }
                
                if(component.get("v.repaymentRec[0].AL_Rent_Arrears__c")>0 || component.get("v.repaymentRec[0].Tenant_Rent_Arrears__c")>0)
                {
                	var rentArrearsAmt = component.get("v.repaymentRec[0].Tenant_Rent_Arrears__c")
                	if(rentArrearsAmt == undefined || isNaN(rentArrearsAmt) || rentArrearsAmt<0) {
                    	component.set("v.errorToBeDisplayed",true);
            		} else if(rentArrearsAmt > component.get("v.repaymentRec[0].AL_Rent_Arrears__c")) {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(rentArrearsAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                    	sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(rentArrearsAmt);
            		}
                }
                
                if(component.get("v.repaymentRec[0].AL_OtherAmt__c")>0 || component.get("v.repaymentRec[0].Tenant_Other__c")>0)
                {
                	var otherAmt = component.get("v.repaymentRec[0].Tenant_Other__c")
                	if(otherAmt == undefined || isNaN(otherAmt) || otherAmt<0) {
                    	component.set("v.errorToBeDisplayed",true);
            		} else if(otherAmt > component.get("v.repaymentRec[0].AL_OtherAmt__c")) {
                        sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(otherAmt);
                        component.set("v.errorToBeDisplayed",true);
                    } else {
                    	sumOfTenantRepaymentsToAGLL = parseFloat(sumOfTenantRepaymentsToAGLL) +  parseFloat(otherAmt);
            		}
                }
				
                for (let i = 0; i < TenantAmoutRec.length; i++) {
                    if(!isNaN(TenantAmoutRec[i].Tenant_ReqAmt__c) && TenantAmoutRec[i].Tenant_ReqAmt__c >= 0 )
                    {
                        if(TenantAmoutRec[i].Account__c==TenantAmoutRec[i].Repayment_Request__r.Deposit__r.Customer__c) {

                            TenantAmoutRec[i].Tenant_ReqAmt__c=parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2);
                        } else {
                            totalAmtToTenant = parseFloat(totalAmtToTenant) + parseFloat(TenantAmoutRec[i].Tenant_ReqAmt__c);
                        }
                    } else {
                        component.set("v.errorToBeDisplayed",true);
                        
                    }
                }
                for (let i = 0; i < component.get("v.repaymentRec[0].Repayment_Request_Lines__r").length; i++) {
                    var repReqItem=component.get("v.repaymentRec[0].Repayment_Request_Lines__r")[i];
                }
                
                component.set("v.sumOfTotalAmountToTenant",parseFloat(totalAmtToTenant).toFixed(2));
                
        		component.set("v.sumOfTenantRepaymentsToAGLL",parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2));
                console.log('@@ '+parseFloat(component.get("v.totalDepositsHeld")) + ' && '+parseFloat(sumOfTenantRepaymentsToAGLL) +' ** '+ parseFloat(totalAmtToTenant));
                var remainderToAllocate = parseFloat(component.get("v.totalDepositsHeld")) - parseFloat(sumOfTenantRepaymentsToAGLL) - parseFloat(totalAmtToTenant);
                
                console.log('amount '+parseFloat(remainderToAllocate).toFixed(2));
                component.set("v.remainderToAllocateBttn3",parseFloat(remainderToAllocate).toFixed(2));
               
                var totalDepRepayment = parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2) + parseFloat(totalAmtToTenant).toFixed(2);
                component.set("v.totalDepRepaymentBttn3",parseFloat(totalDepRepayment).toFixed(2));
                console.log('###--> '+parseFloat(sumOfTenantRepaymentsToAGLL).toFixed(2)  +' && '+component.get("v.repaymentRec")[0].Total_Amount_By_Agent_Landlord__c);
				var newRemainderToAllocate=parseFloat(remainderToAllocate).toFixed(2);
                if (newRemainderToAllocate < 0) {
                    /*alert("You cannot ask for less or high to be paid to the agent/landlord than the amount of " +
                          TotalOldAmount +" that was previously offered.");*/
                    component.set("v.isMoreThanDepAmtBttn3",true);
                }
 				if (newRemainderToAllocate > 0) {
                    /*alert("You cannot ask for less or high to be paid to the agent/landlord than the amount of " +
                          TotalOldAmount +" that was previously offered.");*/
                    component.set("v.isLessThanDepAmtBttn3",true);
                }
                
                if(sumOfTenantRepaymentsToAGLL==component.get("v.repaymentRec")[0].Total_Amount_By_Agent_Landlord__c) {
                    component.set("v.errorToBeDisplayed",true);
                }
                
                if(newRemainderToAllocate == 0 && component.get("v.isBankDetailsPresent") && !component.get("v.errorToBeDisplayed") 
                   && !component.get("v.otherAmtValidationError") ) {
                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",true);
                    //$('#confSect', window.parent.document).get(0).scrollIntoView();
                } else 
                {
                    $('#maincon', window.parent.document).get(0).scrollIntoView();
                }
            }
            else if(buttonName=="resolveWithoutTDS") {
                
                if(!component.get("v.isBankDetailsPresent"))
                {
                    component.set("v.noBankDetailsFoundError",true);
                } else {
                    let TenantRec = component.get("v.repaymentRec[0]");
                    
                    let action = component.get("c.tenantResolveWithoutScheme");
                    action.setParams({
                        TenantRec: JSON.stringify(TenantRec),
                        endDateByTenant: component.get("v.endDateByTenant")
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set("v.hideWindow1",true);
                            component.set("v.confirmationSection",false);
                            component.set("v.thankuSection",true);
                            var result = response.getReturnValue();
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("result:", result);
                                    console.log("Error message: " + errors[0].message);
                                }
                            } else {
                                console.log("Unknown error");
                            }
                        }
                    });
                    $A.enqueueAction(action);
                    
                }
            }
        }
        else {
            //alert('No button was selected');
        }
    },
    
    goBackFromSummarySection: function (component, event, helper) {
          console.log('$$ back '+component.get("v.remainderToAllocateBttn3"));
        component.set("v.confirmationSection",false);
        component.set("v.showInitialform",true);
        component.set("v.hideWindow1",false);
        component.set("v.isUpperSection",true);
        component.set("v.renderAgreeBtn",true);
        component.set("v.noBankDetailsFoundError",false);
        component.set("v.isMoreThanDepAmt",false);
     
        var buttonName = component.get("v.buttonClicked");
        if (buttonName == "I agree with the repayment request") 
        {
            component.set("v.showNextBtn", true);
            component.set("v.showAmountAmendmentForm", false);
            component.set("v.resolvedWithoutScheme", false);
        } else if (buttonName == "AgreeButSplit") {
            
            component.set("v.showAmountAmendmentForm", true);
            component.set("v.showNextBtn", false);
            component.set("v.showResolveByTds", false);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.isMoreThanDepAmt",false);
        } else if (buttonName == "resolveByTds") {
        	component.set("v.isUpperSection", false);
            component.set("v.showResolveByTds", true);
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm", false);
            //component.set("v.showInitialform", false);
            component.set("v.renderAgreeButton", false);
            component.set("v.resolvedWithoutScheme", false);
            component.set("v.isMoreThanDepAmt",false);
        } else if (buttonName == "resolveWithoutTDS") {
            component.set("v.showResolveByTds", false);
            component.set("v.showNextBtn", false);
            component.set("v.showAmountAmendmentForm", false);
            component.set("v.resolvedWithoutScheme", true);
            component.set("v.noBankDetailsFoundError",false);
        }
    },
    
    goToThankuSection: function (component, event, helper) {

        let disableSubmit = event.getSource();
        disableSubmit.set('v.disabled',true);
        
        var currentButton = component.get("v.buttonClicked");
		let totalRepaymentsAgent = component.get("v.totalRepayments");
        
        if (currentButton == "I agree with the repayment request") {
            let TenantRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
            
            let action = component.get("c.aggreedToRepayment");
            //component.set("v.showSubmit", false);
            action.setParams({ RepaymentLineRec: JSON.stringify(TenantRec),
                               totalRepayments: totalRepaymentsAgent,
                               endDateByTenant: component.get("v.endDateByTenant")
                             });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",false);
                    component.set("v.thankuSection",true);
                    var result = response.getReturnValue();
                    
                } else if (state === "ERROR") {
                      disableSubmit.set('v.disabled',false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("result:", result);
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } 
        else if (currentButton == "AgreeButSplit") {
            component.set("v.showSubmit", false);
            let TenantAmoutRec = component.get("v.repaymentRec[0].Repayment_Request_Lines__r");
            
            let action = component.get("c.aggreedbutsplit");
            action.setParams({ RepaymentLineRec: JSON.stringify(TenantAmoutRec),
                               totalRepayments: totalRepaymentsAgent,
                               endDateByTenant: component.get("v.endDateByTenant")
                             });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",false);
                    component.set("v.thankuSection",true);
                    var result = response.getReturnValue();
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("result:", result);
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else if (currentButton == "resolveByTds") {
            
            let TenantRec = component.get("v.repaymentRec[0]");
            let tenantRepReqLines = component.get(
                "v.repaymentRec[0].Repayment_Request_Lines__r"
            );
            
            let action = component.get("c.tenantResponseUpdate");
            action.setParams({
                TenantRec: JSON.stringify(TenantRec),
                RepaymentLineRec: JSON.stringify(tenantRepReqLines),
                endDateByTenant: component.get("v.endDateByTenant")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    var result = response.getReturnValue();
                    component.set("v.hideWindow1",true);
                    component.set("v.confirmationSection",false);
                    component.set("v.thankuSection",true);
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("result:", result);
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    /* ------------------------------------------------------------------------------------------------------- */
    
    backToDepositDetail: function (component, event, helper) {
        /* var currentURL = window.location.href;
        var depositId = currentURL.split("depositId=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: { id: depositId }
        }); */
        window.history.back();
    },
    
    bankDetailsEditSection: function (component, event, helper) {
    	component.set("v.showEditBankDetailsSect",true);
	},
        
    updateBankDetails: function (component, event, helper) {
        helper.updateBankDetails(component, event);
    },
    
    updateInternationalBankDetails: function (component, event, helper) {
        helper.updateInternationalBankDetails(component, event);
    },
        
    cancelBankDetails: function (component, event, helper) {
    	component.set("v.showEditBankDetailsSect",false);
	},
        
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "bankSuccessMessage":
                component.set("v.bankSuccessMessage", false);
                break;
            case "bankErrorMessage":
                component.set("v.bankErrorMessage", false);
                break;
             case "nameOnAccountBlankError":
                component.set("v.nameOnAccountBlankError", false);
                break;
             case "accountNumberBlankError":
                component.set("v.accountNumberBlankError", false);
                break;
            case "invalidAccountNumberError":
                component.set("v.invalidAccountNumberError", false);
                break;
            case "sortCodeBlankError":
                component.set("v.sortCodeBlankError", false);
                break;
            case "invalidSortCodeError":
                component.set("v.invalidSortCodeError", false);
                break;
            case "intbankSuccess":
                component.set("v.intbankSuccessMessage", false);
                break;
            case "intbankname":
                component.set("v.intbanknameerror", false);
                break;
            case "intbankaccount":
                component.set("v.intbankaccounterror", false);
                break;
            case "nameOnAccountSpecialCharError":
                component.set("v.nameOnAccountSpecialCharError", false);
                break;
            case "intNameOnAccountSpecialCharError":
                component.set("v.intNameOnAccountSpecialCharError", false);
                break;    
            case "bankOfAmericaSortCode":
                component.set("v.bankOfAmericaSortCode", false);
                break;    
        }
    },
    
    NumSplCharsCheck: function(component, event, helper){
        var keyCode = (event.which) ? event.which : event.keyCode;
        if(keyCode!= 32 && ((keyCode < 65 || keyCode > 90) && (keyCode < 97 || keyCode > 123))
          	&& (keyCode != 46 && keyCode > 31 && (keyCode < 48 || keyCode > 57))) {
            
            if (event.preventDefault) {
                event.preventDefault();
                
            } else {
                event.returnValue = false;
                
            } 
            
        }
       
    },
        
});