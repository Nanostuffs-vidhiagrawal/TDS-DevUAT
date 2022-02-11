({
    doInit : function(component,  event, helper) {
        console.log('Create Adjudication report component');
        var caseId = component.get("v.recordId");
        var action = component.get("c.getCaseRecord");
        action.setParams({ caseId : caseId });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : ',state);
            if (state === "SUCCESS") {
                // alert("From server: " + response.getReturnValue());
                var caseRecord = response.getReturnValue();
                component.set("v.caseList",caseRecord);
                console.log('caseRecord -> ',JSON.stringify(caseRecord));
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    
  /*  nextBttnSection : function(component,  event, helper) {
		
        component.set("v.nextButton",true);
        //component.find("decType");
        //console.log('Line 10 : ',component.find("decType").get("v.value"));
        console.log('Line 11 : ',document.getElementById("decType").value);
    }, */
    
    handleClick : function(component,  event, helper) {
        //debugger();
        var caseId = component.get("v.recordId");
        var decType = document.getElementById("decType").value;
        console.log('line 20 : ',decType);
        if(decType == 'Adjudication' || decType == 'Default' || decType == 'Review') {
            console.log('line 21 : ',decType);
            var action = component.get("c.createAdjReportRec");
            action.setParams({ caseId : caseId, 
                               decisionType : decType 
                             });
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state : ',state);
                if (state === "SUCCESS") {
                    component.set("v.nextButton",true);
                    // alert("From server: " + response.getReturnValue());
                    var reportid = response.getReturnValue();
                    //alert(reportid);
                    var navService = component.find("navService");
                    
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: reportid, // this is what you will need
                            actionName: 'view',
                            objectApiName: 'Adjudication_Report__c' // the object's api name
                        }
                    };
                    navService.navigate(pageReference);
                }
                else if (state === "INCOMPLETE") {
                    // do something
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
        }
        
        console.log('caseId 3424: ',caseId);
    }
})