({
    doInit : function(component, event, helper) {
      //  debugger;
        try{
            let currentURL = window.location.href;
            let depositid = helper.getUrlParams("depositId");
            var action = component.get("c.getclaimdetailsforevidenceNoConsent");
            action.setParams({
                depositid: depositid
            });
            action.setCallback(this, function(a) {
              //  debugger;
                var state = a.getState();

                if (state == "SUCCESS") {
                    var retVal = a.getReturnValue();
                    var result = retVal.caseRec;

                    component.set("v.ClaimsDetails",a.getReturnValue());
                    var disputedamount = (result.Total_Agreed_by_AG_LL__c-result.Total_Agreed_by_Tenant__c);
                    component.set("v.disputedamount",parseFloat(disputedamount));
                    component.set("v.caserecid",result.Id);

                    //component.set("v.toDate", retVal.daysFromNow);
                
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    (errors && errors[0] && errors[0].message)? console.log("Error message: " + errors[0].message) : console.log("Unknown error");
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            alert(e);
        }
            
            
        },
        goBack :function(component, event, helper) {
            component.set("v.showConfirmDiv", false);
            helper.redirectToEvidenceGatheringPage(component, event, helper);
        },
        
        doAgreeToClaim : function(component, event, helper) {
            let depositid = component.get("v.depositid");
       
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "cancelclaim"
                },
                state: {
                    id : depositid
                }
            });
            
        },

        submit:function(component, event, helper) {
            
            var action = component.get("c.proceedWithNoConsent");
            action.setParams({ caseid : component.get("v.caserecid")});
     
            action.setCallback(this, function(response) {
               // debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.redirectToDepositesummaryPage(component, event, helper);
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
            });
     
            // optionally set storable, abortable, background flag here
     
            // A client-side action could cause multiple events, 
            // which could trigger other events and 
            // other server-side action calls.
            // $A.enqueueAction adds the server-side action to the queue.
            $A.enqueueAction(action);
        }
    })