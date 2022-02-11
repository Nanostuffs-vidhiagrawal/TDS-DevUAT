({
  init: function (component, event, helper) {
    helper.init(component, event);
  },

  handleChange: function (component, event, helper) {
    let selectedValues = event.getParam("value").toString();
    let listofValues = selectedValues.split(",");
      console.log('');
    component.set("v.selectedValues", listofValues);
    component.set("v.isUpdated", true);
  },

  doInit: function (component, event, helper) {
    let accountId = component.get("v.accountId");
    var action2 = component.get("c.getHObranches");
    action2.setParams({
      accountId: accountId
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        let items = [];
        for (var key in result) {
          items.push({
            label: result[key],
            value: key
          });
        }
        component.set("v.options", items);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("errors[0].message:", errors[0].message);
          }
        }
      }
    });

    var action = component.get("c.getJobRoles");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var jobRoleMap = [];
        for (var key in result[2]) {
          jobRoleMap.push({ key: key, value: result[2][key] });
        }
        component.set("v.jobRoleMap", jobRoleMap);
        
        var permissionmap = [];
        for (var key in result[3]) {
          permissionmap.push({ key: key, value: result[3][key] });
        }
        component.set("v.permissionmap", permissionmap);
          
        var salutationMap = [];
        for (var key in result[1]) {
          salutationMap.push({ key: key, value: result[1][key] });
        }
        component.set("v.salutationMap", salutationMap);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("errors[0].message:", errors[0].message);
          }
        }
      }
    });

    $A.enqueueAction(action);
    $A.enqueueAction(action2);
  },
  handleEdit: function (component, event, helper) {
    component.set("v.isDisabled", false);
  },

  handleUpdate: function (component, event, helper) {
    let isUpdated = component.get("v.isUpdated");
    if (isUpdated) {
      let jobRole = component.find("jobRole").get("v.value");
         let permission = component.find("permission").get("v.value");
      let salutation = component.find("salutation").get("v.value");
      var allValid = component
        .find("field")
        .reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
      if (allValid && jobRole.length > 0 && salutation.length > 0) {
        let con = component.get("v.con");
        let selectedValues = component.get("v.selectedValues");
        var oldselectedValues = component.get("v.oldselectedValues");

        function symmetricDifference(a1, a2) {
          var result = [];
          for (var i = 0; i < a1.length; i++) {
            if (a2.indexOf(a1[i]) === -1) {
              result.push(a1[i]);
            }
          }
          for (i = 0; i < a2.length; i++) {
            if (a1.indexOf(a2[i]) === -1) {
              result.push(a2[i]);
            }
          }
          return result;
        }
        var selectedValuesDiff = symmetricDifference(
          oldselectedValues,
          selectedValues
        );
        for (var key in selectedValuesDiff) {
          if (selectedValuesDiff[key].length < 1) {
            alert(selectedValuesDiff[key].length);
            selectedValuesDiff.pop();
          }
        }
          console.log('!! '+con.Additional_Permission__c);
        // let listofValues = selectedValues.split(",");
        //invoke apex class : CreateUserUnderHO controller for DML
        var action = component.get("c.updateHOUser");
           console.log('!!action '+action);
        action.setParams({
          con: con,
          selectedValues: selectedValuesDiff
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
             console.log('!!state '+state);
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            // If result has values fire toast Message

            component.set("v.isDisabled", true);
            component.set("v.isUpdated", false);

            var toastEvent = $A.get("e.force:showToast");
            console.log(toastEvent);
            toastEvent.setParams({
              title: "Success!",
              message: "User has been added to the branch successfully.",
              type: "success"
            });
            toastEvent.fire();

            // Close overlay library
            component.find("overlayLib").notifyClose();

            // Refresh the View

            let refresh = $A.get("e.force:refreshView");
            if (refresh) {
              refresh.fire();
              // alert(`Line 274`);
            } else {
              window.location.reload();
            }
          }
          // Handle Error
          else if (state === "ERROR") {
            console.log(errors);
            var errors = response.getError();
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
      } else {
        let errorTitle = "ERROR !!";
        let errorMsg = "Please update the invalid form entries and try again";
        $A.createComponent(
          "c:EI_errorToastMessage",
          {
            errorMsg: errorMsg,
            errorTitle: errorTitle
          },
          function callback(cmp, status) {
            if (status === "ERROR") {
              alert("status" + errorMsg);
            }
          }
        );
      }
    } else {
      let errorTitle = "ERROR !!";
      let errorMsg = "Please update something or Cancel";
      $A.createComponent(
        "c:EI_errorToastMessage",
        {
          errorMsg: errorMsg,
          errorTitle: errorTitle
        },
        function callback(cmp, status) {
          if (status === "ERROR") {
            alert("status" + errorMsg);
          }
        }
      );
    }
  },

  handleCancel: function (component, event, helper) {
    component.set("v.isDisabled", true);
    component.set("v.isDisabled", true);
    helper.init(component, event);
  },

  isUpdated: function (component, event, helper) {
    component.set("v.isUpdated", true);
  },

  deactivateUser: function (component, event, helper) {
    // Get Attributes from component markup
    let selectedUserId = component.get("v.selectedUserId");
    console.log("selectedUserId:", selectedUserId);
    var action = component.get("c.inactiveBranchUser");
    action.setParams({
      userId: selectedUserId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(state);
      // Handle Success
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        console.log(JSON.stringify(result));
        if (!result) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "User can been successfully deactivated.",
            type: "success"
          });
          toastEvent.fire();
          component.find("overlayLib").notifyClose();
        }
      }
      // Handle Error
      else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log(errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  reactivateUser: function (component, event, helper) {
    // Get Attributes from component markup
    let selectedUserId = component.get("v.selectedUserId");
    var action = component.get("c.reactiveBranchUser");
    action.setParams({
      userId: selectedUserId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      //   console.log(state);
      // Handle Success
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // console.log(result);
        // console.log(JSON.stringify(result));
        if (result) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "User can been successfully Activated.",
            type: "success"
          });
          toastEvent.fire();
          component.find("overlayLib").notifyClose();
        }
      }
      // Handle Error
      else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            // console.log(errors[0].message);
          }
        } else {
          //   console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});