({
  doInit: function (component, event, helper) {
    let errorTitle = component.get("v.errorTitle");
    let errorMsg = component.get("v.errorMsg");

    let toastEvent = $A.get("e.force:showToast");
    if (toastEvent) {
      toastEvent.setParams({
        title: errorTitle,
        message: errorMsg,
        type: "error"
      });
      toastEvent.fire();
    } else {
      alert(`${errorTitle} ${errorMsg}`);
    }
  }
});