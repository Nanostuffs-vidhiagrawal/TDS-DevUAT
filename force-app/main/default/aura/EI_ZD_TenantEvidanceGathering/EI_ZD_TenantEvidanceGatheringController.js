({ 
    doInit : function(component, event, helper) {
        var action = component.get("c.getLoginUserDetails");
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                let returnval = a.getReturnValue();
                component.set("v.WrapperList",returnval);
                component.set("v.claimId",component.get("v.WrapperList[0].Caseparticipant[0].Case__c"));
                helper.claimDetails(component, event, helper);
                if(component.get("v.WrapperList[0].Caseparticipant[0].Is_Active__c"))
                {
                 //   $A.enqueueAction(component.get("c.viewTenancy"));
                }
            }
            else {
                let errormessage = JSON.stringify(a.getReturnValue());
                if (errormessage.includes("<br>")) {
                    errormessage = errormessage.replaceAll("<br>", " ");
                  /*  component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message: errormessage,
                        closeCallback: function() {}
                    });*/
                }
            }
        });
        $A.enqueueAction(action);
    },
showContinue : function(component, event, helper) {
        debugger;
		console.log('view evidence clicked');
        component.set("v.ViewContinue",true);
         component.set("v.HideContinue",true);
        component.set("v.viewClaim",false);
	},
    getExtraTextBox : function(component, event, helper) {
        
		console.log('getExtraTextBox');
        component.set("v.HideContinue",false);
        component.set("v.getTextBox",true);
	},
    goToClaimBreakdown : function(component, event, helper) {
        
		console.log('goToClaimBreakdown');
        component.set("v.ViewContinue",false);
        component.set("v.showClaimBreakdown",true);
	},
     goToNextItem : function(component, event, helper) {
        let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
        let CurrentItem = component.get("v.currentItem") +1;
        if(totalItem == CurrentItem)
        {
            component.set("v.showAdditionalComments",true);
            component.set("v.showClaimBreakdown",false);
            component.set("v.keyDocuments",false);
            
        }
        else
        {
            component.set("v.AGLLRecords",true);

            component.set("v.currentItem",(component.get("v.currentItem")+1));
        }
        
        
    },
    hideAGLLRecords: function(component, event, helper) {
           component.set("v.AGLLRecords",false);
        
    }
   
    
})