({
	    claimDetails : function(component, event, helper) {
              let weapperRec = component.get("v.WrapperList");
            let userrec = weapperRec[0].usr;
          var action = component.get("c.getClaimDetails");
        action.setParams({
            "claimId":   component.get("v.claimId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.ClaimsDetails",a.getReturnValue());
                let totalAmount = component.get("v.ClaimsDetails[0].Total_Agreed_by_Tenant__c");
                component.set("v.totalTenantAmount",totalAmount);
                let casePartirec = a.getReturnValue()[0].Case_Participants__r;
                let leadtenant =false;
                for(let i =0; i< casePartirec.length; i++)
                {
                    if(userrec.ContactId ==casePartirec[i].Contact__c )
                    {
                        if(casePartirec[i].Is_Lead__c)
                        {
                            leadtenant= true; 
                        }
                    }
                }
                component.set("v.isLead",leadtenant);
            }
            else {
                let errormessage = JSON.stringify(a.getReturnValue());
                if (errormessage.includes("<br>")) {
                    errormessage = errormessage.replaceAll("<br>", " ");
                   /* component.find("notifLib").showNotice({
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
	
})