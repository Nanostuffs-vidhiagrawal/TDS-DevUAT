({
    doInit : function(component, event, helper) {
        window.history.pushState(null,null,window.location.href);
        window.history.forward();
       // alert('Back btn Testing');
      // component.find("select").focus();
      //$A.get('e.force:refreshView').fire();
       
       // window.history.pushState(null,null,window.location.href);
        //window.history.forward();
        /* window.history.pushState(null,null,window.location.href);
        window.onpopstate = function()
        {
            console.log('Line 9');
            window.history.go(1);
        }
        */
       // window.location.replace(window.location.href);

        
        
        var action = component.get("c.getLoginUserDetails");
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                let returnval = a.getReturnValue();
                component.set("v.WrapperList",returnval);
                if(component.get("v.WrapperList[0].Caseparticipant[0].Is_Active__c"))
                {
                    $A.enqueueAction(component.get("c.viewTenancy"));
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
    
    doConfirmTenancy : function(component, event, helper) {
        let postcode = component.get("v.Postcode");
        if(postcode) 
        {
            var action = component.get("c.validateUser");
            action.setParams({
                RecordID: component.get("v.ConfirmTenancyID"),
                Postcode:postcode
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();
                let ReturnValue = a.getReturnValue();
                if (state == "SUCCESS") {
                    component.set("v.attemptLeft",ReturnValue[1]);
                    if(ReturnValue[0]=='Postcode Incorrectly')
                    {
                        component.set("v.invalidPostcode",true);
                        component.set("v.unauthorizedUser",false);
                        
                    }
                    else if(ReturnValue[0]=='Postcode Correct')
                    {
                        component.set("v.invalidPostcode",false);
                        component.set("v.unauthorizedUser",true);
                        $A.get('e.force:refreshView').fire();
                    }
                        else if(ReturnValue[0] =='User Deactivate')
                        {
                            alert('Please contact Zero Deposit to gain access to your  Account'); 
                            $A.get('e.force:refreshView').fire();
                        }
                            else
                            {
                                component.set("v.invalidPostcode",false);
                                component.set("v.unauthorizedUser",false);
                                alert('Someting wrong happand');
                                
                            }
                }
                else {
                    
                }
            });
            $A.enqueueAction(action);
            
        }
        else
        {
            alert ('Please Enter Postcode');
        }
    },
    viewConfirm : function(component, event, helper) {
        
        component.set("v.ConfirmTenancy",true);
        document.getElementById('scrollView').scrollIntoView(true);
        //component.set("v.ConfirmTenancyID",event.getSource().get("v.value"));
        component.set("v.ConfirmTenancyID",event.currentTarget.dataset.myid);
        component.set("v.viewClaim",false);
        
        
    },
    viewTenancy : function(component, event, helper) {
        component.set("v.ConfirmTenancy",false);
        component.set("v.viewClaim",true);
       // let calimID =event.getSource().get("v.value");
       // let calimID =event.currentTarget.dataset.myid;
        let calimID =component.get("v.WrapperList[0].Caseparticipant[0].Case__c");
        var childComponent = component.find("childCmp"); 
        var message = childComponent.childMethod(calimID);
    },
    contactZD : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "http://app.zerodeposit.com/contact"
        });
        urlEvent.fire();
    },
    doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                         
                         }, 1000);
    },
    
    
    
})