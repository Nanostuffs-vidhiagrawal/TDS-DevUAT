({
    doInit : function(component, event, helper) {
        
        helper.getError(component, event, helper);
        component.set("v.ViewContinue",true);
        component.set("v.viewClaim",false);
        component.set("v.isEditable",true); 
        // document.getElementById('scrollView').scrollIntoView(true);
        
        let currentURL = window.location.href;
        let depositid = currentURL.split("depositId=")[1];
        component.set("v.depositid" , depositid);
        var action = component.get("c.getclaimdetailsforevidence");
        action.setParams({
            depositid: depositid
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                //  alert("line 17" + JSON.stringify(a.getReturnValue()));
                component.set("v.ClaimsDetails",a.getReturnValue());
                //  console.log('line--> 21')
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
                //  component.set("v.disputOldRecMap",disputOldRecMap);
                if(component.get("v.ClaimsDetails[0].Status") =='Closed' || component.get("v.ClaimsDetails[0].Status") =='Invitation to view the claim'  )
                {
                    component.set("v.showContinueBtn",false);
                }
                else
                {
                    
                    component.set("v.showContinueBtn",true);
                }
                if(component.get("v.ClaimsDetails[0].Consent_box_AGLL__c") =='Yes'){
                    component.set("v.consent",true);
                }
                else{
                    component.set("v.consent",false);   
                }
               
                if((component.get("v.ClaimsDetails[0].Total_Claimed_by_Landlord__c")) >= (component.get("v.ClaimsDetails[0].Deposit_Protected_Amount__c"))){
                    component.set("v.Isclaimamountexceed",true);
                }
                else{
                    component.set("v.Isclaimamountexceed",false);   
                }
                /*    if(component.get("v.ClaimsDetails[0].Status") =='Evidence gathering AG/LL')
                {
                    var appEvent = $A.get("e.c:EI_ZD_refreshParentView");
                    appEvent.setParams({"pageName" : "Submit evidence"}); 
                    appEvent.fire();
                }*/
                
                
                
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
    
    cancelClaim : function(component, event, helper) {
        
        let depositid = component.get("v.depositid");
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "cancelclaim"
            },
            state: {
                depositId : depositid
            }
        });
        
        //  component.set("v.viewClaim",false);
        //  component.set("v.showCancelDiv",true);
        
        
        /*   var action = component.get("c.UpdateClaimDetails");
        action.setParams({
            "claimId": component.get("v.ClaimsDetails[0].Id"),
            "customerType":"AGLL"
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();
            if (state == "SUCCESS") {
                
                component.set("v.viewClaim",false);
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
     */   
   },
    
   /* goToCliamSummary : function(component, event, helper) {
        component.set("v.documentsskipError",false); 
        var divId = event.getSource().getLocalId();
        // Jump to first Item in claim catagories
        component.set("v.currentItem",0);
        if(divId=='div0'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
        }
        
        if(divId=='div1'){
            component.set("v.ViewContinue",true);
            component.set("v.viewClaim",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
        }
        
        if(divId=='div2'){
            component.set("v.keyDocuments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
        }
        
        if(divId=='div3'){
            component.set("v.showClaimBreakdown",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
        }
        
        if(divId=='div4'){
            component.set("v.showAdditionalComments",true);
            component.set("v.viewClaim",false);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showReviewsubmission",false);
        }
        if(divId=='div5'){
            component.set("v.viewClaim",true);
            component.set("v.ViewContinue",false);
            component.set("v.keyDocuments",false);
            component.set("v.showClaimBreakdown",false);
            component.set("v.showAdditionalComments",false);
            component.set("v.showReviewsubmission",false);
        }
        
        //location.reload();
    },
   */ 
    
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
        document.getElementById('scrollView').scrollIntoView(true);
        
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
            //  alert(component.get("v.ClaimsDetails[0].Id"));
            var action = component.get("c.updateClaimAGLL");
            action.setParams({
                "claimId":component.get("v.ClaimsDetails[0].Id"),
                "consentBox":true
                
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    
                    component.set("v.consent",true);
                    component.set("v.ViewContinue",false);
                    component.set("v.viewClaim",false);
                    component.set("v.keyDocuments",true);
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
         else if(selectRecordId =='Exceedclaim')
        {
            component.set("v.ClaimsDetails[0].Claim_exceed__c",'Yes');
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
        else if(selectRecordId =='Exceedclaim')
        {
            component.set("v.ClaimsDetails[0].Claim_exceed__c",'No');
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
       // debugger;
        var isvalid = true;
        var lengthOfCheckList = 0;
        var lengthOfEvidAtt = 0;
        //component.set("v.documentsskipError",false);
        var checklist = component.get("v.ClaimsDetails[0].Evidence_Attachments__r");
        
        //if(!checklist) {
            console.log('275 '+checklist);
            if( component.get("v.ClaimsDetails[0].Tenant_obligations__c") =='Yes'){
                lengthOfCheckList++;
                isvalid=false;
            }
            if(component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") =='Yes'){
                lengthOfCheckList++;
                isvalid=false;
            }
            if(component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") =='Yes'){
                lengthOfCheckList++;
                isvalid=false;
            }
            if(component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") =='Yes'){
                lengthOfCheckList++;
                isvalid=false;
            }
        //}
        
        if(checklist) {
			
			if(component.get("v.ClaimsDetails[0].Tenant_obligations__c") =='Yes') {
                for(let i=0; i< checklist.length; i++) {
                    if(checklist[i].Evidence_Categories__c == 'Tenant obligations')
                    {
                        lengthOfEvidAtt++;
                        break;
                        //isvalid=false;
                    }
                }
            }
            if(component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") =='Yes'){
                for(let i=0; i< checklist.length; i++) {
                    if(checklist[i].Evidence_Categories__c == 'Inventorycheck in report')
                    {
                        lengthOfEvidAtt++;
                        break;
                        //isvalid=false;
                    }
                }
            }
            if(component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") =='Yes'){
                for(let i=0; i< checklist.length; i++) {
                    if(checklist[i].Evidence_Categories__c == 'Check out report')
                    {
                        lengthOfEvidAtt++;
                        break;
                        //isvalid=false;
                    }
                }
            }
            if(component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") =='Yes'){
                for(let i=0; i< checklist.length; i++) {
                    if(checklist[i].Evidence_Categories__c == 'Rent statement')
                    {
                        lengthOfEvidAtt++;
                        break;
                        //isvalid=false;
                    }
                }
            }
            
            /*for(let i=0; i< checklist.length; i++) {
                console.log(checklist[i].Evidence_Categories__c);
                if(component.get("v.ClaimsDetails[0].Tenant_obligations__c") =='Yes' && checklist[i].Evidence_Categories__c =='Tenant obligations')
                {
                    console.log('line-->267',checklist[i].Evidence_Categories__c);
                    count++;
                    isvalid=false;
                }   
                
                if(component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") =='Yes' && checklist[i].Evidence_Categories__c =='Inventorycheck in report')
                {
                    console.log('line-->272',checklist[i].Evidence_Categories__c);
                    count++;
                    isvalid=false;
                }
                
                if(component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") =='Yes' && checklist[i].Evidence_Categories__c =='Check out report')
                {
                    console.log('line-->279' ,checklist[i].Evidence_Categories__c);
                    count++;
                    isvalid=false;
                }
                
                if(component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") =='Yes' && checklist[i].Evidence_Categories__c =='Rent statement')
                {   
                    console.log('line-->285' + checklist[i].Evidence_Categories__c);
                    count++;
                    isvalid=false;
                }
                else{
                    console.log('line-->289');
                    isvalid=true;       
                }
            } */
            
            console.log('Line 325 ',checklist.length);
            
            if(lengthOfCheckList==lengthOfEvidAtt) {
                isvalid=true;
            } else {
                isvalid=false;
            }
        }
        
        console.log('337 '+checklist);
        
        if(isvalid){
           if(component.get("v.Isclaimamountexceed")){
                
            if(component.get("v.ClaimsDetails[0].Tenant_obligations__c") && component.get("v.ClaimsDetails[0].Claim_exceed__c") && component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") &&
               component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") && ((component.get("v.isClaimForRent")) ? component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") : true))
            { 
                var action = component.get("c.updatekeyDocuments");
                action.setParams({
                    "caseRecID":component.get("v.ClaimsDetails[0].Id"),
                    "tenantObligation":component.get("v.ClaimsDetails[0].Tenant_obligations__c"),
                    "exceedclaim":component.get("v.ClaimsDetails[0].Claim_exceed__c"),
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
                        document.getElementById('scrollView').scrollIntoView(true);
                        // just yo test 
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
                component.set("v.showKeyDocumentsError",true);
                component.set("v.keyDocuments",true);
                component.set("v.showClaimBreakdown",false);
                
            }
        }
        else{
            
         if(component.get("v.ClaimsDetails[0].Tenant_obligations__c") && component.get("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c") &&
               component.get("v.ClaimsDetails[0].check_out_report_AGLL__c") && ((component.get("v.isClaimForRent")) ? component.get("v.ClaimsDetails[0].Rent_statement_AGLL__c") : true))
            { 
                var action = component.get("c.updatekeyDocuments");
                action.setParams({
                    "caseRecID":component.get("v.ClaimsDetails[0].Id"),
                    "tenantObligation":component.get("v.ClaimsDetails[0].Tenant_obligations__c"),
                    "exceedclaim":component.get("v.ClaimsDetails[0].Claim_exceed__c"),
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
                        document.getElementById('scrollView').scrollIntoView(true);
                        // just yo test 
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
                component.set("v.showKeyDocumentsError",true);
                component.set("v.keyDocuments",true);
                component.set("v.showClaimBreakdown",false);
                
            }   
            
        }
        }
        else{
        	component.set("v.documentsskipError",true); 
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.documentsskipError",false); 
                }), 4000
            );
        }       
        
    },
    
    goToNextItem : function(component, event, helper) {
        let totalItem = component.get("v.ClaimsDetails[0].Dispute_Items__r").length;
        let index= component.get("v.currentItem");
        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
        let disputeItemsCatagories = Dispute_Item[index].Type__c;
        let validateItem = false;
        if(disputeItemsCatagories =='Cleaning')
        {
            validateItem = component.find('Cleaning').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true); 
        }
        else if (disputeItemsCatagories =='Damage')
        {
            validateItem = component.find('Damage').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true); 
        }
            else if(disputeItemsCatagories =='Redecoration')
            {
                validateItem = component.find('Redecoration').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
            }
                else if(disputeItemsCatagories =='Gardening')
                {
                    validateItem = component.find('Gardening').reduce(function (validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                        return validSoFar && inputCmp.get('v.validity').valid;
                    }, true);
                }
                    else if(disputeItemsCatagories =='Rent')
                    {
                        validateItem = component.find('Rent').reduce(function (validSoFar, inputCmp) {
                            inputCmp.showHelpMessageIfInvalid();
                            return validSoFar && inputCmp.get('v.validity').valid;
                        }, true);
                    }
                        else if(disputeItemsCatagories =='Other')
                        {
                            validateItem = component.find('Other').reduce(function (validSoFar, inputCmp) {
                                inputCmp.showHelpMessageIfInvalid();
                                return validSoFar && inputCmp.get('v.validity').valid;
                            }, true);
                        }
        
        
        if(validateItem)
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
                        document.getElementById('scrollView').scrollIntoView(true);
                    }
                    else
                    {
                        component.set("v.currentItem",(component.get("v.currentItem")+1));
                        let index= component.get("v.currentItem");
                        let Dispute_Item =  component.get("v.ClaimsDetails[0].Dispute_Items__r");
                        component.set("v.currentClaimCatagories",Dispute_Item[index].Type__c);
                        document.getElementById('scrollView').scrollIntoView(true);
                    }
                    
                }
                else {
                    alert('Something wrong happand');
                }
            });
            $A.enqueueAction(action); 
        }
        else
        {
            component.set("v.showDisputeItemError",true);
        }
        
        
    },
    
    goToReviewsubmission : function(component, event, helper) {
        //alert('line 375');
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
                component.set("v.showReviewsubmission",true);
                document.getElementById('scrollView').scrollIntoView(true);
            }
            else {
                alert('Something wrong happand');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    handleUploadFinished : function(component, event, helper) {
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
    
    goTodepositsummary :function(component, event, helper){
    let depositid = component.get("v.depositid");
   
    component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositid
            }
        });
    },
    
    showevidencehelpfile:function(component, event, helper){
    //window.open("https://thedisputeservice--uat--c.documentforce.com/servlet/servlet.FileDownload?file=0158E000001mDjN", '_blank');
    window.open("https://uat-thedisputeservice.cs87.force.com/servlet/servlet.FileDownload?file=0158E000001mDjN", '_blank');
    }
    
})