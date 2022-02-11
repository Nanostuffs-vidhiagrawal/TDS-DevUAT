({
	
    doInit : function(component, event, helper) { 
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        console.log("depositId"+depositId);
        
        
        var action = component.get("c.getDepositInstallmentData");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                console.log('line-->17' + JSON.stringify(result));
                
                component.set("v.depositInstallmentInstance" ,result);
            }
            else if (state === "INCOMPLETE") {
                alert('line 21');
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
        
	$A.enqueueAction(action);
  		
    },
    cancelPaymentJS : function(component, event, helper) {
        alert('I m here')
        component.set("v.isOpen", true);
        
    },
    openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isOpen", true);
   },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isOpen", false);
   },
   bankTransferMethod : function(component, event, helper) {
       
       var action = component.get("c.updatePaymentMethod");
        action.setParams({
            depositId :depositId,
            newMethod : ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isCheque", true);
                component.set("v.showChangePayment", false);
                component.set("v.isBankTransfer", true);
            }
            else if (state === "INCOMPLETE") {
                alert('line 21');
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
        
	   $A.enqueueAction(action);
       
        
   },
   chequeMethod : function(component, event, helper) {
       
       var action = component.get("c.updatePaymentMethod");
        action.setParams({
            depositId :depositId,
            newMethod : ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isCheque", true);
                component.set("v.showChangePayment", false);
                component.set("v.isBankTransfer", false);
            }
            else if (state === "INCOMPLETE") {
                alert('line 21');
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
        
	   $A.enqueueAction(action);
   },
   backToShowChangePayment : function(component, event, helper) {
       component.set("v.isBankTransfer", false);
       component.set("v.isCheque", false);
       component.set("v.showChangePayment", true);
        
   }
})