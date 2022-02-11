({
		helperInit : function(component, event, helper) {
		 var action = component.get("c.getChangeOverCase");     
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
    // alert(resResult);
            if(resResult != '' || resResult != null){
//              alert(resResult);
                component.set("v.changeOverList",resResult);
                
          	  }
        });
          $A.enqueueAction(action);
	},
    
    emaildomaincheck : function(component, event) {
      //  alert("line-->3");
        var action = component.get("c.loggedInUserAccountInfo");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userCon = response.getReturnValue();
                console.log("result --> 24 :" + JSON.stringify(userCon));
                if(userCon){
                     component.set("v.acc" ,userCon);
                     component.set("v.showemailpopup" ,true);
                   /* var modalBody;
                    $A.createComponent("c:EI_TenantALternateEmail", {
                        
                        acc :userCon
                    },
                                       function(content, status) {
                                           if (status === "SUCCESS") {
                                               modalBody = content;
                                               component.find('overlayLib').showCustomModal({
                                                   header: "Second Email Address",
                                                   body: modalBody,
                                                   showCloseButton: false,
                                                   cssClass: "mymodal",
                                                   closeCallback: function() {
                                                      // alert('You closed the alert!');
                                                   }
                                               })
                                           }
                                       }); */
                    
                } 
                else {
                component.set("v.showemailpopup" ,false);  
                    
                }
            }
            else if (state === "INCOMPLETE") {
          //      alert('line 15');
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
})