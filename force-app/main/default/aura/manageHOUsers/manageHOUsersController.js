({
  loadUser: function (component, event, helper) {
   helper.fetchUserData(component, event, helper);
      
      // Get Country codes Picklist Values
      helper.fetchPhoneCodePicklist(component); 
  },

  handleRowAction: function (component, event, helper) {
    var action = event.getParam("action");
    var row = event.getParam("row");
    // console.log(row.ContactId);
    let accountId = component.get("v.accId");

    switch (action.name) {
      case "view_user":
        var modalBody;
        $A.createComponent(
          "c:EI_userEditHO",
          {
            userId: row.Id,
            selectedUserId: row.ContactId,
            accountId: accountId
          },
          function (content, status) {
            if (status === "SUCCESS") {
              modalBody = content;
              component.find("overlayLib").showCustomModal({
                header: "User Detail",
                body: modalBody,
                showCloseButton: true,
                cssClass: "mymodal",
                closeCallback: function () {
                  window.location.reload();
                }
              });
            }
          }
        );
        break;
    }
  },

  addNewUser: function (component, event, helper) {
    let accountId = component.get("v.accId");
    var modalBody;
    $A.createComponent(
      "c:userCreateHO",
      {
        accountId: accountId
      },
      function (content, status) {
        if (status === "SUCCESS") {
          modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "User Creation",
            body: modalBody,
            showCloseButton: true,
            cssClass: "mymodal",
            closeCallback: function () {
              console.log("You closed the alert!");
            }
          });
        }
      }
    );
  },
    
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
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
            case "mobileNumber":
                component.set("v.mobileError", false);
                break;
            case "levelOfAccess":
                component.set("v.levelOfAccesserror", false);
                break;
            case "duplicateEmail":
                component.set("v.duplicateemailerror", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            case "successbutton":
                component.set("v.success", false);
                break;
            case "updatesuccessmsg":
                component.set("v.updatesucceessmessage", false);
                break;
           case "success":
                component.set("v.succeessmessage1", false);
                break;
             case "deactivateuser":
                component.set("v.deactiveusersucceessmessage", false);
                break;
              case "reactivateuser":
                component.set("v.reactiveusersucceessmessage", false);
                break;
              case "livedeposit":
                component.set("v.livedepositerror", false);
                break;
        }
    },
    
        // this is realted to createhouser Start //
    
    handleChange: function (component, event, helper) {
    let selectedValues = event.getParam("value").toString();
    // alert(`${typeof selectedValues} Values=> ${selectedValues}`);
    let listofValues = selectedValues.split(",");
    console.log("listofValues:", listofValues);
    // listofValues.forEach(function (listofValues) {
    // console.log("listofValues:", listofValues);
    // });
    component.set("v.selectedValues", listofValues);
  },
  newusercreate: function (component, event, helper) {
   // let accountId = component.get("v.accountId");
      component.set("v.titleError", false);
      component.set("v.firstNameError", false);
      component.set("v.surNameError", false);
      component.set("v.emailError", false);
      component.set("v.mobileError", false);
      component.set("v.success", false);
      document.getElementById("createform").reset();
    var accountId = event.target.id;
    var action2 = component.get("c.getHObranches");
    action2.setParams({
      accountId: accountId
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(response.getReturnValue());

        let items = [];
        for (var key in result) {
          items.push({
            label: result[key],
            value: key
          });
        }
        console.log(items);
        component.set("v.options", items);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("errors[0].message:", errors[0].message);
          }
        }
      }
    });

    var action = component.get("c.getJobRoles");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // console.log(result);
        var permissionmap = [];
        var jobRoleMap = [];
            var plValues = [];
        for (var key in result[2]) {
          jobRoleMap.push({ key: key, value: result[2][key] });
        //  permissionmap.push({ key: key, value: result[3][key] });
        }
          component.set("v.jobRoleMap", jobRoleMap);
        for (var key in result[3]) {
      
          permissionmap.push({ key: key, value: result[3][key] });
             plValues.push({
                        label: key,
                        value: key
                    });
        }
      
            component.set("v.permissionmap", permissionmap);
           component.set("v.permissionList", plValues);
        var salutationMap = [];
        for (var key in result[1]) {
          salutationMap.push({ key: key, value: result[1][key] });
        }
        component.set("v.salutationMap", salutationMap);
      }
    });

    $A.enqueueAction(action);
    $A.enqueueAction(action2);
  },
   handleChange:function (component, event, helper) {
          //Get the Selected values   
        var selectedValues = event.getParam("value");
		console.log(selectedValues+' selectedValues ');
         
        //Update the Selected Values  
        component.set("v.selectedPermList", selectedValues);
    },
  handleClick: function (component, event) {
    let jobRole = document.getElementById("userjobrole").value;
    let salutation = document.getElementById("usertitle").value;
    let additionPermission = component.get("v.selectedPermList");
    let firstnamecheck = component.find("createfirstname").get("v.value");
    let surnamecheck = component.find("createsurname").get("v.value");
    let phoneCode = document.getElementById("selectPhoneCode").value;
    let telephonecheck = component.find("createtelephone").get("v.value");
    let emailcheck = component.find("createemail").get("v.value");
    //let salutation = component.find("usertitle").get("v.value");  
   //let jobRole = component.find("userjobrole").get("v.value");
    //if (allValid && jobRole.length > 0 && salutation.length > 0) {
     var isValid = true;
      let con = component.get("v.con");
      let selectedValues = component.get("v.selectedValues");
       if (salutation == undefined || salutation == "" || salutation == null || salutation == "-- Select Title --") {  
            component.set("v.titleError",true);    
            isValid = false;
        } 
        else{
            component.set("v.titleError",false); 
        }
        if (firstnamecheck == undefined || firstnamecheck == "" || firstnamecheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.firstNameError",false); 
        }
        if (surnamecheck == undefined || surnamecheck == "" || surnamecheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.surNameError",false); 
        }
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }
        else if (phoneCode == "+44" && (telephonecheck.length != 11 || !telephonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
        }
        else{
            component.set("v.mobileError",false); 
            component.set("v.PhonelengthError",false); 
        }
        if (emailcheck == undefined || emailcheck == "" || emailcheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        else{
            component.set("v.emailError",false); 
        }
      
      // let listofValues = selectedValues.split(",");
      //invoke apex class : CreateUserUnderHO controller for DML
      if(isValid){
      var action = component.get("c.createHOUser");
      action.setParams({
          jobRole:jobRole,
          salutation:salutation,
          phoneCode: phoneCode,
          additionPermission:additionPermission,
          con: con,
          selectedValues: selectedValues
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        // Handle Success
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          component.set("v.data", result);
          // If result has values fire toast Message
          if (result) {
            component.set("v.succeessmessage", true);
    
          }
        }
        // Handle Error
        else if (state === "ERROR") {
          var errors = response.getError();
          // If error then check error type
          if (errors) {
            if (errors[0] && errors[0].message) {
              // If duplicate username fire toast message
              if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                 component.set("v.duplicateemailerror", true);
           
              } 
                else {}
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
    
    cancelRefresh:function(component, event, helper) {
      //  $A.get('e.force:refreshView').fire();
     // this.loadUser(component, event, helper);
      helper.fetchUserData(component, event, helper);
    },  
    // this is realted to createhouser end //
    
    
    
    
    // this is realted to updatehouser start //

    getuserdetailstoedit: function (component, event,helper) { 
        helper.getAdditionalPerm(component,event,helper);
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.mobileError", false);
        component.set("v.success", false);
        component.set("v.updatesucceessmessage", false);
        component.set("v.succeessmessage1", false);
        component.set("v.deactiveusersucceessmessage", false);
        component.set("v.reactiveusersucceessmessage", false);
        component.set("v.livedepositerror", false);
        component.set("v.levelOfAccesserror", false);
         component.set("v.isDisabled", true);
        var userId = event.target.id;
     //   alert(userId);
     component.set("v.userId",userId);  
     //   
      // alert(userId);
   // let userId = component.get("v.userId");
    let action = component.get("c.getUserDetails");
    action.setParams({ userId: userId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
          
        let result = response.getReturnValue();
         // alert('line-->417  ' + JSON.stringify(result));
        if (result) {
          //  component.set("v.selectedPermList",result.usr.Contact.Additional_Permission__c);
            component.set("v.selectedPermList", result.selectedPermission);
            console.log("perm "+component.get("v.selectedPermList"));
          component.set("v.con", result.usr.Contact);
                $('#edithouser').modal('show');
          // console.log("result.ut.usr.IsActive:", result.usr.IsActive);
          let items = [];
          let selectedValues = [];
          for (let key in result.bum) {
            let item = {
              label: result.bum[key].Branch__r.Branch_Name__c,
              value: result.bum[key].Branch__r.Id
            };
            items.push(item);
            selectedValues.push(item.value);
          }
          component.set("v.isActive", result.usr.IsActive);
          component.set("v.options", items);
          component.set("v.selectedValues", selectedValues);
          component.set("v.values", selectedValues);
          component.set("v.oldselectedValues", selectedValues);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });
    var action2 = component.get("c.getJobRoles");
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
          console.log('line-> 451 ' + JSON.stringify(result));
        var jobRoleMap = [];
        for (var key in result[2]) {
          jobRoleMap.push({ key: key, value: result[2][key] });
        }
        component.set("v.jobRoleMap", jobRoleMap);
          
         var permissionmap = [];
        for (var key in result[3]) {
          permissionmap.push({ key: key, value: result[3][key] });
        }
        component.set("v.permissionmap", permissionmap);  
          
        var salutationMap = [];
        for (var key in result[1]) {
          salutationMap.push({ key: key, value: result[1][key] });
        }
        component.set("v.salutationMap", salutationMap);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });
    let accountId = component.get("v.accId");
  //  let accountId = component.get("v.accountId");
    var action3 = component.get("c.getBranchesUnderAccount");
    action3.setParams({ accountId: accountId });
    action3.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
         // alert('line-->478  ' + JSON.stringify(result));
        let items = [];
        for (var key in result.branchList) {
          items.push({
            label: result.branchList[key].Branch_Name__c,
            value: result.branchList[key].Id
          });
        }
        component.set("v.options", items);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });

    $A.enqueueAction(action);
    $A.enqueueAction(action2);
    $A.enqueueAction(action3);
  } ,
    
    handleChange1: function (component, event, helper) {
        let selectedValues = event.getParam("value").toString();
        let listofValues = selectedValues.split(",");
     //   alert(listofValues);
        component.set("v.selectedValues", listofValues);
        component.set("v.isUpdated", true);
    },
    
   handleEdit: function (component, event, helper) {
    component.set("v.isDisabled", false);
  },

  handleUpdate: function (component, event, helper) {
    let isUpdated = component.get("v.isUpdated");
            var jobrolecheck = document.getElementById("edituserjobrole").value;
      //let jobRole = document.getElementById("userjobrole").value;
      let salutation = document.getElementById("editusertitle").value;
    var addpermissioncheck = component.get("v.selectedPermList");
      if(addpermissioncheck != undefined){
          isUpdated = true
      }
      let firstnamecheck = component.find("editfirstname").get("v.value");
      let surnamecheck = component.find("editsurname").get("v.value");
      let phoneCode = document.getElementById("editPhoneCode").value;
      let telephonecheck = component.find("edittelephone").get("v.value");
      let emailcheck = component.find("editemail").get("v.value");
      //let salutation = component.find("usertitle").get("v.value");  
      //let jobRole = component.find("userjobrole").get("v.value");
      //if (allValid && jobRole.length > 0 && salutation.length > 0) {
      var isValid = true; 
      
    
    if (isUpdated) {

        if (salutation == undefined || salutation == "" || salutation == null || salutation == "-- Select Title --") {  
            component.set("v.titleError",true);    
            isValid = false;
        } 
        else{
            component.set("v.titleError",false); 
        }
        if (firstnamecheck == undefined || firstnamecheck == "" || firstnamecheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.firstNameError",false); 
        }
        if (surnamecheck == undefined || surnamecheck == "" || surnamecheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.surNameError",false); 
        }
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }
        else if (phoneCode == "+44" && (telephonecheck.length != 11 || !telephonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
        }else{
            component.set("v.mobileError", false);
            component.set("v.PhonelengthError",false);   
        }
        if (emailcheck == undefined || emailcheck == "" || emailcheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        else{
            component.set("v.emailError",false); 
        }
        if(isValid){
        let selectedValues = component.get("v.selectedValues");
        var oldselectedValues = component.get("v.oldselectedValues");
        let con = component.get("v.con");

        function symmetricDifference(a1, a2) {
          var result = [];
          for (var i = 0; i < a1.length; i++) {
            if (a2.indexOf(a1[i]) === -1) {
              result.push(a1[i]);
            }
          }
          for (i = 0; i < a2.length; i++) {
            if (a1.indexOf(a2[i]) === -1) {
              result.push(a2[i]);
            }
          }
          return result;
        }
        var selectedValuesDiff = symmetricDifference(
          oldselectedValues,
          selectedValues
        );
        for (var key in selectedValuesDiff) {
          if (selectedValuesDiff[key].length < 1) {
            alert(selectedValuesDiff[key].length);
            selectedValuesDiff.pop();
          }
        }
       console.log(salutation+' '+jobrolecheck+' selectedValuesDiff '+selectedValuesDiff);
        //invoke apex class : CreateUserUnderHO controller for DML
        var action = component.get("c.updateHOUser");
        action.setParams({
            con: con,
            phoneCode: phoneCode,
            userpermission: addpermissioncheck,
            jobrole: jobrolecheck,
            salutation: salutation
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            // If result has values fire toast Message

            component.set("v.isDisabled", true);
            component.set("v.isUpdated", false);
              component.set("v.updatesucceessmessage", true);
     $('#maincon', window.parent.document).get(0).scrollIntoView();
               helper.fetchUserData(component, event, helper);
               setTimeout(function(){ 
                     $('#edithouser').modal('hide');
                   console.log('testload');
                          
                        }, 500);
          }
          // Handle Error
          else if (state === "ERROR") {
          
            var errors = response.getError();
             console.log(errors);
          }
        });
        $A.enqueueAction(action);
     } else {
         $('#maincon', window.parent.document).get(0).scrollIntoView();
      }
    } else {
      component.set("v.levelOfAccesserror", true);
  
    }
  },

  handleCancel: function (component, event, helper) {
   // component.set("v.isDisabled", true);
    component.set("v.isDisabled", true);
    this.getuserdetailstoedit(component, event);
  },

  isUpdated: function (component, event, helper) {
    component.set("v.isUpdated", true);
  },

  deactivateUser: function (component, event, helper) {
    // Get Attributes from component markup
   // let selectedUserId = component.get("v.selectedUserId");
    var selectedUserId =  component.get("v.userId"); 
    console.log("selectedUserId:", selectedUserId);
    var action = component.get("c.inactiveBranchUser");
    action.setParams({
      userId: selectedUserId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(state);
      // Handle Success
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        console.log(JSON.stringify(result));
        if (!result) {
          component.set("v.deactiveusersucceessmessage", true);
          component.set("v.isActive", false);
          component.set("v.reactiveusersucceessmessage", false);
            
         /* var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "User can been successfully deactivated.",
            type: "success"
          });
          toastEvent.fire();
          component.find("overlayLib").notifyClose();*/
        }
      }
      // Handle Error
      else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.livedepositerror", true);
            console.log(errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  reactivateUser: function (component, event, helper) {
    // Get Attributes from component markup
   // var selectedUserId = event.target.id;
     var selectedUserId =  component.get("v.userId");
    //let selectedUserId = component.get("v.selectedUserId");
    var action = component.get("c.reactiveBranchUser");
    action.setParams({
      userId: selectedUserId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      //   console.log(state);
      // Handle Success
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        // console.log(result);
        // console.log(JSON.stringify(result));
        if (result) {
           component.set("v.reactiveusersucceessmessage", true);
            component.set("v.isActive", true);
            component.set("v.deactiveusersucceessmessage", false);
        /*  var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "User can been successfully Activated.",
            type: "success"
          });
          toastEvent.fire();
          component.find("overlayLib").notifyClose();*/
        }
      }
      // Handle Error
      else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
            // console.log(errors[0].message);
          }
        } else {
          //   console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  // this is realted to updatehouser end //  
  /* javaScript function for pagination */
  navigation: function(component, event, helper) {
    var sObjectList = component.get("v.listOfAllusers");
    var end = component.get("v.endPage");
    var start = component.get("v.startPage");
    var pageSize = component.get("v.pageSize");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPage", component.get("v.currentPage") + 1);
      helper.next(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPage", component.get("v.currentPage") - 1);
      helper.previous(component, event, sObjectList, end, start, pageSize);
    }
  }
   
    
});