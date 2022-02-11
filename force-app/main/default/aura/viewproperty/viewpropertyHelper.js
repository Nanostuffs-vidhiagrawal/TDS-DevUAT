({
	getProperty : function(component, event, helper) {
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const propertyRecId = urlParams.get('id');

        var action = component.get("c.getPropertyDetails");
        action.setParams({
            propertyId: propertyRecId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                if(result!=null){                    
                   component.set("v.property",result);
                   console.log(component.get("v.property.Property_status__c")+' +++++111++++'+result.NoOfDeposit__c);
                }
            }
            else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    getStatusPicklist:function(component, event) {
          var action = component.get("c.landlordRegistrationStatusList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            // Handle Success
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                console.log('@@ '+result);
                console.log('json '+JSON.stringify(result));
                //alert(result);
                var lanRegStatuses = [];
                for (var key in result) {
                    lanRegStatuses.push({ key: key, value: result[key] });
                }
                component.set("v.LandRegStatuses", lanRegStatuses);
                console.log('lanRegStatuses --->>> ', lanRegStatuses);
            }
			});
			 $A.enqueueAction(action);  
    },
    
    getLandlordData : function(component, event) {
        component.set("v.isRegStatus",false);
        component.set("v.successmessage", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.phonelengthError", false);
        component.set("v.mobileError", false);
        var action = component.get("c.getLandlordDetails");
        
        action.setParams({
            landlordId: event.target.id
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                
                if(result!=null){      
                    console.log("result >>> " + JSON.stringify(result));
                    component.set("v.landlord",result);
                    var regStatusCheck = result.Landlord_Registrataion_Status__c;
                    if(regStatusCheck!='' && regStatusCheck!=null && regStatusCheck!=undefined)
                    {
                        if(regStatusCheck == "Landlord is entered on the local authority register for the area where this property is located" || 
                           regStatusCheck == "Landlord is appealing a decision to remove their entry from the local authority register")
                        {
                            component.set("v.isRegStatus",true);
                        }
                        else {
                            
                            component.set("v.isRegStatus",false);
                        }
                    }
                    
                    $('#editLandlord').modal('show')
                    //  console.log('+++++111++++'+JSON.stringify(component.get("v.landlord")));
                }
            }
            else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    updateLandlordData : function(component, event,helper) {
        
        var isValid = true;
        var firstName = $("#sf-popup-First").val();	
        var lastName = $("#sf-popup-Surname").val();
        var email = $("#sf-popup-Email").val();
        var phoneCode = document.getElementById("phoneCodeId").value;
        var mobile = $("#sf-popup-Mobile").val();
        var registrationStatus = document.getElementById("regStId").value;
        
        var registration = $("#sf-popup-Registration").val();
        
        if (firstName == undefined || firstName == "" || firstName == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        if (lastName == undefined || lastName == "" || lastName == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        
        if (email == undefined || email == "" || email == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        if (mobile == undefined || mobile == "" || mobile == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }else if (phoneCode == "+44" && (mobile.length != 11 || !mobile.startsWith("07"))) {
            component.set("v.phonelengthError",true);    
            isValid = false;
        }
        
        /*if (registration == undefined || registration == "" || registration == null) {
            component.set("v.registrationError",true);    
            isValid = false;
        }*/
        if(isValid){
            var action = component.get("c.updateLandlordDetail");
            action.setParams({
                firstName : firstName,
                lastName : lastName,
                email : email,
                phoneCode : phoneCode,
                mobile : mobile,
                registration : registration,
                registrationStatus : registrationStatus,
                contactid : component.get("v.landlord.Contact__c"),
                propAllocationId : component.get("v.landlord.Id")
            });
            console.log('action'+action+firstName+lastName+email+mobile+registration+registrationStatus+component.get("v.landlord.Id"));
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var result = response.getReturnValue();
                    console.log("add landlord result=> " + JSON.stringify(result));
                    var duplicateValue = [];
                    for ( var key in result ) {
                        duplicateValue.push({val:result[key], key:key});
                    }
                    var key = duplicateValue[0].key;
                    var recValue = duplicateValue[0].val;
                    
                    if(key == "Duplicate Email"){
                        component.set("v.duplicateEmailError", true);	
                    }
                    else if(key == "Duplicate Name"){
                        component.set("v.duplicateNameError", true);
                        component.set("v.duplicateRecord", recValue);
                    }
                        else{
                            $('#mainLandlord', window.parent.document).get(0).scrollIntoView();
                            document.getElementById('mainLandlord').scrollIntoView(true);
                            
                            component.set("v.successmessage", true);
                            setTimeout(function(){ 
                                $A.get('e.force:refreshView').fire();
                            }, 1000);
                        }
                }
                else{
                    
                }
            });
        }
        else{
            $('#mainLandlord', window.parent.document).get(0).scrollIntoView();
            $('#editLandlord', window.parent.document).get(0).scrollIntoView();
        }
        $A.enqueueAction(action); 
    },
    
    deleteProperty : function(component, event, helper, status) {
        
        console.log('status '+status);
       const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const propertyRecId = urlParams.get('id');
        var action = component.get('c.deletePropertyRecord');
        // pass the all selected record's Id's to apex method 
        action.setParams({
            propertyRec : propertyRecId,
            status: status
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state1 = response.getState();
            var response1 = response.getReturnValue();
            if (state1 === "SUCCESS") {
                //    console.log('response1 '+response1);
                if(response1 == 'Inactive'){
                    
                    $('#myModal').modal('hide'); 
                    // $A.get('e.force:refreshView').fire();
                }
                else if(response1 == 'Active'){
                    
                    
                }
                //         $A.get('e.force:refreshView').fire();         
                helper.getProperty(component, event, helper);
            }
            else{
                component.set("v.displayError",true);
                component.set("v.message",response);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPropertyAllocations : function(component, event, helper) {
          console.log('propertyRecId 1');
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const propertyRecId = urlParams.get('id');
        // let propertyRecId = component.get("v.strRecordId");
         console.log('propertyRecId '+propertyRecId);
        var action = component.get("c.landlordList");
        action.setParams({
            propertyId: propertyRecId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            console.log(state);
            if (state == "SUCCESS") {
                console.log(a.getReturnValue());
                if(a.getReturnValue()!=null){
                    component.set("v.LandlordList",a.getReturnValue());
             //       console.log('+++++++++LandlordList++++'+component.get("v.LandlordList"));
                    component.set("v.strRecordId",propertyRecId);                    
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = a.getReturnValue();
               //     console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    var PaginationLst = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.LandlordList").length > i) {
                            PaginationLst.push(a.getReturnValue()[i]);
                        }
                    }//console.log('+++++++++PaginationLst++++'+PaginationLst);
                    component.set("v.PaginationList", PaginationLst);
                   // console.log('++++++PaginationList+++++++'+component.get("v.PaginationList"));
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                    var xyz = getElementsByClassName("dataTables_empty");
                    for(i = 0; i < xyz.length; i++) {
                        xyz.style.visibility = 'hidden';
                    }
                    document.getElementsByClassName("dataTables_empty").style.visibility = 'hidden';
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // navigate to next pagination record set
  next: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
  // navigate to previous pagination record set
  previous: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
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
    
 /*     nextLandlord: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  },
     previousLandlord: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  }, 
    getMyLandlords : function(component, event, helper) {
      console.log('@@ mylandlord');
          var searchTextValue =$("#searchValue").val();
        var action = component.get("c.myLandlordList");
         action.setParams({
            searchVar: searchTextValue
        }); 
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            console.log(state);
            if (state == "SUCCESS") {
              //  console.log('returned value '+a.getReturnValue());
                if(a.getReturnValue()!=null){
                     document.getElementById("SelectItem").value = '-- Please select --';
                    component.set("v.LandlordListView",a.getReturnValue());
                    console.log('+++++++++LandlordListView++++'+component.get("v.LandlordListView"));
                  //  component.set("v.strRecordId",propertyRecId);                    
                    var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = a.getReturnValue();
                    console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    component.set("v.startPageLandlord", 0);
                    component.set("v.endPageLandlord", pageSize - 1);
                    var PaginationLandlordList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.LandlordListView").length > i) {
                            PaginationLandlordList.push(a.getReturnValue()[i]);
                        }
                    }console.log('+++++++++PaginationLandlordList++++'+JSON.stringify(PaginationLandlordList));
                    component.set("v.PaginationLandlordList", PaginationLandlordList);
                  //  console.log('++++++PaginationLandlordList+++++++'+component.get("v.PaginationLandlordList"));
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
                    var xyz = getElementsByClassName("dataTables_empty");
                    for(i = 0; i < xyz.length; i++) {
                        xyz.style.visibility = 'hidden';
                    }
                   
                    document.getElementsByClassName("dataTables_empty").style.visibility = 'hidden';
                }
            }
        });
        
        $A.enqueueAction(action);
    },*/
})