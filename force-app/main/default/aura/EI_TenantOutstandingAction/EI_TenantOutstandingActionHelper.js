({
    helperInit : function(component, event, helper) {
        var action = component.get("c.getChangeOverCase");     
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
            //   alert(resResult);
            if(resResult != '' || resResult != null){
                
                component.set("v.changeOverList",resResult);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    helperGetOutstandingCases : function(component, event, helper) {
        var action = component.get("c.getOutstandingCases");     
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
            
            if(resResult != '' || resResult != null){
                
                component.set("v.outstandingCases",resResult);
                
            }
        });
        $A.enqueueAction(action);
    }
    
})