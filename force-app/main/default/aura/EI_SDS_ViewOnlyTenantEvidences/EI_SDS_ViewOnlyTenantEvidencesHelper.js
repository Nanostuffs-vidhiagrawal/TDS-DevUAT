({
    steps : function() {
         
        var steps = new Map(
        	Object.entries(
        		{"v.ViewContinue": true, 
        		"v.showClaimBreakdown": false, 
        		"v.showAdditionalComments": false, 
        		"v.showReviewsubmission": false}
    		)
    	);
        
        return steps;
    },
    
    
    shiftnext : function(component){
       // debugger;
        let newStepsState = component.get("v.stepsSequence");
        
        let next;
        let counter = 0;
        newStepsState.forEach((value, key, map) => {
            if(next  != undefined) return;
            if(value){
				  next = counter + 1; 
            		map.set(key, false);
        	}
            counter ++;
        });
        
        if(next === undefined) return;
        
        var nextKey = Array.from(newStepsState.keys())[next];
        
        newStepsState.set(nextKey, true);
                
        component.set("v.stepsSequence", newStepsState);
    },
    
    shiftPrev : function(component){
      //  debugger;
        let newStepsState = component.get("v.stepsSequence");
        
        let prev;
        let counter = 0;
        newStepsState.forEach((value, key, map) => {
            
                if(prev  != undefined) return;
            
                if(value){
                    prev = counter - 1;  
                    map.set(key, false); 
            		component.set(key, false); // hide current section
                }
                counter ++;
                                  
            }
        );
        
        if(prev === undefined) return;
        
        var prevKey = Array.from(newStepsState.keys())[prev];
        
        if(!prevKey) return;
        
		newStepsState.set(prevKey, true);// update the map for future usage
        
        component.set(prevKey, true); // show prev section
        
        component.set("v.stepsSequence", newStepsState); // save the map
    },
    
	getUrlParams : function(paramName) {

        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const params = window.location.search.substring(1).split('&');
        
        var paramMap = [];
        for(let p of params){
            if(p){
                let pName = p.split("=")[0];
                let pval = p.split("=")[1];
                
                paramMap[pName] = pval;
            }
        }
        
        return decodeURIComponent(paramMap[paramName]);
    },
    redirectToDisclaimer : function(component, event, helper) {
        let depositid = helper.getUrlParams('depositId');

        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "no-consent"
            },
            state: {
                depositId : depositid,
                leadTenant : this.getUrlParams('leadTenant')
            }
        });
    },
        
    getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        //console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                 // console.log("line-->9  " +errorList[i].MasterLabel );
                 //  console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'Evidence Gathering  Tenant'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.tenantgathErrorNew",userErr);
                  }
                  else if(errorList[i].MasterLabel === 'Evidence Gathering  Tenant Respond'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.tenantRespondErrorNew",userErr);
                  }  
                  
                     else if(errorList[i].MasterLabel === 'Evidence Gathering  Tenant Field'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.tenantFieldErrorNew",userErr);
                     }                 
                                   
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
 
})