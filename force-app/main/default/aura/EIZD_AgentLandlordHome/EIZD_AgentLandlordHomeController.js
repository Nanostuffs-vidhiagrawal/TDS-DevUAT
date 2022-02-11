({
    doInit : function(component, event, helper) {
       
        let currentURL = window.location.href;
        let AccessCode = currentURL.split("id=")[1];
        var action = component.get("c.getCaseDetails");
         AccessCode = AccessCode.replace("#",'');
        action.setParams({
            AccessCode: AccessCode
        });
        action.setCallback(this, function(a) {
            
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.CaseParticipant",a.getReturnValue());
                let returnvalue  = a.getReturnValue();
                component.set("v.claimId",returnvalue.Case__c);
                var depositdate =component.get("v.CaseParticipant.Case__r.Deposit_Account_Number__r.End_Date__c");
                let endDate =new Date(depositdate);
                let bs = endDate.getDate();
                let stDate = bs.toString();
                component.set("v.startdateDay", stDate);          
                component.set("v.startdateMonth", endDate.getMonth()+1);
                component.set("v.startdateYear", endDate.getFullYear());
            }
            else {
                let errormessage = JSON.stringify(errors);
            }
        });
        $A.enqueueAction(action);
    },
    doSubmit: function (component, event, helper) {
        let validateamount = true;
        let validateReason = true;
        let Cleaning = component.get("v.Cleaning");
        let Damage = component.get("v.Damage");
        let Redecoration = component.get("v.Redecoration");
        let Gardening = component.get("v.Gardening");
        let RentArrears = component.get("v.RentArrears");
        let Other = component.get("v.Other");
        let OtherReason = component.get("v.OtherReason");
        let levelofcover = component.get("v.CaseParticipant.Case__r.Total_Deposit__c");
        if(Cleaning=="" || Cleaning==undefined){           
            Cleaning = 0;         
        }
        if(Damage=="" || Damage==undefined){           
            Damage = 0;         
        }
        if(Redecoration=="" || Redecoration==undefined){           
            Redecoration = 0;         
        }
        if(Gardening=="" || Gardening==undefined){           
            Gardening = 0;         
        }
        if(RentArrears=="" || RentArrears==undefined){           
            RentArrears = 0;         
        }
        if(Other=="" || Other==undefined){           
            Other = 0;         
        }
        if (Other > 0 ) {
            if (
                OtherReason == null ||
                OtherReason == undefined ||
                OtherReason.length == 0
            ) {
                component.set("v.showErrorOther",true);
                validateReason = false;
                
            } else {
                component.set("v.showErrorOther",false);
                validateReason = true;
            } 
        }
        let totalfilledAmount = parseFloat(Cleaning)+parseFloat(Damage)
        + parseFloat(Redecoration) + parseFloat(Gardening) +parseFloat(RentArrears)+
            parseFloat(Other) ;
        if(totalfilledAmount == component.get("v.CaseParticipant.Case__r.Total_Claim_Amount__c"))
        {
            validateamount = true; 
        }
        else
        {
            validateamount = false;
        }
        if(validateamount && validateReason)
        { 
            let action = component.get("c.saveDisputeLine");
            action.setParams({
                Cleaning : Cleaning,
                Damage: Damage,
                Redecoration : Redecoration,
                Gardening: Gardening,
                RentArrears : RentArrears,
                Other : Other,
                OtherReason: OtherReason,
                CaseId: component.get("v.CaseParticipant.Case__c"),
                claimExceedsFlag : component.get("v.claimExceedsFlag")
            });
            action.setCallback(this, function (a) {                 
                var state = a.getState();
                if (state === "SUCCESS") 
                {
                    if(a.getReturnValue() =='successfully inserted')
                    {
                        component.set("v.isOpen",true);
                    }
                    else
                    {
                        let message ='Record Created successfully';
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: 'You have already submit the cliam',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                        $A.get('e.force:refreshView').fire();
                        
                    }
                   /* let message ='Record Created successfully';
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: message ,
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
                    
                }
            });
           $A.enqueueAction(action);
        }
        else
        {
            let message;
            if(!validateamount && validateReason )
            {
                if(totalfilledAmount > levelofcover)
                {
                    message='The maximum you can claim is the total level of cover. If your total claim exceeds the level of cover, you will still be able to explain this to the adjudicator if the case requires formal adjudication. The adjudicator will decide the extent of any award up to the level of the maximum cover level.';
                }
                else
                {
                    message ='The breakdown of your claim should match the total claim value';
                }
                component.set("v.showError",true);
                component.set("v.ErrorMassage",message);
                document.getElementById('errorMsg').scrollIntoView(true);
            }        
        }
    },
    
    onClickCheckBox: function (component, event, helper) {
        var checkBoxV=document.getElementById("checkBoxId").checked;
        if(checkBoxV)
        {
            component.set("v.claimExceedsFlag",true);
        }
        else
        {
            component.set("v.claimExceedsFlag",false);
        }  
    },
    showOtherReasonMethod : function (component, event, helper) {
        component.set("v.showOtherReason",true);
    },
    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
   },
    doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                         
                         }, 1000);
    },
})