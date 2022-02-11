({
	myAction : function(component, event, helper) {
		
	},
    doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                         
                         }, 2200);
    },
    showSpinner: function(component, event, helper) {
        component.set("v.PageSpinner",true);
    }
})