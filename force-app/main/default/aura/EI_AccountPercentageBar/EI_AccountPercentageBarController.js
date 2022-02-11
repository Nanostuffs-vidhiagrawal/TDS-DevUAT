({
  
	doInit : function(component, event, helper) {
        component.set("v.personalDetails",false);
        component.set("v.marketingPref",false);
        component.set("v.piClaus",false);
        component.set("v.bankDetails",false);
	 var action = component.get("c.getscore");
        action.setParams({  });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
            /* var interval = setInterval($A.getCallback(function () {
            var progressbar = response.getReturnValue();
            
            component.set('v.progress', progressbar === 1000 ? clearInterval(interval) : progressbar);
             }), 200);*/
                var returnResult = response.getReturnValue();
              
               // var res = returnResult.split("#");
                var paymentDetails =parseInt(returnResult.split("#")[0]); 
                var marketPref = parseInt(returnResult.split("#")[1]);
                var piClause = parseInt(returnResult.split("#")[2]);
                var bankDetails = parseInt(returnResult.split("#")[3]);
                
              //    alert('account details '+paymentDetails+marketPref+piClause+bankDetails)
                  if(paymentDetails != 0){
                      component.set("v.personalDetails",true);
                  }
                 if(marketPref != 0){
                      component.set("v.marketingPref",true);
                  }
                 if(piClause != 0){
                      component.set("v.piClaus",true);
                  }
                 if(bankDetails != 0){
                      component.set("v.bankDetails",true);
                  }
                var total = parseInt(paymentDetails + marketPref + piClause + bankDetails);
                 component.set("v.progress",total);
            }
            else if (state === "INCOMPLETE") {
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
   
    component2Event: function(cmp, event) {
         $A.enqueueAction(cmp.get("c.doInit"));
       // this.doInit(component, event, helper);
    }
})