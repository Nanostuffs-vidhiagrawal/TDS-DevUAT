({
  doEditDeposit: function (component, event, helper) {
    var modalBody;
    $A.createComponent("c:EI_depositDetail", {}, function (content, status) {
      if (status === "SUCCESS") {
        modalBody = content;
        component.find("overlayLib").showCustomModal({
          header: "Edit Deposit",
          body: modalBody,
          showCloseButton: true,
          cssClass: "mymodal",
          closeCallback: function () {}
        });
      }
    });
  }
});