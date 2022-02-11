({
  waiting: function(component, event, helper) {
    component.set("v.HideSpinner", true);
  },
    
  doneWaiting: function(component, event, helper) {
    component.set("v.HideSpinner", false);
    component.set("v.PageSpinner", true);
  },
    
  loginPage: function(component, event, helper) {
    var urlRedirect = $A.get("$Label.c.Lightning_Component_URL") + "login";
    window.location.replace(urlRedirect);
    return false;
  },
    
  doInit: function(component, event, helper) {
    var cmpDiv = component.find("fieldIdSelect");
    $A.util.removeClass(cmpDiv, "slds-select_container");
    $A.util.addClass(cmpDiv, "form-control");
  },

  userTitle: function(component, event, helper) {
    var sel = document.getElementById("SelectTitle");
    var selectedValue = sel.options[sel.selectedIndex].text;
    component.set("v.Title", selectedValue);
    component.set("v.flagTitle", false);
  },

  userTypeHadler: function(component, event, helper) {
    //var selectedValue = event.getSource().get("v.value");
    var sel = document.getElementById("selectIam");
    var selectedValue = sel.options[sel.selectedIndex].text;
    var orguser = component.get("v.OrgUser");
    var finalvalue;
    let Childcomp = component.find("compB");
    if (selectedValue == "Tenant") {
      component.set("v.userType", selectedValue);
      component.set("v.flagRegAsOrg", false);
      component.set("v.tenantmobcheck", true);
      component.set("v.teleNumber", "Mobile Number");
      component.set("v.teleNumberPlaceholder", "Enter Mobile Number");
      // component.set("v.regexPattern", "^[07]{2}[0-9]{9}");
      //component.set("v.mismatchPatternErr", "Please Enter Valid Mobile Number");

      Childcomp.mandatoryMethod(false);
    } else {
      if (selectedValue == "joint Landlord") {
        finalvalue = true;
      } else {
        finalvalue = false;
        if (selectedValue == "Agent" && orguser) {
          component.set("v.HeadOfficeUser", true);
        } else {
          component.set("v.HeadOfficeUser", false);
        }
      }
      component.set("v.userType", selectedValue);
      component.set("v.isModalOpenJointLandlord", finalvalue);
      component.set("v.aggrement", finalvalue);
      component.set("v.flagUserType", false);
      component.set("v.flagRegAsOrg", true);
      component.set("v.teleNumber", "Telephone number");
      component.set("v.teleNumberPlaceholder", "Enter telephone number");
      //component.set("v.regexPattern", "");
      // component.set("v.mismatchPatternErr", "");
      Childcomp.mandatoryMethod(true);
    }
  },
    
  OrgUsers: function(component, event, helper) {
    //var selectedValue = event.getSource().get("v.checked");
    var selectedValue = document.getElementById("gridCheck1");
    var userType = component.get("v.userType");
    if (selectedValue.checked) {
      component.set("v.OrgUser", true);
      if (userType == "Agent") {
        component.set("v.HeadOfficeUser", true);
      } else {
        component.set("v.HeadOfficeUser", false);
      }
    } else {
      component.set("v.HeadOfficeUser", false);
      component.set("v.OrgUser", false);
    }
  },
  
	hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "selectIam":
                component.set("v.selectIamerrorMessage", false);
                break;
            case "title":
                component.set("v.titleErrorMessage",false);
                break;
			case "firstName":
                component.set("v.firstNameError", false);
                break;
            case "surName":
                component.set("v.surNameError", false);
                break;
            case "emailOfUser":
                component.set("v.emailError", false);
                break;
			case "mobileNumber":
                component.set("v.mobileError", false);
                break;
			case "address":
                component.set("v.addressError", false);
                break;
			case "phoneNotValid":
                component.set("v.MessagePhone", false);
                break;
			case "companyName":
                component.set("v.companyNameError", false);
                break;
			case "companyEmail":
                component.set("v.companyEmailError", false);
                break;
			case "companyPhone":
                component.set("v.companyPhoneError", false);
                break;
			case "DRMEmail":
                component.set("v.DRMEmailError", false);
                break;
			case "FinanceEmail":
                component.set("v.FinanceEmailError", false);
                break;
			case "LettingAgentNumber":
                component.set("v.LettingAgentNumberError", false);
                break;
			case "companyEmailMessage":
                component.set("v.companyEmailMessageError", false);
                break;
			case "DrmEmailMessage":
                component.set("v.companyDrmEmailMessageError", false);
                break;
			case "FinanceEmailMessage":
                component.set("v.companyFinanceEmailMessageError", false);
                break;
			case "emailMessage":
                component.set("v.emailMessageError", false);
                break;
        }
    },
	
	clickCreate: function(component, event, helper) {
		let userTyp = component.get("v.userType");
		let salutation = component.get("v.Title");
		var inputCmp = component.find("UserTypeID");
		var firstName = component.get("v.firstName");
		var lastName = component.get("v.lastName");
		var phone = component.get("v.Phone");
		var email = component.get("v.Email");
        var street = component.get("v.Street");
        var city = component.get("v.Town");
        var postcode = component.get("v.PostCode");
        var country = component.get("v.Country");
        var county = component.get("v.County");
		var address = component.get("v.Address");
		var companyName= component.get("v.companyName");
		var companyPhone= component.get("v.companyPhone");
		var companyAddress= component.get("v.companyAddress");
		var companyEmail=component.get("v.companyEmail");
		var companyDrmEmail= component.get("v.companyDrmEmail");
		var companyletAgntId= component.get("v.letAgntId");
		var companyFinanceEmail= component.get("v.companyFinanceEmail");
		var orguser	= component.get("v.OrgUser");
		var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		let validateextrafields = true;
		var isValid = true;
		var title = component.get("v.Title"); 
        console.log('streetcheck' + street);
        console.log('citycheck' + city);
        console.log('Postcodecheck' + postcode);
        console.log('Countrycheck' + country);
        console.log('countycheck' + street);
		if (userTyp == undefined || userTyp == "" || userTyp == null || userTyp=='-- Please select ---') {  
			component.set("v.selectIamerrorMessage",true);    
			isValid = false;
		}
		else{
			component.set("v.selectIamerrorMessage",false);
		}
		if (salutation == undefined || salutation == "" || salutation == null || salutation=='-- Please select ---') {  
			component.set("v.titleErrorMessage",true);    
			isValid = false;
		}
		else{
			component.set("v.titleErrorMessage",false);
		}
		if (firstName == undefined || firstName == "" || firstName == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
		else{
			component.set("v.firstNameError",false);
		}
        if (lastName == undefined || lastName == "" || lastName == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
		else{
			component.set("v.surNameError",false);
		}
        if (email == undefined || email == "" || email == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
		else{
			component.set("v.emailError",false);
		}		
		if (phone == undefined || phone == "" || phone == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }
		else{
			component.set("v.mobileError",false);
		}
        var street = component.get("v.Street");
        var city = component.get("v.Town");
        var postcode = component.get("v.PostCode");
        var country = component.get("v.Country");
        var county = component.get("v.County");
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
                component.set("v.addressError",true);  
              isValid = false;
                  }
		  else{
			component.set("v.addressError",false);
		      }   
                    
		/*if (street == undefined || street == "" || street == null||
           city == undefined || city == "" || city == null||
           postcode == undefined || postcode == "" || postcode == null||
           country == undefined || country == "" || country == null||
           county == undefined || county == "" || county == null) {
            component.set("v.addressError",true);    
            isValid = false;
        }
		else{
			component.set("v.addressError",false);
		}*/console.log('+++++++email++++++++++'+email);
		if(email != undefined && email != "" && email != null){
			if(!email.match(regExpEmailformat)){
				component.set("v.emailMessageError",true);
				isValid = false;
			}
		}
		if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Agent" && orguser) {
			if (companyName == undefined || companyName == "" || companyName == null) {
				component.set("v.companyNameError",true);    
				isValid = false;
			}
			else{
				component.set("v.companyNameError",false);
			}
			if (companyEmail == undefined || companyEmail == "" || companyEmail == null) {
				component.set("v.companyEmailError",true);    
				isValid = false;
			}
			else{
				component.set("v.companyEmailError",false);
			}
			if (companyPhone == undefined || companyPhone == "" || companyPhone == null) {
				component.set("v.companyPhoneError",true);    
				isValid = false;
			}
			else{
				component.set("v.companyPhoneError",false);
			}
			if (companyDrmEmail == undefined || companyDrmEmail == "" || companyDrmEmail == null) {
				component.set("v.DRMEmailError",true);    
				isValid = false;
			}
			else{
				component.set("v.DRMEmailError",false);
			}
			if (companyFinanceEmail == undefined || companyFinanceEmail == "" || companyFinanceEmail == null) {
				component.set("v.FinanceEmailError",true);    
				isValid = false;
			}
			else{
				component.set("v.FinanceEmailError",false);
			}
			if (companyletAgntId == undefined || companyletAgntId == "" || companyletAgntId == null) {
				component.set("v.LettingAgentNumberError",true);    
				isValid = false;
			}
			else{
				component.set("v.LettingAgentNumberError",false);
			}
			if(companyEmail != undefined && companyEmail != "" && companyEmail != null && !companyEmail.match(regExpEmailformat)){
				component.set("v.companyEmailMessageError",true);
				isValid = false;
			}
			if(companyDrmEmail != undefined && companyDrmEmail != "" && companyDrmEmail != null && !companyDrmEmail.match(regExpEmailformat)){
				component.set("v.companyDrmEmailMessageError",true);
				isValid = false;
			}
			if(companyFinanceEmail != undefined && companyFinanceEmail != "" && companyFinanceEmail != null && !companyFinanceEmail.match(regExpEmailformat)){
				component.set("v.companyFinanceEmailMessageError",true);
				isValid = false;
			}
		}
		if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Landlord" && orguser) {
			if (companyName == undefined || companyName == "" || companyName == null) {
				component.set("v.companyNameError",true);    
				isValid = false;
			}
			else{
				component.set("v.companyNameError",false);
			}
			if (companyPhone == undefined || companyPhone == "" || companyPhone == null) {
				component.set("v.companyPhoneError",true);    
				isValid = false;
			}
			else{
				component.set("v.companyPhoneError",false);
			}
		}
		if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Tenant") {
			if (phone != null || typeof phone != "undefined") {
				if (phone[0] != "0" && phone[1] != "7") {
					component.set("v.MessagePhone", true);
					isValid = false;
				}
			}
		}
		if(isValid){
          //  alert('to create');
			/*component.set("v.selectIamerrorMessage", false);
			component.set("v.titleErrorMessage",false);
			component.set("v.firstNameError", false);
            component.set("v.surNameError", false);
            component.set("v.emailError", false);
            component.set("v.mobileError", false);
            component.set("v.addressError", false);*/
			var allValid = component
			.find("fieldId")
			.reduce(function(validSoFar, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validSoFar && inputCmp.get("v.validity").valid;
			}, true);
			if (userTyp == "Tenant") {
				let validatePhone = true;
				let phone = component.get("v.Phone");
				if (phone != null || typeof phone != "undefined") {
					if (phone[0] != "0" && phone[1] != "7") {
						validatePhone = false;
					}
				}
				if (!validatePhone) {
					component.set("v.MessagePhone", true);
				} else {
					component.set("v.MessagePhone", false);
				}
				if (allValid && validateextrafields && validatePhone) {
					$A.enqueueAction(component.get("c.submitDetails"));
				}
			} /*else {
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
				//alert("Please fill Address");
				$("#createUser").modal("hide");
				component.set("v.flagAddress", true);
				} else {
					if (component.get("v.OrgUser") == true) {
						if (userTyp == "Landlord") {
                            alert('line-->372');
							var CompallValid = component
							.find("CompfieldId2")
							.reduce(function(validSoFar, inputCmp) {
							inputCmp.showHelpMessageIfInvalid();
							return validSoFar && inputCmp.get("v.validity").valid;
							}, true);
							if (allValid && CompallValid) {
								component.set("v.isModalOpen", true);
							}
						} else {
							var CompallValid = component
							.find("CompfieldId")
							.reduce(function(validSoFar, inputCmp) {
							inputCmp.showHelpMessageIfInvalid();
							return validSoFar && inputCmp.get("v.validity").valid;
							}, true);
							if (allValid && CompallValid) {
								component.set("v.isModalOpen", true);
							}
						}
					} else {
						if (allValid && validateextrafields) {
                            alert('line-->394');
							component.set("v.isModalOpen", true);
						}
					}
				}
			}*/

                else{
               component.set("v.isModalOpen", true); 
                }
		}
		
		/*if (userTyp == "" || userTyp == "-- Please select ---") {
			  component.set("v.flagUserType", true);
			  validateextrafields = false;
		}
    if (salutation == "" || salutation == "-- Please Select --") {
      component.set("v.flagTitle", true);
      validateextrafields = false;
    }*/

    
  },
  closeModel: function(component, event, helper) {
    document.getElementById("confirm").style.display = "none";
    // component.set("v.isModalOpen", false);
    // component.set("v.isModalOpenJointLandlord", false);
  },

  multiplebranches: function(component, event, helper) {
    var selectedValue = document.getElementById("gridCheck2");
    component.set("v.HeadoficeUsercheckbox", selectedValue.checked);
  },

  submitDetails: function(component, event, helper) {      
     component.set("v.isModalOpen", false);  
    var action = component.get("c.selfRegister");
    action.setParams({
      salutation: component.get("v.Title"),
      firstname: component.get("v.firstName"),
      lastname: component.get("v.lastName"),
      email: component.get("v.Email"),
      phone: component.get("v.Phone"),
      address: component.get("v.Address"),

      OrgUSer: component.get("v.OrgUser"),
      HoUser: component.get("v.HeadoficeUsercheckbox"),
      userType: component.get("v.userType"),

      companyName: component.get("v.companyName"),
      companyPhone: component.get("v.companyPhone"),
      companyAddress: component.get("v.companyAddress"),

      companyEmail: component.get("v.companyEmail"),
      companyDrmEmail: component.get("v.companyDrmEmail"),
      companyFinanceEmail: component.get("v.companyFinanceEmail"),

      LAid: component.get("v.letAgntId"),
      street: component.get("v.Street"),
      city: component.get("v.Town"),
      postcode: component.get("v.PostCode"),
      country: component.get("v.Country"),
      county: component.get("v.County")
    });
    action.setCallback(this, function(a) {
      var state = a.getState();
      var errors = a.getError();
      if (state == "SUCCESS") {
        if (a.getReturnValue() == "User Create successfully") {
          var toastEvent = $A.get("e.force:showToast");
        /*  toastEvent.setParams({
            title: "Success",
            message: "User Create successfully",
            duration: " 5000",
            key: "info_alt",
            type: "success",
            mode: "pester"
          });
          toastEvent.fire();*/
        } else {
          if (a.getReturnValue() == "User already have an account") {
            component.find("notifLib").showNotice({
              variant: "Warning",
              header: "Oops!",
              message:
                "It looks like you already have an account with SafeDeposits Scotland. We have sent you an email that will allow you to access your account. Alternatively, please click ‘Login’ and enter your username and password.",
              closeCallback: function() {}
            });
          } else if (a.getReturnValue() == "Email is already registered") {
            component.find("notifLib").showNotice({
              variant: "Warning",
              header: "Oops!",
              message: "This email is already registered in the system.",
              closeCallback: function() {}
            });
          } else {
            let errormessage = JSON.stringify(a.getReturnValue());
              console.log('line 492' + errormessage);
            if (errormessage.includes("<br>")) {
              errormessage = errormessage.replaceAll("<br>", " ");
            }
            component.find("notifLib").showNotice({
              variant: "Warning",
              header: "Oops!",
              message:
                "We encountered a problem. For help,Please contact your administrator.",
              closeCallback: function() {}
            });
          }
        }
      } else {
        let errormessage = JSON.stringify(a.getReturnValue());
        if (errormessage.includes("<br>")) {
          errormessage = errormessage.replaceAll("<br>", " ");
          component.find("notifLib").showNotice({
            variant: "Warning",
            header: "Oops!",
            message: errormessage,
            closeCallback: function() {}
          });
        }
      }
    });
    $A.enqueueAction(action);
  },
  downloadDocument: function(component, event, helper) {
    window.location = "/apex/TermsAndConditionPdf";
  },
  
  parentPress: function(component, event, helper) {
    helper.PassVariable(component, event, helper);
    //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
  },
  
  ValidateEmail: function(component, event, helper) {
    var soucerec = event.getSource();
    var emailFieldValue = component.get("v.Email");
    var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if (!$A.util.isEmpty(emailFieldValue)) {
      if (emailFieldValue.match(regExpEmailformat)) {
        component.set("v.vlidateEmail", true);
        soucerec.setCustomValidity("");
      } else {
        soucerec.setCustomValidity("Please enter a valid email");
        component.set("v.vlidateEmail", false);
      }
    }
  },
  ValidatePhone: function(component, event, helper) {
    var soucerec = event.getSource();
    var Phonenmbr = event.getSource().get("v.value");
    var regExpPhoneformat = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
    if (!$A.util.isEmpty(Phonenmbr)) {
      if (Phonenmbr.match(regExpPhoneformat)) {
        component.set("v.vlidateEmail", true);
        soucerec.setCustomValidity("");
      } else {
        soucerec.setCustomValidity("Please enter a valid Phone");
        component.set("v.vlidateEmail", false);
      }
    }
  },
  loadpdf: function(component, event, helper) {
    try {
      var pdfData = component.get("v.pdfData");
      var pdfjsframe = component.find("pdfFrame");
      if (typeof pdfData != "undefined") {
        pdfjsframe.getElement().contentWindow.postMessage(pdfData, "*");
      }
    } catch (e) {
      alert("Error: " + e.message);
    }
  }
  /*
    testpdf : function(component, event, helper) {
       // $(".html-content").append('ddd');
        var HTML_Width = $(".html-content").width();
    var HTML_Height = $(".html-content").height();
    var top_left_margin = 15;
    var PDF_Width = HTML_Width + (top_left_margin * 2);
    var PDF_Height = (PDF_Width * 1.5) + (top_left_margin * 2);
    var canvas_image_width = HTML_Width;
    var canvas_image_height = HTML_Height;

    var totalPDFPages = Math.ceil(HTML_Height / PDF_Height) - 1;
      //abcdef();

    html2canvas($(".html-content")[0], {

    ignoreElements: function (node) {
        return node.nodeName === 'IFRAME';
    }
}).then(function (canvas) {
        var imgData = canvas.toDataURL("image/jpeg", 1.0);
        var pdf = new jsPDF('p', 'pt', [PDF_Width, PDF_Height]);
        pdf.addImage(imgData, 'JPG', top_left_margin, top_left_margin, canvas_image_width, canvas_image_height);
        for (var i = 1; i <= totalPDFPages; i++) {
            pdf.addPage(PDF_Width, PDF_Height);
            pdf.addImage(imgData, 'JPG', top_left_margin, -(PDF_Height*i)+(top_left_margin*4),canvas_image_width,canvas_image_height);
        }
        pdf.save("Your_PDF_Name.pdf");
        $(".html-content").hide();

    });
    }
     */
});