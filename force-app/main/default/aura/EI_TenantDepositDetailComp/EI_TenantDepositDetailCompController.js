({
  doInit: function (component, event, helper) {
    var currentURL = window.location.href;
    var depositId = currentURL.split("depositId=")[1];
    console.log("depositId:", depositId);
    var action = component.get("c.checkRepaymentRequested");
    action.setParams({ depositId: depositId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state:", state);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result == true) {
          component.set("v.showRespondBtn", true);
        } else if (result == false) {
          component.set("v.showRespondBtn", false);
        } else {
          component.set("v.showRespondBtn", false);
        }
        // Code when Success
        console.log("result:", result);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("result:", result);
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  moveToRepaymentPage: function (component, event, helper) {
    var currentURL = window.location.href;
    var depositId = currentURL.split("depositId=")[1];
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "tenantresponsedetail"
      },
      state: {
        depositId: depositId
      }
    });
  }
});