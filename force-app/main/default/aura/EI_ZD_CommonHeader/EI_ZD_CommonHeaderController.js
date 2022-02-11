({
    doInit : function(component, event, helper) {
        //document.body.style.backgroundColor = '#ccc';
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        var urlId = '';
        var userType = '';
        if(urlParams.has("id")){
            urlId = urlParams.get("id");


            userType = 'agent';
        }
        else {
            urlId =  $A.get("$SObjectType.CurrentUser.Id");
            userType = 'tenant';
            
        }
        var action = component.get("c.getTenantDetails");
        
        action.setParams({
            "urlID": urlId,
            "userType" : userType
        });
        
        action.setCallback(this,
                           function (response) {
                               if(response.getState() === 'SUCCESS'){
                                   
                                  /* var spinner = component.find("mySpinner");
                                   
                                   window.setTimeout(
                                       $A.getCallback(function() {
                                           $A.util.toggleClass(spinner, "slds-hide");
                                       }), 500
                                   ); */
                                   
                                   var res = response.getReturnValue();
                                   
                                   component.set("v.userName",res);
                               }
                           });
        $A.enqueueAction(action);
        
    },
    contactZD : function(component, event, helper) {
        
        
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "http://app.zerodeposit.com/contact"
        });
        urlEvent.fire();
    },
    logout :  function(component, event, helper) {
        //window.location.replace('/secur/logout.jsp');
        window.location.href = window.location.origin+'/zd/s/login';
        // window.location.replace("https://espdevpro1-thedisputeservice.cs87.force.com/servlet/networks/switch?startURL=%2Fsecur%2Flogout.jsp");
    },
    goToCliamSummary:function(component, event, helper) {
        location.reload();
    },
    refreshParentViewEvent :function(component, event, helper){
        var pageName = event.getParam("pageName"); 
        component.set("v.pageName",pageName);
    },
    doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                         
                         }, 2200);
    },
    showSpinner: function(component, event, helper) {
        component.set("v.PageSpinner",true);
    }
})