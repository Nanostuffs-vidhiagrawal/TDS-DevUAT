({
	helperMethod : function() {
		
	},
    getError:function (component, event, helper){
        
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                  console.log("line-->9  " +errorList[i].MasterLabel );
                   console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'Evidence Gathering'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.eviGatheringErrorNew",userErr);
                  }
                  else if(errorList[i].MasterLabel === 'Evidence Gathering AG/LL'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.evigatAGLLErrorNew",userErr);
                  }  
                  
                     else if(errorList[i].MasterLabel === 'Evidence Gathering AG/LL Document'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.evigatDocErrorNew",userErr);
                  } 
                  else if(errorList[i].MasterLabel === 'AGLL Evidence'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.evidenceErrorNew",userErr);
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