({
  handleClick: function (component, event, helper) {
    var msg = "Are you sure you want to close your account?";
    if (!confirm(msg)) {
      console.log("No");
      return false;
    } else {
      var action = component.get("c.deactivateaccount");
      action.setParams({});
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log("getstate: " + state);
        if (state === "SUCCESS") {
          console.log("From server: " + response.getReturnValue());
          var resmsg = response.getReturnValue();
          if (resmsg == "Msg1") {
             component.set("v.succeessmessage", true);
           /* var showmsg =
              "Thank you for confirming you wish to close your account. The request has been sent to our customer service team who will be in contact regarding this shortly.";
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              //"title": "Success!",
              message: showmsg
            });
            toastEvent.fire();*/
          } else if (resmsg == "Msg2") {
            // window.location.reload();

            let currentURL = window.location.origin;
            let redirectURL = currentURL + "/Sds/secur/logout.jsp";
            window.location.replace(redirectURL);
            //alert('line-->28');
          } else {
            // alert('line-->33');
          }
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
    }
  },
    
   hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
    switch (button_Name) {
      case "successmsg":
     component.set("v.succeessmessage", false);
        break;
    }
   }
});