({
    doInit : function(component, event, helper) {
        // call error messages
         helper.getError(component, event, helper);
        
        var url = window.location.href.slice(window.location.href.indexOf('?') + 1);
        var depositRecordId = url.split("depositId=")[1];
        console.log('+++++++++++depositRecordId++'+depositRecordId);
        component.set("v.depositRecordId", depositRecordId);
        

    },
    
    depositSummaryPage : function(component, event, helper) {
      /*  console.log('+++++++++++1111++'+component.get("v.depositRecordId"));
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {id: component.get("v.depositRecordId")
                   }
        });*/
        history.back();
    },
    
    validateEmail : function(component, event, helper) {
        var emailField = component.find("emailId");
        var emailFieldValue = emailField.get("v.value");
        console.log('+++++++++++emailFieldValue++'+emailFieldValue);
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        
        if(!$A.util.isEmpty(emailFieldValue)){
            component.set("v.emailValidationError", false);
            if(emailFieldValue.match(regExpEmailformat)){
                component.set("v.emailNotValid", false);
            }else{
                component.set("v.emailNotValid", true);
            }
        }
        else{
            component.set("v.emailValidationError", true);
           // component.set("v.errors", "This field is required and cannot be left empty.");
        }
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
        case "blankemailcheck":
            component.set("v.emailValidationError", false);
            break;
        case "validemailcheck":
            component.set("v.emailNotValid", false);
            break;
        }
    },  
    
    transferSingleDeposit : function(component, event, helper) {
       var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        var emailFieldValue = component.find("emailId").get("v.value");
        
        if(!$A.util.isEmpty(emailFieldValue)){
            component.set("v.emailValidationError", false);
            if(emailFieldValue.match(regExpEmailformat)){
                component.set("v.emailNotValid", false);
                component.set("v.multipleDeposit", false);
                component.set("v.singleDeposit", true);
                component.set("v.showDeposits", false);
                component.set("v.openmodel",true);
            }else{
                component.set("v.emailNotValid", true);
            }
        }
        else{
            component.set("v.emailValidationError", true);
        }
        /*if(!$A.util.isEmpty(component.find("emailId").get("v.value"))){
            component.set("v.emailValidationError", false);
            component.set("v.multipleDeposit", false);
            component.set("v.singleDeposit", true);
            component.set("v.showDeposits", false);
            component.set("v.openmodel",true);
        }
        else{
            component.set("v.emailValidationError", true);
        }*/
    },
    
    transferMultipleDeposits : function(component, event, helper) {
        if(!$A.util.isEmpty(component.find("emailId").get("v.value"))){
            component.set("v.emailValidationError", false);
            component.set("v.multipleDeposit", true);
            component.set("v.showDeposits", true);
            component.set("v.singleDeposit", false);
            helper.getDepositDetails(component);
        }
        else{
            component.set("v.emailValidationError", true);
            component.set("v.errors", "This field is required and cannot be left empty.");
        }
    },
    
    //Select all contacts
    handleSelectAllDeposit: function(component, event, helper) {
        var selectedDeposits = [];
        var getID = component.get("v.listOfAllDeposits");
        var checkvalue = component.find("selectAll").get("v.value"); 
        //alert('+++++39'+checkvalue);
        var checkDeposit = component.find("checkDeposit");
        //alert('+++++41+'+checkDeposit);
        //alert('+++++42+'+checkDeposit.length);
        if(checkvalue){
                       if(checkDeposit.length==undefined){
                           checkDeposit.set("v.value",true);
                           selectedDeposits.push(checkDeposit.get("v.text"));
                       }
                       else{       
                           for(var i=0; i<checkDeposit.length; i++){
                               checkDeposit[i].set("v.value",true);
                               selectedDeposits.push(checkDeposit[i].get("v.text"));
                           }
                       }
                      }
        else{ 
            for(var i=0; i<checkDeposit.length; i++){
                checkDeposit[i].set("v.value",false);
                selectedDeposits.push(checkDeposit[i].get("v.text"));
            }
        }//alert('+++++61+'+checkDeposit);        
        component.set("v.selectedDeposits",selectedDeposits);
        //alert('+++++63+'+selectedDeposits);
    },
    
    //Process the selected deposits
    handleSelectedDeposits: function(component, event, helper) {
        var selectedDeposits = [];
        var checkvalue = component.find("checkDeposit");
        
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value")) {
                //alert('+++++73+'+checkvalue.get("v.text"));
                selectedDeposits.push(checkvalue.get("v.text"));
            }//alert('+++++75+'+selectedDeposits);
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedDeposits.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedDeposits-' + selectedDeposits);
        component.set("v.selectedDeposits",selectedDeposits);
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.openmodel', false);
    },
    
    closeModal: function(component, event, helper){
        component.set("v.openmodel", false);
    },
    
    //Process the selected deposits
    submitTransfers: function(component, event, helper) {
        component.set("v.openmodel",true);
    },
    
    //Process the selected deposits
    transferDeposits: function(component, event, helper) {
        component.set("v.openmodel",false);
        helper.submitTransfers(component);
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
                  console.log("line-->9  " +errorList[i].MasterLabel );
                   console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'Transfer to another Landlord'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.emailErrorNew",userErr);
                  }
                   
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }

})