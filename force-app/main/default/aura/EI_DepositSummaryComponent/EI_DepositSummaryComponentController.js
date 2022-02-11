({
    doInit : function(component, event, helper) {
        component.set("v.changeovercancelled", false);
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        if(depositId){
            helper.handleLeadTenant(component, event, depositId);
        }
        console.log("depositId"+depositId);
        helper.getAgentLandlordRepayRequest(component,event,depositId);
        helper.getTenantRepayRequest(component,event,depositId);
        console.log("Line 8");
        var action = component.get("c.getDepositDetails");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                console.log(JSON.stringify(result));
                // alert('@@ '+result[0].objdeposit.Case_Status__c);
                component.set("v.newDepositAmount" ,result[0].objdeposit.Deposit_Amount__c);
                component.set("v.depsumlist" , response.getReturnValue());
                if(result[0].objdeposit.Deposit_Transferred__c && result[0].objdeposit.Status__c=="Deposits held by scheme" ){
                    component.set("v.depositTransferred" ,true);
                }

                if(result[0].objdeposit.Status__c=="Awaiting payment" ||result[0].objdeposit.Status__c=="Deposits held by scheme")
                {
                    component.set("v.hidebutton" ,false);
                    component.set("v.showAddNewTenantButton", true);
                }
                else{
                    component.set("v.hidebutton" ,true);
                    component.set("v.showAddNewTenantButton", false);
                }
                var counter = result[0].objdeposit.Repayment_Requests__r.length;
                if(counter>0 && result[0].objdeposit.Status__c==="Repayment requested by tenant"){
                    component.set("v.IsDisabled", false);
                }
            }
            else if (state === "INCOMPLETE") {
             //   alert('line 15');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
	console.log("line 51");
    console.log("depositId:", depositId);
    var action2 = component.get("c.checkRepaymentRequested");
        console.log("line 54");
    action2.setParams({ depositId: depositId });
         console.log("line 56");
    action2.setCallback(this, function (response) {
         console.log("line 58");
      var state2 = response.getState();
         console.log("line 60");
      console.log("state2:", state2);
      if (state2 === "SUCCESS") {
        var result2 = response.getReturnValue();
        if (result2 == true) {
          component.set("v.showTenantRespondBtn", true);
        } else if (result2 == false) {
          component.set("v.showTenantRespondBtn", false);
        } else {
          component.set("v.showTenantRespondBtn", false);
        }
        // Code when Success
        console.log("result:", result2);
      } else if (state2 === "ERROR") {
        var errors2 = response.getError();
        if (errors2) {
          if (errors2[0] && errors2[0].message) {
            console.log("result2:", result2);
            console.log("Error2 message: " + errors2[0].message);
          }
        } else {
          console.log("Unknown error2");
        }
      }
    });
        $A.enqueueAction(action2);
        $A.enqueueAction(action);
        
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "depositTransfer":
                component.set("v.depositTransferred", false);
                break;
                case "changeovercancel":
                component.set("v.changeovercancelled", false);
                break;
            case "notenant":
                component.set("v.notenanterror", false);
                break;
            case "noamount":
                component.set("v.noamounterror", false);
                break;
             case "unknown":
                component.set("v.unknownerror", false);
                break;
                case "before30days":
                component.set("v.before30dayserror", false);
                break;
                case "depositupdated":
                component.set("v.depositupdatedsuccessmsg", false);
                break;
                case "bankdetailstenent":
                component.set("v.bankdetailssuccessmsg", false);
                break;
                
        }
    },
    
    cancelDeposit: function(component, event) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        console.log("depositId"+depositId);
        var action = component.get("c.cancelDepositTransfer");
        action.setParams({depositId : depositId});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            console.log("allValues"+allValues);
            if(allValues!=null && allValues=='canceldeposit'){
                component.set("v.depositTransferred", false);
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "depositsummarypage"
                    },
                    state: {
                        id: depositId
                    }
                });
            }
        });        
        $A.enqueueAction(action);
    },
    
    doTransferProperty : function(component, event, helper) {
      //  alert('If you need to edit the deposit amount or the amount of tenants, they are unable to do this within this process but can make these changes before or after the transfer has taken place from within their account')
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "transferproperty"
            },
            state: {id: depositId}
        });
    },
    
    downloaDPCTemplate : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var customlbl ='https://thedisputeservice--uat--c.visualforce.com';
        var redirectURL = ''+customlbl+'/apex/DownloadDPC?id='+depositid;
        window.open(redirectURL);	
    },
    
    doTransferDeposit : function(component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "transferdeposit"
            },
            state: {depositId: depositId}
        });
    },
    
    deleteLandlord : function(component, event, helper) {
        var landlordid = event.getSource().get("v.value"); 
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        // alert(landlordid);   
        var action = component.get("c.deletelandlord");
        action.setParams({ 
            landlordid :landlordid,
            depositdelid  :depositid                    
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // alert('171');
                console.log('check value' + JSON.stringify(response.getReturnValue()));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Landlord has been deleted successfully."
                });
                toastEvent.fire();
                window.location.reload();
            }
            else if (state === "INCOMPLETE") {
               // alert('180');
                
            }
                else if (state === "ERROR") {
                    // alert('184');
                    var errors = response.getError();
                    if (errors) {
                      //   alert('187');
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
        });
        
        $A.enqueueAction(action);    
    },
    
    deletedeposit : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        // alert(depositid);
        var action = component.get("c.changedepositstatus");
        action.setParams({ 
            depositid:depositid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('check value' + JSON.stringify(response.getReturnValue()));
                window.location.reload();
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
        });
        
        $A.enqueueAction(action);    
    },
    
    viewedittenant: function(component, event, helper) {
        var clickedBtn = event.getSource().get("v.value");
        // alert(clickedBtn);
        $A.createComponent("c:EI_TenentDetails",
                           {'strRecordId'  : clickedBtn},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Tenant details",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       
                                   })
                               }
                           });
    } 
    ,
    addlandlord: function(component, event, helper) {
        var propertyid = component.get("v.depsumlist[0].objdeposit.Property__c");
        
        $A.createComponent("c:EI_addLandlord",
                           {
                               propertyid:propertyid   
                           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib1').showCustomModal({
                                       header: "New landlord",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       
                                   })
                               }
                           });
    },
    
    vieweditlandlord: function(component, event, helper) {
        var landlordid = event.getSource().get("v.value");
        // alert(clickedBtn);
        $A.createComponent("c:EI_LandlordDetails",
                           {'strRecordId'  : landlordid},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib2').showCustomModal({
                                       header: "Landlord details",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       
                                   })
                               }
                           });
    } ,
    
    downloadpitemplate : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var customlbl ='https://thedisputeservice--staging--c.visualforce.com';
        // alert(customlbl);
        //let currentURL = window.location.origin;
        //let redirectURL = currentURL +'/apex/EI_Prescribeinformation?id=a0L26000003qcDh';
        var redirectURL = ''+customlbl+'/apex/EI_Prescribeinformation?id='+depositid+'';
        window.open(redirectURL);	
    },
    
    doRepaymentRequestOfDeposit : function(component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        /*var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"requestrepaymentofdeposit?depositId="+depositId;
        window.location.replace(urlRedirect);
        return false;*/
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "requestrepaymentofdeposit"
            },
            state: {
                depositId : depositId
            }
        });
    },
    
    doRepaymentRequestOfDepositTenant : function(component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        /*var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"requestrepaymentofdeposit?depositId="+depositId;
        window.location.replace(urlRedirect);
        return false;*/
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
    
    continuerepayment : function(component, event, helper) {
       var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "repaymentjourneycontinue"
            },
            state: {
              depositId : depositid,
              leadTenant : component.get('v.isLeadTenant')
            }
        });
    },
    
    
    dochangeover:function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var profileName = component.get("v.currentUser.Profile.Name");
        //  alert('@@'+profileName);
        if(profileName == 'Tenant'){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "changeover"
                },
                state: {
                    id : depositid
                }
            });
        }else{
            
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantchangeoverrequest"
                },
                state: {
                    id : depositid
                }
            });            
        }
        
        
        
        
        /*    var address = "/tenantchangeoverrequest";
        var domain = window.location.origin;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            url: address + "?id=" + depositid
        });
        urlEvent.fire();    */
        
    },
    
    CancelTenantChangeover : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var action = component.get("c.tenancychangeovercancel");
        action.setParams({
            depositid:depositid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('check value' + JSON.stringify(response.getReturnValue()));
                  component.set("v.changeovercancelled", true);
                $A.get('e.force:refreshView').fire();
             /*   var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Tenancy Changeover Request cancelled."
                });
                toastEvent.fire();              
                window.location.reload();*/
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
        });
        $A.enqueueAction(action);     
    },
    editDeposit : function(component, event, helper) {
        component.set("v.hideDiv" ,false);
        component.set("v.showSavebtn" ,true);
    },
    saveDeposit  : function(component, event, helper) {
        let depositId = component.get("v.depsumlist[0].objdeposit.Id");
        let oldDepositAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Deposit_Amount__c"));
        let newDepositAmount = parseFloat(component.get("v.newDepositAmount"));
       // let heldAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Amount_of_Deposit_Protected_by_TDS__c"));
        let heldAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Protected_Amount__c"));
        let selectedTenant = component.get("v.selectedTenant");
        let startDateDeposit = component.get("v.depsumlist[0].objdeposit.Date_Deposit_Received__c");
        
        
        if(newDepositAmount =='')
        {
            component.set("v.noamounterror" , true);
        }
        else
        { 
            if(oldDepositAmount != newDepositAmount )
            {
                if(newDepositAmount == heldAmount)
                {
                    let action1 = component.get("c.saveEqualDepositApx");
                    action1.setParams({ 
                        depositId:depositId,
                        oldDepositAmount: oldDepositAmount,
                        newDepositAmount: newDepositAmount,
                        heldAmount :heldAmount
                    });
                    
                    action1.setCallback(this, function(response) {
                        let state = response.getState();
                        if (state === "SUCCESS") {
                            if(response.getReturnValue() =='successfully Updated')
                            {
                                component.set("v.depositupdatedsuccessmsg", true);
                               /* var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Success',
                                    message: 'Record Updated Successfully',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'success',
                                    mode: 'pester'
                                });
                                toastEvent.fire();*/
                                component.set("v.hideDiv" ,true);
                                component.set("v.showSavebtn" ,false);
                                component.set("v.ShowTenantRec" ,false);
                                $A.get('e.force:refreshView').fire();
                            }
                        }
                        else
                        {
                             component.set("v.unknownerror", true);
                       /*    let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:'There is an error Please contact Adminstrator',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire(); */
                        }
                    });
                    
                    $A.enqueueAction(action1);
                    
                }
                else
                {
                    if(newDepositAmount > heldAmount)
                    {
                        let action2 = component.get("c.saveGraterAmountDepositApx");
                        action2.setParams({ 
                            depositId:depositId,
                            oldDepositAmount: oldDepositAmount,
                            newDepositAmount: newDepositAmount,
                            heldAmount :heldAmount
                        });
                        
                        action2.setCallback(this, function(response) {
                            
                            let state = response.getState();
                            console.log('-->>'+state);
                            console.log('-->>'+response.getReturnValue());
                            if (state === "SUCCESS") {
                                if(response.getReturnValue() =='successfully Updated')
                                {
                                    component.set("v.depositupdatedsuccessmsg", true);
                                  /*  var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Success',
                                        message: 'Record Updated Successfully and the remaing part will be picked once Findoc available',
                                        duration:' 5000',
                                        key: 'info_alt',
                                        type: 'success',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();*/
                                    component.set("v.hideDiv" ,true);
                                    component.set("v.showSavebtn" ,false);
                                    component.set("v.ShowTenantRec" ,false);
                                    $A.get('e.force:refreshView').fire();
                                }
                            }
                            else
                            {
                                component.set("v.unknownerror", true);
                               /* let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message:'There is an error Please contact Adminstrator',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();*/
                            }
                        });
                        
                        $A.enqueueAction(action2);
                        
                    }
                    else
                    {
					//	let depositReceiveDate  = component.get("v.depsumlist[0].objdeposit.Date_Deposit_Received__c");
                    let depositReceiveDate  = component.get("v.depsumlist[0].objdeposit.WD_Date_Deposit_Received__c");    
                        var browserDate = new Date(depositReceiveDate);
                     //   browserDate.setDate(browserDate.getDate() + 30);
                        var today = new Date(); 
                        if(browserDate.getTime() < today.getTime())
                        {
                            //alert(`495`);
                            if(selectedTenant.length < 1)
                            {
                               component.set("v.notenanterror",true);
                            }
                            else
                            {
                                let action3 = component.get("c.saveLessAmountDepositApx");
                                action3.setParams({ 
                                    depositId:depositId,
                                    DAN : component.get("v.depsumlist[0].objdeposit.Name"),
                                    oldDepositAmount: oldDepositAmount,
                                    newDepositAmount: newDepositAmount,
                                    heldAmount :heldAmount,
                                    tenantDetails :selectedTenant,
                                    startDateDeposit : startDateDeposit
                                });
                                
                                action3.setCallback(this, function(response) {
                                    let state = response.getState();
                                    if (state === "SUCCESS") {
                                        if(response.getReturnValue() =='successfully Updated')
                                        {
                                           // component.set("v.unknownerror", true);
                                            component.set("v.depositupdatedsuccessmsg", true);
                                          /*  var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title : 'Success',
                                                message: 'Record Updated Successfully',
                                                duration:' 5000',
                                                key: 'info_alt',
                                                type: 'success',
                                                mode: 'pester'
                                            });
                                            toastEvent.fire();*/
                                            component.set("v.hideDiv" ,true);
                                            component.set("v.showSavebtn" ,false);
                                            component.set("v.ShowTenantRec" ,false);
                                            $A.get('e.force:refreshView').fire();
                                            
                                        }
                                        else 
                                        {
                                            if(response.getReturnValue() =='Bank Details Missing')
                                            {
                                                component.set("v.bankdetailssuccessmsg", true);
                                             /*   var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Success',
                                                    message: 'Record Updated Successfully and send email to selected tenant to update Bank Details',
                                                    duration:' 5000',
                                                    key: 'info_alt',
                                                    type: 'success',
                                                    mode: 'pester'
                                                });
                                                toastEvent.fire();*/
                                                component.set("v.hideDiv" ,true);
                                                component.set("v.showSavebtn" ,false);
                                                component.set("v.ShowTenantRec" ,false);
                                                $A.get('e.force:refreshView').fire();
                                            }
                                            else
                                            {
                                                component.set("v.unknownerror", true);
                                             /*   let toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Error',
                                                    message:'There is an error Please contact Adminstrator',
                                                    duration:' 5000',
                                                    key: 'info_alt',
                                                    type: 'error',
                                                    mode: 'pester'
                                                });
                                                toastEvent.fire(); */
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                });
                                $A.enqueueAction(action3);
                                
                            }
                        }
                        else
                        {
                            component.set("v.before30dayserror", true);
                           // alert('Deposit has not been held for more than 30 days And this need to be picked in NPP-220');
                        }
                        
                    }
                }
                
                
            }
            else
            {
                component.set("v.hideDiv" ,true);
                component.set("v.showSavebtn" ,false);
                component.set("v.ShowTenantRec" ,false);
            }
            
        }  
    },
    CancelDeposit  : function(component, event, helper) {
            component.set("v.hideDiv" ,true);
            component.set("v.showSavebtn" ,false);
            component.set("v.ShowTenantRec" ,false);
            component.set("v.unknownerror", false);
            component.set("v.before30dayserror", false);
        
    },
    
    viewRepayRequestAgentLandlord : function(component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "repaymentrequestrecordsummary"
            },
            state: {
                repaymentrequest: component.get("v.repayIdAgentLandlord")
            }
        });
    }, 
    
    RespondtoRequest : function(component, event, helper) {
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "respondtorequest"
            },
            state: {
                depositId: depositId
            }
        });
    }, 
    handleNewAmount : function(component, event, helper) {
        let oldDepositAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Deposit_Amount__c"));
        let newDepositAmount = parseFloat(component.get("v.newDepositAmount"));
      //  let heldAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Amount_of_Deposit_Protected_by_TDS__c"));
         let heldAmount = parseFloat(component.get("v.depsumlist[0].objdeposit.Protected_Amount__c"));
        
        
        if(oldDepositAmount == newDepositAmount  )
        {
            component.set("v.disabledSaveBtn",true);
        }
        else
        {
            if(newDepositAmount < heldAmount)
            {
             //  alert('check');
                var cmpTarget = component.find("searchField1");
                $A.util.addClass(cmpTarget, "changeMe1");
                component.set("v.ShowTenantRec",true);
            }
            else
            {
                component.set("v.ShowTenantRec",false); 
            }
            component.set("v.disabledSaveBtn",false);
        }
        
    },
    searchKeyChange: function (component, event, helper) {
        let searchField = component.find("searchField1").get("v.value");
        let currentURL = window.location.href;
        let depositId = currentURL.split("id=")[1];
        let action = component.get("c.getTenant");
        action.setParams({
            searchField: searchField,
            depositId:depositId        
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state == "SUCCESS") {
                component.set("v.tenantDetails", a.getReturnValue());
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    SelectTenant : function (component, event, helper) {
        let selectRecord = event.target.id;
        let tenantDetails = component.get("v.tenantDetails");
        let selectedrec = [];
        let selectedTenant = component.get("v.selectedTenant");
        for (let i = 0; i < tenantDetails.length; i++) {
            if (tenantDetails[i].Id == selectRecord) {
                selectedrec.push(tenantDetails[i]);
            }
        }
        component.set("v.tenantDetails", "");
        component.set("v.selectedTenant", selectedrec);
    },
    
    handleAddMoreTenants: function (component, event, helper) {
        var modalBody;
        var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
        $A.createComponent(
            "c:EI_addMoreTenants",
            {
                depositId: depositId
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("overlayLib").showCustomModal({
                        header: "Additional Tenant Form",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function () {
                            //  alert('You closed the alert!');
                        }
                    });
                }
            }
        );
    },
    
    moveToRepaymentPage: function (component, event, helper) {
    var currentURL = window.location.href;
        var depositId = currentURL.split("id=")[1];
    component.find("navService").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "tenantresponsedetail"
      },
      state: {
        depositId: depositId
      }
    });
  }
})