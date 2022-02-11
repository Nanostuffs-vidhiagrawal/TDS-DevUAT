({
      doneWaiting: function(component, event, helper) {
      
    }, 
	  doInit : function(component, event, helper) {
          // Get Country codes Picklist Values
      
          const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const LandlordRecId = urlParams.get('id');
    
          if(LandlordRecId == null || LandlordRecId == undefined || LandlordRecId == ""){
              //  setTimeout(function(){ 
              var selPickListValue = 'Active';
              helper.getMyLandlords(component, event, helper,selPickListValue);
              //       }, 500);
          
          }else{
              //alert('LandlordRecId =>' + LandlordRecId);
              var action = component.get("c.getLandlord");
              action.setParams({
                  landlordRecId: LandlordRecId
              });
              action.setCallback(this, function(response) {
                  var result = response.getReturnValue();
                  var state = response.getState();
                  if (state === "SUCCESS"){
                      component.set("v.showViewPage",false);
                      if(result!=null){   
                          //   alert('result '+result.MailingStreet);
                          var valz =result.MailingStreet+"\n"+result.MailingCity+"\n"+result.MailingState+"\n"+result.MailingPostalCode;
                          component.set("v.textareaval",valz);
                          component.set("v.landlord",result);  
                      }
                  }
                  else{
                      
                  }
              });
              $A.enqueueAction(action); 
          }
         helper.fetchPhoneCodePicklist(component);
    },
    archiveStatus: function(component, event, helper) {
          var hrefId =  event.target.id;
         component.set("v.landlordStatus",hrefId);
    },
     handleArch : function(component, event, helper) {
          console.log('archive');
              var conRec = component.get("v.landlord");
        
         var hrefId =  event.target.id;
          console.log('hrefId '+hrefId);
         var action = component.get("c.archieveLandlord");
        action.setParams({
            landlordRec: conRec,
            status:hrefId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('result for save '+result.Account_Status__c);
            if (state === "SUCCESS"){
               
                if(result!=null){   
                    if(hrefId == 'Inactive'){
                         component.set("v.archivedLandlord",true);
                       
                    }
                    else if(hrefId == 'Active'){
                         component.set("v.archivedLandlord",false);
                    }
                   component.set("v.landlord",result);
                    
                  // helper.getMyLandlords(component, event, helper);
                     $('#myModal2').modal('hide'); 
                }
            }
            else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    handleEditLandlord : function(component, event, helper) {
         component.set("v.editPage",true);
    },
    handleCancle: function(component, event, helper) {
        component.set("v.editPage",false);
    },
    handleSave: function(component, event, helper) {
        component.set("v.blankFields",false);
        component.set("v.phonelengthError",false); 
        component.set("v.duplicateEmailError",false);  
        
        var conRec = component.get("v.landlord");
        conRec.Phone_Code__c = document.getElementById("phoneCodeId").value;
       
        // console.log('conRec '+conRec.email);
   //    var field1 = component.find("field1input");
          console.log(conRec.Phone_Code__c +' field1');
        if(conRec.LandLord_Registration_Number__c == undefined || conRec.MailingStreet == undefined || conRec.MailingCity == undefined || conRec.MailingPostalCode == undefined || conRec.MailingCountry == undefined || conRec.Email == undefined || conRec.Phone_Code__c == undefined|| conRec.Phone == undefined) 
        {
            console.log('Invalid ');
            component.set("v.blankFields",true);
            console.log('Invalid '+ component.get("v.blankFields"));
        }
        else if(conRec.Phone_Code__c == "+44" && (conRec.Phone.length != 11 || !conRec.Phone.startsWith("07"))) 
        {
            component.set("v.phonelengthError",true);   
            console.log('Invalid phonelengthError '+ component.get("v.phonelengthError"));
        }
        else{
            console.log('valid');
            var action = component.get("c.saveLandlord");
            action.setParams({
                landlordRec: conRec
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('State for save '+state);                
                if (state === "SUCCESS"){
                    var result = response.getReturnValue();
                    console.log('result for save '+ JSON.stringify(result));
                    var duplicateValue = [];
                    for ( var key in result ) {
                        duplicateValue.push({val:result[key], key:key});
                    }
                    var key = duplicateValue[0].key;
                    var recValue = duplicateValue[0].val;
                    
                    if (key == "Duplicate Email") {
                        component.set("v.duplicateEmailError",true);
                    } 
                    else if(key == "Duplicate Name"){
                        component.set("v.duplicateNameError", true);
                        component.set("v.duplicateRecord", recValue);
                    }
                    else { 
                        component.set("v.editPage",false);
                        component.set("v.landlord",recValue);
                        
                    }
                }
                else{
                    var result = response.getReturnValue();
                    console.log('ERROR '+ JSON.stringify(result));
                }
            });
            $A.enqueueAction(action); 
        } 
        
    },
       
    hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
     //  alert(button_Name);
    switch (button_Name) {
        case "blankFieldsBtn":
            component.set("v.blankFields", false);
            break;
        case "phonelength":
            component.set("v.phonelengthError", false);
            break;
        case "duplicateEmail":
            component.set("v.duplicateEmailError", false);
            break;
    }
        },
    
    ViewLandlord: function(component, event, helper) {  
        var landlordRecId = event.target.id;
    //    alert('land'+landlordRecId);
        var action = component.get("c.getLandlord");
        action.setParams({
            landlordRecId: landlordRecId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.showViewPage",false);
                if(result!=null){   
                 //   alert('result '+result.MailingStreet);
                   var valz =result.MailingStreet+"\n"+result.MailingCity+"\n"+result.MailingState+"\n"+result.MailingPostalCode;
        component.set("v.textareaval",valz);
                   component.set("v.landlord",result);
                   
                }
            }
            else{
                
            }
        });
        $A.enqueueAction(action); 
    
    },

    handleSearch : function(component, event, helper) {
          if (event.keyCode === 13) {
                     var sel = document.getElementById("SelectItemPick");
    var selPickListValue = sel.options[sel.selectedIndex].value;
        helper.getMyLandlords(component, event, helper,selPickListValue);         }
    },
     handleClick : function(component, event, helper) {
           var sel = document.getElementById("SelectItemPick");
    var selPickListValue = sel.options[sel.selectedIndex].value;
        helper.getMyLandlords(component, event, helper,selPickListValue);
       
    },
      navigateLandlord : function(component, event, helper) {
      //    helper.getMyLandlords(component, event, helper);
       component.set("v.showViewPage",true);
        component.set("v.fromParentComp",true);
         component.set("v.showLandlord",true);
          
              const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {branchId : branchId}
            });
        }else{
             component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                }
          
            });
        }
    },
    navigateMyProp: function(component, event, helper) {
   component.set("v.showLandlord",false);
        component.set("v.fromParentComp",false);
        
          component.set("v.showViewPage",true);
        component.set("v.fromParentComp",true);
         component.set("v.showLandlord",true);
        console.log('nav');
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {}
            }); 
        }
        
     
        
    },
     refreshLandlordList2: function (component, event, helper){
         console.log('refresh');
         var selPickListValue = 'Active';
    helper.getMyLandlords(component, event, helper,selPickListValue);
    },
    statusCheckPick: function(component, event, helper) {
         console.log('Data1 ');
            var sel = document.getElementById("SelectItemPick");
    var selPickListValue = sel.options[sel.selectedIndex].value;
        var selPickListValueTxt = sel.options[sel.selectedIndex].text;
       // var selPickListValue = event.getSource().get("v.value");
          console.log(selPickListValueTxt+' Data2 '+selPickListValue);
 
      helper.getMyLandlords(component, event, helper,selPickListValue);
  /*       var filteredList=[];
 var sObjectList = component.get("v.LandlordListView");
        console.log('Data3 '+JSON.stringify(sObjectList));
         console.log('Data33 '+sObjectList[0].Account_Status__c);
        
for(var i=0;i<sObjectList.length;i++){
     console.log(selPickListValue+' Data4 '+sObjectList[i].Account_Status__c);
            if(sObjectList[i].Account_Status__c == selPickListValue)
            {
                 console.log(selPickListValue+' Data45 '+sObjectList[i].Account_Status__c);
                 filteredList.push(sObjectList[i]); 
            }
              
        }
         console.log('Data44 '+filteredList);
        console.log('Data4 '+JSON.stringify(filteredList));
        if(filteredList.length>0){
         //   component.set("v.PaginationLandlordList",filteredList);
         var PaginationLandlordList = [];
         var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = filteredList;
                    console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    component.set("v.startPageLandlord", 0);
                    component.set("v.endPageLandlord", pageSize - 1);
                    var PaginationLandlordList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (filteredList.length > i) {
                            PaginationLandlordList.push(filteredList[i]);
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
            
        }*/
          
    },
       navLandlordPage: function(component, event, helper) {
    var sObjectList = component.get("v.LandlordListView");
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
    
    handleLinkToViewLandlord : function(component, event, helper){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {
                    id: event.target.id,
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceLandlord").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {
                    id: event.target.id,
                }
            }); 
        }
    }
})