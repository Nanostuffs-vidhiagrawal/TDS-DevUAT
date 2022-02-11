({
  doInit: function (component, event, helper) {
    var action = component.get("c.getuserDetails");
    action.setCallback(this, function (a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        component.set("v.Usersdetails", a.getReturnValue());
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  primaryLandlord: function (component, event, helper) {
    let selectRecord = event.target.id;
    let primarylandlord = component.get("v.PrimarylandlordDetails");
    let selectedrecId = component.get("v.selectedjointlandlordID");
    let selectedrec = [];
    let selectedPrimarylandlord = component.get("v.selectedPrimarylandlord");
    if (selectedPrimarylandlord.length > 0) {
      if (selectedrecId.includes(selectedPrimarylandlord[0].Id)) {
        let index = selectedrecId.indexOf(selectedPrimarylandlord[0].Id);
        selectedrecId.splice(index, 1);
      }
    }

    for (let i = 0; i < primarylandlord.length; i++) {
      if (primarylandlord[i].Id == selectRecord) {
        if (!selectedrecId.includes(selectRecord)) {
          selectedrec.push(primarylandlord[i]);
          selectedrecId.push(selectRecord);
        }
      }
    }
    component.set("v.PrimarylandlordDetails", "");
    component.set("v.selectedPrimarylandlord", selectedrec);
    component.set("v.selectedjointlandlordID", selectedrecId);
  },
  JointLandlord: function (component, event, helper) {
    let selectRecord = event.target.id;
    let landlord = component.get("v.landlordDetails");
    let selectedrec = component.get("v.selectedjointlandlord");
    let selectedrecId = component.get("v.selectedjointlandlordID");
    for (let i = 0; i < landlord.length; i++) {
      if (landlord[i].Id == selectRecord) {
        if (!selectedrecId.includes(selectRecord)) {
          selectedrec.push(landlord[i]);
          selectedrecId.push(selectRecord);
        }
      }
    }
    component.set("v.landlordDetails", "");
    component.set("v.selectedjointlandlordID", selectedrecId);
    component.set("v.selectedjointlandlord", selectedrec);
  },
  doCreate: function (component, event, helper) {
    let flag = true;
    let flag2 = false;
    let allValid = component
      .find("Newid")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.get("v.validity").valid;
      }, true);
    var objChild = component.find("compB");
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
      flag2 = false;
    } else {
      flag2 = true;
    }

    let selectedPrimarylandlord = component.get("v.selectedPrimarylandlord");
    if (
      component.get("v.Usersdetails").User_Type__c == "Agent" &&
      !selectedPrimarylandlord.length > 0
    ) {
      alert("Please add Primary landlord");
      flag = false;
    }

    if (allValid && flag && flag2) {
      var action = component.get("c.addNewProperty");
        
      action.setParams({
        property: component.get("v.Propobj"),
        usertype: component.get("v.Usersdetails"),
        primaryLandord: component.get("v.selectedPrimarylandlord"),
        jointlandlord: component.get("v.selectedjointlandlord")
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
          console.log('state-->>'+state);
          console.log('Error-->>'+JSON.stringify(response.getError()));
        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "Property has been created successfully."
          });
          toastEvent.fire();
          component.set("v.selectedProperty", response.getReturnValue());
          var cmpEvent = component.getEvent("EI_depositEvent");
          var rec=  component.get("v.selectedPrimarylandlord");
            let primaryLandlordid=null;
        	if(rec !='' )
            {
              primaryLandlordid =rec[0].Id;  
            }
          cmpEvent.setParams({ Property: response.getReturnValue(),
                              primaryLandlord:primaryLandlordid
                             });
          cmpEvent.fire();
        } else if (state === "ERROR") {
          alert(
            "Oops!! Something unexpected happen. Please Contact support team"
          );
        }
      });

      $A.enqueueAction(action);
    }
  },

  parentPress: function (component, event, helper) {
    var objChild = component.find("compB");
    component.set("v.Propobj.Country__c", objChild.get("v.Country"));
    component.set("v.Propobj.Postal_Code__c", objChild.get("v.PostCode"));
    component.set("v.Propobj.City__c", objChild.get("v.Town"));
    component.set("v.Propobj.County__c", objChild.get("v.County"));
    component.set('v.Propobj.Local_Authority_Area__c',objChild.get('v.localAuthorityArea'));  
    //  var StreetAddress = objChild.get('v.AddressLine1') + ' \n '+ objChild.get('v.Street');
    component.set("v.Propobj.Street__c", objChild.get("v.AddressLine1"));
    //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
  },
  clickYes: function (component, event, helper) {
    component.set("v.addLandlord", true);
  },
  clickNo: function (component, event, helper) {
    component.set("v.addLandlord", false);
    component.set("v.addLandlord", false);
    let arr = [];
    component.set("v.selectedjointlandlordID", arr);
    component.set("v.selectedjointlandlord", arr);
  },
  addLandlord: function (component, event, helper) {
    var modalBody;
    $A.createComponent(
      "c:EI_addLandlordToProperty",
      {},
      function (content, status) {
        if (status === "SUCCESS") {
          modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "Landlord",
            body: modalBody,
            showCloseButton: true,
            cssClass: "mymodal",
            closeCallback: function () {}
          });
        }
      }
    );
  },

  searchKeyChange: function (component, event, helper) {
    component.set("v.PrimarylandlordDetails", "");
    let searchField = component.find("searchField").get("v.value");
    let action = component.get("c.getlandlord");
    let selectedrec = component.get("v.selectedjointlandlord");
    action.setParams({
      searchField: searchField
    });
    action.setCallback(this, function (a) {
      var state = a.getState();

      if (state == "SUCCESS") {
        component.set("v.landlordDetails", a.getReturnValue());
        var result = a.getReturnValue();
        if (a.getReturnValue() != null) {
          component.set("v.Continuebtnflag", false);
        } else {
          component.set("v.Continuebtnflag", true);
        }
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  searchKeyChange1: function (component, event, helper) {
    component.set("v.landlordDetails", "");
    let searchField = component.find("searchField1").get("v.value");
    let action = component.get("c.getlandlord");
    action.setParams({
      searchField: searchField
    });
    action.setCallback(this, function (a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        component.set("v.PrimarylandlordDetails", a.getReturnValue());
        var result = a.getReturnValue();
       
        if (a.getReturnValue() != null) {
          component.set("v.Continuebtnflag", false);
        } else {
          component.set("v.Continuebtnflag", true);
        }
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  removeJoint: function (component, event, helper) {
    let RecId = event.getSource().get("v.value");
    let selectedrecrm = component.get("v.selectedjointlandlord");
    let selectedrecId = component.get("v.selectedjointlandlordID");
    for (let i = 0; i < selectedrecrm.length; i++) {
      if (selectedrecrm[i].Id == RecId) {
          selectedrecrm.splice(i, 1);
          let index = selectedrecId.indexOf(RecId);
          selectedrecId.splice(index, 1);
          //selectedrecId.pop(RecId);
      }
    }
    component.set("v.selectedjointlandlord", selectedrecrm);
    component.set("v.selectedjointlandlordID", selectedrecId);
  },
  onblurbtn: function (component, event, helper) {
    component.set("v.landlordDetails", "");
    component.set("v.PrimarylandlordDetails", "");
  }
});