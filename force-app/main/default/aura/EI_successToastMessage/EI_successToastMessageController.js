({
  doInit: function (component, event, helper) {
    let successTitle = component.get("v.successTitle");
    let successMsg = component.get("v.successMsg");

    let toastEvent = $A.get("e.force:showToast");
    if (toastEvent) {
      toastEvent.setParams({
        title: successTitle,
        message: successMsg,
        type: "success"
      });
      toastEvent.fire();
    } else {
      alert(`${successTitle} ${successMsg}`);
    }
  }
});