({
        removeZero: function (component, event, helper) {
        
        var edValue = event.getSource().get("v.value");
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>1 && !s.includes(".")) { s = s.substring(1,9999); }
            return s;
        }
        var trimeVal = trimNumber(edValue);
        
        event.getSource().set("v.value",trimeVal);
        
    },
    doInit: function (component, event, helper) {
        /*let action = component.get("c.getLoggedInUserDetail");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				
                var result = response.getReturnValue();
                component.set("v.loggedInUserName", result);
                
            }
            // Handle Error
            else if (state === "ERROR") {
                console.log(errors);
                var errors = response.getError();
                // If error then check error type
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action); */
        
        console.log('Line 24');
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('depositId');
        
        let action = component.get("c.getTenantsInformation");
        action.setParams({
            depositRecordId: depositId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				
                var result = response.getReturnValue();
                if(result != '' && result != null && result != undefined){
                    
                    if(result.length > 0){
                        component.set("v.blankAllocationList",result);
                        component.set("v.showAddressFlag",true);
                    }
                }
                
            }
            // Handle Error
            else if (state === "ERROR") {
                console.log(errors);
                var errors = response.getError();
                // If error then check error type
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action); 
        

        let action1 = component.get("c.getRequestRepayment");
        action1.setParams({
            depositId: depositId
        });
        action1.setCallback(this, function (a) {
            let state1 = a.getState();
            if (state1 == "SUCCESS") {

                var result1 = a.getReturnValue();
                //component.set("v.repaymentRec", result1);
                component.set("v.repReqLines",result1.Repayment_Request_Lines__r);
                /*console.log(JSON.stringify(result1));
                console.log('Line 23');
                console.log('Total_Amount_By_Tenant__c'+result1.Total_Amount_By_Tenant__c);*/
                
                let totalDepositsHeld = parseFloat(result1.Deposit__r.Protected_Amount__c);
                let totalRepayments = parseFloat(result1.Total_Amount_By_Tenant__c);
                /*if(result1[0].AL_CleaningAmt__c!='' && result1[0].AL_CleaningAmt__c!=undefined 
                   && result1[0].AL_CleaningAmt__c!=null)
                {
                    totalRepayments = totalRepayments+result1[0].AL_CleaningAmt__c;
                }
                if(result1[0].AL_DmgPropAmt__c!='' && result1[0].AL_DmgPropAmt__c!=undefined 
                   && result1[0].AL_DmgPropAmt__c!=null)
                {
                    totalRepayments = totalRepayments+result1[0].AL_DmgPropAmt__c;
                }
                if(result1[0].AL_GardeningAmt__c!='' && result1[0].AL_GardeningAmt__c!=undefined 
                   && result1[0].AL_GardeningAmt__c!=null)
                {
                    totalRepayments = totalRepayments+result1[0].AL_GardeningAmt__c;
                }
                if(result1[0].AL_RedecorationAmt__c!='' && result1[0].AL_RedecorationAmt__c!=undefined 
                   && result1[0].AL_RedecorationAmt__c!=null)
                {
                    totalRepayments = totalRepayments+result1[0].AL_RedecorationAmt__c;
                }
                if(result1[0].AL_Rent_Arrears__c!='' && result1[0].AL_Rent_Arrears__c!=undefined 
                   && result1[0].AL_Rent_Arrears__c!=null)
                {
                    totalRepayments = totalRepayments+result[0].AL_Rent_Arrears__c;
                }
                if(result1[0].AL_OtherAmt__c!='' && result1[0].AL_OtherAmt__c!=undefined 
                   && result1[0].AL_OtherAmt__c!=null)
                {
                    totalRepayments = totalRepayments+result1[0].AL_OtherAmt__c;
                }*/
                
                //let totalDepositsHeld = result1.Total_Amount_Offer_from_AALL_To_Tenant__c+totalRepayments;/*+result[0].Total_Amount_By_Agent_Landlord__c*/
                
                let totalRepaymentsToTenants = parseFloat(totalDepositsHeld) - parseFloat(totalRepayments);
               // console.log(totalDepositsHeld+' $$ '+totalRepayments+' ** '+'parseFloat&& '+totalRepaymentsToTenants);
                //component.set("v.totalDepositsHeld", totalDepositsHeld);
                //component.set("v.totalRepayments", totalRepayments);
                component.set("v.totalRepaymentsToTenants", parseFloat(totalRepaymentsToTenants.toFixed(2)));
                component.set("v.remainderToAllocate", parseFloat(totalDepositsHeld.toFixed(2)));
                /*component.set("v.remainderToAllocateBttn3", totalDepositsHeld);
                component.set("v.totalDepRepaymentBttn2", totalRepayments);
                component.set("v.agentLLName", result1.Account__r.Name);*/
                let totalAmtToTent = 0;
                for(var i=0; i<result1.Repayment_Request_Lines__r.length; i++)
                {
                    totalAmtToTent=totalAmtToTent+result1.Repayment_Request_Lines__r[i].Tenant_ReqAmt__c;
                }
                //totalAmtToTent=totalAmtToTent-totalRepayments;
                component.set("v.totalAmtToTent",totalAmtToTent);
                //alert(totalAmtToTent-totalRepayments);
                
                //var repaymentRec = component.get("v.repaymentRec");
                var repaymentRec = result1;
                if(isNaN(repaymentRec.Total_Amount_Requested_AL__c))
                    repaymentRec.Total_Amount_Requested_AL__c = 0;
                if(isNaN(repaymentRec.AL_CleaningAmt__c))
                    repaymentRec.AL_CleaningAmt__c = 0;                 
                if(isNaN(repaymentRec.AL_DmgPropAmt__c))
                    repaymentRec.AL_DmgPropAmt__c = 0;                  
                if(isNaN(repaymentRec.AL_GardeningAmt__c))
                    repaymentRec.AL_GardeningAmt__c = 0;                
                if(isNaN(repaymentRec.AL_Rent_Arrears__c))
                    repaymentRec.AL_Rent_Arrears__c = 0;         
                if(isNaN(repaymentRec.AL_RedecorationAmt__c))
                    repaymentRec.AL_RedecorationAmt__c = 0;         
                if(isNaN(repaymentRec.AL_OtherAmt__c))
                    repaymentRec.AL_OtherAmt__c = 0; 
                console.log('@@ '+repaymentRec.Tenant_Other_Reason__c);
                for(var i=0; i<repaymentRec.Repayment_Request_Lines__r.length;i++) 
                {
                    
                    if(isNaN(repaymentRec.Repayment_Request_Lines__r[i].AL_ReqAmt__c)) {
                        repaymentRec.Repayment_Request_Lines__r[i].AL_ReqAmt__c=parseFloat(0);
                    }
                }
                component.set("v.repaymentRec",repaymentRec);
            } 
            // Handle Error
            else if (state1 === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                // If error then check error type
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action1);

        helper.checkBankDetails(component, event, helper);
        
        //component.find("hidebutton").set("v.isTrue", false);
        //component.find("renderTenancyEndfrom").set("v.isTrue", true);
        
    },
    
    doRespondRepayment: function (component, event, helper) {
        component.find("hidebutton").set("v.isTrue", false);
        component.find("renderTenancyEndfrom").set("v.isTrue", true);
    },
    
    updateDate: function (component, event, helper) {
        
        component.find("renderAgentForm").set("v.isTrue", false);
        component.find("renderBankButton").set("v.isTrue", false);
        component.find("renderAgreeBtn").set("v.isTrue", false);
        component.find("renderRepaymentAcceptPage").set("v.isTrue", false);
        var selectedDate = event.getParam("value");
        var browserDate = new Date(selectedDate);
        
        var action = component.get("c.getCurrentDate");
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var serverDate = new Date(result);
                console.log('result',result);
                console.log('browserDate',browserDate);
                console.log('serverDate',serverDate);
                var inputbrowserDate = component.find("browserDate");
                if (browserDate.getTime() > serverDate.getTime()) {
                    inputbrowserDate.setCustomValidity("Date cannot be in Future");
                    component.find("renderAgreeBtn").set("v.isTrue", false);
                } else {
                    inputbrowserDate.setCustomValidity("");
                    component.find("renderAgreeBtn").set("v.isTrue", true);
                }
                
                var action = component.get("c.getCurrentDate");  
            }
            // Handle Error
            else if (state === "ERROR") {
                console.log(errors);
                var errors = response.getError();
                // If error then check error type
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    
    doCancelRequest: function (component, event, helper) {
        var btnValue = event.getSource().get("v.checked");
        if (btnValue) {
            var popUp = confirm("Do you want to close case?");
            if (popUp == true) {           
                 const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('depositId');

                var action = component.get("c.closeCase");
                action.setParams({
                    depositId : depositId,
                    repaymentRec: component.get("v.repaymentRec.Id")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result =  response.getReturnValue();
                        alert(
                            "The case has been cancelled as the tenancy has not yet ended."
                        );
                        component.find("renderAgreeBtn").set("v.isTrue", false);
                        component.find("renderAgentForm").set("v.isTrue", false);
                        component.find("renderRepaymentAcceptPage").set("v.isTrue", false);
                        var pageURL = window.location.origin;
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": pageURL + "/Sds/s/viewdeposit"
                        });
                        urlEvent.fire();
                        
                    } 
                    else if (state === "ERROR") {
                        console.log(errors);
                        var errors = response.getError();
                        console.log("Error message: " + 
                                    JSON.stringify(errors[0].message));
                    } else {
                        console.log("Unknown error");
                    }
                });
                $A.enqueueAction(action);
                
                
                component.find("renderAgreeBtn").set("v.isTrue", false);
                component.find("renderTenancyEndfrom").set("v.isTrue", false);
            } else {
                // alert("Case has been not been cancelled");
                //component.find("renderAgreeBtn").set("v.isTrue", false);
                component.find("checkbtn").set("v.checked", false);
            }
        } else {
            component.find("renderAgreeBtn").set("v.isTrue", false);
            btnValue.set("v.checked", false);
        }
    },
    
    doAgreeRespondRepayment: function (component, event, helper) {
        
        component.find("renderAgreeBtn").set("v.isTrue", false);
        component.find("renderAgentForm").set("v.isTrue", false);
        component.find("renderRepaymentAcceptPage").set("v.isTrue", true);
        
    },
    
    dodisAgreeRespondRepayment: function (component, event, helper) {
        // alert("dodisAgreeRespondRepayment");
        component.find("renderAgreeBtn").set("v.isTrue", false);
        component.find("renderAgentForm").set("v.isTrue", true);
    },
    
    doProceed: function (component, event, helper) {
        let validateamount = true;
        let validateReason = true;
        
        let agentOther = component.find("agentOther").get("v.value");
        
        let repaymentRec = component.get("v.repaymentRec");
        if(repaymentRec.Total_Amount_Requested_AL__c=="" || repaymentRec.Total_Amount_Requested_AL__c==undefined){           
            repaymentRec.Total_Amount_Requested_AL__c = 0;         
        }
        if(repaymentRec.AL_CleaningAmt__c=="" || repaymentRec.AL_CleaningAmt__c==undefined){           
            repaymentRec.AL_CleaningAmt__c = 0;         
        }
        if(repaymentRec.AL_DmgPropAmt__c=="" || repaymentRec.AL_DmgPropAmt__c==undefined){           
            repaymentRec.AL_DmgPropAmt__c = 0;         
        }
        if(repaymentRec.AL_GardeningAmt__c=="" || repaymentRec.AL_GardeningAmt__c==undefined){           
            repaymentRec.AL_GardeningAmt__c = 0;         
        }
        if(repaymentRec.AL_Rent_Arrears__c=="" || repaymentRec.AL_Rent_Arrears__c==undefined){           
            repaymentRec.AL_Rent_Arrears__c = 0;         
        }
        if(repaymentRec.AL_RedecorationAmt__c=="" || repaymentRec.AL_RedecorationAmt__c==undefined){           
            repaymentRec.AL_RedecorationAmt__c = 0;         
        }
        if(repaymentRec.AL_OtherAmt__c=="" || repaymentRec.AL_OtherAmt__c==undefined){           
            repaymentRec.AL_OtherAmt__c = 0;         
        }
        if (agentOther.length > 0 && (agentOther!=0 || agentOther!="0")) {
            let agentOtherReason = component.find("agentOtherReason");
            let agentOtherReasonValue = agentOtherReason.get("v.value");
            if (
                agentOtherReasonValue == null ||
                agentOtherReasonValue == undefined ||
                agentOtherReasonValue.length == 0
            ) {
                agentOtherReason.setCustomValidity("Please describe the Reason");
                validateReason = false;
                
            } else {
                agentOtherReason.setCustomValidity("");
            }
            agentOtherReason.reportValidity();
        }
        
        
        
        
        let landlordTotalAmount = parseFloat(repaymentRec.Total_Amount_Requested_AL__c);
        let totalfilledAmount = parseFloat(repaymentRec.AL_CleaningAmt__c)+parseFloat(repaymentRec.AL_DmgPropAmt__c)
        + parseFloat(repaymentRec.AL_GardeningAmt__c) + parseFloat(repaymentRec.AL_Rent_Arrears__c) +parseFloat(repaymentRec.AL_RedecorationAmt__c)+
            parseFloat(repaymentRec.AL_OtherAmt__c) ;
        if(totalfilledAmount == landlordTotalAmount)
        {
            validateamount = true;
        }
        else
        {
            validateamount = false;
        }
        
        if(validateamount)
        {
            if (agentOther.length > 0 && (agentOther!=0 || agentOther!="0")) {
                let agentOtherReason = component.find("agentOtherReason");
                let agentOtherReasonValue = agentOtherReason.get("v.value");
                if (
                    agentOtherReasonValue == null ||
                    agentOtherReasonValue == undefined ||
                    agentOtherReasonValue.length == 0
                ) {
                    agentOtherReason.setCustomValidity("Please describe the Reason");
                    validateReason = false;
                    
                } else {
                    agentOtherReason.setCustomValidity("");
                    component.find("renderAgentForm").set("v.isTrue", false);
                    component.find("renderBankButton").set("v.isTrue", true);
                }
                agentOtherReason.reportValidity();
            }
            else{           
                let action1 = component.get("c.getBankDetails");
                action1.setCallback(this, function (a) {                 
                    var state1 = a.getState(); 
                    console.log('state1-->>'+state1);
                    if (state1 === "SUCCESS") {
                        console.log('a.getReturnValue()-->>'+a.getReturnValue());
                        if(a.getReturnValue() ===null)
                        {
                            //   alert('bank fetched line 166')
                            component.find("renderAgentForm").set("v.isTrue", false);
                            component.find("renderBankButton").set("v.isTrue", true);
                        }
                        else
                        {
                            
                            component.set("v.BankDetailsFlag",true);
                            component.find("renderBankButton").set("v.isTrue", false);
                            component.find("renderAgentForm").set("v.isTrue", false);
                            $A.enqueueAction(component.get('c.addBankDetails')); 
                             
                        }
                    } else if (state1 === "ERROR") {
                        var errors1 = a.getError();				             
                        if (errors1[0] && errors1[0].message) {
                            console.log("Error message: " + 
                                        JSON.stringify(errors1[0].message));
                            
                        } 
                    }
                });
                $A.enqueueAction(action1);
            }}
        else
        {
            component.find("renderBankButton").set("v.isTrue", false);
            alert('Amount you would like to receive and break down of all amount should be equivalent');
        }
    },
    
    doEdit: function (component, event, helper) {
        component.find("renderRepaymentAcceptPage").set("v.isTrue", false);
        component.find("renderAgentForm").set("v.isTrue", true);
    },
    
    agentOther: function (component, event, helper) {
        let agentOther = component.find("agentOther").get("v.value");
        if (agentOther.length > 0) {
            component.find("agentOtherReason").set("v.required", true);
            component.find("renderBankButton").set("v.isTrue", false);
        } else {
            component.find("agentOtherReason").set("v.required", false);
        }
    },
    
    hideBankButton :  function (component, event, helper) {
        component.find("renderBankButton").set("v.isTrue", false);
    },
    
    goBack: function (component, event, helper) {
        component.find("renderAgentForm").set("v.isTrue", false);
        component.find("renderBankButton").set("v.isTrue", false);
        component.find("renderAgreeBtn").set("v.isTrue", true);
    },
    
    addBankDetails: function (component, event, helper) {
        
        var allValid = false;
        var saveDetail = false;
        var flag = component.get("v.BankDetailsFlag");
        if(flag)
        {
			allValid = true; 
            saveDetail = true;
        }
        else
        {
            allValid = component.find('bankInfo').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
             saveDetail = component.find('saveDetail').get("v.checked");
        }

        if (allValid) {  
            
            
            if(saveDetail){
                var msg ='Are you sure?';
                if (confirm(msg)) {
                    let BankDetails =  component.get("v.BankDetails");
                    var action = component.get("c.addBankDetail");
                 //   console.log(JSON.stringify(component.get("v.repaymentRec")));
                    action.setParams({
                        BankDetails : JSON.stringify(BankDetails),
                        RequsetRec : JSON.stringify(component.get("v.repaymentRec"))
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                       // alert('line 345'+state);
                        if (state === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "You've responded to the tenant request.",
                                "type":"success"
                            });
                            toastEvent.fire();
                            var result = response.getReturnValue();
                            var pageURL = window.location.origin;
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": pageURL + "/Sds/s/viewdeposit"
                            });
                            urlEvent.fire();
                        } 
                        else if (state === "ERROR") {
                         //   console.log(errors);
                            var errors = response.getError();
                        //    console.log("Error message: " + 
                       //                 JSON.stringify(errors[0].message));
                        } else {
                     //       console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(action);
                }else{}
            }
            
        } else {
            alert('Please update the invalid form entries and try again.');
        }   
    },
    
    backToBreakDown : function (component, event, helper) {
        component.find("renderAgentForm").set("v.isTrue", true);
        component.find("renderBankButton").set("v.isTrue", false);
    },
    
    doSubmit : function (component, event, helper) {
        var repaymentRec =  component.get("v.repaymentRec");
        helper.doSubmitHelper(component, repaymentRec);
        
        let tenancyEndDate = component.get("v.tenancyEndDate");
        var action = component.get("c.AgreedTorequest");
        console.log('tenancyEndDate', component.get("v.tenancyEndDate"));
        action.setParams({
            RecId : component.get("v.repaymentRec.Id"),
            Amount : component.get("v.tenantrequestedAmount"),
            TenancyEndDate: tenancyEndDate
        });
        //    console.log("repaymentRec",component.get("v.repaymentRec.Id"));
        //    console.log("tenantrequestedAmount",component.get("v.tenantrequestedAmount"));
        action.setCallback(this, function (response) {
            var state = response.getState();
            alert('state--->>'+state);
            alert('response.getReturnValue()--->>'+response.getReturnValue());
            if (state === "SUCCESS") {
                
                component.find("renderAgreeBtn").set("v.isTrue", false);
                component.find("renderAgentForm").set("v.isTrue", false);
                component.find("renderRepaymentAcceptPage").set("v.isTrue", true);
                var result =  response.getReturnValue();
                if(result == "Bank Detail Missing. Email will be sent via MailJet Api"){
                    alert(result);
                }
                let pageURL1 = window.location.origin;
                let urlEvent1 = $A.get("e.force:navigateToURL");
                urlEvent1.setParams({
                    "url": pageURL1 + "/Sds/s/viewdeposit"
                });
                urlEvent1.fire();
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    backToDepositDetail: function (component, event, helper) {
		//location.reload();

         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('depositId');
        console.log('depositId -->>'+depositId+'qaz');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: { id: depositId }
        });
        console.log('depositId -->>'+depositId+'qaz');
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
            //component.set("v.isValidTenancyStartDate",isValidDate);
            console.log(isValidDate);
            
            if(isValidDate)
            {
                console.log(`todayDate - ${todayDate} todayMonth - ${todayMonth} - todayYear - ${todayYear}`);
                console.log(`endDate - ${endDate} endMonth - ${endMonth} - endYear - ${endYear}`);
                if(endYear == todayYear)
                {
                    //console.log('Line 84');
                    if(endMonth == todayMonth)
                    {
                        //console.log('Line 87');
                        if(endDate<=todayDate)
                        {
                            component.set("v.isValidTenancyEndDate",true);
                        } else {
                            component.set("v.isFutureDateError",true);
                        }
                    } else if(endMonth < todayMonth) {
                        component.set("v.isValidTenancyEndDate",true);
                    } else {
                        component.set("v.isFutureDateError",true);
                    }
                } else if(endYear < todayYear) {
                    component.set("v.isValidTenancyEndDate",true);
                } else {
                    component.set("v.isFutureDateError",true);
                }
                
            } else {
                component.set("v.isTenEndDateValid",true);
            }
            
            if(!isValidDate || component.get("v.isFutureDateError"))
            {
                component.set("v.buttonClicked","");
                component.set("v.isValidTenancyEndDate",false);
            }
            
            if(component.get("v.isValidTenancyEndDate"))
            {
                //let setEndDate = todayYear+'-'+todayMonth+'-'+todayDate;
                let setEndDate = endYear+'-'+endMonth+'-'+endDate;
                component.set("v.tenancyEndDate",setEndDate);
                console.log('Line 573 -> ',component.get("v.tenancyEndDate"));
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
    
    tenancyHasEnded: function (component, event, helper) {
        //alert('Ended');
        component.set("v.isTenancyEnded",true);
        component.set("v.isFutureDateError",false);
        component.set("v.isTenEndDateValid",false);
        component.set("v.isValidTenancyEndDate",false);
        
        var firstyes = component.find("firstyes");
        var firstno = component.find("firstno"); 
        $A.util.removeClass(firstno, "clickButton");
        $A.util.addClass(firstyes, "clickButton");
    },
    
    tenancyHasNotEnded: function (component, event, helper) {
        component.set("v.isTenancyEnded",false);
        component.set('v.showConfirmDialog', true);
        
        var firstyes = component.find("firstyes");
        var firstno = component.find("firstno"); 
        $A.util.removeClass(firstyes, "clickButton");
        $A.util.addClass(firstno, "clickButton");
    },
    
    tenancyHasNotEndedYes: function (component, event, helper) {
        
        //component.set("v.isTenancyEnded",false);
        //var popUp = confirm("Do you want to close case?");
             
        console.log("Line 738 -> The case has been cancelled as the tenancy has not yet ended.");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('depositId');
        var action = component.get("c.closeCase");
        action.setParams({
            depositId : depositId,
            repaymentRec: component.get("v.repaymentRec.Id")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =  response.getReturnValue();
                //alert("The case has been cancelled as the tenancy has not yet ended.");
                
                const queryString = window.location.search;
                const urlParams = new URLSearchParams(queryString);
                const depositId = urlParams.get('depositId');
                console.log('depositId -->>'+depositId+'qaz');
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "depositsummarypage"
                    },
                    state: { id: depositId }
                });
                /*component.find("renderAgreeBtn").set("v.isTrue", false);
                    component.find("renderAgentForm").set("v.isTrue", false);
                    component.find("renderRepaymentAcceptPage").set("v.isTrue", false);
                    var pageURL = window.location.origin;
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": pageURL + "/Sds/s/viewdeposit"
                    });
                    urlEvent.fire();*/
                    
                } 
                else if (state === "ERROR") {
                    console.log(errors);
                    var errors = response.getError();
                    console.log("Error message: " + 
                                JSON.stringify(errors[0].message));
                } else {
                    console.log("Unknown error");
                }
            });
        $A.enqueueAction(action);
        
    },
    
    tenancyHasNotEndedNo: function (component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    
    agreeingRepayment: function (component, event, helper) {
        component.set("v.buttonClicked","agreeRepayment");
    },
    
    disagreeingRepayment: function (component, event, helper) {
        component.set("v.buttonClicked","disagreeRepayment");
    },
    
    saveDetailsForLater: function (component, event, helper) {
        let isChecked = event.target.checked;
        component.set("v.saveBankForLater",isChecked);
        console.log('Line 702 - ',component.get("v.saveBankForLater"));
    },
    
    bankDetailsEditSection: function (component, event, helper) {
        //alert('Bank details section will render');
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
    
    goToNextSection: function (component, event, helper) {
        
        let buttonClicked = component.get("v.buttonClicked");
        
        if(buttonClicked == "agreeRepayment")
        {
            var isBankPresent = component.get("v.isBankDetailsPresent");
            //console.log('Line 652 agree');
            if(isBankPresent) {
                
                let disableBttn = event.getSource();
                disableBttn.set('v.disabled',true);
                var repaymentRec =  component.get("v.repaymentRec");
                helper.doSubmitHelper(component, repaymentRec);
                console.log('Line 391');
                console.log('Line 735 saveBankForLater -> ', component.get("v.saveBankForLater"));
                //console.log('browserDate', component.get("v.browserDate"));
                console.log('Line 744 -> ',component.get("v.tenancyEndDate"));
                
                var action = component.get("c.AgreedTorequest");
                action.setParams({
                    RecId : component.get("v.repaymentRec.Id"),
                    Amount : component.get("v.sumOfTenantRepaymentsToAGLL"),
                    TenancyEndDate: component.get("v.tenancyEndDate"),
                    saveBankDetForLater: component.get("v.saveBankForLater")
                });
                //    console.log("repaymentRec",component.get("v.repaymentRec.Id"));
                //    console.log("tenantrequestedAmount",component.get("v.tenantrequestedAmount"));
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state--->>'+state);
                    console.log('response.getReturnValue()--->>'+response.getReturnValue());
                    if (state === "SUCCESS") {
                        /*component.find("renderAgreeBtn").set("v.isTrue", false);
                    component.find("renderAgentForm").set("v.isTrue", false);
                    component.find("renderRepaymentAcceptPage").set("v.isTrue", true);*/
                    var result =  response.getReturnValue();
                    console.log(JSON.stringify(result));
                    
                    component.set("v.showInitialform",false);
                    component.set("v.thankuSection",true);
                    //if(result == "Bank Detail Missing. Email will be sent via MailJet Api"){
                    
                    //}
                    /*let pageURL1 = window.location.origin;
                    let urlEvent1 = $A.get("e.force:navigateToURL");
                    urlEvent1.setParams({
                        "url": pageURL1 + "/Sds/s/viewdeposit"
                    });
                    urlEvent1.fire();*/
                } 
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('errors -> ',errors);
                } else {
                }
            });
                $A.enqueueAction(action);
            } else {
                component.set("v.noBankDetailsFoundError",true);
            }
            
            
        } else if(buttonClicked == "disagreeRepayment") {
            
            component.set("v.isUpperSection",false);
            component.set("v.disagreeSection",true);
        }
    },
    
    /*call validateOtherAmt function on onchange event on Other field*/ 
    validateOtherAmt : function(component, event, helper) {
        var othAmt= Number(component.get("v.repaymentRec.AL_OtherAmt__c"));
        var othAmtReason = component.get("v.repaymentRec.AL_Other_Reason__c");
        
        if(component.get("v.otherAmt") != "" && othAmt > 0
           && (othAmtReason == undefined || othAmtReason == "" || othAmtReason.length > 300)){
            component.set("v.otherAmtValidationError" , true);
        }else{
            component.set("v.otherAmtValidationError" , false);
        }
        var action = component.get('c.handleOnChange');
        $A.enqueueAction(action);        
    },
	
    handleOnChange: function (component, event, helper) {
        component.set("v.errorToBeDisplayed",'');
        component.set("v.isLessThanDepAmtBttn",false);
        component.set("v.isMoreThanDepAmtBttn",false);
        
        let repaymentRequestLineObj = component.get("v.repaymentRec.Repayment_Request_Lines__r");
        let totalAmountToTenant = 0;
        
        for(var i=0; i<repaymentRequestLineObj.length; i++) {
            
            var tempVar = repaymentRequestLineObj[i].AL_ReqAmt__c;
            
            if(tempVar!='' && tempVar!=undefined && tempVar!=null && tempVar!= 0 
               && !isNaN(repaymentRequestLineObj[i].AL_ReqAmt__c))
            {
                totalAmountToTenant = totalAmountToTenant + parseFloat(Math.round(tempVar*100)/100);
                repaymentRequestLineObj[i].AL_ReqAmt__c = parseFloat(Math.round(tempVar*100)/100);
            }
        }
        // alert('totalAmountToTenant 123 '+totalAmountToTenant);
        
        //var whichOne = event.getSource().getLocalId();
        //var total = component.get("v.totalAmount");
        /* if(whichOne == 'Other') {
            let othAmount = component.get("v.OtherAmount");
            if(othAmount >0)
                component.set("v.textArea",true);
            else
                component.set("v.textArea",false);
        } */
        
        let repaymentRequestObj = component.get("v.repaymentRec");
        
        var totalRepaymentToAgentLL = 0;
        var clean = repaymentRequestObj.AL_CleaningAmt__c;
        var damage = repaymentRequestObj.AL_DmgPropAmt__c;
        var redecor = repaymentRequestObj.AL_RedecorationAmt__c;
        var gardening = repaymentRequestObj.AL_GardeningAmt__c;
        var rent = repaymentRequestObj.AL_Rent_Arrears__c;
        var other = repaymentRequestObj.AL_OtherAmt__c;
        
        //alert(`clean -> ${clean}  damage -> ${damage} redecor -> ${redecor} gardening -> ${gardening} other -> ${other} `);
        
        if(clean!='' && clean!=undefined && clean!=null && clean!= 0 
           && !isNaN(repaymentRequestObj.AL_CleaningAmt__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(clean*100)/100);
            repaymentRequestObj.AL_CleaningAmt__c=Math.round(clean*100)/100;
        } else {
            repaymentRequestObj.AL_CleaningAmt__c = 0;
        }
        if(damage!='' && damage!=undefined && damage!=null && damage!= 0 
           && !isNaN(repaymentRequestObj.AL_DmgPropAmt__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(damage*100)/100);
            repaymentRequestObj.AL_DmgPropAmt__c=Math.round(damage*100)/100;
        } else {
            repaymentRequestObj.AL_DmgPropAmt__c = 0;
        }
        if(redecor!='' && redecor!=undefined && redecor!=null && redecor!= 0 
           && !isNaN(repaymentRequestObj.AL_RedecorationAmt__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(redecor*100)/100);
            repaymentRequestObj.AL_RedecorationAmt__c=Math.round(redecor*100)/100;
        } else {
            repaymentRequestObj.AL_RedecorationAmt__c = 0;
        }
        if(gardening!='' && gardening!=undefined && gardening!=null && gardening!= 0 
           && !isNaN(repaymentRequestObj.AL_GardeningAmt__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(gardening*100)/100);
            repaymentRequestObj.AL_GardeningAmt__c=Math.round(gardening*100)/100;
        } else {
            repaymentRequestObj.AL_GardeningAmt__c = 0;
        }
        if(rent!='' && rent!=undefined && rent!=null && rent!= 0 
           && !isNaN(repaymentRequestObj.AL_Rent_Arrears__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(rent*100)/100);
            repaymentRequestObj.AL_Rent_Arrears__c=Math.round(rent*100)/100;
        } else {
            repaymentRequestObj.AL_Rent_Arrears__c = 0;
        }
        if(other!='' && other!=undefined && other!=null && other!= 0 
           && !isNaN(repaymentRequestObj.AL_OtherAmt__c))
        {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(other*100)/100);
            repaymentRequestObj.AL_OtherAmt__c=Math.round(other*100)/100;
        } else {
            repaymentRequestObj.AL_OtherAmt__c = 0;
        }
        
        let remainderToAllocate = Math.round((component.get("v.repaymentRec.Deposit__r.Protected_Amount__c") - 
            totalRepaymentToAgentLL - totalAmountToTenant)*100)/100;
        console.log(`totalRepaymentToAgentLL -> ${Math.round(totalRepaymentToAgentLL*100)/100}  totalAmountToTenant -> ${Math.round(totalAmountToTenant*100)/100}`);
        component.set("v.remainderToAllocate",remainderToAllocate);
        component.set("v.totalDepRepayment",(Math.round((totalAmountToTenant+totalRepaymentToAgentLL)*100)/100));
        component.set("v.sumOfTotalAmountToTenant",totalAmountToTenant);
        component.set("v.sumOfTenantRepaymentsToAGLL",totalRepaymentToAgentLL);
        // alert('Line 710 totalAmount -> '+totalAmount);
        // alert('total agents money '+total);
        
        if(remainderToAllocate > 0)
        {
            component.set("v.isLessThanDepAmtBttn",true);
        } else if(remainderToAllocate < 0) {
            component.set("v.isMoreThanDepAmtBttn",true);
        }
		
    },
    
    goToThankuSection: function(component, event) {
        component.set("v.errorToBeDisplayed",'');
        component.set("v.isMoreThanDepAmtBttn",false);
        component.set("v.isLessThanDepAmtBttn",false);
        
        let repaymentRequestLineObj = component.get("v.repaymentRec.Repayment_Request_Lines__r");
        let totalAmountToTenant = 0;
        let isValid = true;
        //alert('Line 842 ->>> '+repaymentRequestLineObj[0].Repayment_Request__r.Deposit__r.Customer__c)
        for(var i=0; i<repaymentRequestLineObj.length; i++) {
             console.log(repaymentRequestLineObj[i].Repayment_Request__r.Deposit__r.Customer__c+' Line 988 -> '+repaymentRequestLineObj[i].Account__c);
            if(repaymentRequestLineObj[i].Account__c != repaymentRequestLineObj[i].Repayment_Request__r.Deposit__r.Customer__c)
            {
                var tempVar = repaymentRequestLineObj[i].AL_ReqAmt__c;
                
                if(tempVar =='' || tempVar == undefined || tempVar == null || isNaN(tempVar))
                {
                    isValid = false;
                } else {
                    totalAmountToTenant = totalAmountToTenant + parseFloat(Math.round(tempVar*100)/100);
                    repaymentRequestLineObj[i].AL_ReqAmt__c = parseFloat(Math.round(tempVar*100)/100);
                }   
            }
        }
        console.log('Line 855 -> '+isValid);
        let repaymentRequestObj = component.get("v.repaymentRec");
        
        var totalRepaymentToAgentLL = 0;
        var clean = repaymentRequestObj.AL_CleaningAmt__c;
        var damage = repaymentRequestObj.AL_DmgPropAmt__c;
        var redecor = repaymentRequestObj.AL_RedecorationAmt__c;
        var gardening = repaymentRequestObj.AL_GardeningAmt__c;
        var rent = repaymentRequestObj.AL_Rent_Arrears__c;
        var other = repaymentRequestObj.AL_OtherAmt__c;
        //alert(`clean -> ${clean}  damage -> ${damage} redecor -> ${redecor} gardening -> ${gardening} other -> ${other} `);
        
        if(clean == '' || clean == undefined || clean == null || isNaN(repaymentRequestObj.AL_CleaningAmt__c))
        {
            //isValid = false;
            repaymentRequestObj.AL_CleaningAmt__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(clean*100)/100);
            repaymentRequestObj.AL_CleaningAmt__c=Math.round(clean*100)/100;
        }console.log('Line 873 -> '+isValid);
        if(damage == '' || damage == undefined || damage == null || isNaN(repaymentRequestObj.AL_DmgPropAmt__c))
        {
            //isValid = false;
            repaymentRequestObj.AL_DmgPropAmt__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(damage*100)/100);
            repaymentRequestObj.AL_DmgPropAmt__c=Math.round(damage*100)/100;
        }console.log('Line 880 -> '+isValid);
        if(redecor == '' || redecor == undefined || redecor == null || isNaN(repaymentRequestObj.AL_RedecorationAmt__c))
        {
            //isValid = false;
            repaymentRequestObj.AL_RedecorationAmt__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(redecor*100)/100);
            repaymentRequestObj.AL_RedecorationAmt__c=Math.round(redecor*100)/100;
        }console.log('Line 887 -> '+isValid);
        if(gardening == '' || gardening == undefined || gardening == null || isNaN(repaymentRequestObj.AL_GardeningAmt__c))
        {
            //isValid = false;
            repaymentRequestObj.AL_GardeningAmt__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(gardening*100)/100);
            repaymentRequestObj.AL_GardeningAmt__c=Math.round(gardening*100)/100;
        }console.log('Line 894 -> '+isValid);
        if(rent == '' || rent == undefined || rent == null || isNaN(repaymentRequestObj.AL_Rent_Arrears__c))
        {   
            //isValid = false;
            repaymentRequestObj.AL_Rent_Arrears__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(rent*100)/100);
            repaymentRequestObj.AL_Rent_Arrears__c=Math.round(rent*100)/100;
        }console.log('Line 901 -> '+isValid);
        if(other == '' || other == undefined || other == null || isNaN(repaymentRequestObj.AL_OtherAmt__c))
        {
            //isValid = false;
            repaymentRequestObj.AL_OtherAmt__c=0;
        } else {
            totalRepaymentToAgentLL = totalRepaymentToAgentLL + parseFloat(Math.round(other*100)/100);
            repaymentRequestObj.AL_OtherAmt__c=Math.round(other*100)/100;
        }
        console.log('Line 909 -> '+isValid);
        if(!isValid) {
        	component.set("v.errorToBeDisplayed",'Errors');
        }
        
        let remainderToAllocate = Math.round((component.get("v.repaymentRec.Deposit__r.Protected_Amount__c") - 
            totalRepaymentToAgentLL - totalAmountToTenant)*100)/100;
        //alert(`totalRepaymentToAgentLL -> ${totalRepaymentToAgentLL}  totalAmountToTenant -> ${totalAmountToTenant}`);
        component.set("v.remainderToAllocate",remainderToAllocate);
        component.set("v.totalDepRepayment",(Math.round((totalAmountToTenant+totalRepaymentToAgentLL)*100)/100));
        component.set("v.sumOfTotalAmountToTenant",totalAmountToTenant);
        component.set("v.sumOfTenantRepaymentsToAGLL",totalRepaymentToAgentLL);
        
        if(remainderToAllocate > 0)
        {
            component.set("v.isLessThanDepAmtBttn",true);
            component.set("v.errorToBeDisplayed",'');
            isValid = false;
        } else if(remainderToAllocate < 0) {
            component.set("v.isMoreThanDepAmtBttn",true);
            component.set("v.errorToBeDisplayed",'');
            isValid = false;
        } /*else if(remainderToAllocate == 0) {
            isValid = true;
        } */
        
        var isBankPresent = component.get("v.isBankDetailsPresent");
        console.log('isBankPresent -> '+isBankPresent);
        if(!isBankPresent) {
            component.set("v.noBankDetailsFoundError",true);
            isValid = false;
        }
        
        if(component.get("v.otherAmtValidationError")) {
            isValid = false;
        }
        
        console.log('Line 923 -> '+isValid);
        if(isValid) {
            console.log('LINE 784--> ',JSON.stringify(component.get("v.repaymentRec")));
            let repReq = component.get("v.repaymentRec");
            let repReqLines = component.get("v.repaymentRec.Repayment_Request_Lines__r");
            let tenancyEndDate = component.get("v.tenancyEndDate");
            //alert(tenancyEndDate);
            console.log(tenancyEndDate +' 789 - ', typeof tenancyEndDate);
            //   console.log(JSON.stringify(component.get("v.repaymentRec")));
            console.log('LINE 788--> '+JSON.stringify(repReq)+' && '+JSON.stringify(repReqLines));
            var action = component.get("c.DisagreedTorequest");
            action.setParams({            
                RequsetRec : JSON.stringify(repReq),
                RepaymentLineRec : JSON.stringify(repReqLines),
                TenancyEndDate : tenancyEndDate
                //repaymentsToAgLL : component.get("v.sumOfTenantRepaymentsToAGLL")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // alert('line 345'+state);
                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    component.set("v.showInitialform",false);
                    component.set("v.thankuSection",true);
                    //alert(result);
                    
                    /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "You've responded to the tenant request.",
                    "type":"success"
                });
                toastEvent.fire();
                var result = response.getReturnValue();
                var pageURL = window.location.origin;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": pageURL + "/Sds/s/viewdeposit"
                });
                urlEvent.fire();*/
                } 
                else if (state === "ERROR") {
                    //   console.log(errors);
                    var errors = response.getError();
                    //    console.log("Error message: " + 
                    //                 JSON.stringify(errors[0].message));
                } else {
                    //       console.log("Unknown error");
                }
            });
            $A.enqueueAction(action);
        }
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
        
    NumSplCharsCheck: function(component, event, helper) {
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
    handleComponentEvent : function(cmp, event) {
        

        // set the handler attributes based on event data
        cmp.set("v.showAddressFlag", false);
        
    },
    
});