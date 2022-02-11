({
  doInit: function(component, event, helper) {
    var action = component.get("c.getuserDetails");
    action.setCallback(this, function(a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        let UserDetails = a.getReturnValue();
        component.set("v.Usersdetails", a.getReturnValue());
        if (UserDetails.Profile.Name == "Branch User") {
          let action1 = component.get("c.getBranchID");
          action1.setParams({
            UserId: UserDetails.Id
          });
          action1.setCallback(this, function(res) {
            var state = res.getState();
            if (state == "SUCCESS") {
              component.set("v.BranchID", res.getReturnValue());
            }
          });
          $A.enqueueAction(action1);
        } else {
          if (UserDetails.Profile.Name == "Head Office User") {
            let currentURL = window.location.href;
            let branchId = currentURL.split("branchId=")[1];
            component.set("v.BranchID", branchId);
          }
        }
      }
        var successDeposit = document.getElementById("successDeposit");
			successDeposit.style.display = "none";   
          console.log(31);
    });
    $A.enqueueAction(action);
    component.set("v.notLoaded", false);
  },
  activeSpan1: function(component, event, helper) {
    var propcircle = component.find("1stCircle");
    var propform = component.find("1stForm");
    var depcircle = component.find("2ndCircle");
    var depform = component.find("2ndForm");
    $A.util.addClass(propcircle, "slick-current slick-center");
    $A.util.addClass(propform, "slick-current slick-active formActive");
    $A.util.removeClass(propform, "formNotActive");
    $A.util.removeClass(depcircle, "slick-current slick-center");
    $A.util.addClass(depform, "formNotActive");
    $A.util.removeClass(depform, "slick-current slick-active formActive");
  },
  activeSpan2: function(component, event, helper) {
    var propcircle = component.find("1stCircle");
    var propform = component.find("1stForm");
    var depcircle = component.find("2ndCircle");
    var depform = component.find("2ndForm");
    $A.util.removeClass(propcircle, "slick-current slick-center");
    $A.util.removeClass(propform, "slick-current slick-active formActive");
    $A.util.addClass(propform, "formNotActive");
    $A.util.addClass(depcircle, "slick-current slick-center");
    $A.util.removeClass(depform, "formNotActive");
    $A.util.addClass(depform, "slick-current slick-active formActive");
  },
  continuetolandlord: function(component, event, helper) {
    var depsoit = document.getElementById("depsoit");
    var property = document.getElementById("depsoit");
    $A.util.removeClass(property, "slick-current");
    $A.util.addClass(depsoit, "slick-current");
    var step2 = component.find("step2");
    $A.util.addClass(step2, "active");

    component.set("v.showdepositComp", true);
    component.set("v.showdepositHome", false);
    var v1 = document.getElementsByClassName("state-indicator");
    v1[1].classList.add("active");
    component.set("v.successProperty", false);
 	component.set("v.successDeposit", false);      
      var successDeposit = document.getElementById("successDeposit");
      successDeposit.style.display = "none";  
    /*component.set("v.showpropertyComp", false);
    component.set("v.showLandlorddetails", true);
    let userRec = component.get("v.Usersdetails");
    let primaryLandlord = component.get("v.selecedPrimeLandlord");
    if (
      userRec.User_Type__c == "Agent" &&
      (primaryLandlord == "" || primaryLandlord == null)
    ) {
      component.set("v.showprimaryLandlord", true);
    } else {
      component.set("v.showprimaryLandlord", false);
    }*/
      
  },
  addLandlord: function(component, event, helper) {
    var modalBody;
    $A.createComponent("c:EI_addLandlordToProperty", {}, function(
      content,
      status
    ) {
      if (status === "SUCCESS") {
        modalBody = content;
        component.find("overlayLib").showCustomModal({
          header: "Landlord",
          body: modalBody,
          showCloseButton: true,
          cssClass: "mymodal",
          closeCallback: function() {}
        });
      }
    });
  },

  backToProperty: function(component, event, helper) {
    component.set("v.showpropertyComp", true);
    component.set("v.showLandlorddetails", false);
  },
  eventHendle: function(component, event, helper) {
    var propertyrec = [];
    propertyrec = event.getParam("Property");
    component.set("v.flaguserInput", true);
    component.set("v.defaultflag", true);
    component.set("v.disbableContinueBtn", false);
    component.set("v.selectedProperty", propertyrec);
    component.set("v.selecedPrimeLandlord", event.getParam("primaryLandlord"));
  },

  EI_tenantHome: function(component, event, helper) {
    console.log("Event Handled Line 116");
    var leadTenantObj = event.getParam("leadTenantObj");
    var arrObj = event.getParam("arrObj");
    console.log("Event Handled Line 119");
    component.set("v.leadTenantObj", leadTenantObj);
    component.set("v.arrObj", arrObj);
    console.log("Event Handled Line 121");
  },
  searchKeyChange: function(component, event) {
      
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
    console.log("++++++++searchKeyChange++++++");
    var searchField = component.find("searchField").get("v.value");
    console.log("searchField :", searchField);
    var action = component.get("c.getProperties");
    action.setParams({
      searchField: searchField,
        branchId: branchid
    });
    action.setCallback(this, function(a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        component.set("v.Properties", a.getReturnValue());
        var result = a.getReturnValue();
        console.log("result", result);
        if (a.getReturnValue() != null) {
          component.set("v.Continuebtnflag", false);
        } else {
          component.set("v.Continuebtnflag", true);
        }
      } else {
        var error = a.getError();
        console.error("error", error);
        console.error("error", JSON.stringify(error));
      }
    });
    $A.enqueueAction(action);
  },

  Viewdeposit: function(component, event, helper) {
    window.history.back();
  },

  clickYes: function(component, event, helper) {
    var ys =  document.getElementById("property_yes");
    var no =   document.getElementById("property_no");
 
   $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
      component.set("v.displayYesSection", true);
    component.set("v.displayNoSection", false);
    component.set("v.successProperty", false);  
    //component.set("v.flaguserInput", true);
    //component.set("v.defaultflag", true);
      var successDeposit = document.getElementById("successDeposit");
      successDeposit.style.display = "none"; 
      
  },

  clickNo: function(component, event, helper) {
  var ys =  document.getElementById("property_yes");
    var no =   document.getElementById("property_no");
 
   $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");     
    component.set("v.displayYesSection", false);
    component.set("v.displayNoSection", true);
    component.set("v.Properties", "");
    var goBack = document.getElementsByClassName("go-back");
    console.log("goBack", goBack[1]);
    goBack[1].style.display = "none";
     component.set("v.successProperty", false); 
     var successDeposit = document.getElementById("successDeposit");
     successDeposit.style.display = "none"; 
      
    //component.set("v.defaultflag", true);
    //component.set("v.flaguserInput", false);
  },

  continueBtn: function(component, event, helper) {
    let PropertyList = component.get("v.Properties");
    let selectedRecid = [];
    for (let i = 0; i < PropertyList.length; i++) {
      if (PropertyList[i].isChecked) {
        selectedRecid.push(PropertyList[i].recId);
      }
    }
    if (selectedRecid.length == 0) {
      alert("Please select atleast one property");
    } else {
      if (selectedRecid.length > 1) {
        alert("Please select only one property");
      } else {
        $A.createComponent(
          "c:EI_addDepositForm",
          { selectedRecordId: selectedRecid },
          function(content, status) {
            if (status === "SUCCESS") {
              var modalBody = content;
              component.find("overlayLib").showCustomModal({
                header: "Add Deposit",
                body: modalBody,
                showCloseButton: true
              });
            }
          }
        );
      }
    }
  },

  selectedRecord: function(component, event, helper) {
    component.set("v.selectedPrimarylandlord", null);
    let selectRecord = event.target.id;
    let recordID = selectRecord.slice(0, 18);
    let prop = component.get("v.Properties");
    let selectedrec = [];
    for (let i = 0; i < prop.length; i++) {
      if (prop[i].recId == recordID) {
          component.set("v.Livedeposit", prop[i].livedeposit);
          component.set("v.selecedPrimeLandlord", prop[i].primaryLandlord);
          selectedrec.push(prop[i].proprtyrec);
      }
    }
    component.set("v.selectedProperty", selectedrec);
    console.log("++++++selectedrec++++++" + JSON.stringify(selectedrec));
    component.set("v.Properties", "");
    component.find("propertyContinuetolandlordBtn").set("v.disabled", false);
  },

  continue: function(component, event, helper) {
    let loginuser = component.get("v.Usersdetails");
    let selectedPrimarylandlord = component.get("v.selectedPrimarylandlord");
    let selecedPrimeLandlord = component.get("v.selecedPrimeLandlord");
    let allValid = component
      .find("fieldId")
      .reduce(function(validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.get("v.validity").valid;
      }, true);
    if (allValid) {
      var flag = true;
      if (
        loginuser.User_Type__c == "Agent" &&
        selectedPrimarylandlord == null
      ) {
        if (selecedPrimeLandlord == "") {
          alert("Please provide details about the landlord");
          flag = false;
        }
      }
      if (flag) {
        component.set("v.showpropertyComp", false);
        component.set("v.showLandlorddetails", false);
        component.set("v.showdepositComp", true);
      }
    }
  },

  EI_backToDepositHome: function(component, event, helper) {
    console.log("Event 253 handle strt");
    console.log("rentAmount", event.getParam("v.rentAmount"));
    console.log("depositAmount", event.getParam("v.depositAmount"));
    console.log("amountToProtect", event.getParam("v.amountToProtect"));
    console.log("depositRecievedDate", event.getParam("v.depositRecievedDate"));
    console.log("tenancyStartDate", event.getParam("v.tenancyStartDate"));
    console.log("noOfTenants", event.getParam("v.noOfTenants"));
    console.log("depositReference", event.getParam("v.depositReference"));
    component.set("v.showdepositHome", true);
    component.set("v.disbableContinueBtn", false);
    // component.find("propertyContinueBtn").set("v.disabled", true);
    component.set("v.showpropertyComp", true);
    component.set("v.showdepositComp", false);

    component.set("v.rentAmount", event.getParam("rentAmount")),
      //   alert(event.getParam("rentAmount"));
      // alert(component.get("v.rentAmount"));
      component.set("v.depositAmount", event.getParam("depositAmount")),
      component.set("v.amountToProtect", event.getParam("amountToProtect")),
      component.set(
        "v.depositRecievedDate",
        event.getParam("depositRecievedDate")
      ),
      component.set("v.tenancyStartDate", event.getParam("tenancyStartDate")),
      component.set("v.noOfTenants", event.getParam("noOfTenants")),
      component.set("v.depositReference", event.getParam("depositReference"));
    // alert(`Event Handled`);
    console.log(`Line 280`);
  },

  closeSuggestion: function(component, event, helper) {
    component.set("v.Properties", "");
  },
  searchKeyChange1: function(component, event, helper) {
    console.log("+++++searchKeyChange1+++");
    component.set("v.landlordDetails", "");
    let searchField = component.find("searchField1").get("v.value");
    let action = component.get("c.getlandlord");
    action.setParams({
      searchField: searchField
    });
    action.setCallback(this, function(a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        component.set("v.PrimarylandlordDetails", a.getReturnValue());
        var result = a.getReturnValue();
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  primaryLandlord: function(component, event, helper) {
    let selectRecord = event.target.id;
    let primarylandlord = component.get("v.PrimarylandlordDetails");
    let selectedrec = [];
    let selectedrecId;
    for (let i = 0; i < primarylandlord.length; i++) {
      if (primarylandlord[i].Id == selectRecord) {
        selectedrec.push(primarylandlord[i]);
        selectedrecId = primarylandlord[i].Id;
      }
    }
    component.set("v.PrimarylandlordDetails", "");
    component.set("v.selectedPrimarylandlord", selectedrec);
    component.set("v.selecedPrimeLandlord", selectedrecId);
  },

  EI_PopulateProperty: function(component, event) {
    console.log('Event Recieved');
    var propYes = event.getParam("switchYes");
    var depCreated = event.getParam("depositCreated");
    
     console.log("propYes",propYes);
     console.log("depCreated",depCreated); 
      if(propYes){ 
           console.log("newSelectedProperty",event.getParam("newSelectedProperty"));
           component.set("v.disbableContinueBtn", false);
          component.set("v.selectedProperty", event.getParam("newSelectedProperty"));
          component.set("v.displayYesSection", true);
          component.set("v.displayNoSection", false);
          component.set("v.successProperty", false);
          component.set("v.showdepositHome", false);
            component.set("v.showdepositComp", true);
        var divstep2 = document.getElementById("stepdiv2");
           $A.util.addClass(divstep2, "active");
        var step2 = component.find("step2");
          console.log('step2 '+step2);
    $A.util.addClass(step2, "active");
           $('#maincon', window.parent.document).get(0).scrollIntoView();
          console.log("Line 342");
      }else if(depCreated){
          component.set('v.successDeposit',true);
           //component.set('v.successProperty',true);
          console.log(component.get('v.successDeposit'));
          console.log(component.get('v.successProperty'));
          setTimeout(function(){ 
          var successDeposit = document.getElementById("successDeposit");
			successDeposit.style.display = "block";   
          console.log(350);
          }, 1000);
			
      }  
   
  },

  hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
    switch (button_Name) {
      case "successProperty":
        component.set("v.successProperty", false);
        break;
      case "successDeposit":
       var successDeposit = document.getElementById("successDeposit");
			successDeposit.style.display = "none"; 
        break;      
    }
  },
      
      handleLinktoLiveDeposit : function(component, event, helper) {
          const queryString = window.location.search;
          const urlParams = new URLSearchParams(queryString);
          const branchId = urlParams.get('branchId');
          
          if(branchId != null){
              component.find("navService").navigate({
                  type: "comm__namedPage",
                  attributes: {
                      pageName: "depositsummarypage"
                  },
                  state: {
                      id: event.target.id,
                      branchId: branchId
                  }
              });
          }else{
              component.find("navService").navigate({
                  type: "comm__namedPage",
                  attributes: {
                      pageName: "depositsummarypage"
                  },
                  state: {
                      id: event.target.id
                  }
              });
          }
    },
        
});