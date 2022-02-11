({
    doSave : function(component, event, helper) {
        var objChild = component.find("compB");
        helper.PassVariable(component, event, helper);
        if (
            objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined" 
        ) {
            alert("Please fill Address");
        }
        else{            
            
            var action = component.get("c.saveproperty");
            
            action.setParams({
                "prop": component.get("v.Propobj"),
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Property has been created successfully."
                    });
                    toastEvent.fire();
                    component.find("overlayLibDemo1").notifyClose();
                    window.location.reload();
                }
                /*  else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Invalid details!",
                        "message": "Please fill correct values."
                    });
                    toastEvent.fire();
               component.find("overlayLibDemo1").notifyClose();
                }  */
                });
            
            $A.enqueueAction(action);
            
        }
    },
    
    parentPress: function (component, event, helper) {
        helper.PassVariable(component, event, helper);
           alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
})