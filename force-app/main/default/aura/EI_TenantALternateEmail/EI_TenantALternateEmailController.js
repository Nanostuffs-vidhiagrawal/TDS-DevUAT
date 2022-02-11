({
	handleClick: function (component, event) {
    
       var Acc = component.get("v.acc");
      var action = component.get("c.updatealternateemail");
        action.setParams({
            Acc: Acc,
            altenateemail:component.get("v.altenateemail")
        });
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(`state=> ${state}`);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result :" + JSON.stringify(result));
            component.find("overlayLib").notifyClose();
         // window.location.reload();
        } else if (state === "ERROR") {
          var errors = response.getError();
          console.log("result :" + JSON.stringify(errors));
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
})