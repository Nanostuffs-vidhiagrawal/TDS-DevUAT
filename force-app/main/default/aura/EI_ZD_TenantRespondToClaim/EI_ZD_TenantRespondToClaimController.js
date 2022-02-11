({
    doInit : function(component, event, helper) {
    },
    claimDetails : function(component, event, helper) {
        component.set("v.viewClaim",true);
        component.set("v.ClaimBreakup",false);
        let weapperRec = component.get("v.WrapperList");
        let userrec = weapperRec[0].usr;
        
        var claimId /*= event.target.getAttribute("data-recId")*/;
        var params = event.getParam('arguments');
        if (params) {
            claimId = params.viewTenancyID;
            component.set("v.ClaimId",claimId);
            
        }
        var action = component.get("c.getClaimDetails");
        action.setParams({
            "claimId": claimId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.ClaimsDetails",a.getReturnValue());
                let totalAmount = component.get("v.ClaimsDetails[0].Total_Agreed_by_Tenant__c");
                component.set("v.totalTenantAmount",totalAmount);
                let casePartirec = a.getReturnValue()[0].Case_Participants__r;
                let leadtenant =false;
                let checkResponse = false;
                let leadTenantName ='Lead';
                for(let i =0; i< casePartirec.length; i++)
                {
                    if(userrec.ContactId ==casePartirec[i].Contact__c )
                    {
                        if(casePartirec[i].Is_Lead__c)
                        {
                            leadtenant= true; 
                            leadTenantName = casePartirec[i].Contact__r.Name;
                        }
                        if(casePartirec[i].CheckResponse__c)
                        {
                            checkResponse= true; 
                        }
                    }
                    if(casePartirec[i].Is_Lead__c)
                    {
                        leadTenantName = casePartirec[i].Contact__r.Name;
                    }
                }
                component.set("v.isLead",leadtenant);
                component.set("v.LeadText",leadtenant);
                
                component.set("v.checkResponse",checkResponse);
                component.set("v.leadTenantName",leadTenantName);
            }
            else {
                let errormessage = JSON.stringify(a.getReturnValue());
                if (errormessage.includes("<br>")) {
                    errormessage = errormessage.replaceAll("<br>", " ");
                    component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message: errormessage,
                        closeCallback: function() {}
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },
    showClaimRepond : function(component, event, helper) {
        component.set("v.ClaimBreakup",true);
        component.set("v.viewClaim",false);
        
    },
    doSubmit : function(component, event, helper) {
        let selectedValue = component.get("v.tenantSelectOption");
        if(selectedValue =='-- Please select ---')
        {
            alert('Please select one of the following options');
        }
        else if(selectedValue =="I agree with the agent/landlord's claim")
        {
            if(component.get("v.isLead"))
            {
                var action = component.get("c.UpdateClaimDetails");
                action.setParams({
                    "claimId": component.get("v.ClaimId"),
                    "customerType" :"TT",
                    "amount":component.get("v.ClaimsDetails[0].Total_Claim_Amount__c"),
                    "scheme":'Zero Deposite',
                    "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        if(a.getReturnValue() =='Someone has already respond to this claim' || a.getReturnValue() =='AGLL')
                        {
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info',
                                message: 'Something went wrong please Contact Administrator',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'info',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                            
                        }
                        else
                        {
                            component.set("v.isOpen",true); 
                            component.set("v.showPopupBtn",true);
                            component.set("v.LeadTenantUrl",a.getReturnValue());
                        }
                    }
                    else
                    {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: 'Something went wrong please Contact Administrator',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        
                    }
                    
                });
                $A.enqueueAction(action);
            }
            else
            {
                window.setTimeout(
                    $A.getCallback(function() {
                        var action = component.get("c.UpdateClaimDetails");
                        action.setParams({
                            "claimId": component.get("v.ClaimId"),
                            "customerType" :"TT",
                            "amount":component.get("v.ClaimsDetails[0].Total_Claim_Amount__c"),
                            "scheme":'Zero Deposite',
                            "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
                        });
                        action.setCallback(this, function(a) {
                            let state = a.getState();
                            let errors = a.getError();
                            if (state == "SUCCESS") {
                                if(a.getReturnValue() =='Someone has already respond to this claim' || a.getReturnValue() =='AGLL')
                                {
                                    let toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Info',
                                        message: 'Something went wrong please Contact Administrator',
                                        duration:' 5000',
                                        key: 'info_alt',
                                        type: 'info',
                                        mode: 'dismissible'
                                    });
                                    toastEvent.fire();
                                    
                                }
                                else
                                {
                                    component.set("v.isOpen",true); 
                                    component.set("v.showPopupBtn",true);
                                    component.set("v.LeadTenantUrl",a.getReturnValue());
                                    
                                }
                                
                                
                                
                            }
                            else
                            {
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Info',
                                    message: 'Something went wrong please Contact Administrator',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'info',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }), 5000
                );
                
            }
            
        }
            else
            {
                component.set("v.disAgreeToClaim",true); 
                component.set("v.ClaimBreakup",false); 
            }
        
    },
    makePayment: function (component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.LeadTenantUrl") 
        });
        urlEvent.fire();
        
    },
    handleSelectedvalue : function(component, event, helper) {
        // var sel = document.getElementById("selectIam");
        //var selectedValue = sel.options[sel.selectedIndex].text;
        var selectedValue = event.currentTarget.dataset.myid;
        component.set("v.tenantSelectOption",selectedValue);
        var property_yes = document.getElementById("property_yes");
        var property_no = document.getElementById("property_no");
        
        if(selectedValue =="I agree with the agent/landlord's claim"){
            component.set("v.showConfirmMessage",true);
            property_yes.style.color = "#F45372";
            property_yes.style.borderColor = "#F45372";
            
            property_no.style.color = "#4D4C4C";
            property_no.style.borderColor = "rgba(0,0,0,0.08)";
        }
        else
        {
            component.set("v.showConfirmMessage",false);
            property_yes.style.color = "#4D4C4C";
            property_yes.style.borderColor = "rgba(0,0,0,0.08)";
            
            property_no.style.color = "#F45372";
            property_no.style.borderColor = "#F45372";
        }
        
        
    },
    updateDate: function (component, event, helper) {
        let depositRecievedDate = document.getElementById("depositRecievedDate").value;
        let depositRecievedMonth = document.getElementById("depositRecievedMonth").value;
        let depositRecievedYear = document.getElementById("depositRecievedYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD = depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        let isDateValid = false;
        // var selectedDate = event.getParam("value");
        var selectedDate = recievedDateYMD;
        var browserDate = new Date(selectedDate);
        var action = component.get("c.getCurrentDate");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var serverDate = new Date(result);
                var inputbrowserDate = component.find("browserDate");
                if (browserDate.getTime() > serverDate.getTime()) {
                    component.set("v.showRecievedDateError",true);
                    component.set("v.DateErrorMessage",'This cannot be a date in the future.');
                    // inputbrowserDate.setCustomValidity("Date cannot be in Future");
                    component.set("v.showClaimForm",false);
                    component.set("v.isDateValid",false);
                    isDateValid = false;
                    document.getElementById('scrollView').scrollIntoView(true);
                } else {
                    component.set("v.showRecievedDateError",false);
                    component.set("v.DateErrorMessage",'');
                    // inputbrowserDate.setCustomValidity("");
                    component.set("v.showClaimForm",true);
                    //let totalAmount = component.get("v.ClaimsDetails[0].Total_Agreed_by_Tenant__c");
                    //component.set("v.totalTenantAmount",totalAmount);
                    component.set("v.isDateValid",true);
                    isDateValid = true;
                }  
            }
            else if (state === "ERROR") {
                var errors = response.getError();
            } else {
            }
        });
        $A.enqueueAction(action);
        return isDateValid;
    },
    doSubmitDisagree: function (component, event, helper) {
        let arraydate = [];
        let depositRecievedDate = document.getElementById("depositRecievedDate").value;
        let depositRecievedMonth = document.getElementById("depositRecievedMonth").value;
        let depositRecievedYear = document.getElementById("depositRecievedYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD = depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        arraydate.push(receivedDate);
        let loopCounter = 0;
        let allDateValid = false;
        for(var i=0; i<arraydate.length; i++){
            allDateValid = validatedate(arraydate[i]);        
            if(allDateValid==false){
                if(loopCounter == 0){
                    component.set("v.showRecievedDateError",true);
                    component.set("v.DateErrorMessage",'Please enter a valid date');
                    allDateValid =false;
                    document.getElementById('scrollView').scrollIntoView(true);
                }else{
                    component.set("v.showRecievedDateError",false);
                    component.set("v.DateErrorMessage",'');
                    allDateValid =true;
                } 
                break;
            }
            loopCounter++;
        }
        
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
        //let isDateValid = false;
        if(allDateValid)
        {
            var selectedDate = recievedDateYMD;
            var browserDate = new Date(selectedDate);
            var action = component.get("c.getCurrentDate");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var serverDate = new Date(result);
                    var inputbrowserDate = component.find("browserDate");
                    if (browserDate.getTime() > serverDate.getTime()) {
                        component.set("v.showRecievedDateError",true);
                        component.set("v.DateErrorMessage",'This cannot be a date in the future.');
                        // isDateValid = false;
                        component.set("v.isDateValid",false);
                        document.getElementById('scrollView').scrollIntoView(true);
                        //  helper.helperMethod(component);
                    } else {
                        component.set("v.showRecievedDateError",false);
                        component.set("v.DateErrorMessage",'');
                        component.set("v.isDateValid",true);
                        //isDateValid = true;
                        helper.helperMethod(component, recievedDateYMD, allDateValid);
                    }  
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                } else {
                }
            });
            $A.enqueueAction(action);
            
        }
        
        
        
    },
    
    calculateTenantTotal: function (component, event, helper) {
        component.set("v.errorOn",'');
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        for(let i=0; i < disputeItemRec.length ; i++ )
        {
            if(disputeItemRec[i].Agreed_by_Tenant__c)
            {
                if(disputeItemRec[i].Agreed_by_Tenant__c <= disputeItemRec[i].Claimed_by_Landlord__c)
                {                    
                    totalamount = parseFloat(totalamount)+ parseFloat(disputeItemRec[i].Agreed_by_Tenant__c);
                }
                else
                {
                    component.set("v.errorOn",disputeItemRec[i].Type__c);
                    
                    disputeItemRec[i].Agreed_by_Tenant__c = '';
                    component.set("v.ClaimsDetails[0].Dispute_Items__r",disputeItemRec);
                }
            }
        }
        component.set("v.totalTenantAmount",totalamount);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire(); 
    },
    
})