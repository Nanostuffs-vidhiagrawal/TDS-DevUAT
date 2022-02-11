({
      doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 1200);
    }, 
  fadeModal: function(component, event, helper) {
    //  alert('Test');
    var modal = document.getElementById("myModal");

    // Get the button that opens the modal
    var btn = document.getElementById("myBtn");

    // Get the <span> element that closes the modal
    var span = document.getElementsByClassName("close")[0];

    // When the user clicks the button, open the modal
    btn.onclick = function() {
      modal.style.display = "block";
    };

    // When the user clicks on <span> (x), close the modal
    span.onclick = function() {
      modal.style.display = "none";
    };

    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function(event) {
      if (event.target == modal) {
        modal.style.display = "none";
      }
    };
  },
  doInit: function(component, event, helper) {
     
      var selPickListValue = 'Active';
    helper.doInitHelper(component, event,selPickListValue);
 //   helper.getMyLandlords(component, event, helper);
       setTimeout(function(){
      var currentUser = component.get("v.currentUser");
       
      if(currentUser.Contact.Job_role__c=='Dispute administrator' && (currentUser.Contact.Additional_Permission__c== undefined || currentUser.Contact.Additional_Permission__c == null))
        {
            component.set("v.viewPropertyFlag",true);
           
        }
         
             }, 800);
  },
     handleClick : function(component, event, helper) {
        helper.getMyLandlords(component, event, helper);
       
    },
    searchButton: function(component, event, helper) {
        helper.searchpropertylist(component, event);
    },
      statusCheck: function(component, event, helper) {
         console.log('Data1 ');
            var sel = document.getElementById("SelectItem");
    var selPickListValue = sel.options[sel.selectedIndex].value;
       // var selPickListValue = event.getSource().get("v.value");
          console.log('Data2 '+selPickListValue);
 
      helper.doInitHelper(component, event,selPickListValue);
      },
          
  searchproperty: function(component, event, helper) {
    // var rac = component.get("v.searchText");
    //alert(rac);
    if (event.keyCode === 13) {
        console.log('clicked');
        helper.searchpropertylist(component, event);
    }
  },
      navigateLandlord : function(component, event, helper) {
      //    helper.getMyLandlords(component, event, helper);
       component.set("v.showViewPage",true);
        component.set("v.fromParentComp",true);
         component.set("v.showLandlord",true);
        console.log('nav');
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {}
            }); 
        }
    },
    navigateMyProp: function(component, event, helper) {
        
   component.set("v.showLandlord",false);
        component.set("v.fromParentComp",false);
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
     
        if(branchId != null){
                component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {branchId : branchId}
            });
        }else{
        component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                }
          
            });
        }
        
    },
    
  /* javaScript function for pagination */
  navigation: function(component, event, helper) {
    var sObjectList = component.get("v.listOfPropertyAlocations");
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
  },

    
     navLandlordPage: function(component, event, helper) {
    var sObjectList = component.get("v.LandlordList");
    var end = component.get("v.endPageLandlord");
    var start = component.get("v.startPageLandlord");
    var pageSize = component.get("v.pageSizeLandlord");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") + 1);
      helper.nextLandlord(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") - 1);
      helper.previousLandlord(component, event, sObjectList, end, start, pageSize);
    }
  },
  ViewProperty: function(component, event, helper) {
    const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        if(branchId != null){
            component.find("navServiceMyProperty").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "viewproperty"
                },
                state: {
                    id: event.target.id,
                    branchId: branchId}
            });
        }
      else{component.find("navServiceMyProperty").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "viewproperty"
      },
      state: {
        id: event.target.id
      }
    });
          }


  },

  CreateProperty: function(component, event, helper) {
    $A.createComponent("c:PropertyCreatecomp", {}, function(result, status) {
      if (status === "SUCCESS") {
        component.find("overlayLibDemo").showCustomModal({
          header: "Create New Property",
          body: result,
          showCloseButton: true,
          cssClass: "mymodal",
          closeCallback: function() {
            helper.doInitHelper(component, event);
          }
        });
      }
    });
  },
  doSave: function(component, event, helper) {
    var noOfBedroom = document.getElementById("sf-popup-Bedrooms").value;
    var noOfLivingBedroom = document.getElementById("sf-popup-Livingrooms")
      .value;
    var selectedValue = document.getElementById("gridCheck2");
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
      typeof objChild.get("v.Country") == "undefined" ||
      objChild.get("v.County") == "" ||
      typeof objChild.get("v.County") == "undefined"
    ) {
      alert("Please fill Address");
    } else {
      var action = component.get("c.saveproperty");

      action.setParams({
        noOfBedroom: noOfBedroom,
        noOfLivingBedroom: noOfLivingBedroom,
        selectedValue: selectedValue.checked,
        street: component.get("v.Street"),
        city: component.get("v.Town"),
        postcode: component.get("v.PostCode"),
        country: component.get("v.Country"),
        county: component.get("v.County"),
        LocalAreaCode: component.get("v.LocalAreaCode")
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            type: "success",
            message: "Property has been created successfully."
          });
          toastEvent.fire();
          setTimeout(
            function() {
              window.location.reload();
            },

            500
          );
        }
        /*  else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Invalid details!",
                        "message": "Please fill correct values."
                    });
                    toastEvent.fire();
               component.find("overlayLibDemo1").notifyClose();
                }  */
      });

      $A.enqueueAction(action);
    }
  },

  parentPress: function(component, event, helper) {
    helper.PassVariable(component, event, helper);
    //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
  },

  forceRefreshCallback: function(component, event, helper) {
    component.find("navServiceMyProperty").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "manageyouraddresses"
      },
      state: {}
    });
    $A.get("e.force:refreshView").fire();
  },

  navigateToProperty: function(component, event, helper) {
    helper.navService(component);
  }
});