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
    
    getRepaymentRequestLine :function(component) {
        var total = 0.0
        var action = component.get('c.getRepaymentRequestLineDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null){
                component.set("v.repaymentRequestLine", allValues);
                for(var i = 0; i < allValues.length; i++){
                     console.log('++++++++++111+++'+allValues[i].AL_ReqAmt__c);
                    total = total + allValues[i].AL_ReqAmt__c;                    
                } component.set("v.repaymentRequestLineTotal", total);
            }
        });        
        $A.enqueueAction(action);
    },
    
    submitTheForm :function(component) {
        var repaymentRecordId = component.get("v.repaymentRequestRecordId");
        var action = component.get('c.submitRepaymentRequestDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null){
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "repaymentrequestsuccess"
                    },
                    state: {
                        repaymentrequest : repaymentRecordId
                    }
                }); 
            }
        });        
        $A.enqueueAction(action);
    },
    
    editDetailsOfRequest :function(component) {
       var depositId = component.get("v.repaymentRequest.Deposit__c");
        var action = component.get('c.deleteDetailsOfRepaymentRequest');
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues=='deleted'){
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "requestrepaymentofdeposit"
                    },
                    state: {
                        depositId : depositId
                    }
                }); 
            }
        });        
        $A.enqueueAction(action);
    }
})