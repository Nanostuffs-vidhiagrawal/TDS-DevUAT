({
  PassVariable: function (component, event, helper) {
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
  },
    
          SubmitDetails: function (component, event, helper) {
        var startDate = component.get("v.startDate");
        var rentAmount = component.get("v.rentAmount");
        let OrgUser = component.get("v.OrgUser");
        let validinput = false;
        let validateAddress = false;
        let orgvalid = true; 
        var Email = component.get("v.Email");
        var Phone = component.get("v.Phone");
      //         alert('comp'); 
        //        alert('comp '+OrgUser);
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
             // alert('comp '+orgvalid);
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
        
        if (validinput) {
          //  alert(component.get("v.startDate") +' '+ component.get("v.rentAmount"));
            var companyname = component.get("v.companyName");
            var companyPhone = component.get("v.companyPhone");
            var companyEmail = component.get("v.companyEmail");
            if(typeof component.get("v.companyName") == "undefined"){
                companyname = '';
            }
            if(typeof component.get("v.companyPhone") == "undefined"){
                companyPhone = '';
            }
            if(typeof component.get("v.companyEmail") == "undefined"){
                companyEmail = '';
            }
            
            //-------
            
           var phone = component.get("v.Phone");
           var landregNumber = component.get("v.LandRegNumber");
            if(typeof component.get("v.Phone") == "undefined" || component.get("v.Phone") == ''){
                phone = '';
            }
            if(typeof component.get("v.LandRegNumber") == "undefined" || component.get("v.LandRegNumber") == ''){
                landregNumber = '';
            }

 // alert(companyname +' '+ companyPhone +' '+companyEmail);          
                 const queryString = window.location.search;
                  const urlParams = new URLSearchParams(queryString);
                  const depositId = urlParams.get('id');
            var action = component.get("c.savelandlord");
         
           action.setParams({
               landlordRegNumber : landregNumber,
               startDate : startDate,
               rentAmount : rentAmount,
                DepositId : depositId,
                salutation: component.get("v.Title"),
                firstname: component.get("v.firstName"),
                lastname: component.get("v.lastName"),
                email: component.get("v.Email"),
                phone: phone,
                isOrguser: OrgUser,
                companyName: companyname,
                companyPhone: companyPhone,
                companyEmail: companyEmail,               
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County") 
            });
            action.setCallback(this, function (a) {
                
                 var returnResult = a.getReturnValue();
             //    alert('result '+returnResult);
                var state = a.getState();
                var errors = a.getError();
            //    alert('errors '+errors+' && '+state);
                if (state == "SUCCESS" || errors == '' ) {
                    console.log('SUCCESS');
                     var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    title: "Success",
                    message: "Landlord has been created successfully.",
                    duration: " 500",
                    key: "info_alt",
                    type: "success",
                    mode: "pester"
                  });
                 
                    toastEvent.fire();
                     const Dbase = returnResult.split("=")
                   
                    var retdepositId = Dbase[1];
                       console.log('Deposit return '+retdepositId);
                    
                                         
                                          
                        if(retdepositId != null){
                            component.find("navService").navigate({
                              type: "comm__namedPage",
                              attributes: {
                                pageName: "depositsummarypage"
                              },
                              state: {id: retdepositId}
                            });
                        }
                    
                }
                 else {
                      component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message:
                          "We encountered a problem. For help,Please contact your administrator."+errors,
                        closeCallback: function () {}
                      });
                }
            });
            
            $A.enqueueAction(action);
        }
    }
});