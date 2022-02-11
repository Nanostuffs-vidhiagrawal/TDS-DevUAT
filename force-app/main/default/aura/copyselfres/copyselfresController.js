({
	doInit : function(cmp, event, helper) {
		
        let pageURL = decodeURIComponent(window.location.search.substring(1));
        let variablesURL = pageURL.split('&');
        let parameterNameAndValue;
        let nameAndValueMap = new Map();
        for(let i=0; i<variablesURL.length; i++){
            parameterNameAndValue = variablesURL[i].split('=');
            nameAndValueMap.set(parameterNameAndValue[0],parameterNameAndValue[1]);
        }
        let depositId = nameAndValueMap.get('depositId');
        let isLeadTenant = nameAndValueMap.get('leadTenant');
        //alert(isLeadTenant);
        if(!isLeadTenant){
            cmp.set('v.isLeadTenant',true);
            cmp.set('v.backgroundColor','background-color: #EFEFEF;');
            cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
        }
        //let depositId = 'a0L8E000006ZkXO';
        helper.loadData(cmp, event, depositId);
	},
    closeModel : function (cmp, event, helper) {
        
        cmp.set('v.isModal',false);
    },
    goToDepositSummary : function (cmp, event, helper) {
        
        let pageURL = decodeURIComponent(window.location.search.substring(1));
        let variablesURL = pageURL.split('&');
        let parameterNameAndValue;
        let nameAndValueMap = new Map();
        for(let i=0; i<variablesURL.length; i++){
            parameterNameAndValue = variablesURL[i].split('=');
            nameAndValueMap.set(parameterNameAndValue[0],parameterNameAndValue[1]);
        }
        let depositId = nameAndValueMap.get('depositId');
        cmp.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: { 
                id: depositId 
            }
        });
    },
    handleAgreeTenantAndAgentRepayment : function(cmp, event, helper){
        
        cmp.set('v.iconName','');
        cmp.set('v.isAgree',true);
        cmp.set('v.adjustRePayment',false);
        cmp.set('v.makeAnOffer',false);
        cmp.set('v.submitBtn',false);
    },
    handleAdjustRepayment : function(cmp, event, helper){

        cmp.set('v.changeTextOnAdjust',true);
        cmp.set('v.iconName','utility:edit');
        cmp.set('v.backgroundColor','background-color: #fff;');
        cmp.set('v.adjustRePayment',true);
        cmp.set('v.isAgree',true);
        cmp.set('v.makeAnOffer',false);
        cmp.set('v.submitBtn',true);
        cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
    },
    handleSettlementcomment : function(cmp, event, helper){
        
        cmp.set('v.settlementComment',true);
        cmp.set('v.madeAnOffer',false);
        cmp.set('v.submitBtn',false);
        cmp.set('v.btnBackgroundColor','');
    },
    
    sliderMethod  : function(component, event, helper) {
        let claimRec = component.get("v.disputeItemList");
        let totalamount = 0;
        let selectRecordValue = event.target.value;
        let selectRecordId = event.currentTarget.id;
          console.log('selectRecordValue '+selectRecordValue+' $$ '+selectRecordId);
        let disputOldRecMap = component.get("v.disputeOldRecMap");
           console.log('disputOldRecMap '+disputOldRecMap[selectRecordId].Percentage);
        for(let i =0; i< claimRec.length; i++)
        {
            if(claimRec[i].Id ==selectRecordId)
            {console.log('inIf1 ');
                if(parseFloat(selectRecordValue) < parseFloat(disputOldRecMap[selectRecordId].Percentage) )
                {console.log('inIf ');
                    component.set("v.showError",claimRec[i].Id);
                      component.set("v.submitBtn",true);
                         component.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                    component.set("v.errorMessage",'You can only increase the amount');
                    claimRec[i].Adjustment_Percentage_by_TT__c = selectRecordValue;
                }
                else
                {
                    if(selectRecordValue > parseFloat(claimRec[i].Adjustment_Percentage_by_AGLL__c) )
                    {
                        component.set("v.showError",claimRec[i].Id);
                           component.set("v.submitBtn",true);
                         component.set('v.btnBackgroundColor','background-color: #EFEFEF;');

                        component.set("v.errorMessage",'Amount entered should be equal to or less than amount requested by landlord');
                        claimRec[i].Adjustment_Percentage_by_TT__c = disputOldRecMap[selectRecordId].Percentage;
                    }
                    else
                    {
                        component.set("v.showError",'');
                          component.set("v.submitBtn",false);
                        component.set('v.btnBackgroundColor','');
                        claimRec[i].Adjustment_Percentage_by_TT__c = selectRecordValue;
                    }
                    
                }
                console.log(claimRec[i].Claimed_by_Landlord__c + ' %% '+claimRec[i].Adjustment_Percentage_by_TT__c );
                //claimRec[i].Adjustment_Percentage_by_TT__c = selectRecordValue;
                var AGLLResponse = (claimRec[i].Adjustment_Percentage_by_TT__c * claimRec[i].Claimed_by_Landlord__c)/100;
             console.log('AGLLResponse '+AGLLResponse);  
             claimRec[i].Agreed_by_Tenant__c = parseFloat(AGLLResponse).toFixed(2);
             
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_Tenant__c);
             console.log('Agreed_by_Tenant__c '+parseFloat(claimRec[i].Agreed_by_Tenant__c));  
        }
      
      
           console.log('disputeItemListclaimRec '+claimRec);  
        component.set("v.disputeItemList",claimRec);
        console.log('disputeItemList '+ component.get("v.disputeItemList"));  
        component.set("v.totalAGLLAmount",totalamount);
   },
    
      sliderMethod2  : function(component, event, helper) {
        let claimRec = component.get("v.disputeItemList");
        let totalamount = 0;
        let selectRecordValue = event.target.value;
        let selectRecordId = event.target.id;
        let disputOldRecMap = component.get("v.disputeOldRecMap");
           console.log('disputOldRecMap '+disputOldRecMap[selectRecordId].Percentage);
        for(let i =0; i< claimRec.length; i++)
        {
            if(claimRec[i].Id ==selectRecordId)
            { console.log('@@ in if1 '+selectRecordValue);
                if(parseFloat(selectRecordValue) > parseFloat(disputOldRecMap[selectRecordId].Percentage) )
                { console.log('@@ in if2');
                   component.set("v.submitBtn",true);
                  component.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                    component.set("v.showError",claimRec[i].Id);
                    component.set("v.errorMessage",'You can only reduce the amount');
                    claimRec[i].Adjustment_Percentage_by_AGLL__c = disputOldRecMap[selectRecordId].Percentage;
                }
                else
                {console.log('@@ in else1 '+claimRec[i].Adjustment_Percentage_by_TT__c);
                    if(selectRecordValue < parseFloat(claimRec[i].Adjustment_Percentage_by_TT__c) )
                    {console.log('@@ in elseif ');
                       component.set("v.submitBtn",true);
                      component.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                        component.set("v.showError",claimRec[i].Id);
                        component.set("v.errorMessage",'Amount entered should be equal to or greater than amount requested by tenant');
                        claimRec[i].Adjustment_Percentage_by_AGLL__c = disputOldRecMap[selectRecordId].Percentage;
                    }
                    else
                    {console.log('@@ in elseifelse ');
                        component.set("v.showError",'');
                       component.set("v.submitBtn",false);
                     component.set('v.btnBackgroundColor','');
                        claimRec[i].Adjustment_Percentage_by_AGLL__c = parseFloat(selectRecordValue).toFixed(2);
                        
                    }
                    
                }
                
                //claimRec[i].Adjustment_Percentage_by_AGLL__c = selectRecordValue;
                var AGLLResponse = (claimRec[i].Adjustment_Percentage_by_AGLL__c * claimRec[i].Claimed_by_Landlord__c)/100;
                claimRec[i].Agreed_by_AGLL__c = AGLLResponse;
            }
            totalamount = parseFloat(totalamount) + parseFloat(claimRec[i].Agreed_by_AGLL__c);
        }
      
        component.set("v.disputeItemList",claimRec);
        component.set("v.totalTenantAmount",totalamount);
        
        
        
        //console.log('==>>'+JSON.stringify(component.get("v.ClaimsDetails[0].Dispute_Items__r[0].Adjustment_Percentage_by_AGLL__c")));
    },
    handleSliderchange : function(cmp, event, helper){
        
         let index = event.getSource().get('v.name');
         let value = event.getSource().get('v.value');
        let amount = 0;
        let maxAmount = 0;
        let profileName = cmp.get('v.profileName');
        let disputeList = cmp.get('v.disputeItemList');
        let selectRecordId =cmp.get('v.disputeItemList')[index].Id;
        let percent;
        let otherValue = 0;
        let totalamount = 0;
        let disputOldRecMap = cmp.get("v.disputeOldRecMap");
        
        
         for(let i =0; i< disputeList.length; i++) {
            if(disputeList[i].Id == selectRecordId) {
                if(profileName != 'Tenant'){
                if(parseFloat(value) > disputOldRecMap[selectRecordId].Percentage )
                {    
                      cmp.set('v.submitBtn',true);
                    cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                    cmp.set("v.showError",cmp.get('v.disputeItemList')[index].Id);
                    cmp.set("v.errorMessage",'You can only decrease the amount');
                    disputeList[i].Adjustment_Percentage_by_AGLL__c = disputOldRecMap[selectRecordId].Percentage;
                    console.log('line--> 99 ' + disputOldRecMap[selectRecordId].Amount);
                    disputeList[i].Agreed_by_AGLL__c=disputOldRecMap[selectRecordId].Amount;
                } 
                    else{
                     cmp.set("v.errorMessage",'');
                     cmp.set('v.submitBtn',false);
                     cmp.set('v.btnBackgroundColor','');
                 //  disputeList[i].Adjustment_Percentage_by_AGLL__c = parseFloat(value).toFixed(2);
                    }
                  //  var AGLLResponse = (disputeList[i].Adjustment_Percentage_by_AGLL__c * disputeList[i].Claimed_by_Landlord__c)/100;
                  //  disputeList[i].Agreed_by_AGLL__c = AGLLResponse;
                    
            }
            else{
                     cmp.set('v.submitBtn',false);
                     cmp.set('v.btnBackgroundColor','');
                }
        }
          totalamount = parseFloat(totalamount) + parseFloat(disputeList[i].Agreed_by_AGLL__c);
        }
         console.log('line--> 119 ' );
        cmp.set('v.disputeItemList',disputeList);
        cmp.set('v.totalAGLLAmount',totalamount);
        console.log('line--> 122' + JSON.stringify(disputeList ));
        
        
        if(profileName == 'Tenant'){
            maxAmount = (cmp.get('v.disputeItemList')[index].Tenant_Response__c*100)/cmp.get('v.disputeItemList')[index].Adjustment_Percentage_by_TT;
            amount = (maxAmount*cmp.get('v.disputeItemList')[index].Adjustment_Percentage_by_TT__c)/100;
            disputeList[index].Agreed_by_Tenant__c = Math.round(amount);
        }/*else{
            let otherValue = cmp.get('v.disputeItemList')[index].other;
            let newVar = otherValue.split('\n');
            if(cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c){
                amount = (value*cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c)/100;
            }else{
                amount = (value*newVar[0])/100;
            }
            disputeList[index].Agreed_by_AGLL__c = Math.round(amount);
            disputeList[index].other = '£'+amount+'.00'+'\n'+newVar[1];
        }*/
        
        if(cmp.get('v.disputeItemList')[index].Agreed_by_AGLL__c < cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c || cmp.get('v.disputeItemList')[index].Agreed_by_AGLL__c >= cmp.get('v.disputeItemList')[index].Agreed_by_Tenant__c){	
          //  cmp.set('v.submitBtn',false);
          //  cmp.set('v.btnBackgroundColor','');
        }else{
            cmp.set('v.submitBtn',true);
            cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
        }
        
              
    },
    handleinputchange : function(cmp, event, helper){
        
        let index = event.getSource().get('v.name');
        let value = event.getSource().get('v.value');
        let recid = event.getSource().get('v.label');
       // alert(index);
     //   alert(value);
        let selectRecordId =cmp.get('v.disputeItemList')[index].Id;
        let disputeList = cmp.get('v.disputeItemList');
        let profileName = cmp.get('v.profileName');
        let percent;
        let otherValue = 0;
        let totalamount = 0;
      let disputOldRecMap = cmp.get("v.disputeOldRecMap");
        for(let i =0; i< disputeList.length; i++) {
            if(disputeList[i].Id == selectRecordId) {
                if(profileName != 'Tenant'){
                if(value > disputOldRecMap[selectRecordId].Amount )
                {    
                      cmp.set('v.submitBtn',true);
                    cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                    cmp.set("v.showError",cmp.get('v.disputeItemList')[index].Id);
                    cmp.set("v.errorMessage",'You can only decrease the amount');
                  // disputeList[i].Agreed_by_AGLL__c=disputOldRecMap[selectRecordId].Amount;
                } 
                    else{
                     cmp.set("v.errorMessage",'');
                     cmp.set('v.submitBtn',false);
                     cmp.set('v.btnBackgroundColor','');
                   
                    }
            }
            else{
                     cmp.set('v.submitBtn',false);
                     cmp.set('v.btnBackgroundColor','');
                }
        }
          totalamount = parseFloat(totalamount) + parseFloat(disputeList[i].Agreed_by_AGLL__c);
        }
           
        
        if(profileName == 'Tenant'){
            percent = (value/cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c)*100;
            if(percent>100){
                percent=100 ;  
            }
            disputeList[index].Adjustment_Percentage_by_TT__c = percent;
        }else{
            if(value.includes('\n')){
                otherValue = value.split('\n');
                if(otherValue[0].includes('£')){
                    otherValue[0] = otherValue[0].replace("£","");
                }
                percent = (otherValue[0]/cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c)*100;
            }else{
                percent = (value/cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c)*100;
                if(percent>100){
                    percent=100 ;  
                }
            }
        }
        if(cmp.get('v.disputeItemList')[index].Agreed_by_AGLL__c < cmp.get('v.disputeItemList')[index].Claimed_by_Landlord__c || cmp.get('v.disputeItemList')[index].Agreed_by_AGLL__c >= cmp.get('v.disputeItemList')[index].Agreed_by_Tenant__c){	
            disputeList[index].Adjustment_Percentage_by_AGLL__c = percent;
           // cmp.set('v.submitBtn',false);
           // cmp.set('v.btnBackgroundColor','');
        }else{
            disputeList[index].Adjustment_Percentage_by_AGLL__c = 100;
            cmp.set('v.submitBtn',true);
            cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
        } 
        
        
       // var totalsumofAgreed = 0;
       // var profilename = cmp.get('v.profile');
       // helper.manageTotalAgreefield(cmp,disputeList,totalsumofAgreed,profilename);
        
        console.log('caseObject.disputeList>>',disputeList);
        cmp.set('v.disputeItemList',disputeList);
        cmp.set('v.totalAGLLAmount',totalamount);
        console.log('line-->185' , cmp.get('v.totalAGLLAmount'));
	//	cmp.set('v.caseObject',caseObject);         
    },
    handleWantToMakeAnOffer : function(cmp, event, helper){
        
        cmp.set("v.offeramounttotenant" , " ");
        cmp.set("v.offeramounttoagentlandlord", " ");
        cmp.set('v.counterOffer',true);
        cmp.set('v.iconName','');
        cmp.set('v.backgroundColor','background-color: #EFEFEF;');
        cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
        cmp.set('v.makeAnOffer',true);
        cmp.set('v.isAgree',true);
        cmp.set('v.adjustRePayment',true);
        cmp.set('v.isDisabledBtn',true);
        cmp.set('v.settlementComment',false);
        cmp.set('v.madeAnOffer',false);
        cmp.set('v.submitBtn',true);
    },
    handleMakeAnOffer : function(cmp, event, helper){
        cmp.set("v.exceedamounttenant" ,false);
        cmp.set("v.moreamountagllrequest" ,false);
        cmp.set("v.lessamounttenant" ,false);
        cmp.set("v.undefinedamount" ,false);
        let agllofferamount = cmp.get("v.offeramounttoagentlandlord");
        let tenantofferamount = cmp.get("v.offeramounttotenant");
      //  alert(cmp.get('v.profileName'));
        let caseInst = cmp.get('v.caseObject');
        if(cmp.get('v.profileName') == 'Tenant' ){
          //  alert(agllofferamount);
            var isvalid=true;
             if(agllofferamount < 0 || agllofferamount ==null || agllofferamount==undefined || agllofferamount == "" ){
                cmp.set("v.undefinedamount" ,true);
                 cmp.set("v.exceedamounttenant" ,false);
                 cmp.set("v.moreamountagllrequest" ,false);
                 cmp.set("v.lessamounttenant" ,false);
                isvalid=false;
            }
           else if(caseInst.AGLL_made_Offer__c == true && caseInst.TT_Offer_Amount__c>0 && agllofferamount>caseInst.TT_Offer_Amount__c ){
                cmp.set("v.exceedamounttenant" ,true);
                cmp.set("v.moreamountagllrequest" ,false);
                cmp.set("v.lessamounttenant" ,false);
                cmp.set("v.undefinedamount" ,false);
                isvalid=false;
            }
         else  if(caseInst.AGLL_made_Offer__c == false && agllofferamount>caseInst.Total_Agreed_by_AG_LL__c ){
                cmp.set("v.moreamountagllrequest" ,true);
                cmp.set("v.exceedamounttenant" ,false);
                cmp.set("v.lessamounttenant" ,false);
                cmp.set("v.undefinedamount" ,false);
                isvalid=false;
            }
             else if(agllofferamount < caseInst.Total_Agreed_by_Tenant__c ){
                cmp.set("v.lessamounttenant" ,true);
              cmp.set("v.exceedamounttenant" ,false);
              cmp.set("v.moreamountagllrequest" ,false);
              cmp.set("v.undefinedamount" ,false);
                isvalid=false;
            }
            else{
                console.log("line-->292");
                caseInst.AGLL_Offer_Amount__c = agllofferamount;
                caseInst.TT_Made_offer__c = true;
                caseInst.TT_Offer_Amount__c = 0;
                caseInst.AGLL_made_Offer__c = false; 
                cmp.set("v.exceedamounttenant" ,false);
                cmp.set("v.moreamountagllrequest" ,false);
                cmp.set("v.lessamounttenant" ,false);
                cmp.set("v.undefinedamount" ,false);
                console.log("line-->301");
                isvalid=true;
                }
            
            if(isvalid){
        console.log("line-->318");
        cmp.set('v.caseObject',caseInst);
        console.log('>>>caseInst',JSON.stringify(caseInst));
        helper.settlementCommentOROfferMade(cmp,event,'OfferMade');
        }
        }
        if(cmp.get('v.profileName') != 'Tenant' ){
          //  alert(tenantofferamount);
            var makevalid=true;
            if(tenantofferamount>caseInst.Total_Agreed_by_AG_LL__c){
              cmp.set("v.exceedamount" ,true);
               cmp.set("v.undefinedamount" ,false);
              makevalid=false;
            }
           else if(tenantofferamount < 0 || tenantofferamount ==null || tenantofferamount==undefined || tenantofferamount == "" ){
                cmp.set("v.undefinedamount" ,true);
                cmp.set("v.exceedamount" ,false);
                makevalid=false;
            }
            else{
            caseInst.TT_Offer_Amount__c = tenantofferamount;
            caseInst.AGLL_made_Offer__c = true;
            caseInst.TT_Made_offer__c = false;
            caseInst.AGLL_Offer_Amount__c=0;
            cmp.set("v.exceedamount" ,false);
            cmp.set("v.undefinedamount" ,false);
            makevalid=true;
            }
           if(makevalid){
        console.log("line-->335");
        cmp.set('v.caseObject',caseInst);
        console.log('>>>caseInst',JSON.stringify(caseInst));
        helper.settlementCommentOROfferMade(cmp,event,'OfferMade');
        }
        }
        
    },
    handleAcceptOffer : function(cmp, event, helper){
        
        cmp.set('v.isSubmit',false); 
        cmp.set('v.acceptOffer',true);
        cmp.set('v.rejectOffer',false);
        let caseInst = cmp.get('v.caseObject');
        if(cmp.get('v.profileName') == 'Tenant'){
            caseInst.AGLL_Offer_Response__c = 'Accept';
         //   caseInst.AGLL_made_Offer__c = false;
        }else{
            caseInst.TT_Offer_Response__c = 'Accept';
            //caseInst.TT_Made_offer__c = false;
        }
        caseInst.Status = 'Deposit to be repaid - repayment agreed';
        cmp.set('v.caseObject',caseInst);
        helper.createPaymentAndInstalmentsData(cmp,event);
    },
    handleErrorMsg : function(cmp, event, helper){
        
        cmp.set('v.isError',false);
    },
    handleRejectOffer : function(cmp, event, helper){
        
        cmp.set('v.isSubmit',false);
        cmp.set('v.acceptOffer',true);
        cmp.set('v.rejectOffer',true);
        
       /* cmp.set('v.makeAnOffer',false);
        cmp.set('v.isAgree',false);
        cmp.set('v.adjustRePayment',false);
        cmp.set('v.settlementComment',false);
        cmp.set('v.madeAnOffer',false);
        cmp.set('v.btnBackgroundColor','');*/
        let caseInst = cmp.get('v.caseObject');
        if(cmp.get('v.profileName') == 'Tenant'){
            caseInst.AGLL_Offer_Response__c = 'Reject';
            caseInst.AGLL_made_Offer__c = false;
           // caseInst.TT_Made_offer__c = false;
        }else{
            caseInst.TT_Offer_Response__c = 'Reject';
            caseInst.TT_Made_offer__c = false;
          //  caseInst.AGLL_made_Offer__c = false;
        }
       
        cmp.set('v.caseObject',caseInst);
        helper.OfferRejected(cmp, event,'OfferRejected');
    },
    handleCancelOffer : function(cmp, event, helper){ 
        
        cmp.set('v.cancelOffer',false);
        cmp.set('v.isSubmit',false);
        cmp.set('v.acceptOffer',false);
        cmp.set('v.rejectOffer',false);
        cmp.set('v.makeAnOffer',false);
        cmp.set('v.isAgree',false);
        cmp.set('v.adjustRePayment',false);
        cmp.set('v.settlementComment',false);
        cmp.set('v.madeAnOffer',false);
        cmp.set('v.btnBackgroundColor','');
        let caseInst = cmp.get('v.caseObject');
        if(cmp.get('v.profileName') == 'Tenant'){
           // caseInst.AGLL_Offer_Response__c = 'Reject';
            caseInst.TT_Made_offer__c = false;
            caseInst.AGLL_Offer_Amount__c = 0;
        }else{
           // caseInst.TT_Offer_Response__c = 'Reject';
            caseInst.AGLL_made_Offer__c = false;
            caseInst.TT_Offer_Amount__c = 0;
        }
        cmp.set('v.caseObject',caseInst);
        helper.OfferRejected(cmp, event,'cancelOffer');
    },
    handleDoNotWantToMakeAnOffer : function(cmp, event, helper){
         cmp.set('v.changeTextOnAdjust',false);
        cmp.set('v.isSubmit',false);
        cmp.set('v.acceptOffer',false);
        cmp.set('v.rejectOffer',false);
        cmp.set('v.makeAnOffer',false);
        cmp.set('v.isAgree',false);
        cmp.set('v.adjustRePayment',false);
        cmp.set('v.settlementComment',false);
        cmp.set('v.madeAnOffer',false);
        cmp.set('v.btnBackgroundColor','');
    },
    handleMakeadjustment : function(cmp, event, helper){
        
        cmp.set('v.isModal',false);
        helper.updatemakeadjustment(cmp,event);
        
    },
    handleSubmit : function(cmp, event, helper){
        
    //cmp.set('v.isSubmit',true);
        
    if(cmp.get('v.madeAnOffer') || (cmp.get('v.isAgree') && cmp.get('v.adjustRePayment') &&
                                    cmp.get('v.madeAnOffer'))){
       // MAde an offer
        if(cmp.get('v.counterOffer')){
            let caseInst = cmp.get('v.caseObject');
            if(cmp.get('v.profileName') == 'Tenant'){
                caseInst.AGLL_Offer_Response__c = 'Counter Offer';
            }else{
                caseInst.TT_Offer_Response__c = 'Counter Offer';
            }
              cmp.set('v.caseObject',caseInst);
        }
       helper.settlementCommentOROfferMade(cmp,event,'OfferMade');
    }else{
       if(cmp.get('v.settlementComment') && (cmp.get('v.isAgree') && cmp.get('v.adjustRePayment'))){
        	// Not agreed,made settlementcomment
        	let caseInstance = cmp.get('v.caseObject');
           	let textValue;
           	let profileName = cmp.get('v.profileName');
           	let isBoolean = true;
           	if(profileName == 'Tenant'){
               	textValue = caseInstance.Not_reach_an_agreement_Reason_AG_LL__c;
            }else{
                textValue = caseInstance.Not_reach_an_agreement_Reason_Tenant__c;
            }
           console.log('textValue.length',textValue.length);
           	if(textValue.length < 150 || textValue.length > 500){
               isBoolean = false;
               cmp.set('v.errorMsg','Character limit: 150 to 500 characters');
               cmp.set('v.isError',true);
            }else{
                cmp.set('v.errorMsg','');
               cmp.set('v.isError',false);
            } 
           	
           if(!isBoolean){
               window.scrollTo(500, 200);
               return;
           }
           	
           if(isBoolean){
               helper.settlementCommentOROfferMade(cmp,event,'Comment');
           }
    	}else{
            if(cmp.get('v.isAgree') && cmp.get('v.adjustRePayment')){
                // Adjustment call
                let profileName = cmp.get('v.profileName');
                var disputrList = cmp.get('v.disputeItemList');
                let isBoolean1 = true; 
                cmp.set('v.errorMsg','');
                cmp.set('v.isError',false);
                if(profileName == 'Tenant'){
                    for(var i = 0; i < disputrList.length; i++){
                        if(profileName == 'Tenant'){
                            	if(disputrList[i].Agreed_by_Tenant__c < disputrList[i].Tenant_Response__c){
                                    alert(disputrList[i].Agreed_by_Tenant__c);
                                    alert(disputrList[i].Tenant_Response__c);
                                    cmp.set('v.errorMsg','The value entered cannot be less than previously agreed by you.');
                                    cmp.set('v.isError',true);
                                    isBoolean1 = false;
                                    break;
                           		}
                    	}
                    }
                   if(!isBoolean1){
                        window.scrollTo(500, 200);
                        return;
                   }else{
                       cmp.set('v.isModal',true);
                   } 
                }else{
                    cmp.set('v.isModal',false);
                    for(var i = 0; i < disputrList.length; i++){
                       
                           	if(disputrList[i].Claimed_by_Landlord__c < disputrList[i].Agreed_by_AGLL__c){
                                cmp.set('v.errorMsg','The value entered cannot be more than requested by you');
                                cmp.set('v.isError',true);
                                isBoolean1 = false;
                                break;
                        	}
                    }
                    if(!isBoolean1){
                        window.scrollTo(500, 200);
                        return;
                    }
                    if(isBoolean1){
                        helper.updatemakeadjustment(cmp,event);
                    }
                }
                    //helper.updatemakeadjustment(cmp,event);
            }else{
                if(cmp.get('v.isAgree')){
                    // I agreed
                    let caseInst = cmp.get('v.caseObject');
                    if(cmp.get('v.profileName') == 'Tenant'){
                        caseInst.Claim_Agreed_By__c = 'Agent/Landlord';
                        caseInst.Claim_Agreed_By__c = 'Tenant';
                    }else{
                        //caseInst.Claim_Agreed_By__c = 'Tenant';
                        caseInst.Claim_Agreed_By__c = 'Agent/Landlord';
                    }
                    caseInst.Status = 'Deposit to be repaid - repayment agreed';
                    cmp.set('v.caseObject',caseInst);
                    helper.createPaymentAndInstalmentsData(cmp,event);
                }
            }
    	}
    }
    
}
     
    

})