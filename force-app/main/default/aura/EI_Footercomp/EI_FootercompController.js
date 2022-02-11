({
       doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                         
                         }, 300);
    },
	myAction : function(component, event, helper) {
		
	}
})