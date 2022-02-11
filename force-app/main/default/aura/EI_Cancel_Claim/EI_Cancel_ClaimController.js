({
    doInit : function(component, event, helper) {
        
        let currentURL = window.location.href;
        let depositid = helper.getUrlParams('depositId');
        let userType = helper.getUrlParams('userType');
        component.set("v.depositid" ,depositid );
        if(userType=='TT'){
        component.set("v.userType" ,userType );
        }
        let userType1=component.get("v.userType");
        if(userType1 === 'AGLL')
            var action = component.get("c.getclaimdetailsforevidence");
        else 
            var action = component.get("c.getclaimdetailsforevidenceForCancel");

        action.setParams({
            depositid: depositid
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            // alert('line 11 ' + errors );
            var errors = a.getError();
            //alert('line 12 ' + errors );
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                // alert("line 13" + JSON.stringify(a.getReturnValue()));
                component.set("v.ClaimsDetails",a.getReturnValue());
                var disputedamount = (result[0].Total_Agreed_by_AG_LL__c-result[0].Total_Agreed_by_Tenant__c);
                component.set("v.disputedamount",parseFloat(disputedamount));
                component.set("v.caserecid",result[0].Id);
                /*    if(component.get("v.ClaimsDetails[0].Status") =='Evidence gathering AG/LL')
                {
                    var appEvent = $A.get("e.c:EI_ZD_refreshParentView");
                    appEvent.setParams({"pageName" : "Submit evidence"}); 
                    appEvent.fire();
                }*/
            }
        });
        $A.enqueueAction(action);
    
    },
    
    cancelclaimdetails:function(component, event, helper) {
    //    debugger;
        var action = component.get("c.cancelclaim");
        action.setParams({ caseid : component.get("v.caserecid"),
                          disptAmount:component.get("v.disputedamount")});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
          //  debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                component.set("v.viewclaimsection",false);
                component.set("v.viewcancelsummary",true);
                
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    goTodepositsummary :function(component, event, helper){
        let depositid = component.get("v.depositid");
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositid
            }
        });
    }
})