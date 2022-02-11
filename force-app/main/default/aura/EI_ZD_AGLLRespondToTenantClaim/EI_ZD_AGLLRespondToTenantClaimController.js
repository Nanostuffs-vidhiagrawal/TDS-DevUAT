({
    doInit : function(component, event, helper) {
        
        let currentURL = window.location.href;
        let AccessCode = currentURL.split("id=")[1];
        AccessCode = AccessCode.replace("#",'');
        var action = component.get("c.getClaimDetailsByAccessCode");
        action.setParams({
            "AccessCode": AccessCode
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.ClaimsDetails",a.getReturnValue());
                let disputOldRecMap = new Map();
                let caseItemRec =a.getReturnValue()[0].Dispute_Items__r;
                for(let i=0; i<caseItemRec.length;i++)
                {
                    var AmountObj = new Object();
                    AmountObj.Amount = caseItemRec[i].Agreed_by_AGLL__c;
                    AmountObj.Percentage = caseItemRec[i].Adjustment_Percentage_by_AGLL__c;
                    disputOldRecMap.set(caseItemRec[i].Id,AmountObj);
                }
                component.set("v.disputOldRecMap",disputOldRecMap);
                if(component.get("v.ClaimsDetails[0].Status") =='Case cancelled' || component.get("v.ClaimsDetails[0].Status") =='Invitation to view the claim' ||
                  component.get("v.ClaimsDetails[0].Status") =='Decision issued' ||component.get("v.ClaimsDetails[0].Status") =='Case closed - no response from either party' ||
                  component.get("v.ClaimsDetails[0].Status") =='Case closed - no response from agent/landlord' ||component.get("v.ClaimsDetails[0].Status") =='Case closed - agreement reached'||
                   component.get("v.ClaimsDetails[0].Status") =='Adjudication' ||component.get("v.ClaimsDetails[0].Status") =='Evidence review complete' || component.get("v.ClaimsDetails[0].Status") =='On Hold')
                {
                    component.set("v.showContinueBtn",false);
                }
                else
                {
                    component.set("v.showContinueBtn",true);
                }
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
    doSubmit : function(component, event, helper) {  
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        let totalamountAGLL = 0;
        for(let i=0; i < disputeItemRec.length ; i++ )
        {
            if(disputeItemRec[i].Agreed_by_Tenant__c)
            {
                totalamount = parseFloat(totalamount)+ parseFloat(disputeItemRec[i].Agreed_by_Tenant__c);
            }
            if(disputeItemRec[i].Agreed_by_AGLL__c)
            {
                totalamountAGLL = parseFloat(totalamountAGLL)+ parseFloat(disputeItemRec[i].Agreed_by_AGLL__c);
            }            
        }
        component.set("v.totalTenantAmount",totalamount);
        component.set("v.totalAGLLAmount",totalamountAGLL);
        
        // var sel = document.getElementById("selectIam");
        //var selectedValue = sel.options[sel.selectedIndex].text;
        var selectedValue = component.get("v.SelectedOption");
        
        if(selectedValue =='-- Please select ---')
        {
            alert('Please select a value');
            component.set("v.adjustToClaim",false);
            component.set("v.viewClaim",false);            
        }
        else if(selectedValue =="I want to adjust my claim")
        {
            component.set("v.adjustToClaim",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.showConfirmDiv",false);
            component.set("v.showCancelDiv",false);
            document.getElementById('scrollToHeader').scrollIntoView(true);
            
        }
            else if(selectedValue =="I want to cancel my claim")
            {
               component.set("v.showConfirmDialog",true);
                
            }else if(selectedValue =="I agreed to tenant response")
            {
                let action = component.get("c.AgreedByAgent");
                action.setParams({
                    "claimId": component.get("v.ClaimsDetails[0].Id")
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        /* let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Case has been closed successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire(); */
                        
                        component.set("v.adjustToClaim",false);
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",true);
                        
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
        
    },
    madeOffer: function(component, event, helper) {  
        var sel = document.getElementById("madeOffer");
        var selectedValue = sel.options[sel.selectedIndex].text;
        
        if(selectedValue =="Accept Offer")
        {
            var action = component.get("c.AGLLMadeOffers");
            action.setParams({
                "claimId": component.get("v.ClaimsDetails[0].Id"),
                "selectedVal":"Accepted"
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();
                if (state == "SUCCESS") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Offer has been Accepted successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
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
        else if(selectedValue =="Decline Offer")
        {
            var action = component.get("c.AGLLMadeOffers");
            action.setParams({
                "claimId": component.get("v.ClaimsDetails[0].Id"),
                "selectedVal":"Rejected"
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();
                if (state == "SUCCESS") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Offer has been Rejected',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
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
        }else{            
            var offerByAGLL = document.getElementById("counterOffer").value;
            var action = component.get("c.AGLLMadeOffers");
            action.setParams({
                "claimId": component.get("v.ClaimsDetails[0].Id"),
                "selectedVal":"Make Counter Offer",
                "offerByAGLL":offerByAGLL
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();
                if (state == "SUCCESS") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Offer has been update successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
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
    },
    editBtn: function (component, event, helper) {
        var selectRecord = event.currentTarget.dataset.id; 
        var divId = 'dis'+selectRecord;
        document.getElementById(divId).contentEditable = true;
    },
    cancelBtn: function (component, event, helper) {
        var selectRecord = event.currentTarget.dataset.id; 
        var divId = 'dis'+selectRecord;
        document.getElementById(divId).contentEditable = false;
    },
    manuallyEnterAGLLRes: function (component, event, helper) {
        var selectRecord = event.currentTarget.dataset.id; 
        var divId = 'dis'+selectRecord;
        var AGLLResponse = document.getElementById(divId).innerHTML;
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        var newItems=[];
        for(let i=0; i < disputeItemRec.length ; i++ )
        {    
            if(disputeItemRec[i].Id==selectRecord)
            { 
                document.getElementById('recDetails'+selectRecord).innerHTML=disputeItemRec[i].Id+'-'+AGLLResponse+'-'+disputeItemRec[i].Adjustment_Percentage_by_AGLL__c; 
            }
        }
        
        var id = document.getElementsByClassName("recordDetails");
        for(let i=0; i < id.length ; i++ ) {
            if(id[i].innerHTML!=''){
                let percentageCal = id[i].innerHTML;
                var recSplt = percentageCal.split('-');
                totalamount = parseFloat(totalamount) + parseFloat(recSplt[1]);
                var Itemss = {Agreed_by_AGLL__c: recSplt[1], id: recSplt[0], Adjustment_Percentage_by_AGLL__c: recSplt[2]};
                newItems.push(Itemss);
            }
        } 
        component.set("v.DisputeItems",newItems); 
        component.set("v.totalAGLLAmount",totalamount);
    },
    calculateAmountByPercentage: function (component, event, helper) {
        let selectRecord = event.getSource().get("v.id");
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        var newItems=[];
        for(let i=0; i < disputeItemRec.length ; i++ )
        {    
            if(disputeItemRec[i].Id==selectRecord && (disputeItemRec[i].Adjustment_Percentage_by_AGLL__c > 100) )
            {
                alert('Percentage can not be greater more than 100%.');
            }else if(disputeItemRec[i].Id==selectRecord)
            { 
                var AGLLResponse = (disputeItemRec[i].Adjustment_Percentage_by_AGLL__c *  disputeItemRec[i].Claimed_by_Landlord__c)/100;
                //component.set("v.ClaimsDetails[0].Dispute_Items__r[i].Agreed_by_AGLL__c",AGLLResponse);
                //component.set("v.ClaimsDetails[0].Dispute_Items__r[i].Adjustment_Percentage_by_AGLL__c",disputeItemRec[i].Adjustment_Percentage_by_AGLL__c);
                document.getElementById('dis'+selectRecord).innerHTML=AGLLResponse;
                document.getElementById('recDetails'+selectRecord).innerHTML=disputeItemRec[i].Id+'-'+AGLLResponse+'-'+disputeItemRec[i].Adjustment_Percentage_by_AGLL__c; 
            }
        }
        
        var id = document.getElementsByClassName("recordDetails");
        for(let i=0; i < id.length ; i++ ) {
            if(id[i].innerHTML!=''){
                let percentageCal = id[i].innerHTML;
                var recSplt = percentageCal.split('-');
                totalamount = parseFloat(totalamount) + parseFloat(recSplt[1]);
                var Itemss = {Agreed_by_AGLL__c: recSplt[1], id: recSplt[0], Adjustment_Percentage_by_AGLL__c: recSplt[2]};
                newItems.push(Itemss);
            }
        }        
        component.set("v.DisputeItems",newItems);
        component.set("v.totalAGLLAmount",totalamount);
    },
    doSubmitAdjustment: function (component, event, helper) {
        let btnValue = component.get("v.isNotAgreedBtnClicked");
        if(btnValue)
        {
            let notAgreementReason = document.getElementById("notAgreementReasonId").value;
            if(notAgreementReason.length > 149 && notAgreementReason.length < 501)
            {
                var action = component.get("c.UpdateDisputeItemSelfResolutionAgreement");
                action.setParams({
                    cmnts: notAgreementReason,
                    claimId : component.get("v.claimId")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.notReachAgreementThanks",true);
                        document.getElementById('scrollToHeader').scrollIntoView(true);
                        component.set("v.adjustToClaim",false);
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",false);
                        component.set("v.showCancelDiv",false);
                        component.set("v.SubmitThanks",false);
                        
                    }
                    else
                    {
                        component.set("v.notReachAgreementThanks",false);
                    }
                });
                $A.enqueueAction(action);
                
            }
            else
            {
                alert('There is a minimum character count for this box of 150 characters and a maximum of 500 characters. Please enter a valid response.');
            } 
        }
        else
        {
            let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
            // let disputeItemRec = component.get("v.DisputeItems");
            var action = component.get("c.UpdateDisputeItemSelfResolution");
            action.setParams({
                "disputeItemRec": JSON.stringify(disputeItemRec),
                "customerType":"AGLL",
                claimId : component.get("v.claimId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result=='Record successfully updated')
                    {
                        /*
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Record has been successfully updated',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        */
                        component.set("v.notReachAgreementThanks",false);
                        component.set("v.adjustToClaim",false);
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",false);
                        component.set("v.showCancelDiv",false);
                        component.set("v.SubmitThanks",true);
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
        
    },
    handleSelectedvalue1 : function(component, event, helper) {
        
        var sel = document.getElementById("selectIam");
        var selectedValue = sel.options[sel.selectedIndex].text;
        component.set("v.tenantSelectOption",selectedValue);
        
        if(selectedValue =="I want to cancel my claim")
        {
            component.set("v.madeOffer",false);
            component.set("v.adjustToClaim",false);
            component.set("v.viewClaim",false);
            alert('By clicking ‘Submit’, you confirm that you would like to cancel your claim and are no longer seeking financial compensation from the tenant(s).'); 
        }else if(selectedValue =="I want to respond to the tenant’s offer")
        {
            component.set("v.madeOffer",true);
            component.set("v.adjustToClaim",false);
            component.set("v.viewClaim",false);
        }else{
            component.set("v.madeOffer",false);
        }
    },
    madeOfferSelect: function(component, event, helper) {
        var sel = document.getElementById("madeOffer");
        var selectedValue = sel.options[sel.selectedIndex].text;
        //component.set("v.tenantSelectOption",selectedValue);
        
        if(selectedValue =="Accept Offer")
        {
            alert('By clicking ‘Submit’, you confirm that you agree to the tenant’s offer. This cannot be amended later.'); 
        }else if(selectedValue =="Decline Offer")
        {
            alert('We will let the tenant know that you do not accept the offer. You can both still try to reach agreement by making adjustments to your claims.'); 
        }else{            
            component.set("v.counterOffer",true);
            var totalClmAmnt = component.get("v.ClaimsDetails[0].Total_Claim_Amount__c");
            alert("The amount of the claim which is still to be agreed is £"+totalClmAmnt+".  You can make an offer to settle this and we will pass it onto the other party to see if they will accept it, or they can make you a counter-offer. Any offer will not be binding until it is accepted. If no agreement is reached, the amount of the claim still to be agreed will not change."); 
        }
    },
    showContinue : function(component, event, helper) {
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        
    },
    handleSelectedvalue : function(component, event, helper) {
        
        var selectedValue = event.currentTarget.dataset.myid;
        component.set("v.SelectedOption",selectedValue);
        if(selectedValue =="I agreed to tenant response"){
            document.getElementById('scrolltoBtn').scrollIntoView(true);
            component.set("v.showConfirmMessage",true);
            document.getElementById("agreed").style.background= "#F45372";
            document.getElementById("agreed").style.color= "white";
            document.getElementById("adjust").style.background= "white";
            document.getElementById("adjust").style.color= "#F45372";
            document.getElementById("cancel").style.background= "white";
            document.getElementById("cancel").style.color= "#F45372";
        }
        else if(selectedValue =="I want to adjust my claim")
        {
            component.set("v.showConfirmMessage",false);
            document.getElementById("adjust").style.background= "#F45372";
            document.getElementById("adjust").style.color= "white";
            document.getElementById("agreed").style.background= "white";
            document.getElementById("agreed").style.color= "#F45372";
            document.getElementById("cancel").style.background= "white";
            document.getElementById("cancel").style.color= "#F45372";
        }
        else
        {
            component.set("v.showConfirmMessage",false);
            document.getElementById("cancel").style.background= "#F45372";
            document.getElementById("cancel").style.color= "white";
            document.getElementById("agreed").style.background= "white";
            document.getElementById("agreed").style.color= "#F45372";
            document.getElementById("adjust").style.background= "white";
            document.getElementById("adjust").style.color= "#F45372";
        }
    },
    goToCliamSummary : function(component, event, helper) {
        var divId = event.getSource().getLocalId();
        // Jump to first Item in claim catagories
        //component.set("v.currentItem",0);
        if(divId=='div0'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.adjustToClaim",false);
        }
        
        if(divId=='div1'){
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",true);
            component.set("v.adjustToClaim",false);
            
        }
    },
    goToHome : function(component, event, helper) {
      location.reload();  
    },
    sliderMethod  : function(component, event, helper) {
        let claimRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        let selectRecordValue = event.target.value;
        let selectRecordId = event.target.id;
        let disputOldRecMap = component.get("v.disputOldRecMap");
        for(let i =0; i< claimRec.length; i++)
        {
            if(claimRec[i].Id ==selectRecordId)
            {
                if(parseFloat(selectRecordValue) > parseFloat(disputOldRecMap.get(selectRecordId).Percentage) )
                {
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You can only reduce the amount');
                    claimRec[i].Adjustment_Percentage_by_AGLL__c = disputOldRecMap.get(selectRecordId).Percentage;
                }
                else
                {
                    if(selectRecordValue < parseFloat(claimRec[i].Adjustment_Percentage_by_TT__c) )
                    {
                        component.set("v.showError",claimRec[i].Id);
                        component.set("v.errorMessage",'Amount entered should be equal to or greater than amount requested by tenant');
                        claimRec[i].Adjustment_Percentage_by_AGLL__c = disputOldRecMap.get(selectRecordId).Percentage;
                    }
                    else
                    {
                        component.set("v.showError",'');
                        claimRec[i].Adjustment_Percentage_by_AGLL__c = parseFloat(selectRecordValue).toFixed(2);
                        
                    }
                    
                }
                
                //claimRec[i].Adjustment_Percentage_by_AGLL__c = selectRecordValue;
                var AGLLResponse = (claimRec[i].Adjustment_Percentage_by_AGLL__c * claimRec[i].Claimed_by_Landlord__c)/100;
                claimRec[i].Agreed_by_AGLL__c = AGLLResponse;
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_AGLL__c);
        }
        component.set("v.enableSubmitAdjustmentBtn",true);
        component.set("v.ClaimsDetails[0].Dispute_Items__r",claimRec);
        component.set("v.totalAGLLAmount",totalamount);
        
        
        
        //console.log('==>>'+JSON.stringify(component.get("v.ClaimsDetails[0].Dispute_Items__r[0].Adjustment_Percentage_by_AGLL__c")));
    },
    handleInput : function(component, event, helper) {
        let totalamount = 0;
        // Html input  Tag
        
        let selectRecordValue = event.target.value;
        let selectRecordId = event.target.id;
        
        
        // Lightning input Tag
        // let selectRecordValue = event.getSource().get("v.value");
        // let selectRecordId = event.getSource().get("v.id");
        
        let disputOldRecMap = component.get("v.disputOldRecMap");
        let claimRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        for(let i =0; i< claimRec.length; i++)
        { 
            if(claimRec[i].Id == selectRecordId)
            {
                if(selectRecordValue < 0)
                {
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You cannot enter a negative figure');
                    claimRec[i].Agreed_by_AGLL__c = disputOldRecMap.get(selectRecordId).Amount;
                }
                else if(selectRecordValue > disputOldRecMap.get(selectRecordId).Amount )
                {
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You can only reduce the amount');
                    claimRec[i].Agreed_by_AGLL__c = disputOldRecMap.get(selectRecordId).Amount;
                    
                }
                else
                {
                    if(selectRecordValue < claimRec[i].Agreed_by_Tenant__c )
                    {
                        component.set("v.showError",claimRec[i].Id);
                        component.set("v.errorMessage",'Amount entered should be equal to or greater than amount requested by tenant');
                        claimRec[i].Agreed_by_AGLL__c = disputOldRecMap.get(selectRecordId).Amount;
                    }
                    else
                    {
                        component.set("v.showError",'');
                        claimRec[i].Agreed_by_AGLL__c = parseFloat(selectRecordValue).toFixed(2);
                    }
                    
                }
                var AGLLResponseperc = (claimRec[i].Agreed_by_AGLL__c * 100 )/claimRec[i].Claimed_by_Landlord__c;
                claimRec[i].Adjustment_Percentage_by_AGLL__c = AGLLResponseperc;
                
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_AGLL__c);
        }
        component.set("v.enableSubmitAdjustmentBtn",true);
        component.set("v.ClaimsDetails[0].Dispute_Items__r",claimRec);
        component.set("v.totalAGLLAmount",totalamount);
        
    },
    handleAgreementBtn : function(component, event, helper) {
        var isNotAgreedBtnClicked = component.get("v.isNotAgreedBtnClicked");
        if(isNotAgreedBtnClicked){
            document.getElementById("agreementBtn").style.background= "#F45372";
            document.getElementById("agreementBtn").style.color= "white";
            var cmpTarget = component.find('btnhandle');
            $A.util.addClass(cmpTarget, 'btnNormal');
            
            component.set("v.isNotAgreedBtnClicked",false);
            component.set("v.disable",false);
            
        }else{
            document.getElementById('scrollToNotPossible').scrollIntoView(true);
            component.set("v.isNotAgreedBtnClicked",true);
            component.set("v.disable",true);
            var cmpTarget = component.find('btnhandle');
            $A.util.removeClass(cmpTarget, 'btnNormal');
        }
    },
    textAreaFun : function(component, event, helper) {
        document.getElementById("doSubmittBtn").style.backgroundColor = "#f45372";
        document.getElementById("doSubmittBtn").disabled = false;
        
    },
    CloseCancelPopup : function(component, event, helper) { 
        component.set("v.showConfirmDialog",false);
    },
    doCancelClaim : function(component, event, helper) {
                    var action = component.get("c.UpdateClaimDetails");
                    action.setParams({
                        "claimId": component.get("v.ClaimsDetails[0].Id"),
                        "customerType":"AGLL",
                        "amount":component.get("v.ClaimsDetails[0].Final_Amount_paid__c"),
                        "scheme":'Zero Deposite',
                        "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
                    });
                    action.setCallback(this, function(a) {
                        let state = a.getState();
                        let errors = a.getError();
                        if (state == "SUCCESS") {
                            
                        component.set("v.adjustToClaim",false);
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",false);
                        component.set("v.showConfirmDialog",false);
                        component.set("v.showCancelDiv",true);
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
        
        
        
    },
})