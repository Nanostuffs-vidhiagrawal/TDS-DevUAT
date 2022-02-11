({
	doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 2200);
    },
    doInit : function(component, event, helper) {
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const referenceNumber = urlParams.get('referenceNumber');
        

        var action = component.get("c.getPaymentConfiramtion");
        action.setParams({
            referenceNumber :referenceNumber,
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                
                
                component.set("v.wrapInstance" ,result);
                
            }
            else if (state === "INCOMPLETE") {
                
                
                //alert('line 21');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {
                        
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    downloadpitemplate : function(component, event, helper) {
        var depositid = event.target.id;
        
       // var customlbl ='https://uat-tds.cs87.force.com/';
        //var customlbl ='https://thedisputeservice--uat--c.visualforce.com';
        // alert(customlbl);
        //let currentURL = window.location.origin;
        //let redirectURL = currentURL +'/apex/EI_Prescribeinformation?id=a0L26000003qcDh';
       // var redirectURL = ''+customlbl+'/apex/EI_Prescribeinformation?id='+depositid+'';
         var redirectURL = '/EI_PrescribedInformationNew?id='+depositid;
        window.open(redirectURL);
    },
})