({
	doInit : function(component, event, helper) {
		var currentURL = window.location.href;
        var depositId = currentURL.split("depositId=")[1];
        console.log("depositId:", depositId);
        component.set("v.showInitialform",true);
        var action = component.get("c.fetchRepaymentrecord");
        action.setParams({ depositId: depositId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                console.log('result -> ',JSON.stringify(result[0].Repayment_Request_Lines__r));
                
                var totalAmtFromAgllToTenant = 0;
                var totalAmtFromTtToTenant = 0;
                for(var i=0;i<result[0].Repayment_Request_Lines__r.length;i++) {
                    console.log('Line 16 -> ',result[0].Repayment_Request_Lines__r[i].AL_ReqAmt__c);
                    if(result[0].Repayment_Request_Lines__r[i].AL_ReqAmt__c==undefined || 
                       result[0].Repayment_Request_Lines__r[i].AL_ReqAmt__c==null) {
                        result[0].Repayment_Request_Lines__r[i].AL_ReqAmt__c=0;
                    }
                    if(result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c==undefined || 
                       result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c==null) {
                        result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c=0;
                    }
                    totalAmtFromTtToTenant = totalAmtFromTtToTenant +
                        parseFloat(result[0].Repayment_Request_Lines__r[i].Tenant_ReqAmt__c);
                    totalAmtFromAgllToTenant = totalAmtFromAgllToTenant + 
                        parseFloat(result[0].Repayment_Request_Lines__r[i].AL_ReqAmt__c);
                }
                
                console.log('Line 22 -> ',result[0].Deposit__r.Customer__r.Name);
                component.set("v.repaymentRec", result);
                component.set("v.totalAmtFromTtToTenant", totalAmtFromTtToTenant);
                component.set("v.totalAmtFromAgllToTenant", totalAmtFromAgllToTenant);
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("result:", result);
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);	
	}, 
    
    backToDepositDetail: function (component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("depositId=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: { id: depositId }
        });
    },
    
})