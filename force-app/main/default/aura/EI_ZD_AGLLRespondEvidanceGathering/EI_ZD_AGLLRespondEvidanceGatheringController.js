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
    
    goToCliamSummary : function(component, event, helper) {
        var divId = event.getSource().getLocalId();
        // Jump to first Item in claim catagories
        //component.set("v.currentItem",0);
        if(divId=='div0'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div1'){
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div2'){
            if(component.get("v.currentItem")==0){
                component.set("v.keyDocuments",true);
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",false);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConsentError",false);
                component.set("v.showKeyDocumentsError",false);
                component.set("v.showDisputeItemError",false);
            }else{
                component.set("v.currentItem",component.get("v.currentItem") - 1); 
                component.set("v.showConsentError",false);
                component.set("v.showKeyDocumentsError",false);
                component.set("v.showDisputeItemError",false);
            }
        }
        
        if(divId=='div3'){
            component.set("v.showClaimBreakdown",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        if(divId=='div4'){
            component.set("v.showAdditionalComments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        if(divId=='div5'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
            component.set("v.showConsentError",false);
            component.set("v.showKeyDocumentsError",false);
            component.set("v.showDisputeItemError",false);
        }
        
        //location.reload();
    },
    goToHomePage : function(component, event, helper) { 
        location.reload();
    },
    showContinue : function(component, event, helper) {        
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        // document.getElementById('scrollView121').scrollIntoView(true);
        
    },
    goToKeyDocuments : function(component, event, helper) {
        var sel ; 
        var isEditable = component.get("v.isEditable");
        component.set("v.consentBoxValue",sel);
        if(isEditable){
            sel = document.getElementById("exampleCheck2").checked;
        }
        else{
            sel=true;
            //  
        }
        if(sel)
        {
            component.set("v.ViewContinue",false);
            component.set("v.viewClaim",false);
            component.set("v.keyDocuments",true);
            component.set("v.showConsentError",false);
            document.getElementById('scrollView121').scrollIntoView(true);
            
        }
        else
        {
            component.set("v.showConsentError",true);
        }
        if(!isEditable){
            document.getElementById("TenantObligations").className = "disabled-link";     
        }
    },
    clickYes : function(component, event, helper) {  
        let selectRecordId = event.target.id;
        if(selectRecordId =='TenantObligations')
        {
            component.set("v.ClaimsDetails[0].Tenant_obligations__c",'Yes');
        }
        else if(selectRecordId =='inventorycheck')
        {
            component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'Yes');
        }
            else if(selectRecordId =='checkoutReport')
            {
                component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'Yes');
            }
                else if(selectRecordId =='rentStatement')
                {
                    component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'Yes');
                }
        
    },
    clickNo : function(component, event, helper) {  
        let selectRecordId = event.target.id;
        if(selectRecordId =='TenantObligations')
        {
            component.set("v.ClaimsDetails[0].Tenant_obligations__c",'No');
        }
        else if(selectRecordId =='inventorycheck')
        {
            component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'No');
        }
            else if(selectRecordId =='checkoutReport')
            {
                component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'No');
            }
                else if(selectRecordId =='rentStatement')
                {
                    component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'No');
                }
    },
    goToClaimBreakdown : function(component, event, helper) {
        
        var elements = document.getElementsByClassName("file_section");
        var elements1 = document.getElementsByClassName("custom_file");
        
        if (elements1.length == 0)
        {
            console.log('Line 233');
            var isEditable = component.get("v.isEditable");
            if(!isEditable){
                component.set("v.showClaimBreakdown",true);
                component.set("v.keyDocuments",false);
                component.set("v.showKeyDocumentsError",false);
                
                let index= component.get("v.currentItem");
                let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                window.scrollTo(0, 0);
                //document.getElementById('scrollView121').scrollIntoView(true);
                // just yo test 
                component.set("v.currentItem",0);
            }
            else{
                if( component.get("v.ClaimsDetails[0].Tenant_obligations__c") && component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") &&
                   component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") && ((component.get("v.isClaimForRent")) ? component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") : true))
                { 
                    let claimExceedsComment = component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c");
                    let flag  = true;
                    if (claimExceedsComment)
                    {
                        if(claimExceedsComment.length > 32768)
                        {
                            flag  = false;
                            alert('You have exceeded the character limit of 32768');
                        }
                        
                    }
                    if(flag)
                    {
                        var action = component.get("c.updatekeyDocuments");
                        action.setParams({
                            "caseRecID":component.get("v.ClaimsDetails[0].Id"),
                            "tenantObligation":component.get("v.ClaimsDetails[0].Tenant_obligations__c"),
                            "inventryChekReport":component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c"),
                            "checkOutReport":component.get("v.ClaimsDetails[0].check_out_report_AGLL__c"),
                            "rentStatement":component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c"),
                            "claimExceedsComment" : component.get("v.ClaimsDetails[0].Claim_exceeds_comment_AGLL__c")
                        });
                        action.setCallback(this, function(a) {
                            var state = a.getState();
                            var errors = a.getError();
                            if (state == "SUCCESS") {
                                
                                component.set("v.showClaimBreakdown",true);
                                component.set("v.keyDocuments",false);
                                component.set("v.showKeyDocumentsError",false);
                                
                                let index= component.get("v.currentItem");
                                let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                                component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                                document.getElementById('scrollView121').scrollIntoView(true);
                                // just yo test 
                                component.set("v.currentItem",0);
                                
                            }
                            else {
                                alert('An error has occured');
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }                   
                }
                else
                {
                    
                    console.log('Line 296');
                    component.set("v.showKeyDocumentsError",true);
                    component.set("v.keyDocuments",true);
                    component.set("v.showClaimBreakdown",false);
                    
                }
            }
        }else{
            alert("Without this document, your chances of success are significantly reduced. If you do not have the evidence to support a claim, you can opt to withdraw your claim by selecting 'Cancel Claim'.");
        }
        
    },
    goToNextItem : function(component, event, helper) {
        
        
        /* var elements = document.getElementsByClassName("file_section");
        var elements1 = document.getElementsByClassName("custom_file");
        
        if (elements.length > 1 || elements1.length == 0)
        {*/
        let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
        let index= component.get("v.currentItem");
        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let disputeItemsCatagories = Dispute_Item[index].Type__c;
        let validateItem = false;
        let validatelength = true;
        let Errormsg='';
        if(disputeItemsCatagories =='Cleaning')
        {
            validateItem = component.find('Cleaning').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true); 
            if(Dispute_Item[index].Claim_description_for_cleaning_agll__c &&
               Dispute_Item[index].Supporting_clause_cleaning_agll__c &&
               Dispute_Item[index].Evidence_at_tenancystart_cleaning_agll__c &&
               Dispute_Item[index].Evidence_at_tenancy_end_for_cleaning_agl__c &&
               Dispute_Item[index].Supporting_evidence_for_cleaning_agll__c)
            {
                if(Dispute_Item[index].Claim_description_for_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for Please describe your claim for cleaning section.';
                }
                if(Dispute_Item[index].Supporting_clause_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim for cleaning section.';
                }
                if(Dispute_Item[index].Evidence_at_tenancystart_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the property’s cleanliness at the start of the tenancy section.';
                }
                if(Dispute_Item[index].Evidence_at_tenancy_end_for_cleaning_agl__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the property’s cleanliness at the end of the tenancy section.';
                }
                if(Dispute_Item[index].Supporting_evidence_for_cleaning_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What evidence supports the value of the claim you are making section.';
                }
                
            }
            
        }
        else if (disputeItemsCatagories =='Damage')
        {
            validateItem = component.find('Damage').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            
            if(Dispute_Item[index].Claim_description_for_damage_agll__c &&
               Dispute_Item[index].Supporting_clause_damage_agll__c &&
               Dispute_Item[index].Evidence_at_tenancystart_damage_agll__c &&
               Dispute_Item[index].Evidence_at_tenancy_end_for_damage_agll__c &&
               Dispute_Item[index].Supporting_evidence_for_damage_agll__c)
            {
                if(Dispute_Item[index].Claim_description_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for Please describe your claim for damage section.';
                }
                if(Dispute_Item[index].Supporting_clause_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim for damage section.';
                }
                if(Dispute_Item[index].Evidence_at_tenancystart_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the property’s condition at the start of the tenancy section.';
                }
                if(Dispute_Item[index].Evidence_at_tenancy_end_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the property’s condition at the end of the tenancy section.';
                }
                if(Dispute_Item[index].Supporting_evidence_for_damage_agll__c.length > 2000)
                {
                    validatelength = false;
                    Errormsg='You have exceeded the character limit of 2000 for What evidence supports the value of the claim you are making section.';
                }
                
            }
        }
            else if(disputeItemsCatagories =='Redecoration')
            {
                validateItem = component.find('Redecoration').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                
                if(Dispute_Item[index].Claim_description_for_redecoration_agll__c &&
                   Dispute_Item[index].Supporting_clause_redecoration_agll__c &&
                   Dispute_Item[index].Evidence_at_tenancystart_redecoration_ag__c &&
                   Dispute_Item[index].Evidence_at_tenancyend_redecoration_agll__c &&
                   Dispute_Item[index].Supporting_evidence_for_redecoration_agl__c)
                {
                    if(Dispute_Item[index].Claim_description_for_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 for Please describe your claim for redecoration section.';
                    }
                    if(Dispute_Item[index].Supporting_clause_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim for redecoration section.';
                    }
                    if(Dispute_Item[index].Evidence_at_tenancystart_redecoration_ag__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the standard of decoration at the start of the tenancy section.';
                    }
                    if(Dispute_Item[index].Evidence_at_tenancyend_redecoration_agll__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the standard of decoration at the end of the tenancy section.';
                    }
                    if(Dispute_Item[index].Supporting_evidence_for_redecoration_agl__c.length > 2000)
                    {
                        validatelength = false;
                        Errormsg='You have exceeded the character limit of 2000 for What evidence supports the value of the claim you are making section.';
                    }
                    
                }
                
            }
                else if(disputeItemsCatagories =='Gardening')
                {
                    validateItem = component.find('Gardening').reduce(function (validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                        return validSoFar && inputCmp.get('v.validity').valid;
                    }, true);
                    
                    if(Dispute_Item[index].Claim_description_for_gardening_agll__c &&
                       Dispute_Item[index].Supporting_clause_gardening_agll__c &&
                       Dispute_Item[index].Evidence_at_tenancystart_gardening_agll__c &&
                       Dispute_Item[index].Evidence_at_tenancyend_gardening_agll__c &&
                       Dispute_Item[index].Supporting_evidence_for_gardening__c)
                    {
                        if(Dispute_Item[index].Claim_description_for_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 for Please describe your claim for gardening section.';
                        }
                        if(Dispute_Item[index].Supporting_clause_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim for gardening section.';
                        }
                        if(Dispute_Item[index].Evidence_at_tenancystart_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the garden’s condition at the start of the tenancy section.';
                        }
                        if(Dispute_Item[index].Evidence_at_tenancyend_gardening_agll__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 for What is your evidence of the garden’s condition at the end of the tenancy section.';
                        }
                        if(Dispute_Item[index].Supporting_evidence_for_gardening__c.length > 2000)
                        {
                            validatelength = false;
                            Errormsg='You have exceeded the character limit of 2000 for What evidence supports the value of the claim you are making section.';
                        }
                        
                    }
                }
                    else if(disputeItemsCatagories =='Rent')
                    {
                        validateItem = component.find('Rent').reduce(function (validSoFar, inputCmp) {
                            inputCmp.showHelpMessageIfInvalid();
                            return validSoFar && inputCmp.get('v.validity').valid;
                        }, true);
                        
                        if(Dispute_Item[index].Rent_arrears_description_agll__c &&
                           Dispute_Item[index].Was_the_property_re_let_rent_agll__c &&
                           Dispute_Item[index].Supporting_clause_rent_agll__c &&
                           Dispute_Item[index].Supporting_evidence_for_rent_agll__c)
                        {
                            if(Dispute_Item[index].Rent_arrears_description_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 for How much are the arrears and how did they arise section.';
                            }
                            if(Dispute_Item[index].Was_the_property_re_let_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 for Was the property re-let during the period being claimed for and if so, when section.';
                            }
                            if(Dispute_Item[index].Supporting_clause_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim for rent arrears section.';
                            }
                            if(Dispute_Item[index].Supporting_evidence_for_rent_agll__c.length > 2000)
                            {
                                validatelength = false;
                                Errormsg='You have exceeded the character limit of 2000 for What is your evidence of rent arrears section.';
                            }
                            
                        }
                        
                    }
                        else if(disputeItemsCatagories =='Other')
                        {
                            validateItem = component.find('Other').reduce(function (validSoFar, inputCmp) {
                                inputCmp.showHelpMessageIfInvalid();
                                return validSoFar && inputCmp.get('v.validity').valid;
                            }, true);
                            if(Dispute_Item[index].Claim_breakdown_other_AGLL__c &&
                               Dispute_Item[index].Supporting_clause_other_agll__c &&
                               Dispute_Item[index].Supporting_evidence_for_other_agll__c )
                            {
                                if(Dispute_Item[index].Claim_breakdown_other_AGLL__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 for Please provide a breakdown of your other claims section.';
                                }
                                if(Dispute_Item[index].Supporting_clause_other_agll__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 for What clause(s) in the tenancy agreement support your claim section.';
                                }
                                if(Dispute_Item[index].Supporting_evidence_for_other_agll__c.length > 2000)
                                {
                                    validatelength = false;
                                    Errormsg='You have exceeded the character limit of 2000 for How does this evidence support your claim section.';
                                }
                                
                            }
                        }
        
        
        if(Errormsg != '')
        {
            alert(Errormsg);
        }
        if(validateItem && validatelength)
        {
            component.set("v.showDisputeItemError",false);
            let CurrentItem = component.get("v.currentItem") +1;
            var action = component.get("c.updateClaimBreakdown");
            action.setParams({
                "disputeItemRec":JSON.stringify(component.get("v.ClaimsDetails[0].Dispute_Items__r"))
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    if(totalItem == CurrentItem)
                    {
                        component.set("v.showAdditionalComments",true);
                        component.set("v.showClaimBreakdown",false);
                        component.set("v.keyDocuments",false);
                        document.getElementById('scrollView121').scrollIntoView(true);
                    }
                    else
                    {
                        component.set("v.currentItem",(component.get("v.currentItem")+1));
                        let index= component.get("v.currentItem");
                        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                        document.getElementById('scrollView121').scrollIntoView(true);
                    }
                    
                }
                else {
                    alert('An error has occured');
                }
            });
            $A.enqueueAction(action); 
        }
        else
        {
            component.set("v.showDisputeItemError",true);
        }
        /* }else{
            alert("Please upload file before continue.");
        }*/
        
    },
    goToReviewsubmission : function(component, event, helper) {
        var action = component.get("c.updateAdditionalComments");
        let consentBoxValue ='';
        if(component.get("v.consentBoxValue"))
        {
            consentBoxValue='Yes'; 
        }
        else
        {
            consentBoxValue='No';
        }
        
        let addComment = component.get("v.ClaimsDetails[0].Additional_comments_AGLL__c");
        if(addComment.length < 2000)
        {
            action.setParams({
                "caseId":component.get("v.ClaimsDetails[0].Id"),
                "additionalComment":component.get("v.ClaimsDetails[0].Additional_comments_AGLL__c"),
                consentBoxValue : consentBoxValue
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    component.set("v.showAdditionalComments",false);
                    component.set("v.showDisputeItemError",false);
                    component.set("v.showReviewsubmission",true);
                    document.getElementById('scrollView121').scrollIntoView(true);
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
        
        
    },
    handleUploadFinished : function(component, event, helper)
    {
        let fileName = event.getSource().get("v.files")[0]['name'];
        var fileInput = component.find("fileId").get("v.files");
        
        var file = fileInput[0];
        
        
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var action = component.get("c.uploadDoc");
            action.setParams({
                "base64Data": encodeURIComponent(fileContents),
                "fileType":file.type
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    
                }
                else {
                    let errormessage = JSON.stringify(a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        });
        
        objFileReader.readAsDataURL(file);
        
        
    },
    refreshParentViewEvent :function(component, event, helper){
        //$A.get('e.force:refreshView').fire();
    },
    cancelClaim : function(component, event, helper) {
        component.set("v.showConfirmDialog",true);
    },
    CloseCancelPopup : function(component, event, helper) { 
        component.set("v.showConfirmDialog",false);
    },
    doCancelClaim : function(component, event, helper) {
        var action = component.get("c.UpdateClaimDetails");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType":"AGLL"
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                
                component.set("v.viewClaim",false);
                component.set("v.ViewContinue",false);
                component.set("v.keyDocuments",false);
                component.set("v.showClaimBreakdown",false);
                component.set("v.showAdditionalComments",false);
                component.set("v.showReviewsubmission",false);
                component.set("v.showConfirmDialog",false);
                component.set("v.showCancelDiv",true);
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
    
})