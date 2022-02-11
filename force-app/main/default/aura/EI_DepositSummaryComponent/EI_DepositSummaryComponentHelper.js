({
	getAgentLandlordRepayRequest : function(component,event,depositId) {
		var action = component.get("c.getAgentLandlordRepaymentRequest");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            var returnResult = a.getReturnValue();
            console.log('@@bank 2222222222'+returnResult+'5555555state'+state);
            if (state == "SUCCESS" ) {
                if(returnResult ==null || returnResult == ''){
                    component.set("v.repayRequestAgentLandlord",false);
                }
                else if(returnResult != '' || returnResult != null){
                   component.set("v.repayRequestAgentLandlord",true);
                   component.set("v.repayIdAgentLandlord",returnResult);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    getTenantRepayRequest : function(component,event,depositId) {
		var action = component.get("c.getTenantRepaymentRequest");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            var returnResult = a.getReturnValue();
            console.log('@@bank 2222222222'+returnResult+'5555555state'+state);
            if (state == "SUCCESS" ) {
                if(returnResult ==null || returnResult == ''){
                    component.set("v.repayRequestTenant",false);
                }
                else if(returnResult != '' || returnResult != null){
                   component.set("v.repayRequestTenant",true);
                   component.set("v.repayIdTenant",returnResult);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    handleLeadTenant : function(component, event, depositId){
        
        let action = component.get('c.getLeadTenant');
        action.setParams({
            depositId : depositId
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	component.set('v.isLeadTenant',result.getReturnValue());
            }else{
                let errors = result.getError();
                console.log('---Error--->>> '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
            }
        });
        $A.enqueueAction(action);
    }
    
})