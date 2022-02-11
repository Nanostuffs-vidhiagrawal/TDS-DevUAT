({
	getDepositDetails :function(component) {
        console.log('allValues display-- >> ');
        var action = component.get('c.getDepositInformation');
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null){
                console.log('allValues display-- >> ' + allValues);
                component.set("v.listOfAllDeposits", allValues);
            }
        });        
        $A.enqueueAction(action);
    },
    
    submitTransfers :function(component) {
        var emailValue = component.find("emailId").get("v.value");
        console.log('11111111111 '+emailValue);
        var action = component.get("c.getAgentLandlordEmailDetails");
        if(component.get("v.singleDeposit")){
            var selectedDeposits = [];
            selectedDeposits.push(component.get("v.depositRecordId"));
            component.set("v.selectedDeposits",selectedDeposits);
            action.setParams({ emailValue : emailValue,
                          listDepositId : component.get("v.selectedDeposits")});
        }
        else{
            action.setParams({ emailValue : emailValue,
                          listDepositId : component.get("v.selectedDeposits")});
        }
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                if(allValues=='transferred'){
                    console.log('allValues display-- >> ' + allValues);
                    component.set("v.openmodel", false);
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: {
                            id: component.get("v.depositRecordId")
                        }
                    });
   				}
            }
            else{  
            }
        });        
        $A.enqueueAction(action);
    },
    
     getError:function (component, event, helper){       
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
                  if(errorList[i].MasterLabel === 'Transfer to another Landlord'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.emailErrorNew",userErr);
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