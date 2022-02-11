({
    doneWaiting: function(component, event, helper) {
        setTimeout(function(){ 
            component.set("v.PageSpinner",false); 
        }, 800);
    },
    
    doInit : function(component, event, helper) {
        
        setTimeout(function(){ 
            console.log('22');
            component.set("v.PageSpinner",false);      
            helper.getcurrentUserJobRole(component, event, helper);
            
            
        }, 800);
        component.set("v.changeovercancelled", false);
        //   var currentURL = window.location.href;
        //  var depositId = currentURL.split("id=")[1];
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        
        
        console.log('depositId '+depositId);
        if(depositId){
            helper.handleLeadTenant(component, event, depositId);
        }
        console.log("depositId"+depositId);
        helper.getPendingInstallment(component,event,depositId);
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
                // console.log(JSON.stringify(result));
                // alert('@@ '+result[0].objdeposit.Case_Status__c);
                component.set("v.newDepositAmount" ,result[0].objdeposit.Deposit_Amount__c);
                component.set("v.depsumlist" , response.getReturnValue());
                
                
                if(result[2].objAR){
                    
                    component.set("v.adjudicatorreportlink",result[2].objAR.Webhook_Report_Link__c);
                }
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
            case "decreaseAmt":
                component.set("v.depositDecreased", false);
                break;
                
            case "successmsg":
                component.set("v.successDPC", false);
                break;
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
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositId = urlParams.get('id');
        
        console.log("depositId"+depositId);
        var action = component.get("c.cancelDepositTransfer");
        action.setParams({depositId : depositId});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            console.log("allValues"+allValues);
            if(allValues!=null && allValues=='canceldeposit'){
                component.set("v.depositTransferred", false);
                if(branchId != null){
                    component.find("navService").navigate({
                        type: "standard__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: {id: depositId,branchId: branchId}
                    });
                }	else{
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: {
                            id: depositId,
                            
                        }
                    });
                }
            }
        });        
        $A.enqueueAction(action);
    },
    
    doTransferProperty : function(component, event, helper) {
        //  alert('If you need to edit the deposit amount or the amount of tenants, they are unable to do this within this process but can make these changes before or after the transfer has taken place from within their account')
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositId = urlParams.get('id');
        if(branchId != null){
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "transferproperty"
                },
                state: {id: depositId,branchId: branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "transferproperty"
                },
                state: {id: depositId}
            });
        }
    },
    
    downloaDPCTemplate : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var depositDAN = component.get("v.depsumlist[0].objdeposit.Name");
        var customerName = component.get("v.depsumlist[0].objdeposit.Customer_Name__c");
        //  var customlbl ='https://thedisputeservice--uat--c.visualforce.com';
        //   var redirectURL = ''+customlbl+'/apex/DownloadDPC?id='+depositid;
        var redirectURL =   'https://eu11.springcm.com/atlas/doclauncher/OneClickDocGen?aid=21169&config=SDSDepositProtectionCertificateConfig&eos[0].Id='+depositid+'&eos[0].System=Salesforce&eos[0].Type=Deposit__c&eos[0].Name='+depositDAN+'&eos[0].ScmPath=/'+customerName+'/Deposits';
        
        var myChild= window.open(redirectURL);  
        
        
        console.log('out'); 
        setTimeout(function(){ 
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            component.set("v.successDPC",true);
            //  helper.getDPCHelper(component, event, helper);
            console.log('Test1');
            myChild.close();
            window.focus();
            
            
        }, 17000);
        
    },
    
    onDownload : function(component, event, helper) {
        helper.getDPCHelper(component, event, helper);
    },
    
    doTransferDeposit : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositId = urlParams.get('id');
        if(branchId != null){
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "transferdeposit"
                },
                state: {branchId: branchId,depositId: depositId}
            });
        }	else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "transferdeposit"
                },
                state: {depositId: depositId}
            });
        }
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
    
    confirmdeletedeposit : function(component, event, helper) {
        component.set('v.showConfirmDialog', true); 
    },
    
    deletedeposit : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
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
    },
    
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
        // var customlbl ='https://uat-tds.cs87.force.com/';
        //var customlbl ='https://thedisputeservice--uat--c.visualforce.com';
        // alert(customlbl);
        //let currentURL = window.location.origin;
        //let redirectURL = currentURL +'/apex/EI_Prescribeinformation?id=a0L26000003qcDh';
        // var redirectURL = ''+customlbl+'/apex/EI_Prescribeinformation?id='+depositid+'';
        var redirectURL = '/EI_PrescribedInformationNew?id='+depositid;
        window.open(redirectURL);
    },
    
    downloadBlankPI :  function(component, event, helper) {
        window.open("/servlet/servlet.FileDownload?file=0153H000000AVP1");
        setTimeout(function(){
            helper.deleteAttacRecord(component, event, helper);
        }, 1000);
    },
    
    downloadAdjreport : function(component, event, helper) {
        var redirectURL = component.get("v.adjudicatorreportlink");    
        window.open(redirectURL);     
    },
    
    doRepaymentRequestOfDeposit : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositId = urlParams.get('id');
        /*var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"requestrepaymentofdeposit?depositId="+depositId;
        window.location.replace(urlRedirect);
        return false;*/
        if(branchId != null){
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "requestrepaymentofdeposit"
                },
                state: {depositId : depositId,branchId: branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "requestrepaymentofdeposit"
                },
                state: {
                    depositId : depositId
                }
            });
        }
    },
    
    doRepaymentRequestOfDepositTenant : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositId = urlParams.get('id');
        /*var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"requestrepaymentofdeposit?depositId="+depositId;
        window.location.replace(urlRedirect);
        return false;*/
        if(branchId != null){
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {branchId: branchId,depositId : depositId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantrepaymentrequest"
                },
                state: {
                    depositId : depositId
                }
            });
        }
    },
    
    continuerepayment : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        if(branchId != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "repaymentjourneycontinue"
                },
                state: {
                    depositId : depositid,
                    leadTenant : component.get('v.isLeadTenant'),
                    branchId: branchId
                }
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "repaymentjourneycontinue"
                },
                state: {
                    depositId : depositid
                }
            });
        }
    },
    
    submitevidence : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        //alert(depositid);
        if(branchId != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "agllevidencegathering"
                },
                state: {
                    depositId : depositid,
                    branchId: branchId
                }
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "agllevidencegathering"
                },
                state: {
                    depositId : depositid
                }
            });
        }
    },
    
    submitevidenceTenant : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        // alert(depositid);
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenant-evidence-gathering"
            },
            state: {
                depositId : depositid,
                leadTenant : component.get('v.isLeadTenant')
            }
        });
    },
    
    viewEvidencesOnly : function(component, event, helper) {
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        // alert(depositid);
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "view-evidences"
            },
            state: {
                depositId : depositid,
                //leadTenant : component.get('v.isLeadTenant')
            }
        });
    },
    
    cancelclaim: function(component, event, helper) {
        //  debugger;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var state
        if(branchId != null){
            state = {
                depositId : depositid,
                branchId : branchId
            };
        }else{
            state = {
                depositId : depositid
            };
        }
        
        
        if(component.get("v.currentUser.Profile.Name") === "Tenant"){
            state.userType = "TT";
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "cancelclaim"
            },
            state: state
        });
    },
    
    dochangeover:function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        var profileName = component.get("v.currentUser.Profile.Name");
        //   alert('@@'+profileName);
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
            var state;
            if(branchId != null){
                state = {
                    id : depositid,
                    branchId : branchId
                };
            }else{
                state = {
                    id : depositid
                };
            }
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantchangeoverrequest"
                },
                state: state
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
    
    reviewChangeOver : function(component, event, helper) {
        //  var depositId = event.getSource().get("v.name");  
        var depositId = component.get("v.depsumlist[0].objdeposit.Id");
        if(typeof depositId != 'undefined'){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantchangeoverresponsebyagll"
                },
                state: {
                    id : depositId,
                    tchange : true
                }
            });
        }
    },
    
    editDeposit : function(component, event, helper) {
        
        component.set("v.hideDiv" ,false);
        component.set("v.showSavebtn" ,true);
        component.set("v.newDepositAmount" ,parseFloat(component.get("v.depsumlist[0].objdeposit.Deposit_Amount__c")));
        
        document.body.scrollTop = 1;
        document.documentElement.scrollTop = 1;
    },
    
    saveDeposit : function(component, event, helper) {
        
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
                                            var topUpVal = true;
                                 let topUpAmnt = parseFloat(newDepositAmount-heldAmount);
                        		
                      //  alert(topUpAmnt.toFixed(2));
                                    helper.topUpHelper(component, event, helper,depositId,topUpVal,topUpAmnt.toFixed(2));
                            
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
                                  //  var topUpVal = true;
                                  //  $A.get('e.force:refreshView').fire();
                                 //   helper.topUpHelper(component, event, helper,depositId,topUpVal);
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
                        
                      //  $A.enqueueAction(action2);
                        
                    }
                    else if(newDepositAmount < heldAmount){
                         component.set("v.depositDecreased", true);
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
    
    CancelDeposit : function(component, event, helper) {
          component.set("v.depositDecreased", false); 
            component.set("v.hideDiv" ,true);
            component.set("v.showSavebtn" ,false);
            component.set("v.ShowTenantRec" ,false);
            component.set("v.unknownerror", false);
            component.set("v.before30dayserror", false);
        
    },
    
    viewRepayRequestAgentLandlord : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var state;
        if(branchId != null){
            state = {
                repaymentrequest: component.get("v.repayIdAgentLandlord"),
                branchId : branchId
            };
        }else{
            state = {
                repaymentrequest: component.get("v.repayIdAgentLandlord")
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "repaymentrequestrecordsummary"
            },
            state: state
        });
    }, 
    
    RespondtoRequest : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var state;
        if(branchId != null){
            state = {
                depositId : depositId,
                branchId : branchId
            };
        }else{
            state = {
                depositId : depositId
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "respondtorequest"
            },
            state: state
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
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
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
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
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
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var state;
        if(branchId != null){
            state = {
                depositId : depositId,
                branchId : branchId
            };
        }else{
            state = {
                depositId : depositId
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenantresponsedetail"
            },
            state: state
        });
    },
    
    viewrepaymentofagll: function (component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var state;
        if(branchId != null){
            state = {
                depositId : depositId,
                branchId : branchId
            };
        }else{
            state = {
                depositId : depositId
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "repaymentviewagll"
            },
            state: state
        });
    },
    
    viewRepReqForJointTenant: function (component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        const depositId = urlParams.get('id');
        var state;
        if(branchId != null){
            state = {
                depositId : depositId,
                branchId : branchId
            };
        }else{
            state = {
                depositId : depositId
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "viewrepaymentrequestfortenants"
            },
            state: state
        });
    },
    
    transferToPay : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var state;
        if(branchId != null){
            state = {
                status: "registered",
                id: event.target.id,
                branchId : branchId
            };
        }else{
            state = {
                status: "registered",
                id: event.target.id
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "paydeposit"
            },
            state: state
        });
    },
    
    transferToPayTop : function(component, event, helper) {
        var depositId= event.currentTarget.id;
        var topUpVal = false;
        helper.topUpHelper(component, event, helper,depositId,topUpVal);
    },
    
    transferToChangePayment : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var state;
        if(branchId != null){
            state = {
                status: "awaiting",
                id: event.target.id,
                branchId : branchId
            };
        }else{
            state = {
                status: "awaiting",
                id: event.target.id
            };
        }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "paydeposit"
            },
            state: state
        });
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    }

    
})