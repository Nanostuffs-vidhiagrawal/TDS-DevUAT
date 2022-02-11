({
  doInit: function (component, event, helper) {
    var actions = [{ label: "View Deposit", name: "viewDeposit" }];
    component.set("v.columns", [
      { label: "Deposit Name", fieldName: "Name", type: "text" },
      { type: "action", typeAttributes: { rowActions: actions } }
    ]);
    var action = component.get("c.getActiveDeposit");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // Code when Success
        console.log("result:", result);

        var result = response.getReturnValue();
        for (var i = 0; i < result.length; i++) {
          var row = result[i];
          if (row.Deposit__r.Name) {
            row.Name = row.Deposit__r.Name;
          }
        }
        component.set("v.data", result);
      } else if (state === "ERROR") {
        var errors = response.getError();
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

  handleRowAction: function (component, event, helper) {
    var action = event.getParam("action");
    var row = event.getParam("row");

    switch (action.name) {
      case "viewDeposit":
      //  alert("Showing Details: " + JSON.stringify(row));
        console.log(`Line 45`);
        component.find("navService").navigate({
          type: "comm__namedPage",
          attributes: {
            pageName: "tenantviewdeposit"
          },
          state: {
            depositId: row.Deposit__c
          }
        });
        console.log(`Line 53`);
        break;
    }
  }
});