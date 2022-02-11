({
    fetchdata: function(component, event, helper) {
     var action = component.get("c.displayLoggedInUserContactInfo");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userCon = response.getReturnValue();
               console.log("result :" + JSON.stringify(userCon));
                if(userCon.Newsletter_Subscription__c ==false || userCon.Marketing_Agreement__c ==false ){
                    var modalBody;
                    $A.createComponent("c:EI_MarketingPreferences", {
                        
                        con :userCon
                    },
                                       function(content, status) {
                                           if (status === "SUCCESS") {
                                               modalBody = content;
                                               component.find('overlayLib').showCustomModal({
                                                   header: "Marketing Preferences",
                                                   body: modalBody,
                                                   showCloseButton: false,
                                                   cssClass: "mymodal",
                                                   closeCallback: function() {
                                                       alert('You closed the alert!');
                                                   }
                                               })
                                           }
                                       }); 
                    
                }
                else {
                    
                    
                }
            }
            else if (state === "INCOMPLETE") {
                alert('line 15');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
     
    
    },
    waiting: function(component, event, helper) {
        component.set("v.HideSpinner", true);
    },
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
        component.set("v.PageSpinner", true);
        
    },
    AddDeposit: function (component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        
        if(branchid != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "adddeposit"
                },
                state: {branchId: branchid}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "adddeposit"
                },
                state: {}
            });
        }
    },
    Viewdeposit: function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        //alert(event.getSource());
        
        // var title = event.getSource().get("v.label");
        //  alert(title);
        if(branchid != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {
                    branchId: branchid
                }
            });
        }
        else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {
                    
                }
            });
        }
    },
    
    recentlydeleted: function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        if(branchid != null){   
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "recentlydeleteddeposit"
                },
                state: {branchId: branchid}
            });
        }
        else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "recentlydeleteddeposit"
                },
                state: {}
            });
        }
    },
    
    
    manageyouraddresses: function(component, event, helper) {
        //   var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        if(branchid != null){ 
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {branchid : branchid}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {}
            }); 
        }
    },
    
    updatemydetails: function(component, event, helper) {
        //  var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        if(branchid != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {branchid : branchid}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {}
            });
        }
    },
    
    reporting: function(component, event, helper) {
        //   var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        if(branchid != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "reporting"
                },
                state: {branchid : branchid}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "reporting"
                },
                state: {}
            });  
        }
    },
    
    manageusers: function(component, event, helper) {
        //  var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        if(branchid != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageusers"
                },
                state: {branchid : branchid}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageusers"
                },
                state: {}
            });
        }
    },
    
    logout: function (component, event, helper) {
        let currentURL = window.location.origin;
        let redirectURL = currentURL + "/secur/logout.jsp?retUrl=https://devuat-thedisputeservice.cs87.force.com/Sds/CommunitiesLanding";
        window.location.replace(redirectURL);
    }
    
    
    
});