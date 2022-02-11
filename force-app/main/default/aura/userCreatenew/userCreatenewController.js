({
    doInit: function (component, event, helper) {
          var fetchPicklist = component.get("c.getUserRole");
        var jobRoleTest = component.find("jobrole");
        var opts=[];
        fetchPicklist.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            jobRoleTest.set("v.options", opts);
             
        });
           var fetchPicklist2 = component.get("c.getUserPermission");
        var userPerm = component.find("userpermission");
        var opts2=[];
        fetchPicklist2.setCallback(this, function(a) {
            opts2.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts2.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            userPerm.set("v.options", opts2);
             
        });
        var action = component.get("c.takesalutation");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var salutationMap = [];
                for (var key in result[0]) {
                    salutationMap.push({ key: key, value: result[0][key] });
                }
                component.set("v.salutationMap", salutationMap);
            }
        });
            $A.enqueueAction(fetchPicklist); 
         $A.enqueueAction(fetchPicklist2);
        $A.enqueueAction(action);
    },
    
    handleClick: function (component, event) {
        var salutation = component.find("salutation").get("v.value");
          var jobrole = component.find("jobrole").get("v.value");
          var userpermission = component.find("userpermission").get("v.value");
       // alert('@@ '+ jobrole+userpermission);
        var allValid = component.find("field")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);   
        if (allValid && salutation.length > 0) {
        var act = component.get("v.act");
       // alert('act'+JSON.stringify(component.get("v.act")));
    //   alert('31');
        var action = component.get("c.usercreate");
            action.setParams({
        salute :component.get("v.Title"),
        act: act,
        jobrole :jobrole,
        userpermission : userpermission 
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        // Handle Success
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          //component.set("v.data", result);
          // If result has values fire toast Message
          if (result) {
            // Refresh the View
            if ($A.get("e.force:refreshView")) {
            //  alert(`Line 43`);
            }
            $A.get("e.force:refreshView").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success!",
              message: "User has been created successfully.",
              type: "success"
            });
            toastEvent.fire();

            // Close overlay library
            //alert(`Line 55`);
            component.find("overlayLib").notifyClose();
           // alert(`Line 57`);
            window.location.reload();
          }
        }
        // Handle Error
        else if (state === "ERROR") {
          var errors = response.getError();
           console.log('line-->41' + JSON.stringify(errors));
          // If error then check error type
          if (errors) {
            if (errors[0] && errors[0].message) {
              // If duplicate username fire toast message
              if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                  title: "Error!",
                  message:
                    "User is already registered with this email Id in the system",
                  type: "error"
                });
                toastEvent.fire();
              } else {
                // for other errors fire toast Message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                  title: "Error!",
                  message: errors[0].message,
                  type: "error"
                });
                toastEvent.fire();
              }
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    } 
        }
})