({
  doInit: function(component, event, helper) {
      
      // get Error Message
       helper.getError(component, event, helper);      
     
      // Get Country codes Picklist Values
      helper.fetchPhoneCodePicklist(component); 
     
      helper.getSalutationPicklist(component, event,helper);
      helper.initHelper(component, event,helper);
    
      
      setTimeout(function(){ 
           helper.contactdetails(component,event,helper);   
       
      helper.fetchbankdetails(component, event,helper);
                           
                           }, 500);
  
    
       
     
          //  $A.get('e.force:refreshView').fire(); 
  },
     accountClick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#account-detail").offset().top - 30 },
      1000
     );
     },
    paymentClick: function(component, event, helper) {
      $("html, body").animate(
      { scrollTop: $("#payment-details").offset().top - 30 },
      1000
    );
     },
     pIClick: function(component, event, helper) {
      $("html, body").animate(
      { scrollTop: $("#prescribed-info").offset().top - 30 },
      1000
    );
     },
	additionalClick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#additional-user").offset().top - 30 },
      1000
    );
     },
	accountTypeClick: function(component, event, helper) {
      $("html, body").animate(
      { scrollTop: $("#account-type").offset().top - 30 },
      1000
    );
     },
	closeClick: function(component, event, helper) {
      $("html, body").animate(
      { scrollTop: $("#close-account").offset().top - 30 },
      1000
    );
     },
    corresPondenceClick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#Correspondence-email").offset().top - 30 },
      1000
    );
    },
    hideClick: function(component, event, helper) {
         var hlink= document.getElementById("left_nav-sf-presonal-tab");
         if ($(hlink).siblings().hasClass("open")) {
      $(".org-detail-list").slideUp();
      $(hlink).siblings().removeClass("open");
    }
    },
    addClick: function(component, event, helper) {
        var hlink= document.getElementById("left_nav-sf-organisation-tab");
         $(".org-detail-list").slideToggle();
    $(hlink).toggleClass("open");
      
    },
    closePopup: function(component, event, helper) {
		 component.set("v.passwordSuccessMsg", false);
          component.set("v.passwordErrorMsg", false);
    },
    closeEditAdd: function(component, event, helper) {
        component.set("v.editAddress",false);
    },
    editAdd: function(component, event, helper) {
        component.set("v.editAddress",true);
    },
  changepassword: function(component, event, helper) {
    var action = component.get("c.changeuserpassword");

    action.setCallback(this, function(response) {
      var state = response.getState();
      console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("result :" + JSON.stringify(result));
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success",
          type: "success",
          message: "Password Change email sent successfully.",
          duration: " 5000",
          key: "info_alt",
          mode: "dismissible"
        });
        toastEvent.fire();
        //     component.set("v.toggle", true);
        //     helper.initHelper(component, event);
        //     $A.get('e.force:refreshView').fire();
      } else if (state === "ERROR") {
        var errors = response.getError();
        console.log(`${errors}`);
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
  },

  closeModal: function(component, event, helper) {
    var cmpTarget = component.find("editDialog");
    var cmpBack = component.find("overlay");
    $A.util.removeClass(cmpBack, "slds-backdrop--open");
    $A.util.removeClass(cmpTarget, "slds-fade-in-open");
    component.set("v.openmodel", false);
      let currentURL = window.location.origin;
      let redirectURL = $A.get("$Label.c.Lightning_CommunityLogout_URL")+"secur/logout.jsp?retUrl="+$A.get("$Label.c.Lightning_CommunityLogout_URL")+"CommunitiesLanding";
      window.location.replace(redirectURL);
  },

  parentPress: function(component, event, helper) {
    var objChild = component.find("compB");
    //    alert("Method Called from Child " );
    component.set("v.con.MailingCountry", objChild.get("v.Country"));
    component.set("v.con.MailingPostalCode", objChild.get("v.PostCode"));
    component.set("v.con.MailingCity", objChild.get("v.Town"));
    component.set("v.con.MailingState", objChild.get("v.County"));
    var StreetAddress =
      objChild.get("v.AddressLine1") + " \n " + objChild.get("v.Street");
    component.set("v.con.MailingStreet", StreetAddress);
 //  component.set("v.Street", StreetAddress);
      // alert("Method Called from Child " + objChild.get('v.AddressLine1'));
  },

  hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
    switch (button_Name) {
       case "passSuccessMessage":
       	 	component.set("v.passwordSuccessMsg", false);
       break;
       case "passErrorMessage":
        	component.set("v.passwordErrorMsg", false);
       break;
       case "SuccessMessage":
        component.set("v.successMsg", false);
        break;
       case "ErrorMessage":
        component.set("v.errorMsg", false);
        break;
      case "title":
        component.set("v.titleError", false);
        break;
      case "firstName":
        component.set("v.firstNameError", false);
        break;
      case "surName":
        component.set("v.SurNameError", false);
        break;
      case "emailOfUser":
        component.set("v.EmailError", false);
        break;
      case "mobileNumber":
        component.set("v.mobileError", false);
        break;
      case "landlineNumber":
        component.set("v.landlineError", false);
        break;
      case "marketingPreference":
        component.set("v.marketingError", false);
        break;
      case "newsLetter":
        component.set("v.newsLetterError", false);
        break;
      case "generalEmail":
        component.set("v.grnlEmailError", false);
        break;
      case "disputeEmail":
        component.set("v.disputeEmailError", false);
        break;
      case "financeEmail":
        component.set("v.financeEmailError", false);
        break;
      case "extraEmailSuccessMessage":
        component.set("v.extraEmailSuccessMessage", false);
        break;
      case "extraEmailErrorMessage":
        component.set("v.extraEmailErrorMessage", false);
        break;
      case "accountNameError":
        component.set("v.accountNameError", false);
        break;
      case "companyNameError":
        component.set("v.companyNameError", false);
        break;
      case "tradingNameError":
        component.set("v.tradingNameError", false);
        break;
      case "companyRegistationNumberError":
        component.set("v.companyRegistationNumberError", false);
        break;
      case "telephoneNumberError":
        component.set("v.telephoneNumberError", false);
        break;
      case "Phonelength":
        component.set("v.PhonelengthError", false);
      	break;
      case "phoneNotValid":
        component.set("v.MessagePhone", false);
        break;
      case "homePhoneNotValid":
        component.set("v.MessageHomePhone", false);
        break;
      case "addressError":
        component.set("v.addressError", false);
        break;
        case "bankOfAmericaSortCode":
          component.set("v.bankOfAmericaSortCode", false);
          break;
        case "nameOnAccountSpecialCharError":
            component.set("v.nameOnAccountSpecialCharError", false);
            break;
      case "prescribedError":
        component.set("v.prescribedError", false);
        break;
      case "grnlEmailPatternError":
        component.set("v.grnlEmailPatternError", false);
        break;
      case "disputeEmailPatternError":
        component.set("v.disputeEmailPatternError", false);
        break;
      case "financeEmailPatternError":
        component.set("v.financeEmailPatternError", false);
        break;
      case "prescribedError":
        component.set("v.prescribedError", false);
        break;
      case "prescribedLengthError":
        component.set("v.prescribedLengthError", false);
        break;
      case "prescribedSuccessMessage":
        component.set("v.prescribedSuccessMessage", false);
        break;
      case "prescribedErrorMessage":
        component.set("v.prescribedErrorMessage", false);
        break;

      case "nameOnAccountBlankError":
        component.set("v.nameOnAccountBlankError", false);
        break;
      case "accountNumberBlankError":
        component.set("v.accountNumberBlankError", false);
        break;
      case "sortCodeBlankError":
        component.set("v.sortCodeBlankError", false);
        break;
      case "invalidSortCodeError":
        component.set("v.invalidSortCodeError", false);
        break;
      case "invalidAccountNumberError":
        component.set("v.invalidAccountNumberError", false);
        break;
      case "bankSuccessMessage":
        component.set("v.bankSuccessMessage", false);
        break;
      case "bankErrorMessage":
        component.set("v.bankErrorMessage", false);
        break;
      case "usernameError":
        component.set("v.usernameErrorMessage", false);
        break;
       case "prescribedReferError":
        component.set("v.prescribedReferError", false);
        break;   
      case "prescribedReferLengthError":
        component.set("v.prescribedReferLengthError", false);
        break;
       case "prescribedReferErrorMessage":
        component.set("v.prescribedReferErrorMessage", false);
        break; 
       case "prescribedReferSuccessMessage":
        component.set("v.prescribedReferSuccessMessage", false);
        break;         
    }
  },

    saveOrganizationDetails: function(component, event, helper) {
        //var orgAdd = component.get("v.orgAdd");
        //console.log('orgAdd',JSON.stringify(orgAdd));
        var isValidAccName = true;
        var isValidRegCompName = true;
        var isValidTradingName = true;
        var isValidCompRegNum = true;
        var isValidTelpNum = true;
        var isValidAddress = true;
        
        var orgAcc = component.get("v.orgAcc");
        
        if (
            orgAcc.accName == undefined ||
            orgAcc.accName == null ||
            orgAcc.accName == ""
        ) {
            component.set("v.accountNameError", true);
            isValidAccName = false;
        } else {
            component.set("v.accountNameError", false);
        }
        
        if (
            orgAcc.regCompName == undefined ||
            orgAcc.regCompName == null ||
            orgAcc.regCompName == ""
        ) {
            component.set("v.companyNameError", true);
            isValidRegCompName = false;
        } else {
            component.set("v.companyNameError", false);
        }
        
        if (
            orgAcc.tradName == undefined ||
            orgAcc.tradName == null ||
            orgAcc.tradName == ""
        ) {
            component.set("v.tradingNameError", true);
            isValidTradingName = false;
        } else {
            component.set("v.tradingNameError", false);
        }
        
        if (
            orgAcc.regCompNo == undefined ||
            orgAcc.regCompNo == null ||
            orgAcc.regCompNo == ""
        ) {
            component.set("v.companyRegistationNumberError", true);
            isValidCompRegNum = false;
        } else {
            component.set("v.companyRegistationNumberError", false);
        }
        
        if (orgAcc.phn == undefined || orgAcc.phn == null || orgAcc.phn == "") {
            component.set("v.telephoneNumberError", true);
            isValidTelpNum = false;
        } else {
            component.set("v.telephoneNumberError", false);
        }
        var objChild = component.find("compB");
        console.log('objChild '+objChild);
        if (objChild != undefined){
            
            
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
                console.log(objChild);
                component.set("v.addressError",true);  
                isValidAddress = false;
            }
            
            /* if (orgAcc.add == undefined || orgAcc.add == null || orgAcc.add == "") {
      component.set("v.addressError", true);
   //   isValidAddress = false;
    } */else {
        component.set("v.addressError", false);
    }
      }
      console.log(isValidAccName);
      console.log(isValidRegCompName);
      console.log(isValidTradingName);
      console.log(isValidCompRegNum);
      console.log(isValidTelpNum);
      console.log(isValidAddress);
      if(isValidAccName && isValidRegCompName && isValidTradingName && isValidCompRegNum && isValidTelpNum && isValidAddress)
      {
          console.log('257');
          helper.updateOrganizationDetails(component);
      }
      var personEnabled = component.get("v.con.Person_Enabled__c");
      console.log('personEnabled '+personEnabled);
      if(personEnabled){
          
          helper.updateOrganizationDetails(component);
      }
      
  },

  handleClick: function(component, event) {
      //debugger;
    //  alert(newpass);
    var isValid = true;
    var toastEvent = $A.get("e.force:showToast");
    var firstName = component.find("firstName").get("v.value");
    var lastName = component.find("lastName").get("v.value");
    var emailcheck = component.find("txtEmail").get("v.value");
    var PhoneCode = document.getElementById("selectContactPhoneCode").value;
    var phonecheck = component.find("phoneid").get("v.value");
    let HomePhone = component.find("HomePhone").get("v.value");
    //    alert('emailcheck '+emailcheck);
    var market = document.getElementById("gridAgreement");
    var news = document.getElementById("gridSubscription");
    var contactSalutation = document.getElementById("selectedId").value;
    //component.get("v.con.Salutation");
    console.log("contactSalutation" + contactSalutation);
    console.log("market" + market.checked);
    console.log("news" + news.checked);

    //  alert('@@ '+market.checked)
    //

      var letters = /^[0-9]+$/;
      if (phonecheck != undefined || phonecheck != "" || phonecheck != null 
          || HomePhone != undefined || HomePhone != "" || HomePhone != null) 
      {console.log("419isValid "+HomePhone);
          if(phonecheck.match(letters) == null ){
				console.log("425isValid "+HomePhone);              
              component.set("v.MessagePhone",true);
              isValid = false;
          }else{console.log("425isValid else"); 
              component.set("v.MessagePhone",false);
          }
      }else{
          console.log("432isValid "+phonecheck);
          component.set("v.MessagePhone",false);
      }
     //  let landline = HomePhone.replace(/ +/g, "");
     // console.log(landline+" isValid433 "+isValid +' && '+landline.match(letters));
     
      if (HomePhone != undefined || HomePhone != null) {
           let landline = HomePhone.replace(/ +/g, "");
          if(landline.match(letters) == null){
              component.set("v.MessageHomePhone",true);
              isValid = false;
          }else{
              component.set("v.MessageHomePhone",false);
          }
      }else{
          component.set("v.MessageHomePhone",false);
      }
      
      if (
          contactSalutation == undefined ||
          contactSalutation == "" ||
          contactSalutation == null ||
          contactSalutation == "-- Select Title --"
      ) {
          component.set("v.titleError", true);
          
          isValid = false;
      }
      else{
          component.set("v.titleError", false);
      }
      if (firstName == undefined || firstName == "" || firstName == null) {
          component.set("v.firstNameError", true);
          isValid = false;
      }
      else{
          component.set("v.firstNameError", false);
      }
      if (lastName == undefined || lastName == "" || lastName == null) {
          component.set("v.SurNameError", true);
          isValid = false;
      }
      else{
          component.set("v.SurNameError", false);
      }
      if (emailcheck == undefined || emailcheck == "" || emailcheck == null) {
          component.set("v.EmailError", true);
          isValid = false;
      }
      else{
          component.set("v.EmailError", false);
      }
      console.log("PhoneCode : " + PhoneCode + " phonecheck : " + phonecheck);
      if (phonecheck == undefined || phonecheck == "" || phonecheck == null) {
          component.set("v.mobileError", true);
          isValid = false;
      }
      else if (PhoneCode == "+44" && (phonecheck.length != 11 || !phonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
      }else{
          component.set("v.mobileError", false);
          component.set("v.PhonelengthError",false);   
      }
      if (HomePhone == undefined || HomePhone == "" || HomePhone == null) {
          component.set("v.landlineError", true);
          isValid = false;
      }
      else{
          component.set("v.landlineError", false);
        
       
      }
      if (market.checked == false) {
        //  component.set("v.marketingError", true);
        //  isValid = false;
      }
      else{
          component.set("v.marketingError", false);
      }
      if (news.checked == false) {
        //  component.set("v.newsLetterError", true);
        //  isValid = false;
      }
	else{
          component.set("v.newsLetterError", false);
      }
         console.log("isValid "+isValid);
    if (isValid) {
      var con = component.get("v.con");
      console.log("++++++con+++" + JSON.stringify(con));
      //  alert(con.Property_Name__c);
      var action = component.get("c.contactInformationUpdate");
      action.setParams({
          con: con,
          market: market.checked,
          news: news.checked,
          contactSalutation: contactSalutation,
          contactPhoneCode:PhoneCode
      });
      console.log("12345 contactInformationUpdate 12345");
      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log(`state=> ${state}`);
        if (state === "SUCCESS") {
          //component.set("v.fieldnotEdit", true);
          var result = response.getReturnValue();
          if(result=='Invalid')
          {
              component.set("v.usernameErrorMessage", true);
             // alert('This username has been already taken.');
          }
            else{
          console.log("result :" + JSON.stringify(result));
          component.set("v.usernameErrorMessage", false);
          component.set("v.successMsg", true);
              component.set("v.errorMsg", false);
                var appEvent = $A.get("e.c:EI_Agentpercentagebarupdate"); 
                appEvent.fire();
          //  var UpdateProgressBar = component.getEvent("UpdateProgressBar");
           //   console.log("UpdateProgressBar :" + UpdateProgressBar);
         //   UpdateProgressBar.fire();
			
                
          //       $A.get('e.force:refreshView').fire();
              //setTimeout(function(){    location.reload();}, 500);
            }
    
        } else if (state === "ERROR") {
       
  			  component.set("v.errorMsg", true);
              component.set("v.successMsg", false);
        }
      });
      $A.enqueueAction(action);
      //console.log("12345 contactInformationUpdate 12345");
    }
      else{
           document.body.scrollTop = 0;
          document.documentElement.scrollTop = 0;
      }
  },
  updatePassword: function(component, event) {
    var isValid = true;
    var CurrentPassword = document.getElementById("sf-currentPassword").value;
    var newPassword = document.getElementById("sf-NewPassword").value;
    var verifyPassword = document.getElementById("sf-VerifyPassword").value;
    var action = component.get("c.changeuserpassword");
    action.setParams({
      newPassword: newPassword,
      verifyNewPassword: verifyPassword,
      oldPassword: CurrentPassword
    });
    action.setCallback(this, function(response) {
      var state = response.getReturnValue();
      //  alert(state);
      if (state === "Success") {
        component.set("v.fieldnotEdit", true);
        var result = response.getReturnValue();
        console.log("result :" + JSON.stringify(result));
	component.set("v.passwordSuccessMsg", true);
        document.getElementById("sf-currentPassword").value = "";
        document.getElementById("sf-NewPassword").value = "";
        document.getElementById("sf-VerifyPassword").value = "";
        console.log("Modal Close");
        //   $('#modalwindow').modal('hide');
        $A.get("e.force:refreshView").fire();
      } else {
        document.getElementById("sf-currentPassword").value = "";
        document.getElementById("sf-NewPassword").value = "";
        document.getElementById("sf-VerifyPassword").value = "";
        component.set("v.ErrorMessage", state);
     
	component.set("v.passwordErrorMsg", true);
        $A.get("e.force:refreshView").fire();
      }
    });
    $A.enqueueAction(action);
  },

  saveCorrespondence: function(component, event) {
    var isValidgeneralEmail = true;
    var isValidcorresEmail = true;
    var isValidfinanceEmail = true;
    var generalEmail = component.find("GeneralEmail").get("v.value");
    var corresEmail = component.find("CorrespondenceEmail").get("v.value");
    var financeEmail = component.find("FinanceEmail").get("v.value");

    console.log(generalEmail);
    console.log(corresEmail);
    console.log(financeEmail);

    var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if (
      generalEmail == "" ||
      generalEmail == undefined ||
      generalEmail == null
    ) {
      component.set("v.grnlEmailError", true);
      component.set("v.extraEmailSuccessMessage", false);
      isValidgeneralEmail = false;
    } else if (
      generalEmail != "" ||
      generalEmail != undefined ||
      generalEmail != null
    ) {
      if (!generalEmail.match(regExpEmailformat)) {
        component.set("v.extraEmailSuccessMessage", false);
        isValidgeneralEmail = false;
        component.set("v.grnlEmailPatternError", true);
      } else {
        isValidgeneralEmail = true;
        component.set("v.grnlEmailPatternError", false);
        component.set("v.grnlEmailError", false);
        component.set("v.extraEmailErrorMessage", true);
      }
    }
    if (corresEmail == "" || corresEmail == undefined || corresEmail == null) {
      component.set("v.disputeEmailError", true);
      component.set("v.extraEmailSuccessMessage", false);
      isValidcorresEmail = false;
    } else if (
      corresEmail != "" ||
      corresEmail != undefined ||
      corresEmail != null
    ) {
      if (!corresEmail.match(regExpEmailformat)) {
        component.set("v.extraEmailSuccessMessage", false);
        isValidcorresEmail = false;
        component.set("v.disputeEmailPatternError", true);
      } else {
        isValidcorresEmail = true;
        component.set("v.disputeEmailPatternError", false);
        component.set("v.disputeEmailError", false);
        component.set("v.extraEmailErrorMessage", true);
      }
    }

    if (
      financeEmail == "" ||
      financeEmail == undefined ||
      financeEmail == null
    ) {
      component.set("v.financeEmailError", true);
      component.set("v.extraEmailSuccessMessage", false);
      isValidfinanceEmail = false;
    } else if (
      financeEmail != "" ||
      financeEmail != undefined ||
      financeEmail != null
    ) {
      if (!financeEmail.match(regExpEmailformat)) {
        component.set("v.extraEmailSuccessMessage", false);
        isValidfinanceEmail = false;
        component.set("v.financeEmailPatternError", true);
      } else {
        isValidfinanceEmail = true;
        component.set("v.financeEmailPatternError", false);
        component.set("v.financeEmailError", false);
        component.set("v.extraEmailErrorMessage", true);
      }
    }

    if (isValidgeneralEmail && isValidcorresEmail && isValidfinanceEmail) {
      var acc = component.get("v.acc");
      console.log(acc);
      console.log(JSON.stringify(acc));
      var action = component.get("c.correspondEmailUpdate");
      action.setParams({
        acc: acc
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log(`state=> ${state}`);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result :" + JSON.stringify(result));
          if (result == "Updated") {
            component.set("v.extraEmailSuccessMessage", true);
            component.set("v.extraEmailErrorMessage", false);
            helper.hideCorrespondenceMessages(component, state);
          } else if (result == "NotAllowed") {
            component.set("v.extraEmailErrorMessage", true);
            component.set("v.extraEmailSuccessMessage", false);
            helper.hideCorrespondenceMessages(component, state);
          } else {
            component.set("v.extraEmailErrorMessage", true);
            component.set("v.extraEmailSuccessMessage", false);
            helper.hideCorrespondenceMessages(component, state);
          }
        } else if (state === "ERROR") {
          component.set("v.extraEmailErrorMessage", true);
          var errors = action.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              alert(errors[0].message);
            }
          }
        }
      });
      $A.enqueueAction(action);
    }
  },

  enableEdit: function(component, event, helper) {
    component.set("v.fieldnotEdit", false);
    component.set("v.toggle", false);
  },

  cancelEdit: function(component, event, helper) {
    component.set("v.fieldnotEdit", true);
    component.set("v.toggle", true);
    // $A.get('e.force:refreshView').fire();
  },

  updateBankDetails: function(component, event, helper) {
    helper.updateBankDetails(component, event);
  },

  changeAccountType: function(component, event, helper) {
    //component.set("v.openmodel", true);
    helper.changeAccountTypeuser(component, event);
  },

  updatePrescribed: function(component, event, helper) {
    var prescribedInfo = component.get(
      "v.con.Prescribed_Information_clauses__c"
    );
      
     var prescribedRefer = component.get(
      "v.con.Prescribed_Clause_Reference__c"
    );    
    if (
      prescribedInfo == undefined ||
      prescribedInfo == null ||
      prescribedInfo == ""
    ) {
      component.set("v.prescribedError", true);
      component.set("v.prescribedLengthError", false);
      component.set("v.prescribedSuccessMessage", false);
      component.set("v.prescribedErrorMessage", false);
    } else {
      if (
        prescribedInfo != undefined ||
        prescribedInfo != null ||
        prescribedInfo != ""
      ) {
        if (prescribedInfo.length > 255) {
          component.set("v.prescribedError", false);
          component.set("v.prescribedLengthError", true);
          component.set("v.prescribedSuccessMessage", false);
          component.set("v.prescribedErrorMessage", false);
        } else {
          component.set("v.prescribedError", false);
          helper.callUpdatePrescribed(component);
        }
      }
    }
      
      if (
      prescribedRefer == undefined ||
      prescribedRefer == null ||
      prescribedRefer == ""
    ) {
      component.set("v.prescribedReferError", true);
      component.set("v.prescribedReferLengthError", false);
      component.set("v.prescribedReferSuccessMessage", false);
      component.set("v.prescribedReferErrorMessage", false);
    }
      
      else {
      if (
        prescribedRefer != undefined ||
        prescribedRefer != null ||
        prescribedRefer != ""
      ) {
        if (prescribedRefer.length > 255) {
          component.set("v.prescribedReferError", false);
          component.set("v.prescribedReferLengthError", true);
          component.set("v.prescribedReferSuccessMessage", false);
          component.set("v.prescribedReferErrorMessage", false);
        } else {
          component.set("v.prescribedReferError", false);
          helper.callUpdatePrescribedRefer(component);
        }
      }
    } 
  },
    
    parentPress: function (component, event, helper) {
        var objChild = component.find("compB");
        component.set("v.orgAdd.Country__c", objChild.get("v.Country"));
        component.set("v.orgAdd.Postcode__c", objChild.get("v.PostCode"));
        component.set("v.orgAdd.Town_City__c", objChild.get("v.Town"));
        component.set("v.orgAdd.County__c", objChild.get("v.County"));
        var StreetAddress;
        if (objChild.get("v.AddressLine1") != "undefined ") {
            StreetAddress =
                objChild.get("v.AddressLine1") + "\n " + objChild.get("v.Street");
        } else {
            StreetAddress = objChild.get("v.Street");
        }
        component.set("v.orgAdd.Address__c", StreetAddress);
    /*    
    var objChild = component.find("compB");
    component.set("v.orgAdd.Country__c", "");
    component.set("v.orgAdd.Postcode__c", "");
    component.set("v.orgAdd.Town_City__c", "");
    component.set("v.orgAdd.County__c", "");
    component.set("v.orgAdd.Address__c", "");
   // component.set("v.valueChanged", true);
    component.set("v.orgAdd.Country__c", objChild.get("v.Country"));
    component.set("v.orgAdd.Postcode__c", objChild.get("v.PostCode"));
    component.set("v.orgAdd.Town_City__c", objChild.get("v.Town"));
    component.set("v.orgAdd.County__c", objChild.get("v.County"));
    component.set("v.orgAdd.Address__c", objChild.get("v.AddressLine1")); */
  },
    NumSplCharsCheck: function(component, event, helper){
        var keyCode = (event.which) ? event.which : event.keyCode;
        //alert('>>>>keycode'+keyCode);
        if( keyCode!= 32 &&((keyCode < 65 || keyCode > 90) && (keyCode < 97 || keyCode > 123))
          	&& (keyCode != 46 && keyCode > 31 && (keyCode < 48 || keyCode > 57))) {
            
            if (event.preventDefault) {
                event.preventDefault();
                
            } else {
                event.returnValue = false;
                
            } 
            
        }
       
    },
   
  /*  isRefreshed: function(component, event, helper) {
    },*/

});