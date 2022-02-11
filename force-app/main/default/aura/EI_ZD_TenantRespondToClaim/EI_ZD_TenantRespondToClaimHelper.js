({
    helperMethod : function(component, recievedDateYMD, allDateValid) {
        //let brwsDate =component.get("v.browserDate"); 
        let brwsDate = recievedDateYMD;
        //let isDateValid =component.get("v.isDateValid"); 
        if(allDateValid  && component.get("v.isDateValid"))
        {
            if(component.get("v.checkResponse"))
            {
                let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
                var action = component.get("c.UpdateDisputeItem");
                action.setParams({
                    "disputeItemRec": JSON.stringify(disputeItemRec),
                    depositId :component.get("v.ClaimsDetails[0].Deposit_Account_Number__c"),
                    brwsDate : brwsDate,
                    CaseparticipantId : component.get("v.WrapperList[0].Caseparticipant[0].Id")              
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(result=='Record successfully updated')
                        {
                            component.set("v.isOpen",true);
                            component.set("v.showPopupBtn",false);
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
                        $A.get('e.force:refreshView').fire();*/
                        }
                        else if(result=='Someone has already respond to this claim')
                        {
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info',
                                message: 'Someone has already responded to this claim',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'info',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                            
                        }
                            else{
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
            else
            {
                window.setTimeout(
                    $A.getCallback(function() {
                        let disputeItemRec = component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        var action = component.get("c.UpdateDisputeItem");
                        action.setParams({
                            "disputeItemRec": JSON.stringify(disputeItemRec),
                            depositId :component.get("v.ClaimsDetails[0].Deposit_Account_Number__c"),
                            brwsDate : brwsDate,
                            CaseparticipantId : component.get("v.WrapperList[0].Caseparticipant[0].Id")              
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var result = response.getReturnValue();
                                if(result=='Record successfully updated')
                                {
                                    component.set("v.isOpen",true);
                                    component.set("v.showPopupBtn",false);
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
                        $A.get('e.force:refreshView').fire();*/
                        }
                        else if(result=='Someone has already respond to this claim')
                        {
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info',
                                message: 'Someone has already responded to this claim',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'info',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                            
                        }
                            else{
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
                        
                        
                    }), 5000
                );  
                
                
            }
            
        }
        else
        {
            // alert('Please Enter valid date');
        }
    }
})