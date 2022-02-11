({
	doSubmit : function(component, event, helper) {
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        let totalamountAGLL = 0;
        let disputOldRecMap = new Map();
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
            var AmountObj = new Object();
            AmountObj.Amount = disputeItemRec[i].Agreed_by_Tenant__c;
            AmountObj.Percentage = disputeItemRec[i].Adjustment_Percentage_by_TT__c;
            disputOldRecMap.set(disputeItemRec[i].Id,AmountObj);
            
        }
        component.set("v.disputOldRecMap",disputOldRecMap);
        component.set("v.totalTenantAmount",totalamount);
        component.set("v.totalAGLLAmount",totalamountAGLL);
       // var sel = document.getElementById("selectIam");
       // var selectedValue = sel.options[sel.selectedIndex].text;
        var selectedValue = component.get("v.SelectedOption");
        if(selectedValue =='-- Please select --')
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
            document.getElementById('scrollToHeader').scrollIntoView(true);
            
        }
        else if(selectedValue =="I agree with the agent/landlord's claim")
        { 
                var action = component.get("c.UpdateClaimDetails");
                action.setParams({
                    "claimId": component.get("v.ClaimsDetails[0].Id"),
                    "customerType": "TT",
                    "amount":component.get("v.ClaimsDetails[0].Total_Agreed_by_AG_LL__c"),
                    "scheme":'Zero Deposite',
                    "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",true);
                        component.set("v.LeadTenantUrl",a.getReturnValue());
                        /*
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Case has been updated successfully and the payment part will be develpoed in ZP-8',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire(); */
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
        /*else if(selectedValue =="View and respond to offer")
        {
            component.set("v.madeOffer",true);
            component.set("v.adjustToClaim",false);
            component.set("v.viewClaim",false);
        }*/
		
	},
    makePayment: function (component, event, helper) {
        /*
        var action = component.get("c.MakePayment");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType": "Tenant",
            "amount":component.get("v.ClaimsDetails[0].Final_Amount_paid__c"),
            "scheme":'Zero Deposite',
            "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
        }); 
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                console.log('line 112');
                var result =a.getReturnValue();
                console.log('result '+result);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": result 
                });
                urlEvent.fire();
                
               
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
        */
        var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": component.get("v.LeadTenantUrl") 
                });
                urlEvent.fire();
        
    },
    calculateTenantTotal: function (component, event, helper) {
        
        let disputeItemOldRec = component.get("v.ClaimsDetailsOldValues[0].Dispute_Items__r");
        let disputeItemOldRecMAp = new Map();
        let selectRecord = event.getSource().get("v.id");
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        for(let i=0; i < disputeItemRec.length ; i++ )
        {
            if(disputeItemRec[i].Agreed_by_Tenant__c)
            {
                totalamount = parseFloat(totalamount)+ parseFloat(disputeItemRec[i].Agreed_by_Tenant__c);
            }
            if(disputeItemRec[i].Id==selectRecord && (parseFloat(disputeItemRec[i].Agreed_by_Tenant__c) > parseFloat(disputeItemRec[i].Claimed_by_Landlord__c)) )
            {
                alert('Item amount can not be greater');
            }
        }
        component.set("v.totalTenantAmount",totalamount);
    },
    doSubmitDisagree: function (component, event, helper) {
        /*let madeOffer = component.find("checkboxAuraId").get('v.checked');
        if(madeOffer)
        {
            component.set("v.madeNewOffer",true);
            component.set("v.viewClaim",false);
            component.set("v.adjustToClaim",false);
        }
        else
        {*/
        // let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        
        let btnValue = component.get("v.isNotAgreedBtnClicked");
        if(btnValue)
        {
            
            let notAgreementReason = document.getElementById("notAgreementReasonId").value;
            if(notAgreementReason.length > 149 && notAgreementReason.length < 501)
            {
                var action = component.get("c.UpdateDisputeItemSelfResolutionAgreementTT");
                action.setParams({
                    cmnts: notAgreementReason,
                    claimId : component.get("v.ClaimsDetails[0].Id")
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
            let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");;
            var action = component.get("c.UpdateDisputeItemSelfResolution");
            action.setParams({
                "disputeItemRec": JSON.stringify(disputeItemRec),
                "customerType":"TT",
                claimId : component.get("v.ClaimsDetails[0].Id")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result=='Record successfully updated')
                    {
                        component.set("v.notReachAgreementThanks",false);
                        component.set("v.adjustToClaim",false);
                        component.set("v.viewClaim",false);
                        component.set("v.ViewContinue",false);
                        component.set("v.showConfirmDiv",false);
                        component.set("v.showCancelDiv",false);
                        component.set("v.SubmitThanks",true);
                        /*let toastEvent = $A.get("e.force:showToast");
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
        
        
        //}
    },
    calculateAmountByPercentage: function (component, event, helper) {
        let selectRecord = event.getSource().get("v.id");
        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let totalamount = 0;
        var newItems=[];
        for(let i=0; i < disputeItemRec.length ; i++ )
        {    
            if(disputeItemRec[i].Id==selectRecord && (disputeItemRec[i].Adjustment_Percentage_by_TT__c > 100) )
            {
                alert('Percentage can not be greater more than 100%.');
            }else if(disputeItemRec[i].Id==selectRecord)
            { 
                var AGLLResponse = (disputeItemRec[i].Adjustment_Percentage_by_TT__c *  disputeItemRec[i].Claimed_by_Landlord__c)/100;
                //component.set("v.ClaimsDetails[0].Dispute_Items__r[i].Agreed_by_AGLL__c",AGLLResponse);
                //component.set("v.ClaimsDetails[0].Dispute_Items__r[i].Adjustment_Percentage_by_AGLL__c",disputeItemRec[i].Adjustment_Percentage_by_AGLL__c);
                document.getElementById('dis'+selectRecord).innerHTML=AGLLResponse;
                document.getElementById('recDetails'+selectRecord).innerHTML=disputeItemRec[i].Id+'-'+AGLLResponse+'-'+disputeItemRec[i].Adjustment_Percentage_by_TT__c; 
            }
        }
        
        var id = document.getElementsByClassName("recordDetails");
        for(let i=0; i < id.length ; i++ ) {
            if(id[i].innerHTML!=''){
                let percentageCal = id[i].innerHTML;
                var recSplt = percentageCal.split('-');
                totalamount = parseFloat(totalamount) + parseFloat(recSplt[1]);
                var Itemss = {Agreed_by_Tenant__c: recSplt[1], id: recSplt[0], Adjustment_Percentage_by_TT__c: recSplt[2]};
                newItems.push(Itemss);
            }
        }
                
        component.set("v.DisputeItems",newItems);
        component.set("v.totalTenantAmount",totalamount);
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
    madeOffer: function(component, event, helper) {  
        var sel = document.getElementById("madeOffer");
        var selectedValue = sel.options[sel.selectedIndex].text;
        
        if(selectedValue =="Accept Offer")
        {
            var action = component.get("c.TTMadeOffers");
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
            var action = component.get("c.TTMadeOffers");
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
            var action = component.get("c.TTMadeOffers");
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
    madeNewOfferBtn: function(component, event, helper) {  
        var offerByTT = document.getElementById("counterNewOffer").value;
        var action = component.get("c.TTMadeOffers");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "selectedVal":"New Offer",
            "offerByAGLL":offerByTT
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
    },
    handleChangeSlider: function(component, event, helper) { 
        let sliderValue = component.get("v.sliderValue");
        let disputeAmount = component.get("v.ClaimsDetails[0].Total_Claim_Amount__c");
        var TTOffer = (disputeAmount * sliderValue)/100;
        component.set("v.newOfferValue",TTOffer);
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
                document.getElementById('recDetails'+selectRecord).innerHTML=disputeItemRec[i].Id+'-'+AGLLResponse+'-'+disputeItemRec[i].Adjustment_Percentage_by_TT__c; 
            }
        }
        
        var id = document.getElementsByClassName("recordDetails");
        for(let i=0; i < id.length ; i++ ) {
            if(id[i].innerHTML!=''){
                let percentageCal = id[i].innerHTML;
                var recSplt = percentageCal.split('-');
                totalamount = parseFloat(totalamount) + parseFloat(recSplt[1]);
                var Itemss = {Agreed_by_Tenant__c: recSplt[1], id: recSplt[0], Adjustment_Percentage_by_TT__c: recSplt[2]};
                newItems.push(Itemss);
            }
        } 
        component.set("v.DisputeItems",newItems); 
        component.set("v.totalTenantAmount",totalamount);
    },
    showContinue : function(component, event, helper) {
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
    },
    handleSelectedvalue : function(component, event, helper) {
        var selectedValue = event.currentTarget.dataset.myid;
        component.set("v.SelectedOption",selectedValue);
        if(selectedValue =="I agree with the agent/landlord's claim"){
            component.set("v.showConfirmMessage",true);
            document.getElementById('scrolltoBtn').scrollIntoView(true);
            document.getElementById("agreed").style.background= "#F45372";
            document.getElementById("agreed").style.color= "white";
            document.getElementById("adjust").style.background= "white";
            document.getElementById("adjust").style.color= "#F45372";
            
        }
        else
        {
            component.set("v.showConfirmMessage",false);
            document.getElementById("adjust").style.background= "#F45372";
            document.getElementById("adjust").style.color= "white";
            document.getElementById("agreed").style.background= "white";
            document.getElementById("agreed").style.color= "#F45372";
        }
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
                if(parseFloat(selectRecordValue) < parseFloat(disputOldRecMap.get(selectRecordId).Percentage) )
                {
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You can only increase the amount');
                    claimRec[i].Adjustment_Percentage_by_TT__c = disputOldRecMap.get(selectRecordId).Percentage;
                }
                else
                {
                    if(selectRecordValue > parseFloat(claimRec[i].Adjustment_Percentage_by_AGLL__c) )
                    {
                        component.set("v.showError",claimRec[i].Id);
                        component.set("v.errorMessage",'Amount entered should be equal to or less than amount requested by landlord');
                        claimRec[i].Adjustment_Percentage_by_TT__c = disputOldRecMap.get(selectRecordId).Percentage;
                    }
                    else
                    {
                        component.set("v.showError",'');
                        claimRec[i].Adjustment_Percentage_by_TT__c = selectRecordValue;
                    }
                    
                }
                
                //claimRec[i].Adjustment_Percentage_by_TT__c = selectRecordValue;
                var AGLLResponse = (claimRec[i].Adjustment_Percentage_by_TT__c * claimRec[i].Claimed_by_Landlord__c)/100;
                claimRec[i].Agreed_by_Tenant__c = parseFloat(AGLLResponse).toFixed(2);
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_Tenant__c);
        }
        component.set("v.enableSubmitAdjustmentBtn",true);
        component.set("v.ClaimsDetails[0].Dispute_Items__r",claimRec);
        component.set("v.totalTenantAmount",totalamount);
        
        
        
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
                if(selectRecordValue < disputOldRecMap.get(selectRecordId).Amount )
                {
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You can only increase the amount');
                    claimRec[i].Agreed_by_Tenant__c = disputOldRecMap.get(selectRecordId).Amount;
                }
                else
                {
                    if(selectRecordValue > claimRec[i].Agreed_by_AGLL__c )
                    {
                        component.set("v.showError",claimRec[i].Id);
                        component.set("v.errorMessage",'Amount entered should be equal to or less than amount requested by landlord');
                        claimRec[i].Agreed_by_Tenant__c = disputOldRecMap.get(selectRecordId).Amount;
                    }
                    else
                        {
                            component.set("v.showError",'');
                            claimRec[i].Agreed_by_Tenant__c = parseFloat(selectRecordValue).toFixed(2);
                        }
                    
                }
                //claimRec[i].Agreed_by_Tenant__c = selectRecordValue;
                var AGLLResponseperc = (claimRec[i].Agreed_by_Tenant__c * 100 )/claimRec[i].Claimed_by_Landlord__c;
                claimRec[i].Adjustment_Percentage_by_TT__c = AGLLResponseperc;
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_Tenant__c);
        }
        component.set("v.enableSubmitAdjustmentBtn",true);
        component.set("v.ClaimsDetails[0].Dispute_Items__r",claimRec);
        component.set("v.totalTenantAmount",totalamount);
        
    },
    handleAgreementBtn : function(component, event, helper) {
        var isNotAgreedBtnClicked =  component.get("v.isNotAgreedBtnClicked");
        if(isNotAgreedBtnClicked){
            document.getElementById("agreementBtn").style.background= "#F45372";
            document.getElementById("agreementBtn").style.color= "white";
            component.set("v.isNotAgreedBtnClicked",false);
            component.set("v.disabled",false);
            var cmpTarget = component.find('btnhandle');
            $A.util.addClass(cmpTarget, 'btnNormal');
        }
        else{
            document.getElementById('scrollToNotPossible').scrollIntoView(true);
            component.set("v.isNotAgreedBtnClicked",true);
            component.set("v.disabled",true);
            var cmpTarget = component.find('btnhandle');
            $A.util.removeClass(cmpTarget, 'btnNormal');
        }
        
    },
    goToCliamSummary:function(component, event, helper) {
        
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
    goToHome:function(component, event, helper) {
        location.reload();
    },
    textAreaFun : function(component, event, helper) {
        document.getElementById("doSubmittBtn").style.backgroundColor = "#f45372";
        document.getElementById("doSubmittBtn").disabled = false;
        
    },
    viewClaim :function(component){
        component.set("v.isNotJT",false);
          component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        
      //  alert('Joint Tenant');
    }
    
})