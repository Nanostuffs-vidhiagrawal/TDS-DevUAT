({
	getDraftIdfromURL : function() {
		var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        
        return paramValue["draftId"];
	},
    getDraftId : function(component, event, helper) {
        var action = component.get("c.getDraftId");
  
        action.setCallback(this, function(response){
        //    debugger;
            var state = response.getState();
            console.log('state '+state);
            if (state === "SUCCESS") {
                var depId = response.getReturnValue();
                console.log('deposit ID - '+ depId);
            
                this.transferToPay(component,event, depId);
         
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {

            }
        });
        $A.enqueueAction(action);
	},
    showErrorToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Problem",
            "message": message
        });
        toastEvent.fire();
    },
    transferToPay : function(component,event, draftId) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id: draftId,
                redirect: true
            }
        });
    },
})