({
    helperCancel: function(component, event, helper) {
        
           console.log('1in cancel;'); 
        document.getElementById("output").style.display= "none";
      //  outpt[0].style.display= "none";
        console.log('2in cancel;'+document.getElementById("mySelect"));  
        if(document.getElementById("mySelect") != null){
             document.getElementById("mySelect").style.display= "none";
        }
      
       console.log('3in cancel;'+document.getElementById("searchBox"));   
       document.getElementById("searchBox").value='';
        
         var ys =  component.find("landlordCompYes");
   		 var no =   component.find("landlordCompNo");
 
 		  $A.util.removeClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
    var objChild = component.find("compB");
    	 objChild.set("v.houseNo",""); 
         objChild.set("v.AddressLine1",""); 
         objChild.set("v.Town",""); 
         objChild.set("v.County",""); 
         objChild.set("v.PostCode",""); 
        objChild.set("v.Country",""); 
        
             component.set("v.succeessmessage", false);
        component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.invalidEmailFormatError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.phonelengthError",false);
        component.set("v.companyPhonelengthError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
        component.set("v.succeessmessage",false);
          component.set("v.yesNoError", false);
        
        // Setting all the fields to null
        component.set("v.companyName","");
        component.set("v.companyPhoneCode€","+44");
        component.set("v.companyPhone","");
        document.getElementById("titleId").value = "";
        component.set("v.firstName","");
        component.set("v.lastName","");
        component.set("v.Email","");
        component.set("v.phoneCode","+44");
        component.set("v.Phone","");
        document.getElementById("regStatusId").value = "";
        component.set("v.LandRegNumber","");
        component.set("v.Address","");
        component.set("v.Street","");
        component.set("v.Town","");
        component.set("v.PostCode","");
        component.set("v.Country","");
        component.set("v.County","");
        
        component.set("v.isRegStatus",false);
//	component.set("v.JointLandlord",false);
          console.log('helper cancel');
        
    },
    PassVariable : function(component, event, helper) {
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
    emailFormatChecker: function (component, email) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(email)) {
           return (email.match(regExpEmailformat)) ? true: false;
        }  
    },
    checkEmailDuplicacy: function (component, email, firstname, surname) {
        //alert('checkEmailDuplicacy ' + email + firstname + surname);
        var action = component.get("c.checkDuplicateRecord");
        action.setParams({
            email: email,
            firstname: firstname, 
            surname: surname,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('line 14 State - '+ state );
                console.log('line 14 result - '+ JSON.stringify(result) );
               
                var duplicateValue = [];
                for ( var key in result ) {
                    duplicateValue.push({val:result[key], key:key});
                }
                var key = duplicateValue[0].key;
                var recValue = duplicateValue[0].val;
                
                console.log('duplicateValue => ' + JSON.stringify(duplicateValue[0]) );
                console.log('duplicateValue key => ' + key );
                console.log('duplicateValue value => ' + recValue );
                
                if (key == "Duplicate Email") {
                   // alert(key == "Duplicate Email");
                    component.set("v.isDuplicateEmail",true);
                    component.set("v.duplicateEmailError",true);
                } else if(key == "Duplicate Name"){
                    // alert(key == "Duplicate Name");
                    component.set("v.isDuplicateEmail",true);
                    component.set("v.duplicateNameError", true);
                    component.set("v.duplicateRecord", recValue);
                }
                else {
                    component.set("v.isDuplicateEmail",false);
					component.set("v.duplicateEmailError",false);
                    component.set("v.duplicateNameError", false);
                }
            } else if (state == "ERROR") {
                var errors = response.getError();
                console.log("Unknown error");
            }
            
        });
        $A.enqueueAction(action);
    },
    
    fetchPhoneCodePicklist : function(component, event, helper){
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phoneCodePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
})