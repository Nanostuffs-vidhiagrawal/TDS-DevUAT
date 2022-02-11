({
  handleChange: function (component, event, helper) {
    let selectedValues = event.getParam("value").toString();
    // alert(`${typeof selectedValues} Values=> ${selectedValues}`);
    let listofValues = selectedValues.split(",");
    console.log("listofValues:", listofValues);
    // listofValues.forEach(function (listofValues) {
    // console.log("listofValues:", listofValues);
    // });
    component.set("v.selectedValues", listofValues);
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
        console.log(response.getReturnValue());

        let items = [];
        for (var key in result) {
          items.push({
            label: result[key],
            value: key
          });
        }
        console.log(items);
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
        // console.log(result);
        var permissionmap = [];
        var jobRoleMap = [];
        for (var key in result[2]) {
          jobRoleMap.push({ key: key, value: result[2][key] });
        //  permissionmap.push({ key: key, value: result[3][key] });
        }
          component.set("v.jobRoleMap", jobRoleMap);
        for (var key in result[3]) {
      
          permissionmap.push({ key: key, value: result[3][key] });
        }
      
            component.set("v.permissionmap", permissionmap);
        var salutationMap = [];
        for (var key in result[1]) {
          salutationMap.push({ key: key, value: result[1][key] });
        }
        component.set("v.salutationMap", salutationMap);
      }
    });

    $A.enqueueAction(action);
    $A.enqueueAction(action2);
  },

  handleClick: function (component, event) {
    let jobRole = component.find("jobRole").get("v.value");
    let salutation = component.find("salutation").get("v.value");
    var allValid = component
      .find("field")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
    if (allValid && jobRole.length > 0 && salutation.length > 0) {
      alert("All form entries look valid. Ready to submit!");
      let con = component.get("v.con");
      let selectedValues = component.get("v.selectedValues");
      // let listofValues = selectedValues.split(",");
      //invoke apex class : CreateUserUnderHO controller for DML
      var action = component.get("c.createHOUser");
      action.setParams({
        con: con,
        selectedValues: selectedValues
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        // Handle Success
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          component.set("v.data", result);
          // If result has values fire toast Message
          if (result) {
            // Refresh the View
            if ($A.get("e.force:refreshView")) {
              alert(`Line 43`);
            }
            $A.get("e.force:refreshView").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success!",
              message: "User has been added to the branch successfully.",
              type: "success"
            });
            toastEvent.fire();

            // Close overlay library
            alert(`Line 55`);
            component.find("overlayLib").notifyClose();
            alert(`Line 57`);
            window.location.reload();
          }
        }
        // Handle Error
        else if (state === "ERROR") {
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
  }
});