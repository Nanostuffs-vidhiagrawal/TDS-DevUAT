({
  doInit: function (component, event, helper) {
    let currentURL = window.location.href;
    let branchId = currentURL.split("branchId=")[1];
    component.set("v.branchId", branchId);

    // Server Side call to get userInfo
    var action = component.get("c.fetchBranch");
    action.setParams({
      branchId: branchId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      // Handle Success
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        console.log(JSON.stringify(result));
        if (result.Branch_Name__c) {
          component.set("v.branchName", result.Branch_Name__c);
        }
      }
      // Handle Error
      else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            // for other errors fire toast Message
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Error!",
              message: errors[0].message,
              type: "error"
            });
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});