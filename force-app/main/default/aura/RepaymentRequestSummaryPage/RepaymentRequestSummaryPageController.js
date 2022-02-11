({
	
    doInit : function(component, event, helper) {        
        var url = window.location.href.slice(window.location.href.indexOf('?') + 1);
        var repaymentRecordId = url.split("repaymentrequest=")[1];
        console.log('+++++++++++repaymentRecordId++'+repaymentRecordId);
        component.set("v.repaymentRequestRecordId", repaymentRecordId);
        helper.getRepaymentRequest(component);
        helper.getRepaymentRequestLine(component);
	},
    
    handleAgree : function(component, event, helper) {
        component.set("v.dontAgreeSection" , false);
        component.set("v.agreeSection" , false);
        component.set("v.iAgree" , true);
    },
    
    handleDontAgree : function(component, event, helper) {
        component.set("v.dontAgreeSection" , true);
        component.set("v.agreeSection" , false);
        component.set("v.iAgree" , false);
    },
    
    submitTheForm : function(component, event, helper) {
        if(component.get("v.iAgree")){
            component.set("v.agreeSection" , false);
            helper.submitTheForm(component);
        }
        else{
            component.set("v.agreeSection" , true);
            component.set("v.dontAgreeSection" , false);
        }
    },
    
    editDetailsOfRequest: function(component, event, helper) {
        helper.editDetailsOfRequest(component);
	},
})