({
  doInit: function(component, event, helper) {
    let prop = component.get("v.selectedProperty");
    var action = component.get("c.getLandlordforSummery");
    action.setParams({
      property: prop
    });
    action.setCallback(this, function(a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        console.log('line 11' + JSON.stringify(a.getReturnValue()));
        component.set("v.Landlord", a.getReturnValue());
      }
    });
    $A.enqueueAction(action);
    var v1 = document.getElementsByClassName("state-indicator");
    v1[3].classList.add("active");
  },

  doCancelDeposit: function(component, event, helper) {
    var confirmation = confirm("Are you Sure? All changes will be deleted");
    if (confirmation == true) {
      // $A.get("e.force:refreshView").fire();
      //setTimeout(function(){ window.location.reload();  }, 2000);
      component.find("navService").navigate({
        type: "comm__namedPage",
        attributes: {
          pageName: "home"
        },
        state: {}
      });
    }
  },

  doAddAnotherDeposit: function(component, event, helper) {
      
      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      const branchId = urlParams.get('branchId');
      // alert('branchid '+branchid);
      var clickedBtn = event.getSource().getLocalId();
      let button = event.getSource();
      button.set('v.disabled',true);
         component.set("v.btnClicked",true);
      let leadTenantObj = component.get("v.leadTenantObj");
      let arrObj = component.get("v.arrObj");
      let selectedPrimarylandlord = component.get("v.selectedPrimarylandlord");
      var action = component.get("c.finalSave"); 
      var proprty = component.get("v.selectedProperty");
      var depositAmt = parseFloat(component.get("v.depositAmount")).toFixed(2);
      var amtToProtect = parseFloat(component.get("v.amountToProtect")).toFixed(2);
      var rentAmt = parseFloat(component.get("v.rentAmount")).toFixed(2);
     // var depAmt = parseFloat(depositAmt).toFixed(2);
      //  console.log('& '+depAmt);
      action.setParams({
          branchId:branchId,
          leadTenantObj: JSON.stringify(leadTenantObj),
          tenantRec: JSON.stringify(arrObj),
          property: proprty[0],
          registerNumber: component.get("v.landRegisterNumber"),
          registerstatus: component.get("v.landRegisterstatus"),
          primeLandlordId: component.get("v.selecedPrimeLandlord"),
          rentAmount: rentAmt,
          depositAmount: depositAmt,
          amountToProtect: amtToProtect,
          depositRecievedDate: component.get("v.depositRecievedDate"),
          tenancyStartDate: component.get("v.tenancyStartDate"),
          noOfTenants: component.get("v.noOfTenants"),
          depositReference: component.get("v.depositReference")
      });

      action.setCallback(this, function(response) {
          var state = response.getState();
          // Handle Success
          console.log('clicked state '+state+response.getReturnValue());
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              console.log(result);
              
              if (result != undefined && result != '') {
                  // alert("Deposit has been successfully created");
                  /*  var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "Deposit has been successfully created",
            type: "success"
          });
          toastEvent.fire();*/
            
            if (clickedBtn == "addAnotherDepositBtn") {
                
                let currentURL = window.location.href;
                
                var cmpEvent = component.getEvent("EI_PopulateProperty"); 
                //Set event attribute value
                cmpEvent.setParams({"switchYes" : false,"depositCreated" : true}); 
                cmpEvent.fire();  
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    url: currentURL
                });
                urlEvent.fire();
                
                /*
                            component.find("navService").navigate({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName: "adddeposit"
                                },
                                state: {}
                            });*/
              
              
              // $A.get("e.force:refreshView").fire();
          } else if (clickedBtn == "saveAndPayLaterBtn") {
              setTimeout(function() {
                  
                  if(branchId != null){
                      component.find("navService").navigate({
                          type: "comm__namedPage",
                          attributes: {
                              pageName: "depositsummarypage"
                          },
                          state: {
                              id:result,
                              branchId: branchId
                          }
                      });
                  }
                  else{
                      component.find("navService").navigate({
                          type: "comm__namedPage",
                          attributes: {
                              pageName: "depositsummarypage"
                          },
                          state: {
                              id:result
                          }
                      });
                  }
                  
              }, 1000);
          }
              else if(clickedBtn == "payCustodialDepositBtn"){
                  var state;
                  if(branchId != null){
                      state = {
                          status: "registered",
                          id: result,
                          branchId : branchId
                      };
                  }else{
                      state = {
                          status: "registered",
                          id: result
                      };
                  }
                  component.find("navService").navigate({
                      type: "comm__namedPage",
                      attributes: {
                          pageName: "paydeposit"
                      },
                      state:state
                  });
              }
        } else {
               component.set("v.btnClicked",false);
            component.set("v.errorDepositCreation",true);
        }
      }
        // Handle Error
        else if (state === "ERROR") {
             component.set("v.btnClicked",false);
            button.set('v.disabled',false);
            component.set("v.errorDepositCreation",true);  
          
      }
    });
      $A.enqueueAction(action);
  },

  backToTenantComp: function(component, event, helper) {
    var cmpEvent = component.getEvent("EI_backToTenantComp");  
    cmpEvent.fire();
    var v1 = document.getElementsByClassName("state-indicator");
    v1[3].classList.remove("active"); 
      console.log("Line 151");
      let leadTenantObj = component.get("v.leadTenantObj");
      let arrObj = component.get("v.arrObj");
      
      var cmpEvent = component.getEvent("EI_depositDetailFromSummary"); 
      console.log("Line 156");
      //helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);
      cmpEvent.setParams({ leadTenantObj: leadTenantObj });
      cmpEvent.setParams({ arrObj: arrObj });
      console.log("Line 160");
      cmpEvent.fire();
      console.log("Line 162");
  },

  goToDepositComp: function(component, event, helper) {
    console.log("Line 154");
    var cmpEvent = component.getEvent("EI_backToDepositHome");
      console.log("Line 157");
      console.log("rentAmount",component.get("v.rentAmount"));
      console.log("depositAmount",component.get("v.depositAmount"));
      console.log("amountToProtect",component.get("v.amountToProtect"));
      console.log("depositRecievedDate",component.get("v.depositRecievedDate"));
      console.log("tenancyStartDate",component.get("v.tenancyStartDate"));
      console.log("noOfTenants",component.get("v.noOfTenants"));
      console.log("depositReference",component.get("v.depositReference"));
      
    cmpEvent.setParams({
      showpropertyComp: true,
      rentAmount: component.get("v.rentAmount"),
      depositAmount: component.get("v.depositAmount"),
      amountToProtect: component.get("v.amountToProtect"),
      depositRecievedDate: component.get("v.depositRecievedDate"),
      tenancyStartDate: component.get("v.tenancyStartDate"),
      noOfTenants: component.get("v.noOfTenants"),
      depositReference: component.get("v.depositReference")
    });
      console.log("Line 175");
    cmpEvent.fire();
    var v1 = document.getElementsByClassName("state-indicator");
    v1[3].classList.remove("active");
     v1[2].classList.remove("active");
     v1[1].classList.remove("active");  
      console.log("Line 181");  
  },
    
    backToDepositDetailForm : function(component, event, helper){
        console.log("Line 185");
         let leadTenantObj = component.get("v.leadTenantObj");
        let arrObj = component.get("v.arrObj");
        
        var cmpEvent = component.getEvent("EI_tenantHome"); 
        console.log("Line 190");
        //helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);
        cmpEvent.setParams({ leadTenantObj: leadTenantObj });
        cmpEvent.setParams({ arrObj: arrObj });
        console.log("Line 194");
        cmpEvent.fire();
        console.log("Line 196");
	},
    
    hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
    switch (button_Name) {
      case "errorDepositCreation":
        component.set("v.errorDepositCreation", false);
        break;
    }
  },
  transferToPay : function(component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "paydeposit"
            },
            state: {
                status: "registered",
                id: event.target.id
                
            }
        });
  },
});