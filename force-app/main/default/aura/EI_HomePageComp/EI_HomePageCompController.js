({
  AddDeposit: function (component, event, helper) {
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "adddeposit"
      },
      state: {}
    });
  }
});