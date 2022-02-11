({
    doAgreeToClaim : function(component, event, helper) {
        var action = component.get("c.UpdateClaimDetails");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType": "TT",
            "amount":component.get("v.ClaimsDetails[0].Total_Agreed_by_AG_LL__c"),
            "scheme":'Zero Deposite',
            "claimExternalId":component.get("v.ClaimsDetails[0].External_ID__c")
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",false);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConfirmDiv",true);
                component.set("v.LeadTenantUrl",a.getReturnValue());
            }
            else
            {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info',
                    message: 'Something went wrong please Contact Administrator',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
        
    },
    makePayment: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.LeadTenantUrl") 
        });
        urlEvent.fire();
        
    },
    showContinue : function(component, event, helper) {        
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        //  document.getElementById('scrollView').scrollIntoView(true);
        
    },
    goToClaimBreakdown : function(component, event, helper) {
        
        
        if(!component.get("v.isLead")) 
        {
            component.set("v.ViewContinue",false);
            component.set("v.viewClaim",false);
            component.set("v.showConsentError",false);
            component.set("v.showClaimBreakdown",true);
            let index= component.get("v.currentItem");
            let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
            component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
            document.getElementById('scrollView').scrollIntoView(true);
            component.set("v.currentItem",0);
        }
        else{
            var sel = document.getElementById("exampleCheck2").checked; 
            if(sel)
            {
                var action = component.get("c.updateClaimTT");
                action.setParams({
                    "claimId":component.get("v.ClaimsDetails[0].Id"),
                    "consentBox":true
                    
                });
                action.setCallback(this, function(a) {
                    var state = a.getState();
                    var errors = a.getError();
                    if (state == "SUCCESS") {
                        component.set("v.ViewContinue",false);
                        component.set("v.viewClaim",false);
                        component.set("v.showConsentError",false);
                        component.set("v.showClaimBreakdown",true);
                        let index= component.get("v.currentItem");
                        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                        document.getElementById('scrollView').scrollIntoView(true);
                        component.set("v.currentItem",0);
                        
                    }
                    else {
                        alert('An error has occured');
                    }
                });
                $A.enqueueAction(action); 
                
                
            }
            else
            {
                component.set("v.showConsentError",true);
            }
        }
        
    },
    goToNextItem : function(component, event, helper) {
       
        /*var elements = document.getElementsByClassName("file_section");
        var elements1 = document.getElementsByClassName("custom_file");
        if (elements.length > 1 || elements1.length == 0)
        { */          
            
            let validInput = true;
            let index= component.get("v.currentItem");
            let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
            if((Dispute_Item[index].Is_Tenant_Agree__c=='No' && (!Dispute_Item[index].Tenant_Disagree_comment__c)) ||(!Dispute_Item[index].Is_Tenant_Agree__c) )
            {
                validInput= false;
            }
            if(Dispute_Item[index].Tenant_Disagree_comment__c)
            {
                
                if(Dispute_Item[index].Tenant_Disagree_comment__c.length > 2000)
                {
                    validInput= false;
                    alert('You have exceeded the character limit of 2000.');
                }
            }
        
            if(!Dispute_Item[index].Is_Tenant_Upload_Evidence__c)
            {
                validInput= false;
            }
            if(!component.get("v.isLead"))
            {
                validInput=true;            
            }
            
            if(validInput)
            {
                component.set("v.showDisputeItemError",false);
                if(!component.get("v.isLead")) {
                    let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
                    let CurrentItem = component.get("v.currentItem") +1;
                    document.getElementById('scrollView').scrollIntoView(true);
                    component.set("v.agentResponse",true);
                    if(totalItem == CurrentItem)
                    {
                        component.set("v.showAdditionalComments",true);
                        component.set("v.showClaimBreakdown",false);
                        component.set("v.viewClaim",false);
                    }
                    else
                    {
                        component.set("v.currentItem",(component.get("v.currentItem")+1));
                        let index= component.get("v.currentItem");
                        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                    } 
                    
                    
                }else{
                    
                    var action = component.get("c.updateClaimItemTT");
                    action.setParams({
                        "disputeItemRec":JSON.stringify(component.get("v.ClaimsDetails[0].Dispute_Items__r")),
                        "claimId": component.get("v.ClaimsDetails[0].Id"),
                        "isTenantRespond":component.get("v.ClaimsDetails[0].TT_respond_evidence_gathering__c")
                        
                    });
                    action.setCallback(this, function(a) {
                        var state = a.getState();
                        var errors = a.getError();
                        if (state == "SUCCESS") {
                            let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
                            let CurrentItem = component.get("v.currentItem") +1;
                            document.getElementById('scrollView').scrollIntoView(true);
                            component.set("v.agentResponse",true);
                            if(totalItem == CurrentItem)
                            {
                                component.set("v.showAdditionalComments",true);
                                component.set("v.showClaimBreakdown",false);
                                component.set("v.showDisputeItemError",false);
                                component.set("v.viewClaim",false);
                            }
                            else
                            {
                                component.set("v.currentItem",(component.get("v.currentItem")+1));
                                let index= component.get("v.currentItem");
                                let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                                component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                            } 
                            
                        }
                        else
                        {
                            alert('An error has occured');
                        }
                        
                    });
                    $A.enqueueAction(action); 
                }
            }
            else
            {
                component.set("v.showDisputeItemError",true);
            }
       /* }else{
            alert("Please upload file before continue.");
        }*/
    },
    goToTenantResponse: function(component, event, helper) {
        document.getElementById('scrollView').scrollIntoView(true);
        component.set("v.agentResponse",false);        
    },
    goToReviewsubmission : function(component, event, helper) {
        if(!component.get("v.isLead")) {
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",true);
            document.getElementById('scrollView').scrollIntoView(true);
        }else{
            let addComment = component.get("v.ClaimsDetails[0].Additional_comments_TT__c");
            if(addComment.length < 2000)
            {
                var action = component.get("c.updateAdditionalCommentsTT");
                action.setParams({
                    "caseId":component.get("v.ClaimsDetails[0].Id"),
                    "additionalComment":component.get("v.ClaimsDetails[0].Additional_comments_TT__c")
                });
                action.setCallback(this, function(a) {
                    var state = a.getState();
                    var errors = a.getError();
                    if (state == "SUCCESS") {
                        component.set("v.showAdditionalComments",false);
                        component.set("v.showReviewsubmission",true);
                        document.getElementById('scrollView').scrollIntoView(true);
                    }
                    else {
                        alert('An error has occured');
                    }
                });
                $A.enqueueAction(action);
                
            }
            else
            {
                alert('You have exceeded the character limit of 2000.');
            }
            
        }
    },
    goToCliamSummary : function(component, event, helper) {
        //location.reload();
        var divId = event.getSource().getLocalId();
        if(divId=='div0'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
        }
        
        if(divId=='div1'){
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
        }
        
        if(divId=='div2'){
            let agentresponce = component.get("v.agentResponse");
            if(component.get("v.currentItem")==0 && agentresponce){
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",true);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
            }else{
                if(agentresponce)
                {
                    component.set("v.agentResponse",false);
                    component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
                    component.set("v.currentItem",component.get("v.currentItem") - 1);
                }
                else
                {
                    component.set("v.agentResponse",true);
                    component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
                }
                
                
            }
        }
        
        if(divId=='div3'){
            component.set("v.showClaimBreakdown",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.agentResponse",false);
            component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
        }
        
        if(divId=='div4'){
            component.set("v.showAdditionalComments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
        }
        if(divId=='div5'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showDisputeItemError",false);
            component.set("v.showConsentError",false);
        }
    },
    clickYes : function(component, event, helper) {
        let selectRecordId = event.target.id;
        let selectBtnName = event.target.name;
        let disputeItemRec  = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        
        for(let i=0; i< disputeItemRec.length;i++)
        {
            if(selectRecordId ==disputeItemRec[i].Id)
            {
                if(selectBtnName =='IsTenantAgree')
                {
                    disputeItemRec[i].Is_Tenant_Agree__c= 'Yes';
                }
                else if (selectBtnName =='IsTenantUploadEvidence')
                {
                    disputeItemRec[i].Is_Tenant_Upload_Evidence__c= 'Yes';
                }
                
            }
        }
        component.set("v.ClaimsDetails[0].Dispute_Items__r",disputeItemRec);
        
        
    },
    clickNo : function(component, event, helper) { 
        let disputeItemRec  = component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let selectRecordId = event.target.id;
        let selectBtnName = event.target.name;
        for(let i=0; i< disputeItemRec.length;i++)
        {
            if(selectRecordId ==disputeItemRec[i].Id)
            {
                if(selectBtnName =='IsTenantAgree')
                {
                    disputeItemRec[i].Is_Tenant_Agree__c= 'No';
                }
                else if (selectBtnName =='IsTenantUploadEvidence')
                {
                    disputeItemRec[i].Is_Tenant_Upload_Evidence__c= 'No';
                }
                
            }
        }
        component.set("v.ClaimsDetails[0].Dispute_Items__r",disputeItemRec);
        
    },
    goToHomePage :function(component, event, helper)
    {
        location.reload();
    }
    
})