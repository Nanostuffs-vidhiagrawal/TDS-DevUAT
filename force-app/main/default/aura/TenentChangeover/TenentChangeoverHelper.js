({
    getloggedInTenants : function(component, event, helper) {
      var action = component.get("c.getLoggedInUserAccountId");

        action.setCallback(this, function(result){
            component.set("v.loggedinTenant",result.getReturnValue());
         //   alert(result.getReturnValue());
        });
          $A.enqueueAction(action);
    },
    
	getChangeOverTenants : function() {
        
	},
    
    getError:function (component, event, helper) {       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
                console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
                component.set("v.errorList",response.getReturnValue());
                var   errorList= component.get("v.errorList");                 
                var userErr;
                
                for(var i=0; i<errorList.length; i++){
                    console.log("line-->9  " +errorList[i].MasterLabel );
                    console.log("line-->9  " +errorList[i].Error_Message__c );
                    if(errorList[i].MasterLabel === 'Tenant Changover'){
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.tenantErrorNew",userErr);
                    }
                   /* else if(errorList[i].MasterLabel === 'Tenant Changover Amount'){
                        console.log("line-->101" +errorList[i].Error_Message__c );
                        userErr = errorList[i].Error_Message__c;
                        
                        component.set("v.fullAmountErrorNew",userErr);
                    }  */
                    
                        else if(errorList[i].MasterLabel === 'Tenant Changover valid Amount'){
                            userErr = errorList[i].Error_Message__c;
                            component.set("v.validAmountErrorNew",userErr);
                        }            
                    
                            else if(errorList[i].MasterLabel === 'Tenant Changover valid deposit amount'){
                                userErr = errorList[i].Error_Message__c;
                                component.set("v.validDepositErrorNew",userErr);
                            }
                                else if(errorList[i].MasterLabel === 'Tenant Changover Previous Deposit'){
                                    userErr = errorList[i].Error_Message__c;
                                    component.set("v.preDepositErrorNew",userErr);
                                }    
                    
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
})