({
	getRepaymentRequest :function(component) {
        var action = component.get('c.getRepaymentRequestDetails');
        console.log('++++++++++4444+++'+component.get("v.repaymentRequestRecordId"));
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(!$A.util.isEmpty(allValues) && !$A.util.isUndefined(allValues)){
                component.set("v.repaymentRequest", allValues);
            }
        });        
        $A.enqueueAction(action);
    },
})