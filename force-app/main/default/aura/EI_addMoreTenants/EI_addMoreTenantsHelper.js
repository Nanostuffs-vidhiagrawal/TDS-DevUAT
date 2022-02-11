({
  checkEmailDuplicacy: function (component, email) {
    var IsOrg = component.get("v.IsOrg");
        let firstname = "" ;
        let surname = "" ;
        if(!IsOrg){
            firstname = component.find("personfirstname").get("v.value");
            surname = component.find("personlastname").get("v.value");
        }
       
        let depositId = component.get("v.depositId"); 
    var action = component.get("c.checkDuplicateEmails");
      action.setParams({
          email: email,
          type: "onlyemail",
          phone: "",
          firstname: firstname,
          surname: surname,
          depositId:depositId  
      });
    action.setCallback(this, function (response) {
      var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            console.log('Helper '+result);
            // var inputCmp = component.find("emailfield");
            if (result == "Duplicate email" || result == "Duplicate Name") {
                console.log(`line 19`);
                component.set("v.IsEmailValid", false);
                component.set("v.aleadyReg", true);
                console.log('Line 20');
                //  inputCmp.setCustomValidity("This email Id is already registered");
                console.log('Line 22');
            } else {
                component.set("v.IsEmailValid", true);
                component.set("v.aleadyReg", false);
                //  inputCmp.setCustomValidity("");
            }
            //inputCmp.reportValidity();
        } else if (state === "ERROR") {
            var errors = response.getError();
            console.log("Unknown error");
        }
    });
    $A.enqueueAction(action);
  },

  checkPhoneDuplicacy: function (component, phone) {
      
      let firstname = component.find("personfirstname").get("v.value");
      let surname = component.find("personlastname").get("v.value");
      let depositId = component.get("v.depositId");
    // alert(phone);
    var action = component.get("c.checkDuplicateEmails");
      action.setParams({
          email: "",
          type: "onlyphone",
          phone: phone,
          firstname: firstname,
          surname: surname,
          depositId:depositId  
      });
    action.setCallback(this, function (response) {
      var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            console.log(result);
            // var inputCmp = component.find("phonefield");
            if (result === "Duplicate Phone") {
                component.set("v.IsPhoneValid", false);
                // inputCmp.setCustomValidity("This Phone is already registered");
            } else {
                component.set("v.IsPhoneValid", true);
                // inputCmp.setCustomValidity("");
            }
            //  inputCmp.reportValidity();
        } else if (state === "ERROR") {
            var errors = response.getError();
            console.log("Unknown error");
        }
    });
    $A.enqueueAction(action);
  },

  /* @What Make Server call to Add tenant to the additional tenant
   * @Who : Ashish Singh
   */
  addAdditionalTenant: function (component, acc, IsOrg) {
    // alert(`${IsOrg}`);
      console.log("Helper contact", JSON.stringify(acc));
      let depositId = component.get("v.depositId");
      console.log(" depositId", depositId);
      let tenanttitle;
      let tenantPhoneCode;
      if(IsOrg){
          tenantPhoneCode =document.getElementById("selectCompPhoneCode").value;
      }else{
          tenanttitle =document.getElementById("persontitle").value;
          tenantPhoneCode =document.getElementById("selectPrsnPhoneCode").value;
      }
      console.log("tenantPhoneCode", tenantPhoneCode);
      
      let action = component.get("c.addAdditionalTenant");
      action.setParams({
          acc: acc,
          tenanttitle:tenanttitle,
          tenantPhoneCode:tenantPhoneCode,
          depositId: depositId,
          IsOrg: IsOrg
      });
      console.log("Line 68");
      action.setCallback(this, function (response) {
          let state = response.getState();
          console.log("state", state);
          if (state === "SUCCESS") {
              let result = response.getReturnValue();
              console.log(result);
              $('#maincon', window.parent.document).get(0).scrollIntoView();
              component.set("v.succeessmessage", true);
              setTimeout(function(){ 
                  
                  $('#createtenant').modal('hide');
                  var ys =  document.getElementById("orgBtn");
                  var no =   document.getElementById("personBtn");
                  
                  $A.util.removeClass(ys, "clickButton");
                  $A.util.removeClass(no, "clickButton");
                  $A.get("e.force:refreshView").fire();
                  
              }, 500);
              /*   var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "Tenant has been added to the Deposit.",
          type: "success"
        });
        toastEvent.fire();
        component.find("overlayLib").notifyClose();*/
          
      } else if (state === "ERROR") {
          let errors = response.getError();
          console.log("errors", errors);
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
    
    getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                  //console.log("line-->9  " +errorList[i].MasterLabel );
                   //console.log("line-->9  " +errorList[i].Error_Message__c );
                  
                   if(errorList[i].MasterLabel === 'Title'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.titleErrorNew",userErr);
                  }  
                  
                     else if(errorList[i].MasterLabel === 'First Name'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.firstNameErrorNew",userErr);
                  }            
                  
                  else if(errorList[i].MasterLabel === 'Surname'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.surNameErrorNew",userErr);
                  } 
                  else if(errorList[i].MasterLabel === 'Tenant Exist'){
                      //console.log("line-->198  " +errorList[i].Error_Message__c );
                      userErr = errorList[i].Error_Message__c;                       
                  component.set("v.TenantExistErrorNew",userErr);
                  } 
                  else if(errorList[i].MasterLabel === 'Phone Number'){
                      //console.log("line-->198  " +errorList[i].Error_Message__c );
                      userErr = errorList[i].Error_Message__c;                       
                  component.set("v.PhoneNoErrorNew",userErr);
                  }            
                  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
});