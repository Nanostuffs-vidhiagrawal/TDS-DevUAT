({
    doInit: function(component, event, helper) {
        helper.helperInit(component, event, helper);
        helper.helperGetOutstandingCases(component, event, helper);
    },
    
    aprvChangeOver : function(component, event, helper) {
        var updateCaseId = event.getSource().get("v.value");
        var action = component.get("c.approveChangeOver");
        //    alert(updateCaseId);
        action.setParams({
            CaseId : updateCaseId
        });
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
            // alert(resResult);
            if(resResult == 'Success'){
                // alert('Successfully Approved Change Over')
                helper.helperInit(component, event, helper);
                $A.get('e.force:refreshView').fire(); 
            }
        });
        $A.enqueueAction(action);
    },
    
    rjctChangeOver : function(component, event, helper) {
        var updateCaseId = event.getSource().get("v.value");
        
        
        var action = component.get("c.rejectChangeOver");
        action.setParams({
            CaseId : updateCaseId
        });
        
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
            if(resResult == 'Successfully Updated'){
                //  alert('Successfully Rejected Change Over')
                
                helper.helperInit(component, event, helper);
                $A.get('e.force:refreshView').fire(); 
            }
        });
        $A.enqueueAction(action); 
    },
    
})