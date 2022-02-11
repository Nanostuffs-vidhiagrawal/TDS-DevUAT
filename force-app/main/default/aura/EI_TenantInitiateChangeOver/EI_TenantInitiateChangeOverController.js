({
    doInit : function(component, event, helper) {
        
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var bankOption = urlParams.get('bankDetails');
        if(bankOption == 'true'){
            
            component.set("v.bankOption",true);  
            component.set("v.firstOption",false);
            
        }
        helper.tenentDetailslist(component, event, helper);
        helper.tenentDetails(component, event, helper);
        helper.bankDetails(component, event, helper);
        helper.getError(component, event, helper);
        
    },
    
    enableBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldBankDetailsEdit", false);
        component.set("v.toggleBankDetails", false);
    }, 
    
    enableInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldInternationalBankDetailsEdit", false);
        component.set("v.toggleInternationalBankDetails", false);
    },
    
    cancelInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldInternationalBankDetailsEdit", true);
        component.set("v.toggleInternationalBankDetails", true);
    },
    
    cancelBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldBankDetailsEdit", true);
        component.set("v.toggleBankDetails", true);
    },
    
    cancelBankDetails: function (component, event, helper) {
        component.set("v.showBankDetails", false);
    },
    
    updateBankDetails: function (component, event, helper) {
        helper.updateBankDetails(component, event);
    },
    
    updateInternationalBankDetails: function (component, event, helper) {
        helper.updateInternationalBankDetails(component, event);
    },
    
    backonfirst:function(component, event, helper){
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var depositId = urlParams.get('id');
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositId
            }
        });
    },
    addBankDetails:function(component, event, helper){
        
        //  alert( component.find("bankName").get("v.value"));
        //var bankData= component.get("v.bankDetails");
        
        component.set("v.showBankDetails",true);
        //component.set("v.noBankDetails",false);
        
        // console.log('addbank bankData '+bankData + component.get("v.bankDetails[0].Bank_Name__c") );
        
        /*   if(bankData == '' || typeof bankData == 'undefined' || bankData == null){
         component.set("v.fieldBankDetailsEdit",false);
          var paymentButton = component.find("addPayment");
             $A.util.removeClass(paymentButton, 'addButton');
        }
        else{
              console.log('ELSE bankData '+bankData);
            	
             var action = component.get("c.getBankDetails");         
                    action.setParams({
                        bankdetail : component.get("v.bankDetails")          
                    });
                  action.setCallback(this, function (a) {
                        var state = a.getState();
                        var errors = a.getError();
                      console.log('@@bank '+a.getReturnValue());
                          if (state == "SUCCESS" ) {
                             var returnResult = a.getReturnValue();
                              if(returnResult != null){
                                  component.set("v.bankDetails",returnResult);
                               component.set("v.fieldBankDetailsEdit",true);
                                  alert('Successfully Updated Bank Details');
                                   component.set("v.noBankDetails",false);
                                  component.set("v.updateBankDetails",true);
                              }
                              else{
                                    component.set("v.noBankDetails",true);
                                  
                              }
                             
                          }
                  });
         $A.enqueueAction(action);
        }
        */
    },
    editBankDetails:function(component, event, helper){
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "my-details"
            },
            state: {
                
            }
        });
        
        
    },
    submitDetails:function(component, event, helper){
        var bankData=   component.get("v.noBankDetails");
        //  console.log('bankData '+bankData);
        if(bankData == true){
            var paymentButton = component.find("addPayment");
            //   console.log('paymentButton '+paymentButton);
            $A.util.addClass(paymentButton, 'addButton');
            alert('You must provide your payment details before you can submit your response. SafeDeposits Scotland will then make payment to you within 5 working days.');
            
        }
        else{
            //alert('DATA.');
            
            helper.submitCase(component, event, helper);
        }
        
    },
    
    dochangeover:function(component, event, helper) {
        //let depositamount = Number(component.get("v.depositDetails.Deposit__r.Deposit_Amount__c"));
        let depositamount = Number(component.get("v.depositDetails.Deposit__r.Protected_Amount__c"));
        let changeoverdetails = component.get("v.depositDetails.Tenencychangeoveramount__c");
        
        
        if(changeoverdetails >=depositamount){
            alert('You are unable to pay the tenant more than the deposit amount held by SafeDeposits Scotland.');
        }
        else if(changeoverdetails == '' || typeof changeoverdetails == 'undefined'){
            alert('You have to fill changeover amount.');
            
        }
            else{
                
                //    component.set("v.changeovertenants",false);
                component.set("v.firstOption",false);
                component.set("v.secondOption",true);
            }
    } ,
    onYes:function(component, event, helper) {
        
        
        component.set("v.bankOption",true);  
        component.set("v.secondOption",false);
        
    },
    onNo:function(component, event, helper) {
        component.set("v.bankOption",false);  
        component.set("v.secondOption",false);
        
        
    },
    onNo2:function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenantchangeoverrequest"
            },
            state: {
                id : depositId,
                bankDetails:true
            }
        });
        
    },
    onYes2:function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenantrepaymentrequest"
            },
            state: {
                depositId : depositId
                
            }
        });
    },
    
    onfirstYes:function(component, event, helper) {
        component.set("v.showSubmitButton",true);
       var accountId = component.get("v.currentUser.AccountId");
         let depositDetailslist = component.get('v.depositDetailslist');
         for(let i=0; i< depositDetailslist.length ; i++)
        {
            if(depositDetailslist[i].Deposit_Holder__c !=accountId && depositDetailslist[i].Istenantmoved__c==true )
            {
                depositDetailslist[i].Istenantmoved__c =false;
                depositDetailslist[i].Tenencychangeoveramount__c =0; 
              
            }
        }
        var firstyesclick = component.find("firstyes");
        var firstnoclick = component.find("firstno");
        $A.util.removeClass(firstnoclick, "clickButton");
        $A.util.addClass(firstyesclick, "clickButton"); 
        component.set("v.showsecondbuttons",false); 
        component.set("v.showanothertenant",false);
        component.set("v.firstyesselect",true);
        
    },
    
    onfirstNo :function(component, event, helper) {
        component.set("v.showSubmitButton",false);
        var firstyesclick = component.find("firstyes");
        var firstnoclick = component.find("firstno");
        $A.util.removeClass(firstyesclick, "clickButton");
        $A.util.addClass(firstnoclick, "clickButton");
        component.set("v.showsecondbuttons",true);  
        component.set("v.firstnoselect",true);
    },
    
    onsecondYes :function(component, event, helper) {
        component.set("v.showSubmitButton",false);
       var secondyesclick = component.find("secondyes");
        var secondnoclick = component.find("secondno"); 
        $A.util.removeClass(secondnoclick, "newclickButton");
        $A.util.addClass(secondyesclick, "newclickButton");
        
        component.set("v.showsecondbuttons",true);  
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenantrepaymentrequest"
            },
            state: {
                depositId : depositId
                
            }
        });
    },
    onsecondNo :function(component, event, helper) {
        component.set("v.showSubmitButton",true);
        var secondyesclick = component.find("secondyes");
        var secondnoclick = component.find("secondno"); 
        $A.util.removeClass(secondyesclick, "newclickButton");
        $A.util.addClass(secondnoclick, "newclickButton");
        component.set("v.showanothertenant",true);  
    },
    
    
    
    handleSelectedtenents: function(component, event, helper) {
        let depositDetailslist = component.get('v.depositDetailslist');
        let isChecked = event.target.checked;
        for(let i=0; i< depositDetailslist.length ; i++)
        {
            if(depositDetailslist[i].Deposit_Holder__c == event.target.value)
            {
                depositDetailslist[i].Istenantmoved__c = isChecked;
                if(!isChecked)
                {
                    depositDetailslist[i].Tenencychangeoveramount__c=0;
                }
            }
        }
        console.log('tenatId--216>>',JSON.stringify(depositDetailslist));
    },
    
    getsubmitdetails: function(component, event, helper) {
        
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var depositId = urlParams.get('id');
        var noBankDetails = component.get("v.noBankDetails");
       
      var isvalid = true;
      var yesselect =component.get('v.firstyesselect');
      var noselect =component.get('v.firstnoselect');
      //let depositamount = Number(component.get("v.depositDetails.Deposit__r.Deposit_Amount__c"));
      let depositamount = Number(component.get("v.depositDetails.Deposit__r.Deposit_Amount__c"));
        //alert(depositamount);
        let changeoverdetails = component.get('v.depositDetailslist');
        console.log(JSON.stringify(changeoverdetails));
     /*  if(yesselect ==false || noselect==false){
        alert('please select yes to proceed');
            isvalid =false;
        }*/
        let total = 0;
        let selectedTenantsRec=[] ;
        let selectedTenantsamount=[] ;        
        for(let i = 0; i <changeoverdetails.length; i++){
             if(changeoverdetails[i].Tenencychangeoveramount__c!=='' &&
               changeoverdetails[i].Tenencychangeoveramount__c!==null &&
               changeoverdetails[i].Tenencychangeoveramount__c!==undefined &&
               changeoverdetails[i].Istenantmoved__c==true)
            {
                total += parseFloat(changeoverdetails[i].Tenencychangeoveramount__c); 
                
            }
              if(changeoverdetails[i].Istenantmoved__c==true)
            {
              selectedTenantsRec.push(changeoverdetails[i]);  
            }
           // if((changeoverdetails[i].Tenencychangeoveramount__c ==''  ) &&
           //    changeoverdetails[i].Istenantmoved__c==true)
              if((parseInt(changeoverdetails[i].Tenencychangeoveramount__c)<0 || 
                  isNaN(changeoverdetails[i].Tenencychangeoveramount__c ||
                  changeoverdetails[i].Tenencychangeoveramount__c =='')&&
                 changeoverdetails[i].Istenantmoved__c==true))
             //  changeoverdetails[i].Tenencychangeoveramount__c ==null ||
             //  changeoverdetails[i].Tenencychangeoveramount__c==undefined 
              { 
                  component.set("v.invalidamounterror", true);
                  // alert('please enter valid amount for selected tenant');
                  isvalid =false;
              }
            else{
             component.set("v.invalidamounterror", false);   
            }
           
            
        }
        
        if(total >=depositamount){
            component.set("v.accessamounterror", true);
           // alert('You are unable to pay the tenant more than the deposit amount held by SafeDeposits Scotland.');
            isvalid =false;  
        }
        else
        {
         component.set("v.accessamounterror", false);    
        }     
        
        if(selectedTenantsRec.length >= changeoverdetails.length){
          component.set("v.showrepaymentmessage",true); 
            isvalid =false;
        }
        
        if(noBankDetails)
        {
            isvalid = false;
            component.set("v.noBankDetailsFoundError",true);
        } else {
            component.set("v.noBankDetailsFoundError",false);
        }
        
        if(isvalid){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        var action = component.get("c.updatedetailstenantchangeover");         
        action.setParams({
            depositId : depositId,
            AgentId :component.get("v.depositDetails.Deposit__r.Customer__c"),
            Depolist : JSON.stringify(component.get('v.depositDetailslist')),
          //  depositDetails : JSON.stringify(component.get("v.depositDetails"))
        });
        action.setCallback(this, function (a) {
            
            
            var state = a.getState();
            var errors = a.getError();
            //    alert('submit '+state);
            console.log('line--> 251 ' + JSON.stringify(state));
            console.log('line--> 252 ' + JSON.stringify(errors));
            var result = a.getReturnValue();            
            if (state == "SUCCESS" ) {
                //alert('Successfully initiated change over');  
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "depositsummarypage"
                    },
                    state: {
                        id : depositId
                    }
                });
            }
            else{
               // alert('Error '+result);  
            }
        });
        $A.enqueueAction(action);
        } 
    },   
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "invalidamount":
                component.set("v.invalidamounterror", false);
                break;
            case "accessamount":
                component.set("v.accessamounterror", false);
                break;
            case "bankSuccessMessage":
                component.set("v.bankSuccessMessage", false);
                break;
            case "bankErrorMessage":
                component.set("v.bankErrorMessage", false);
                break;
             case "nameOnAccountBlankError":
                component.set("v.nameOnAccountBlankError", false);
                break;
             case "accountNumberBlankError":
                component.set("v.accountNumberBlankError", false);
                break;
            case "invalidAccountNumberError":
                component.set("v.invalidAccountNumberError", false);
                break;
            case "sortCodeBlankError":
                component.set("v.sortCodeBlankError", false);
                break;
            case "bankOfAmericaSortCode":
                component.set("v.bankOfAmericaSortCode", false);
                break;
            case "invalidSortCodeError":
                component.set("v.invalidSortCodeError", false);
                break;
            case "intbankSuccess":
                component.set("v.intbankSuccessMessage", false);
                break;
            case "intbankname":
                component.set("v.intbanknameerror", false);
                break;
            case "intbankaccount":
                component.set("v.intbankaccounterror", false);
                break; 
        }
    },
    NumSplCharsCheck: function(component, event, helper){
        var keyCode = (event.which) ? event.which : event.keyCode;
        if(keyCode!= 32 && ((keyCode < 65 || keyCode > 90) && (keyCode < 97 || keyCode > 123))
          	&& (keyCode != 46 && keyCode > 31 && (keyCode < 48 || keyCode > 57))) {
            
            if (event.preventDefault) {
                event.preventDefault();
                
            } else {
                event.returnValue = false;
                
            } 
            
        }
       
    },
})