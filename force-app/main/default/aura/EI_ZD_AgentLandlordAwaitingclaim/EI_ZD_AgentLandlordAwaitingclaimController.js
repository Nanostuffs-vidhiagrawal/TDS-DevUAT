({
    doInit : function(component, event, helper) {
        
        let currentURL = window.location.href;
        let AccessCode = currentURL.split("id=")[1];
        var action = component.get("c.getClaimDetailsByAccessCode");
        action.setParams({
            "AccessCode": AccessCode
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.ClaimsDetails",a.getReturnValue());
                let disputOldRecMap = new Map();
                let caseItemRec =a.getReturnValue()[0].Dispute_Items__r;
                for(let i=0; i<caseItemRec.length;i++)
                {
                    var AmountObj = new Object();
                    AmountObj.Amount = caseItemRec[i].Agreed_by_AGLL__c;
                    AmountObj.Percentage = caseItemRec[i].Adjustment_Percentage_by_AGLL__c;
                    disputOldRecMap.set(caseItemRec[i].Id,AmountObj);
                    if(caseItemRec[i].Type__c=='Rent')
                    {
                        component.set("v.isClaimForRent",true);
                    }
                }
                component.set("v.disputOldRecMap",disputOldRecMap);
                if(component.get("v.ClaimsDetails[0].Status") =='Closed' || component.get("v.ClaimsDetails[0].Status") =='Invitation to view the claim'  )
                {
                    component.set("v.showContinueBtn",false);
                }
                else
                {
                    
                    component.set("v.showContinueBtn",true);
                }
                if(component.get("v.ClaimsDetails[0].Status") =='Evidence gathering agent/landlord')
                {
                    var appEvent = $A.get("e.c:EI_ZD_refreshParentView");
                    appEvent.setParams({"pageName" : "Submit evidence"}); 
                    appEvent.fire();
                }
                
                
                
            }
            else {
                let errormessage = JSON.stringify(a.getReturnValue());
                if (errormessage.includes("<br>")) {
                    errormessage = errormessage.replaceAll("<br>", " ");
                    component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message: errormessage,
                        closeCallback: function() {}
                    });
                }
            }
        });
        $A.enqueueAction(action);
        
    },
   doAgreeToClaim : function(component, event, helper) {
        var action = component.get("c.UpdateClaimDetails");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType": "TT"
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.viewClaim",false);
                component.set("v.showConfirmDiv",true);
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
    showContinue : function(component, event, helper) {        
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        document.getElementById('scrollView').scrollIntoView(true);
        
    },
    goToClaimBreakdown : function(component, event, helper) {
     
        
        if(!component.get("v.isLead")) 
        {
             component.set("v.ViewContinue",false);
                    component.set("v.viewClaim",false);
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
                    component.set("v.showClaimBreakdown",true);
                    let index= component.get("v.currentItem");
                    let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                    component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                    document.getElementById('scrollView').scrollIntoView(true);
                    component.set("v.currentItem",0);
                    
                }
                else {
                    alert('Something wrong happand');
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
        let validInput = true;
        let index= component.get("v.currentItem");
        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
      /*  if((Dispute_Item[index].Is_Tenant_Agree__c=='No' && (!Dispute_Item[index].Tenant_Disagree_comment__c)) ||(!Dispute_Item[index].Is_Tenant_Agree__c) )
        {
            validInput= false;
        }
        if(!Dispute_Item[index].Is_Tenant_Upload_Evidence__c)
        {
            validInput= false;
        }*/
        
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
                    alert('Something wrong happend');
                }
                
            });
            $A.enqueueAction(action); 
        }
        }
        else
        {
            component.set("v.showDisputeItemError",true);
        }
        
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
                alert('Something wrong happened');
            }
        });
        $A.enqueueAction(action);
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
            component.set("v.showConsentError",false);
            component.set("v.showDisputeItemError",false);
            
            
        }
        
        if(divId=='div1'){
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div2'){
            let agentresponce = component.get("v.agentResponse");
            if(component.get("v.currentItem")==0 && agentresponce){
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",true);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConsentError",false);
                component.set("v.showDisputeItemError",false);
            }else{
                if(agentresponce)
                {
                    component.set("v.agentResponse",false);
                    component.set("v.currentItem",component.get("v.currentItem") - 1);
                }
                else
                {
                    component.set("v.agentResponse",true);
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
            component.set("v.showConsentError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div4'){
            component.set("v.showAdditionalComments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showDisputeItemError",false);
        }
        if(divId=='div5'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showDisputeItemError",false);
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