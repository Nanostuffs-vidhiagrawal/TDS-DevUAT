({
    checkDefault: function (component, event, helper) {
         if (key === 32) {
      event.preventDefault();
    }
    },
    OrgUsers: function (component, event, helper) {
        var selectedValue = event.getSource().get("v.checked");
        if (selectedValue) {
            component.set("v.OrgUser", true);
        } else {
            component.set("v.OrgUser", false);
        }
    },
    
    parentPress: function (component, event, helper) {
        helper.PassVariable(component, event, helper);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
    
    /*parentPress: function (component, event, helper) {

        var objChild = component.find("compB");
        component.set("v.Country", objChild.get("v.Country"));
        component.set("v.PostCode", objChild.get("v.PostCode"));
        component.set("v.Town", objChild.get("v.Town"));
        component.set("v.County", objChild.get("v.County"));
        var StreetAddress;
        if (objChild.get("v.AddressLine1") != "undefined ") {
            StreetAddress =
                objChild.get("v.AddressLine1") + "\n " + objChild.get("v.Street");
        } else {
            StreetAddress = objChild.get("v.Street");
        }
        component.set("v.Street", StreetAddress);

        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },*/
    clickCreate: function (component, event, helper) {
        let OrgUser = component.get("v.OrgUser");
        let validinput = false;
        let validateAddress = false;
        let orgvalid = true; 
        var Email = component.get("v.Email");
        var Phone = component.get("v.Phone");
        let allValid = component
        .find("fieldId")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if(OrgUser)
        {
            let orgvalidate = component
            .find("CompfieldId")
            .reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get("v.validity").valid;
            }, true);
            if(!orgvalidate)
            {
                orgvalid = false;
            }
        }
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
            validateAddress = false
        }
        else
        {
            validateAddress = true;
        }
        if(orgvalid && allValid && validateAddress)
        {
            if (Email || Phone)
            {
                validinput = true;  
            }
            else
            {
                alert("Please specify atleast Email or Phone.");
                validinput = false;
            }
        }
        
        let LandRegNumber = component.get("v.LandRegNumber");
        var validatelrn = true;
        if(LandRegNumber != '')
        {
            let lrnArray = component.get("v.LandRegNumber").split(',');
            for(let i =0;i <lrnArray.length ; i++ )
            {
                if(lrnArray[i].length >= 14  && lrnArray[i].length <= 16 )
                {
                    
                    let innervaluearray =lrnArray[i].split('/');
                    if(innervaluearray.length == 3)
                    {
                        if(!(innervaluearray[0].length == 5 || innervaluearray[0].length == 6))
                        {
                            validatelrn = false;
                        }
                        if(innervaluearray[1].length != 3)
                        {
                            validatelrn = false;
                        }
                        if(!(innervaluearray[2].length == 4 || innervaluearray[2].length == 5))
                        {
                            validatelrn = false;
                        }
                    }
                    else
                    {
                        validatelrn = false; 
                    }
                }
                else
                {
                    validatelrn = false;
                }
            }
            if(!validatelrn)
            {
                alert('Please enter the valid landlord regirstration number');
            }
        }
        
        if (validinput && validatelrn) {
            var action = component.get("c.savelandlord");
            action.setParams({
                salutation: component.get("v.Title"),
                firstname: component.get("v.firstName"),
                lastname: component.get("v.lastName"),
                email: component.get("v.Email"),
                phone: component.get("v.Phone"),
                isOrguser: OrgUser,
                companyName: component.get("v.companyName"),
                companyPhone: component.get("v.companyPhone"),
               /* companyAddress: component.get("v.companyAddress"),
                companyEmail: component.get("v.companyEmail"),*/
                
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County"),
                LandRegNumber :LandRegNumber
            });
            action.setCallback(this, function (a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Record has been created successfully."
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
      Submit: function (component, event, helper) {
        helper.SubmitDetails(component, event,helper);
    }
});