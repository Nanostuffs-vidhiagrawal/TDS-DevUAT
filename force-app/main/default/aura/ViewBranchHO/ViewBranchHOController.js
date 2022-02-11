({
  doInit: function (component, event, helper) {
    let action = component.get("c.orgDetails");
    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        let result = response.getReturnValue();
        if (result) {
          component.set("v.accName", result.Name);
          component.set("v.accId", result.Id);
        }
      } else if (state === "ERROR") {
        let errors = response.getError();
        console.log(`${errors}`);
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  openManageUsers: function (component, event, helper) {
    var title = event.getSource().get("v.label");
    console.log(`Hey You have clicked ${title}`);
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "manageusersho"
      },
      state: {
        // accountId: component.get("v.accId")
      }
    });
  },

  openAccountReport: function (component, event, helper) {
    var title = event.getSource().get("v.label");
    console.log(`Hey You have clicked ${title}`);
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "reporting"
      },
      state: {}
    });
  },

  logOut: function (component, event, helper) {
    let currentURL = window.location.origin;
    let redirectURL = currentURL + "/Sd/secur/logout.jsp";
    window.location.replace(redirectURL);
  },

  openBranchTable: function (component, event, helper) {
    var title = event.getSource().get("v.label");
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "branches"
      },
      state: {}
    });
  },
  navigateTochangeMyDetails: function (component, event, helper) {
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "updatemydetails"
      },
      state: {}
    });
  }
});