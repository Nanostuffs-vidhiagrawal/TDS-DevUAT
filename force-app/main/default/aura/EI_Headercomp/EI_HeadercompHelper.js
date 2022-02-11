({
  checkUserProfile: function(component) {   
    var action = component.get("c.getLoggedInUserProfile");
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        let result = response.getReturnValue();
          //alert('recordId => ' + component.get("v.recordId"));
   		  //alert('currentUser => ' + JSON.stringify(component.get("v.currentUser")) );
          console.log('line--> 9' +result);
          //console.log('Local Athority => ' + (String(result) == 'Local Authority'));
          console.log('line--> 8' + JSON.stringify(result));
          component.set("v.profileName",result);
          if(result=='Head Office User'){
              component.set("v.IsHeadOfficeUser",true);
          }else{
              component.set("v.IsHeadOfficeUser",false);
          }
           if(result=='Tenant'){
              component.set("v.Tenant",true);
          }else{
              component.set("v.Tenant",false);
          }          
          if(result=='Local Authority'){              
              component.set("v.LocalAuthority",true);
          }else{
              component.set("v.LocalAuthority",false);
          }
      } else if (state === "ERROR") {
        let errors = response.getError();
        let message = "Unknown error";

        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }

        console.error(message);
      } else {

      }
    });
    $A.enqueueAction(action);
  },
    
   checkdeposit : function(component, event) {
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
    
    navigateToBranch : function(component){
        console.log(`Line helper 30`);
        component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "branches"
                },
                state: {}
            });
    },
    
     tenantCountHelper : function(component, event,helper) {
       
        var action = component.get("c.tenantCount");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === "SUCCESS") {
                
              // alert(responseValue.length);
                component.set('v.countOfTenant',responseValue.length);
                component.set('v.branchlist',responseValue);
               
               
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
    
     agllCountHelper : function(component, event,helper) {
       
        var action = component.get("c.landlordCount");
         
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            if (state === "SUCCESS") {
                
             // alert(responseValue.length);
                component.set('v.countOfLandlord',responseValue.length);
                console.log(":::CountofLandlord " + JSON.stringify(responseValue));
                console.log(":::CountofLandlord length " + responseValue.length);
              //  component.set('v.branchlist',responseValue);
               
               
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

    
});