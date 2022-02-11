({
    doInit : function(component, event, helper) {
        helper.getPaymentsHeldSafeDeposits(component, event);
        helper.getRepaymentsRequestedTenants(component, event, helper);
        helper.getRepaymentsRequestedAgentLandlord(component, event, helper);
        helper.getSelfResolutionResolution(component, event, helper);
        helper.getInDisputeResolution(component, event);
        helper.getUnvalidatedDeposits(component, event);
        helper.getIndisputeresol(component, event);
        helper.getRepaymentprocess(component, event);
        helper.getDepositsrepaidinthelastyear(component, event);
        helper.getyear(component, event);
        component.set("v.displaySearchDepositRecords", false);
    },
    selectmonth: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
      //  alert("Option selected with value: '" + selectedOptionValue + "'");
         cmp.set("v.selectedmonth" ,selectedOptionValue);
    },
    
        selectyear: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue + "'");
         cmp.set("v.selectedyear" ,selectedOptionValue);
    },

    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "postcodecheck":
                component.set("v.postcodeError", false);
                break;
            case "depositamountcheck":
                component.set("v.depositamountError", false);
                break;
            case "monthcheck":
                component.set("v.monthError", false);
                break;
            case "yearcheck":
                component.set("v.yearError", false);
                break; 
        }
    },
    heldSafedepositsection : function(component, event, helper) {
        helper.helperFun(component,event,'heldSafedepositOne');
    },
    
    disputeResolutionsection : function(component, event, helper) {
        helper.helperFun(component,event,'disputeResolutionOne');
    },
    
    unvalidatedSection : function(component, event, helper) {
        helper.helperFun(component,event,'unvalidatedOne');
    },
    
    closeModel: function(component, event, helper){
        component.set("v.confirmQuestions", false);
        component.set("v.errors",'');
    },
    
    confirmdeposit : function(component, event, helper) {
      //  var actionName = event.getParam('action').name;
      //  var depositid = event.getParam('row').Deposit__c;
         var depositid = event.target.id;
        
            component.set("v.depositId", depositid);
            component.set("v.confirmQuestions", true);
            component.set("v.tenantValidationError",false);
            component.set("v.errors", '');
       
        /*var action = event.getParam('action');alert(action);
        switch (action.name) {
            case 'View':
                var address = "/depositsummarypage";
                var domain = window.location.origin;
                
                var urlEvent = $A.get("e.force:navigateToURL");
                console.log(urlEvent);
                urlEvent.setParams({
                    url: address + "?id=" + depositid
                });
                urlEvent.fire(); 
                break;
        }*/
    },
    
    hideform: function(component, event, helper) {
       component.set("v.confirmQuestions", false); 
        
    },
    viewdepositsummary: function(component, event, helper) {
        var depositid = event.target.id;
        var address = "/depositsummarypage";
        var domain = window.location.origin;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            url: address + "?id=" + depositid
        });
        urlEvent.fire();
    },
    
      handleRowAction : function(component, event, helper) {
        var actionName = event.getParam('action').name;
        var depositid = event.getParam('row').Deposit__c;
        component.set("v.depositId", depositid);
        if(actionName == 'Confirm deposit'){
            component.set("v.confirmQuestions", true);
            component.set("v.tenantValidationError",false);
            component.set("v.errors", '');
        }
        else{
            var address = "/depositsummarypage";
            var domain = window.location.origin;
            
            var urlEvent = $A.get("e.force:navigateToURL");
            console.log(urlEvent);
            urlEvent.setParams({
                url: address + "?id=" + depositid
            });
            urlEvent.fire();
        }
        /*var action = event.getParam('action');alert(action);
        switch (action.name) {
            case 'View':
                var address = "/depositsummarypage";
                var domain = window.location.origin;
                
                var urlEvent = $A.get("e.force:navigateToURL");
                console.log(urlEvent);
                urlEvent.setParams({
                    url: address + "?id=" + depositid
                });
                urlEvent.fire(); 
                break;
        }*/
    },
    
    submitTenantDetails : function(component, event, helper) {
        helper.submitDetails(component, event);
    },
    
    handleClick : function(component, event, helper) {
        helper.findDepositBySearchText(component, event);
        //component.set("v.displaySerachDepositRecords", true);
    },
})