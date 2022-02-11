({
    doinit : function(component, event, helper) {
         helper.helperInit(component, event, helper);
        helper.emaildomaincheck(component, event);
        var action = component.get("c.loggedintenantdeposits");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('line-->10' + JSON.stringify(response.getReturnValue()));   
                component.set("v.userdeposit",response.getReturnValue());
                if(responseValue!=null){console.log('length  ' + responseValue.length); 
                    for(var i=0;i<responseValue.length;i++){
                        if(responseValue.length>1){
                            component.set("v.activeDeposits",true);
                        }
                        else if(responseValue.length==1){
                            component.set("v.activeDeposits",true);
                            var depositId = responseValue[i].Deposit__c;
                            console.log('line--depositId' + depositId);   
                            //var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"depositsummarypage?id="+depositId;
                            //window.location.replace(urlRedirect);
                            //return false;
                        }
                    }
                }
            }
            else if (state === "INCOMPLETE") {
             //   alert('line-->63');
            }
                else if (state === "ERROR") {
               //     alert('line-->66');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            console.log("Error message: " + JSON.stringify(errors[0].message)
                                       );
                        }
                    } else {
                 //       alert('line-->75');
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);    
        
    },
    
    depositlookup: function(component, event, helper) {
        var title = event.getSource().get("v.label");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositlookup"
            },
            state: {}
        });
    },
    
    Viewdeposit: function(component, event, helper) {
        var title = event.getSource().get("v.label");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenantavailabledeposit"
            },
            state: {}
        });
    },
    
    myDetails: function(component, event, helper) {
       var title = event.getSource().get("v.label");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "my-details"
            },
            state: {}
        });
    },
    
    OutstandingActions: function(component, event, helper) {
        var title = event.getSource().get("v.label");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "outstandingactions"
            },
            state: {}
        });
    },
    
    ChangeOver: function(component, event, helper) {        
        var title = event.getSource().get("v.label");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "changeover"
            },
            state: {
                id: component.find("ChangeOverId").get("v.value")
                
            }
        });
    },
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            case "emailOfUser":
                component.set("v.emailError", false);
                break;
        }
    },
    
    handleClick: function (component, event) {
    
        var Acc = component.get("v.acc");
        var emailcheck =component.get("v.altenateemail");
        var isValid = true;
        
        if (emailcheck == undefined || emailcheck == "" || emailcheck == null) {  
            component.set("v.emailError",true);    
            isValid = false;
        }
        else{
            component.set("v.emailError",false); 
        }
        if(isValid){
      var action = component.get("c.updatealternateemail");
        action.setParams({
            Acc: Acc,
            altenateemail:component.get("v.altenateemail")
        });
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(`state=> ${state}`);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result :" + JSON.stringify(result));
         component.set("v.succeessmessage", true);
         setTimeout(function(){ component.set("v.showemailpopup", false); }, 3000);
        } else if (state === "ERROR") {
          var errors = response.getError();
          console.log("result :" + JSON.stringify(errors));
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
        }
    },
    
    cancelRefresh : function(component, event) {
        component.set("v.showemailpopup", false);
    }
    	
})