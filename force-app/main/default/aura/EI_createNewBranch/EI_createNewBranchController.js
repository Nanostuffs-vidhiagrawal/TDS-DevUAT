({
  doInit: function (component, event, helper) {
      // Get Country codes Picklist Values
      helper.fetchPhoneCodePicklist(component); 
      
    var action = component.get("c.getCountries");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var countryMap = [];
        for (var key in result) {
          countryMap.push({ key: key, value: result[key] });
        }
        component.set("v.countryMap", countryMap);
      }
    });
    var action2 = component.get("c.userEmail");
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
       // component.find("gnrlemail").set("v.value", result);
      //  component.find("dispemail").set("v.value", result);
      //  component.find("finemail").set("v.value", result);
      }
    });
    $A.enqueueAction(action);
    $A.enqueueAction(action2);
  },
    
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
           
           case "generalEmail":
                component.set("v.generalEmailError", false);
                break;
            case "branchname":
                component.set("v.branchNameError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError", false);
                break;
            case "altPhonelength":
                component.set("v.altPhonelengthError", false);
                break;
            case "telephonenumber":
                component.set("v.telephoneNumError", false);
                break;
           
            case "validAddress":
                component.set("v.isAddressValidError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
        }
    },
  
    backtobranches: function (component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "home"
            },
            state: {}
        });    
        
    },
    

  addBranch: function (component, event, helper) {
    var selectedVal = component.get("v.selectedVal");
    var branch = component.get("v.branch");
      var genEMail = component.find("gnrlemail").get("v.value");
     
      var branchcheck = component.find("branch").get("v.value");
      var phoneCode = document.getElementById("selectPhoneCode").value;
      var telephonecheck = component.find("telephone").get("v.value");
      var altPhoneCode = document.getElementById("selectAltPhoneCode").value;
      var alttelephonecheck = component.find("alttelephone").get("v.value");
   
     // var streetCheck = component.find("street").get("v.value");
     // var townCheck = component.find("town").get("v.value");
    //  var countyCheck = component.find("county").get("v.value");
    //  var countryCheck = component.find("country").get("v.value");
    //  var postcodeCheck = component.find("postcode").get("v.value");
    //  console.log('streetCheck ' + streetCheck);
    //   console.log('townCheck ' + streetCheck);
    //   console.log('countyCheck ' + streetCheck);
     //  console.log('countryCheck ' + streetCheck);
     //  console.log('postcodeCheck ' + streetCheck);
     var isValid = true;
  /*  var allValid = component
      .find("mandate")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.get("v.validity").valid;
      }, true);*/
  //  
   
   if (genEMail == undefined || genEMail == "" || genEMail == null ) {  
            component.set("v.generalEmailError",true);    
            isValid = false;
    
        } 
      else{
            component.set("v.generalEmailError",false); 
        }
      if (branchcheck == undefined || branchcheck == "" || branchcheck == null ) {  
            component.set("v.branchNameError",true);    
            isValid = false;
        } 
        else{
            component.set("v.branchNameError",false); 
        }
        
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null ) {  
            component.set("v.telephoneNumError",true);    
            isValid = false;
        }
      	else if (phoneCode == "+44" && (telephonecheck.length != 11 || !telephonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
        }else{
            component.set("v.telephoneNumError", false);
            component.set("v.PhonelengthError",false);   
        }
      
          if (!(alttelephonecheck == undefined || alttelephonecheck == "" || alttelephonecheck == null) ) {  
              if (altPhoneCode == "+44" && (alttelephonecheck.length != 11 || !alttelephonecheck.startsWith("07"))) {
                  component.set("v.altPhonelengthError",true);    
                  isValid = false;
              }else{
                  component.set("v.altPhonelengthError",false);   
              }
          }
          else{
              component.set("v.altPhonelengthError",false);   
          }
        
       
      /*  if (streetCheck == undefined || townCheck == undefined || countyCheck == undefined ||countryCheck == undefined || postcodeCheck ==undefined) {  
            component.set("v.isAddressValidError",true);    
            isValid = false;
        } 
        else{
            component.set("v.isAddressValidError",false); 
        }*/
      
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
                ){
                component.set("v.isAddressValidError",true);  
              isValid = false;
                  }
		  else{
			component.set("v.isAddressValidError",false);
		      }   

      // alert(genEMail);
      if (isValid) {
      var action = component.get("c.createBranch");
      action.setParams({
          branch: branch,
          telephoneCode: phoneCode,
          altphoneCode: altPhoneCode,
          street:component.get("v.Street"),
          Town:component.get("v.Town"),
          county:component.get("v.County"),
          country:component.get("v.Country"),
          postcode:component.get("v.PostCode")

      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          component.set("v.data", result);
          component.set("v.showform", false);
          component.set("v.succeessmessage", true);  

            function callback(cmp, status) {
              if (status === "SUCCESS") {
                  $('#maincon', window.parent.document).get(0).scrollIntoView();
                var EI_branchDatatableRefresh = $A.get(
                  "e.c:EI_branchDatatableRefresh"
                );
                if (EI_branchDatatableRefresh) {
                  EI_branchDatatableRefresh.setParams({
                    selectedVal: selectedVal
                  });
                  EI_branchDatatableRefresh.fire();
                 // component.find("overlayLib").notifyClose();
                }
              } else if (status === "ERROR") {
                //alert("status" + successMsg);
              }
            }
          
        } else if (state === "ERROR") {
          var errors = response.getError();
          
          $('#maincon', window.parent.document).get(0).scrollIntoView();
       
        }
      });
      $A.enqueueAction(action);
      } else{
          $('#maincon', window.parent.document).get(0).scrollIntoView();
      }
  },

 /* parentPress: function (component, event, helper) {
    var objChild = component.find("compB");
    component.set("v.branch.Country__c", "");
    component.set("v.branch.Postcode__c", "");
    component.set("v.branch.Town_City__c", "");
    component.set("v.branch.County__c", "");
    component.set("v.branch.Address__c", "");
    component.set("v.branch.Country__c", objChild.get("v.Country"));
    component.set("v.branch.Postcode__c", objChild.get("v.PostCode"));
    component.set("v.branch.Town_City__c", objChild.get("v.Town"));
    component.set("v.branch.County__c", objChild.get("v.County"));
    component.set("v.branch.Address__c", objChild.get("v.AddressLine1"))
  },*/
    parentPress: function (component, event, helper) {
    helper.PassVariable(component, event, helper);
  }
});