({
    doInit : function(component, event, helper) {
        
        helper.getError(component, event, helper);        
        
        try{            
        	component.set("v.stepsSequence", helper.steps());
            
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.isEditable",true); 
            
            let depositid = helper.getUrlParams('depositId');
            let isLeadTenant = helper.getUrlParams('leadTenant');
            
            component.set("v.depositid" , depositid);
            component.set("v.isLead" , isLeadTenant == "true");

            var action = component.get("c.getViewOnlyTenantEvidences");
            action.setParams({
                depositid: depositid
            });
            action.setCallback(this, function(a) {
              //  debugger;
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    //alert("line 17" + JSON.stringify(a.getReturnValue()));
                    component.set("v.ClaimsDetails",a.getReturnValue());
                    console.log("line 17" + JSON.stringify(a.getReturnValue()));
                    
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
                    if(component.get("v.ClaimsDetails[0].Status") =='Closed' || component.get("v.ClaimsDetails[0].Status") =='Invitation to view the claim'  )
                    {
                        component.set("v.showContinueBtn",false);
                    }
                    else
                    {
                        component.set("v.showContinueBtn",true);
                    }
                    
                }
                else if (state === "ERROR") {
                    var errors = a.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }else {
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
            
        } catch(e) {
            
        }
        
        
    },
    
    claimBreakdown  : function(component, event, helper) {
        if(event.getParam("value") === true)
            component.set("v.currentItem", 0); // when landing on claim breakdown always start from 0
        
        
        //let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
        //component.set("v.currentClaimCatagories",Dispute_Item[0].Type__c);
        // implemented this logic specially for back button
    },
    
    doAgreeToClaim : function(component, event, helper) {
        let depositid = component.get("v.depositid");
   
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "cancelclaim"
            },
            state: {
                depositId : depositid,
                leadTenant : helper.getUrlParams('leadTenant'),
                userType : 'TT'
            }
        });
        
    },
    
    showContinue : function(component, event, helper) {        
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        document.getElementById('scrollView').scrollIntoView(true);
        
    },
    
    /*  goToClaimBreakdown : function(component, event, helper) {
        debugger;

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
            var sel1 = document.getElementById("exampleCheck2").checked; 
            var sel2 = document.getElementById("exampleCheck3").checked; 

            if(sel2){
                helper.redirectToDisclaimer(component, event, helper);
                return;
            }

            if(sel1 )
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
                        alert('Something wrong happened !!');
                    }
                });
                $A.enqueueAction(action); 
                
                
            }
            else
            {
                component.set("v.showConsentError",true);
            }
        }
        
       helper.shiftnext(component);
    },*/
    
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
            var sel1 = document.getElementById("exampleCheck2").checked; 
            var sel2 = document.getElementById("exampleCheck3").checked; 
            
            if(sel2){
                helper.redirectToDisclaimer(component, event, helper);
                return;
            }
            
            //  var sel = document.getElementById("exampleCheck2").checked; 
            if(sel1)
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
    
    consentSelected : function(component, event, helper) {
        try{
           // debugger;
            var currentCheck = event.target.checked;
            var currentCheckId = event.target.id;
            
            switch(currentCheckId) {
                case "exampleCheck3":
                    if(currentCheck){
                        document.getElementById("exampleCheck2").checked = false;
                    }
                break;
                case "exampleCheck2":
                    if(currentCheck){
                        document.getElementById("exampleCheck3").checked = false;
                    }
                    
                    component.set("v.consent", currentCheck);
                    break;
                default:
            }
        }catch(e){
            alert(e);
        }
        
    },
    
    goToNextItem : function(component, event, helper) {
      //  debugger;
        let validInput = true;
        let index= component.get("v.currentItem");
        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
        if((Dispute_Item[index].Is_Tenant_Agree__c=='No' && (!Dispute_Item[index].Tenant_Disagree_comment__c)) ||(!Dispute_Item[index].Is_Tenant_Agree__c) )
        {
            validInput= false;
        }
        if(!Dispute_Item[index].Is_Tenant_Upload_Evidence__c)
        {
            validInput= false;
        }
        let abcd = component.get("v.isLead");
        
        if(abcd)
        {
            component.set("v.showDisputeItemError",false);
            if(!component.get("v.isLead")) {
                let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
                let CurrentItem = component.get("v.currentItem") +1;
                document.getElementById('scrollView').scrollIntoView(true);
                component.set("v.agentResponse",true);
                if(totalItem == CurrentItem)
                {
                    try{
                        helper.shiftnext(component);
                        
                        component.set("v.showAdditionalComments",true);
                        component.set("v.showClaimBreakdown",false);
                        component.set("v.viewClaim",false);
                        
                    }catch(e){
                        alert(e);
                    }                   
                    
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
                            try{
                                helper.shiftnext(component);
                                
                                component.set("v.showAdditionalComments",true);
                                component.set("v.showClaimBreakdown",false);
                                component.set("v.viewClaim",false);
                                
                            }catch(e){
                                alert(e);
                            }                   
                            
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
            let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
            let CurrentItem = component.get("v.currentItem") +1;
            
            if(totalItem == CurrentItem)
                        {
                            try{
                               // helper.shiftnext(component);
                                
                                component.set("v.showAdditionalComments",true);
                                component.set("v.showClaimBreakdown",false);
                                component.set("v.viewClaim",false);
                                
                            }catch(e){
                                alert(e);
                            }                   
                            
                        }
                        else
                        {
                            component.set("v.currentItem",(component.get("v.currentItem")+1));
                            let index= component.get("v.currentItem");
                            let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                            component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                            component.set("v.agentResponse",true);
                        } 
            
           // component.set("v.showDisputeItemError",true);
        }
        
        
    },
    
    goToTenantResponse: function(component, event, helper) {
      //  debugger;
        document.getElementById('scrollView').scrollIntoView(true);
        let agentresponse =component.get("v.agentResponse");
        if (agentresponse)
        {
            component.set("v.agentResponse",false);
        }
        else
        {
            if(component.get("v.ClaimsDetails[0].TT_respond_evidence_gathering__c") == false && component.get("v.isLead") == false){
                // @goto
                component.set("v.agentResponse",false);
                var action = component.get("c.goToNextItem");
                action.setParams({
                    "component":component,
                    "event": event,
                    "helper":helper
                });
                $A.enqueueAction(action);
                
            }else{
                component.set("v.agentResponse",false);
            }
            
        }
        
        
        
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
        
		helper.shiftnext(component);
    },
    
    goTodepositsummary : function(component, event, helper) {
        let depositid = helper.getUrlParams('depositId');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositid,
            }
        });
    },
    
    /*  goToCliamSummary : function(component, event, helper) {
        // location.reload();
        helper.shiftPrev(component);
    },*/
    
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
        //  debugger;
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
        
        //  debugger;
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
    
    showevidencehelpfile:function(component, event, helper){
        window.open("https://thedisputeservice--uat--c.documentforce.com/servlet/servlet.FileDownload?file=0158E000001mDjN", '_blank');
    }
    
})