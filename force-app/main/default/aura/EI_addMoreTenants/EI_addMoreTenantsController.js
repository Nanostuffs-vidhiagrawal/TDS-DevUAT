({
    doInit: function (component, event, helper) {
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component);
         helper.getError(component, event, helper);
    },
    
    doEnableOrg: function (component, event, helper) {
        var ys =  document.getElementById("orgBtn");
        var no =   document.getElementById("personBtn");
        console.log('ys '+ys+' ' +no);
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        /* component.find("personBtn").set("v.variant", "brand-outline");
    component.find("orgBtn").set("v.variant", "brand");*/
        component.set("v.IsOrg", true);
        component.set("v.acc.FirstName", "");
        component.set("v.acc.LastName", "");
        component.set("v.acc.PersonEmail", "");
        component.set("v.acc.phoneCode2", "+44");
        component.set("v.acc.Phone", "");
        component.set("v.acc.Title", "");
        component.set("v.IsPhoneValid", true);
        component.set("v.IsEmailValid", true);
    },
    
    handleCancel: function (component, event, helper) {
                      var ys =  document.getElementById("orgBtn");
   		 var no =   document.getElementById("personBtn");

 		  $A.util.removeClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        
    },
    
    doPerson: function (component, event, helper) {
        var ys =  document.getElementById("orgBtn");
        var no =   document.getElementById("personBtn");
        console.log('doperson '+ys + no);
        $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");
        
        /*  component.find("personBtn").set("v.variant", "brand");
    component.find("orgBtn").set("v.variant", "brand-outline");*/
        component.set("v.IsOrg", false);
        component.set("v.acc.Name", "");
        component.set("v.acc.PersonEmail", "");
        component.set("v.acc.phoneCode2", "+44");
        component.set("v.acc.Phone", "");
        component.set("v.IsPhoneValid", true);
        component.set("v.IsEmailValid", true);
  },

  handleEmailBlur: function (component, event, helper) {

      //component.set("v.IsEmailValid", false);
      //component.set("v.aleadyReg", false);
      let email = component.get("v.acc.PersonEmail");
      helper.checkEmailDuplicacy(component, email);
    // let IsEmailValid = component.get("v.IsEmailValid");
    // console.log("IsEmailValid:", IsEmailValid);
  },
  handlePhoneBlur: function (component, event, helper) {
    let phone = component.get("v.acc.Phone");
    helper.checkPhoneDuplicacy(component, phone);
    // let IsPhoneValid = component.get("v.IsPhoneValid");
    // console.log("IsPhoneValid:", IsPhoneValid);
  },
    
   hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {                
             case "mobileErrorAlert":
                component.set("v.aleadyRegMobile", false);
                break;  
            case "emailErrorAlert":
                component.set("v.aleadyReg", false);
                break;    
            case "emailInvalid":
                component.set("v.IsEmailValid", true);
                break;
            case "yesNoMsg":
                component.set("v.yesNoError", false);
                break;
            case "companyName":
                component.set("v.companyNameError", false);
                break;
            case "companyPhonelength":
                component.set("v.companyPhonelengthError",false);    
                break;
            case "companyPhone":
                component.set("v.companyPhoneError", false);
                break;
            case "companyemail":
                component.set("v.companyemailError", false);
                break;
            case "emailphone":
                component.set("v.emailphoneError", false);
                break;
            case "title":
                component.set("v.titleError", false);
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
            case "invalidFormatEmail":
                component.set("v.invalidEmailFormatError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError",false);    
                break;
            case "telephoneNumber":
                component.set("v.telephoneNumError", false);
                break;
            case "phoneoremail":
                component.set("v.phoneoremailError", false);
                break;
            case "validAddress":
                component.set("v.isAddressValidError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            /*case "updatesuccessmsg":
                component.set("v.updatesucceessmessage", false);
                break;
           case "success":
                component.set("v.succeessmessage1", false);
                break;*/
        }
    },

  doSubmit2: function (component, event, helper) {
    var IsOrg = component.get("v.IsOrg");
    let acc = component.get("v.acc");
    console.log('acc', JSON.stringify(acc));  
    if((acc.PersonEmail==undefined || acc.PersonEmail == null || acc.PersonEmail == "") && 
       (acc.Phone==undefined || acc.Phone==null  || acc.Phone== "")){
        alert('Please provide either Phone or Email address');
    }else{   
    let IsPhoneValid = component.get("v.IsPhoneValid");
    let IsEmailValid = component.get("v.IsEmailValid");
    // console.log("IsPhoneValid:", IsPhoneValid);
    // console.log("IsEmailValid:", IsEmailValid);

    // console.log("acc", JSON.stringify(acc));
    if (IsOrg) {
        var auraEmailValid = component.find("emailfield").reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var auraPhonefield = component.find("phonefield").reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
       
        var compValid = false;
   var compfield = component.find("compfield").get("v.value");
         console.log("59");
        if(compfield == undefined || compfield == null || compfield == '') {
            compValid = false;
        }else{
            compValid = true;
        }  
        
      console.log("auraEmailValid:", auraEmailValid);
      console.log("auraPhonefield:", auraPhonefield);  
      console.log("compValid:", compValid);  
      console.log("IsEmailValid:", IsEmailValid);
      console.log("IsPhoneValid:", IsPhoneValid);
      if (compValid && auraEmailValid && auraPhonefield && IsEmailValid && IsPhoneValid) {
        alert("All form entries look valid. Ready to submit!");
        // alert(`${IsOrg}`);
        helper.addAdditionalTenant(component, acc, IsOrg);
      } else {
        console.log("Line 44");
        alert("Please fill form with unique email and phone");
      }
    } else {
      var personfield = component.find("personfield"); 
      console.log('personfield',personfield);  
      var emailfield = component.find("emailfield");
       console.log('emailfield',emailfield);   
      var phonefield = component.find("phonefield");
       console.log('phonefield',phonefield);   
      personfield.push(emailfield);
      personfield.push(phonefield);
       console.log('personfield',personfield);   
      var allValid = personfield.reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);

      if (allValid && IsEmailValid || IsPhoneValid) {
        alert("All form entries look valid. Ready to submit!");
        helper.addAdditionalTenant(component, acc, IsOrg);
      } else {
        alert("Please update the invalid form entries and try again.");
      }
    }}
  },
    
 doSubmit: function (component, event, helper) {
    var IsOrg = component.get("v.IsOrg");
    let acc = component.get("v.acc");  
    var compValid = true;
    var allValid =true;
	var validEmail=true;
	var validPhone =true;
	
     console.log('acc', JSON.stringify(acc));
     component.set("v.companyNameError", false); 
     component.set("v.companyemailError", false); 
     component.set("v.companyPhonelengthError", false); 
     component.set("v.companyPhoneError", false);
     component.set("v.titleError",false); 
     component.set("v.firstNameError",false);
     component.set("v.surNameError",false); 
     component.set("v.emailError",false);
     component.set("v.PhonelengthError",false);
     component.set("v.telephoneNumError",false);
     component.set("v.phoneoremailError", false);
     component.set("v.succeessmessage", false);
     console.log('acc', JSON.stringify(acc));

  /*  if((acc.PersonEmail==undefined || acc.PersonEmail == null || acc.PersonEmail == "") && 
       (acc.Phone==undefined || acc.Phone==null  || acc.Phone== "")){
        alert('Please provide either Phone or Email address');
    }else{   
    let IsPhoneValid = component.get("v.IsPhoneValid");
    let IsEmailValid = component.get("v.IsEmailValid");
    // console.log("IsPhoneValid:", IsPhoneValid);
    // console.log("IsEmailValid:", IsEmailValid);

    // console.log("acc", JSON.stringify(acc));
    }*/
     if(IsOrg == undefined){
          component.set("v.yesNoError", true); 
          $('#maincon', window.parent.document).get(0).scrollIntoView();
     }
     
    else if (IsOrg) {
        component.set("v.yesNoError", false); 
        var companynamecheck = component.find("compname").get("v.value");
        var companyemailcheck= component.find("compemail").get("v.value");
        var CompPhoneCode = document.getElementById("selectCompPhoneCode").value;
        var companyphonecheck= component.find("compphone").get("v.value");
         if(companynamecheck == undefined || companynamecheck == null || companynamecheck == '') {
            component.set("v.companyNameError", true);
            compValid = false;
        }else{
         component.set("v.companyNameError", false);  

        }  
        
        if(companyemailcheck == undefined || companyemailcheck == null || companyemailcheck == '') {
            component.set("v.companyemailError", true);
            compValid = false;
        }else{
         component.set("v.companyemailError", false);  

        }  
        
        if(companyphonecheck == undefined || companyphonecheck == null || companyphonecheck == '') {
            component.set("v.companyPhoneError", true);
            compValid = false;
        }else if (CompPhoneCode == "+44" && (companyphonecheck.length != 11 || !companyphonecheck.startsWith("07"))) {
          component.set("v.companyPhonelengthError",true);    
          isValid = false;
        }else{
            component.set("v.companyPhoneError", false);
            component.set("v.companyPhonelengthError",false);   
        }
        
        
        
        
       /* var auraEmailValid = component.find("emailfield").reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var auraPhonefield = component.find("phonefield").reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
       
        var compValid = false;
   var compfield = component.find("compfield").get("v.value");
         console.log("59");
        if(compfield == undefined || compfield == null || compfield == '') {
            compValid = false;
        }else{
            compValid = true;
        }  */
        let IsPhoneValid = component.get("v.IsPhoneValid");
        let IsEmailValid = component.get("v.IsEmailValid");
        
        if(companyemailcheck === ""){
          validEmail = true;
            console.log('value 319 '+validEmail);   
        }
		else if(companyemailcheck != undefined || companyemailcheck != null || companyemailcheck != ""){
			if(IsEmailValid == false){
				 validEmail = false;
                  console.log('value 322 '+IsEmailValid);
                 component.set("v.aleadyReg",true);
                   console.log('value 324 '+component.get("v.aleadyReg"));
             }else{
				 validEmail = true;
                 component.set("v.aleadyReg",false);
             }
		}
		
        
       console.log(IsPhoneValid+' value 332 '+companyphonecheck); 
        if( companyphonecheck === ''){
             validPhone = true; 
            console.log('value 335 '+validPhone);
        }
		else if( companyphonecheck != '' || companyphonecheck != undefined || companyphonecheck != null ){
			if(IsPhoneValid == false){
				 validPhone = false;
                component.set("v.aleadyRegMobile", true);
                  console.log(' value 336 '+validPhone);
             }else{
				validPhone = true;
                 component.set("v.aleadyRegMobile", false);
               console.log(' value 339 '+validPhone);
             }
		} 
        
      if (compValid && IsPhoneValid && IsEmailValid) {
        // alert(`${IsOrg}`);
        helper.addAdditionalTenant(component, acc, IsOrg);
      } else {
              $('#maincon', window.parent.document).get(0).scrollIntoView();
      //  component.set("v.emailphoneError", true);
      }
    } else {
        component.set("v.yesNoError", false); 
        var titleCheck = document.getElementById("persontitle").value;
        var firstnamecheck = component.find("personfirstname").get("v.value");
        var surnameCheck = component.find("personlastname").get("v.value");
        var emailcheck = component.find("personemail").get("v.value");
        var PhoneCode = document.getElementById("selectPrsnPhoneCode").value;
        var telephoneCheck = component.find("personphone").get("v.value");
        
        if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {  
            component.set("v.titleError",true);    
            allValid = false;
        }
        else{
          component.set("v.titleError",false);   
        }
      
        if (firstnamecheck == undefined || firstnamecheck == "" || firstnamecheck == null) {  
            component.set("v.firstNameError",true);    
            allValid = false;
        }
        else{
           component.set("v.firstNameError",false); 
        }
        if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
            component.set("v.surNameError",true);    
            allValid = false;
        }
        else{
           component.set("v.surNameError",false);   
        }
        /*if(telephoneCheck != undefined || telephoneCheck != null  || telephoneCheck != ""){
          if (PhoneCode == "+44" && (telephoneCheck.length != 11 || !telephoneCheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
          }else{
              component.set("v.PhonelengthError",false);   
          }
        }*/
        
        let IsPhoneValid=component.get("v.IsPhoneValid");
        let IsEmailValid=component.get("v.IsEmailValid");
       
        if((emailcheck==undefined || emailcheck == null || emailcheck == "") &&
           (telephoneCheck==undefined || telephoneCheck==null  || telephoneCheck== "")){
            component.set("v.phoneoremailError", true);
            allValid = false;
        }
        else{
            component.set("v.phoneoremailError", false);
            if(telephoneCheck != undefined && telephoneCheck != null  && telephoneCheck != ""){
                if (PhoneCode == "+44" && (telephoneCheck.length != 11 || !telephoneCheck.startsWith("07"))) {
                    component.set("v.PhonelengthError",true);    
                    isValid = false;
                }else{
                    component.set("v.PhonelengthError",false);   
                }
            }
        }
		console.log(IsEmailValid+' value 312 '+emailcheck);
        if(emailcheck === ""){
          validEmail = true;
            console.log('value 319 '+validEmail);   
        }
		else if(emailcheck != undefined || emailcheck != null || emailcheck != ""){
			if(IsEmailValid == false){
				 validEmail = false;
                  console.log('value 322 '+IsEmailValid);
                 component.set("v.aleadyReg",true);
                   console.log('value 324 '+component.get("v.aleadyReg"));
             }else{
				 validEmail = true;
                 component.set("v.aleadyReg",false);
             }
		}
		
        
       console.log(IsPhoneValid+' value 332 '+telephoneCheck); 
        if( telephoneCheck === ''){
             validPhone = true; 
            console.log('value 335 '+validPhone);
        }
		else if( telephoneCheck != '' || telephoneCheck != undefined || telephoneCheck != null ){
			if(IsPhoneValid == false){
				 validPhone = false;
                component.set("v.aleadyRegMobile", true);
                  console.log(' value 336 '+validPhone);
             }else{
				validPhone = true;
                 component.set("v.aleadyRegMobile", false);
               console.log(' value 339 '+validPhone);
             }
		} 

       /* if(emailcheck==undefined || emailcheck == null || emailcheck == "") 
           {
           IsEmailValid = false;
              component.set("v.emailphoneError", true);  
           }
        else{ 
            console.log('value 318');
            IsEmailValid=component.get("v.IsEmailValid");
              console.log('value 320 '+IsEmailValid);
             if(IsEmailValid == false){
                  console.log('value 322 '+IsEmailValid);
                 component.set("v.aleadyRegEmail",true);
                   console.log('value 324 '+component.get("v.aleadyRegEmail"));
             }else{
                 component.set("v.aleadyRegEmail",false);
             }
            }
        if(telephoneCheck==undefined || telephoneCheck==null  || telephoneCheck== "") 
           {
           IsPhoneValid = false;
           }else{component.get("v.IsPhoneValid");}
        
        console.log("IsPhoneValid:", IsPhoneValid);
        console.log("IsEmailValid:", IsEmailValid);
        console.log('out valid '+allValid+IsEmailValid+IsPhoneValid);*/
		 console.log('outvalid '+allValid+validEmail+validPhone);
      if (allValid && (validEmail && validPhone) ) {
           console.log('valid '+allValid+validEmail+validPhone);
       helper.addAdditionalTenant(component, acc, IsOrg);
      } else {
          console.log('not valid');
        $('#maincon', window.parent.document).get(0).scrollIntoView();
        // component.set("v.emailphoneError", true);
         //  component.set("v.aleadyRegEmail",true);
    
      }
    }
  },
    
  resetstate:function(component, event, helper){
      component.set("v.companyNameError", false); 
      component.set("v.companyemailError", false); 
      component.set("v.companyPhoneError", false);
      component.set("v.emailphoneError", false);
      component.set("v.titleError",false); 
      component.set("v.firstNameError",false);
      component.set("v.surNameError",false); 
      component.set("v.emailError",false);
      component.set("v.telephoneNumError",false);
      component.set("v.phoneoremailError", false);
      component.set("v.succeessmessage", false);
      component.set("v.IsPhoneValid", true);
      component.set("v.IsEmailValid", true);
      document.getElementById("landlordForm").reset();
               
    
}
    
  
    
    
});