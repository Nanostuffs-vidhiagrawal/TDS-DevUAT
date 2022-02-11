({
    
    doInit : function(component, event, helper) {
        
        helper.getError(component, event, helper);
        
        component.set("v.displayRequestSection" , true);
        component.set("v.remainderAmt" , 0);
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositRecordId = urlParams.get('depositId');
        //   var depositRecordId = url.split("depositId=")[1];
        console.log('+++++++++++depositRecordId++'+depositRecordId);
        component.set("v.depositRecordId", depositRecordId);
        helper.getDepositDetails(component);
        helper.getTenantDetails(component);
        
        //alert(`currentUser -> ${component.get("v.currentUser.ContactId")}`);
    },
      hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
          switch (button_Name) {
                case "agentZeroAmount":
                component.set("v.blankTenantAmountValidation", false);
                break;
                case "tenZeroAmount":
                component.set("v.blankAgentAmountValidation", false);
                break;

          }
           
    },
    removeZero: function (component, event, helper) {
        
        var edValue = event.getSource().get("v.value");
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>=1 && !s.includes(".")) { s = s.substring(1,9999); }
            return s;
        }
        var trimeVal = trimNumber(edValue);
        
        event.getSource().set("v.value",trimeVal);
        
    },
    
    goBackHandle : function(component, event, helper) {
        /*
        var repayId = component.get("v.repaymentId");
        if(repayId==null || repayId==undefined || repayId==""){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "depositsummarypage"
                },
                state: {
                    id : component.get("v.depositRecordId")
                }
            });
        }
        else{
            var depositId = component.get("v.depositRecordId");
            var action = component.get('c.deleteDetailsOfRepaymentRequest');
            action.setParams({repaymentRecordId : repayId});
            action.setCallback(this, function(response){
                var allValues = response.getReturnValue();
                if(allValues=='deleted'){
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: {
                            id : component.get("v.depositRecordId")
                        }
                    }); 
                }
            });        
        	$A.enqueueAction(action);
        } */
        // history.back();
        window.history.back();
    },
    
    numberCheck : function(component, event, helper) {
        var charCode = (event.which) ? event.which : event.keyCode;
        if((charCode < 48 && charCode != 46) || (charCode > 57 && charCode != 110) ){//&& charCode != 110
            if (event.preventDefault) {
                event.preventDefault();
            } else {
                event.returnValue = false;
            }
        }
    },
    
    /*call dateUpdate function on onchange event on date field*/ 
    dateUpdate : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        console.log('+++++++++++++++++'+todayFormattedDate);
        console.log('++++++++++++111+++++'+component.get("v.myDate"));
        if(component.get("v.myDate")!= null || component.get("v.myDate")!=undefined){            
            component.set("v.dateBlankValidation" , false);
        }
        if(component.get("v.myDate") != '' && component.get("v.myDate") > todayFormattedDate){
            component.set("v.dateValidationError" , true);
        }else{
            component.set("v.dateValidationError" , false);
        }
    },
    
    /*call validateOtherAmt function on onchange event on Other field*/ 
    validateOtherAmt : function(component, event, helper) {
        var othAmt= Number(component.get("v.otherAmt"));
        var othAmtReason = component.get("v.otherAmtReason");
        console.log('++++++otherAmt+++++++++++'+othAmt);
        console.log('+++++++otherAmtReason++++++++'+othAmtReason);        
        if(component.get("v.otherAmt") != "" && othAmt > 0
           && (othAmtReason == undefined || othAmtReason == "" || othAmtReason.length > 300)){
            component.set("v.otherAmtValidationError" , true);
        }else{
            component.set("v.otherAmtValidationError" , false);
        }
        var action = component.get('c.calculateRemainder');
        $A.enqueueAction(action);        
    },
    
    /*call calculateTenAmount function on 'onCommit' event in Tenant Amount Allocation of the No Deduction option*/ 
    calculateTenAmount : function(component, event, helper) {
        console.log('tenInfo weird 134- >> '+JSON.stringify(component.get("v.tenInfo")));
        console.log('depositAllocation weird 135 - >> '+JSON.stringify(component.get("v.depositAllocation")));
        
        component.set("v.noButtonOnCommit" , true);
        var value = event.getSource().get('v.value');
        //alert(value);
        var value1 = event.getSource().get('v.label');
        var value2 = event.getSource().getGlobalId();
        var value3 = event.getSource().get("v.title");
        
        var jsonArrayData = component.get("v.tenInfo");
        //var lstOfRepReqObj = component.get("v.lstOfRepReqObj");
        var keyName = value3;
        let keyfound=false;
        var tenAmt= Number(value);
        if(jsonArrayData == undefined || jsonArrayData == null)
        {	
            console.log(' 11111');
            jsonArrayData=[];
            jsonArrayData.push({key:keyName,value:tenAmt,name:value1});
            console.log('RepReqObj Line 149 -> '+jsonArrayData);
        }
        else
        {	
            console.log(' 1111jsonArrayData2'+jsonArrayData);
            if(jsonArrayData.length>0)
            {
                for(let i=0;i<jsonArrayData.length;i++)
                {
                    console.log(' 222333333333333333333333322');
                    let tempobj= jsonArrayData[i];
                    console.log(' tempobj[keyName]'+tempobj[keyName]);
                    console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
                    if(jsonArrayData[i].key == keyName) {
                        jsonArrayData[i].value = tenAmt;
                        console.log('RepReqObj Line 164 -> '+JSON.stringify(jsonArrayData));
                        keyfound=true;
                        break;
                    }
                }
                if(!keyfound)
                {
                    jsonArrayData.push({key:keyName,value:tenAmt,name:value1});
                    console.log('RepReqObj Line 173-> '+JSON.stringify(jsonArrayData));
                }
            }
            else
            {
                // console.log(' 4444444444444444'+jsonArrayData);
                jsonArrayData=[];
                jsonArrayData.push({key:keyName,value:tenAmt,name:value1});
                //  console.log('RepReqObj Line 180 -> '+JSON.stringify(jsonArrayData));
            }
        }
        var leftAmt = 0;
        leftAmt = Number(component.get("v.deposit.Protected_Amount__c")); 
        component.set("v.tenInfo" , jsonArrayData);
        //    console.log('@@leftAmt191 '+leftAmt);  
        for(let i=0;i<jsonArrayData.length;i++)
        {	
            console.log(' Deduction');            
            var tenAm = jsonArrayData[i].value;
            console.log(tenAm+' @@leftAmt196 '+leftAmt);  
            leftAmt = parseFloat(parseFloat(leftAmt.toFixed(2)) - parseFloat(tenAm.toFixed(2)));             
        }
        component.set("v.remainderAmt" , leftAmt.toFixed(2));
        console.log('++++++remain+++++++++++'+component.get('v.remainderAmt'));	
        //jsonArrayData.push({key:keyName,value:tenAmt}); 
        component.set("v.tenInfo",jsonArrayData);
        
        
        //    console.log('tenInfo weird 199- >> '+JSON.stringify(component.get("v.tenInfo")));
        //    console.log('depositAllocation weird 200 - >> '+JSON.stringify(component.get("v.depositAllocation")));
        
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
    },
    
    /*call calculateTenAmount function on 'onCommit' event in Tenant Amount Allocation of the Yes Deduction option*/ 
    calculateTenRemainder : function(component, event, helper) {     
        
        var value = event.getSource().get('v.value');
        var value1 = event.getSource().get('v.label');
        var value3 = event.getSource().get("v.title");
        
        var prevAmt = component.get("v.tenantAmt");
        var tenAmt= Number(value);
        var leftAmt = 0;
        if(prevAmt != "" && prevAmt != NaN && prevAmt > 0 && tenAmt != NaN && tenAmt > 0) {
            prevAmt = tenAmt;
        } else {
            prevAmt = tenAmt;
        } 
        
        component.set("v.tenantAmt" , prevAmt);        
        var jsonArrayData = component.get("v.tenInfo");
        var keyName = value3;
        let keyfound=false;
        if(jsonArrayData == undefined || jsonArrayData == null)
        {//	console.log(' 11111');
            jsonArrayData=[];
            jsonArrayData.push({key:keyName,value:tenAmt,name:value1}); 
            //	console.log('RepReqObj Line 222 -> '+JSON.stringify(jsonArrayData));
        }
        else
        {//	console.log(' 1111jsonArrayData1'+jsonArrayData);
            if(jsonArrayData.length>0)
            {
                for(let i=0;i<jsonArrayData.length;i++)
                {	
                    let tempobj= jsonArrayData[i];console.log(' tempobj[keyName]'+tempobj[keyName]);
                    //	console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
                    if(jsonArrayData[i].key == keyName){
                        jsonArrayData[i].value = tenAmt;
                        keyfound=true;
                        //      console.log('RepReqObj Line 235 -> '+JSON.stringify(jsonArrayData));
                        break;
                    }
                }
                if(!keyfound)
                {
                    jsonArrayData.push({key:keyName,value:tenAmt,name:value1});
                    //   console.log('RepReqObj Line 242 -> '+JSON.stringify(jsonArrayData));
                }
            }
            else
            {
                jsonArrayData=[];
                jsonArrayData.push({key:keyName,value:tenAmt,name:value1});
                //  console.log('RepReqObj Line 242 -> '+JSON.stringify(jsonArrayData));
            }
        }
        //jsonArrayData.push({key:keyName,value:tenAmt});
        leftAmt = Number(component.get("v.deposit.Protected_Amount__c")); 
        component.set("v.tenInfo" , jsonArrayData);
        let tempamount1 =0;
        console.log('leftAmt266 '+leftAmt +' --tenAm-- '+tenAm);
        for(let i=0;i<jsonArrayData.length;i++)
        {//	console.log(' Deduction');            
            var tenAm = jsonArrayData[i].value;
            tempamount1 = parseFloat(tempamount1)+parseFloat(jsonArrayData[i].value);
            leftAmt = parseFloat(leftAmt.toFixed(2)) - parseFloat(tenAm.toFixed(2));             
        }
        console.log('leftAmt273 '+parseFloat(leftAmt) +' --tenAm-- '+parseFloat(tenAm));
        component.set("v.tenantAmt" , parseFloat(tempamount1));
        // New Added
        var clnAmt= Number(component.get("v.cleanAmt"));
        var dmgAmt = Number(component.get("v.damageAmt"));
        var redAmt= Number(component.get("v.redecorationAmt"));
        var garAmt = Number(component.get("v.gardeningAmt"));
        var arrAmt= Number(component.get("v.arrearsAmt"));
        var othAmt = Number(component.get("v.otherAmt"));
        if(clnAmt != "" && clnAmt != NaN && clnAmt > 0){
            leftAmt = parseFloat(leftAmt - clnAmt).toFixed(2); 
            console.log(parseFloat(clnAmt)+' ++++++leftAmt+++++++++++ '+parseFloat(leftAmt));
        }
        if(dmgAmt != "" && dmgAmt != NaN && dmgAmt > 0){
            leftAmt = parseFloat(leftAmt - dmgAmt).toFixed(2);
        }
        if(redAmt != "" && redAmt != NaN && redAmt > 0){
            leftAmt = parseFloat(leftAmt - redAmt).toFixed(2);
        }
        if(garAmt != "" && garAmt != NaN && garAmt > 0){
            leftAmt = parseFloat(leftAmt - garAmt).toFixed(2);
        }
        if(arrAmt != "" && arrAmt != NaN && arrAmt > 0){
            leftAmt = parseFloat(leftAmt - arrAmt).toFixed(2);
        }
        if(othAmt != "" && othAmt != NaN && othAmt > 0){
            leftAmt = parseFloat(leftAmt - othAmt).toFixed(2);
        }
        console.log('leftAmtTenRem '+leftAmt);
        component.set("v.remainderAmt" , parseFloat(leftAmt));
        //    console.log('++++++remain+++++++++++'+component.get('v.remainderAmt'));				
        //    console.log('+++++++tenInfo++++++++'+component.get('v.tenInfo'));
        //    console.log('+++++++5454++++++++'+JSON.stringify(component.get("v.tenInfo")));       
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
    },
    
    /*call calculateTenAmount function on 'onCommit' event in Category Allocation of the Yes Deduction option*/
    calculateRemainder : function(component, event, helper) {  
		
        var clnAmt= component.get("v.cleanAmt");
        var dmgAmt = component.get("v.damageAmt");
        var garAmt = component.get("v.gardeningAmt");
        var redAmt= component.get("v.redecorationAmt");
        var arrAmt= component.get("v.arrearsAmt");
        var othAmt = component.get("v.otherAmt");
        var tntAmt= component.get("v.tenantAmt");
        
        var leftAmt = 0;
        var amt = component.get("v.remainderAmt");

        if(amt == "" || amt == NaN || amt == 0) {
            leftAmt = component.get("v.deposit.Protected_Amount__c")- tntAmt;
			
        } else {
            //leftAmt = parseInt(component.get("v.remainderAmt"));
			leftAmt =component.get("v.deposit.Protected_Amount__c") - tntAmt;
        }

		if(tntAmt != "" && tntAmt != NaN && tntAmt > 0){
         //   leftAmt = leftAmt - tntAmt;
        }
		
        if(clnAmt != null && clnAmt != NaN && clnAmt>=0 && clnAmt != '') {
			component.set("v.cleanAmtValidation" , false);
            leftAmt = (leftAmt - clnAmt).toFixed(2); 
        } else {
            component.set("v.cleanAmt",0);
			//component.set("v.cleanAmtValidation" , true);console.log('+++++++ clnAmt2++++++++'+clnAmt);
		}

        if(dmgAmt != null && dmgAmt != NaN && dmgAmt>=0 && dmgAmt != '') {
			component.set("v.damageAmtValidation" , false);
            leftAmt = (leftAmt - dmgAmt).toFixed(2);
        } else {
            component.set("v.damageAmt",0);
			//component.set("v.damageAmtValidation" , true);
		}
		
        if(garAmt != null && garAmt != NaN && garAmt>=0 && garAmt != '') {
			component.set("v.gardeningAmtValidation" , false);
            leftAmt = (leftAmt - garAmt).toFixed(2);
        } else {
            component.set("v.gardeningAmt",0);
			//component.set("v.gardeningAmtValidation" , true);
		}
		
        if(redAmt != null && redAmt != NaN && redAmt>=0 && redAmt != '') {
			component.set("v.redecorationAmtValidation" , false);
            leftAmt = (leftAmt - redAmt).toFixed(2);
        } else {
            component.set("v.redecorationAmt",0);
			//component.set("v.redecorationAmtValidation" , true);
		}
		
        if(arrAmt != null && arrAmt != NaN && arrAmt>=0 && arrAmt != ''){
			component.set("v.arrearsAmtValidation" , false);
            leftAmt = (leftAmt - arrAmt).toFixed(2);
        } else {
            component.set("v.arrearsAmt",0);
			//component.set("v.arrearsAmtValidation" , true);
		}
        
        if(othAmt != null && othAmt != NaN && othAmt>=0 && othAmt != '') {
			component.set("v.otherAmtValidation" , false);
            leftAmt = (leftAmt - othAmt).toFixed(2);
        } else {
            component.set("v.otherAmt",0);
			//component.set("v.otherAmtValidation" , true);
		}        
		
               component.set("v.remainderAmt" , parseFloat(leftAmt));
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
    },
    
    calculateTotalDeposited : function(component, event, helper) {
         console.log('testtotal');
        var remAmt = component.get("v.remainderAmt"); 
        var sharedAmt = (Number(component.get("v.deposit.Protected_Amount__c")) - Number(remAmt)).toFixed(2);
        console.log('+++++++remAmt++++++++'+remAmt); 
        console.log('+++++++sharedAmt++++++++'+sharedAmt); 
        if(remAmt < 0 ){
            component.set("v.displayNegaiveAmtSection" , true);
            component.set("v.leftToAllocate" , false);
        }else{
            component.set("v.totalAmount" , sharedAmt);
            component.set("v.leftToAllocate" , false);
		    component.set("v.displayNegaiveAmtSection" , false);
        }
        // component.set("v.totalAmount" , sharedAmt);  
    },
    
    handleOnYesClick : function(component, event, helper) {
        component.set("v.leftToAllocate" , false);
        component.set("v.displaySplitSection" , true);
        component.set("v.displayNoSection" , false);
        component.set("v.yesButton" , true);
        component.set("v.noButton" , false);
        console.log('111111yesButton11111-- >> '+component.get("v.yesButton"));
        console.log('>>>>>>remainder>>>>'+component.get("v.deposit.Protected_Amount__c"));
        component.set("v.remainderAmt" , component.get("v.deposit.Protected_Amount__c"));
        var ys =  component.find("landlordCompYes");
        var no =   component.find("landlordCompNo");
        
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        
        /*Newly added code START*/
        var depAlloc = component.get("v.depositAllocation");
        var jsonArrayData=[];
        
        console.log('weird depAlloc length -> '+depAlloc.length);
        for(var i=0; i<depAlloc.length; i++) {
            depAlloc[i].value = 0;
            jsonArrayData.push({key:depAlloc[i].Deposit_Holder__c,value:0,name:depAlloc[i].Deposit_Holder__r.Name});
        }
        
        component.set("v.depositAllocation",depAlloc);
        component.set("v.tenInfo",jsonArrayData);
        
        console.log('depositAllocation weird 442 late - >> '+JSON.stringify(component.get("v.depositAllocation")));
        console.log('tenInfo weird 443 late - >> '+JSON.stringify(component.get("v.tenInfo")));
        /*Newly added code END*/
        
        /*component.set("v.totalAmount" , 0);        
        component.set("v.displayRepayTenantSection" , false);
        component.set("v.displayLeadTenantSection" , false);
        component.set("v.displayAllTenantSection" , false);
        component.set("v.RepaymentoptionsBlankValidation" , false);
        component.set("v.buttonText" , 'DivideAmount');*/
    },
    
    handleOnNoClick : function(component, event, helper) {
        component.set("v.leftToAllocate" , false);
        component.set("v.displayNoSection" , true);
        component.set("v.displaySplitSection" , false);
        component.set("v.noButton" , true);
        component.set("v.yesButton" , false);
        var ys =  component.find("landlordCompYes");
        var no =   component.find("landlordCompNo");
        
        $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");
        
        /*Newly added code START*/
        var depAlloc = component.get("v.depositAllocation");
        var amtDivided = component.get("v.amountDividedByTenant");
        var lastTenAmt = component.get("v.lastTenantAmount");
        var jsonArrayData=[];
        console.log('amtDivided '+amtDivided);
        console.log('weird depAlloc length -> '+depAlloc.length);
        for(var i=0; i<depAlloc.length; i++) {
            if(i == depAlloc.length-1 && lastTenAmt >0){
                 depAlloc[i].value = lastTenAmt;
            console.log('weird -> 449 -> '+depAlloc[i].Deposit_Holder__r.Name);
            jsonArrayData.push({key:depAlloc[i].Deposit_Holder__c,value:Number(lastTenAmt),name:depAlloc[i].Deposit_Holder__r.Name});
  
            }else{
                
            
            depAlloc[i].value = amtDivided;
            console.log('weird -> 449 -> '+depAlloc[i].Deposit_Holder__r.Name);
            jsonArrayData.push({key:depAlloc[i].Deposit_Holder__c,value:Number(amtDivided),name:depAlloc[i].Deposit_Holder__r.Name});
            }
        }
        component.set("v.depositAllocation",depAlloc);
        component.set("v.remainderAmt",0);
        component.set("v.tenInfo",jsonArrayData);    
        
        console.log('Protected_Amount__c weird 442 - >> '+component.get("v.deposit.Protected_Amount__c"));
        console.log('depositAllocation weird 442 - >> '+JSON.stringify(component.get("v.depositAllocation")));
        console.log('tenInfo weird 443 - >> '+JSON.stringify(component.get("v.tenInfo")));
        /*Newly added code END*/
        
        
        /*console.log('111111noButton11111-- >> '+component.get("v.noButton"));
        component.set("v.displayRepayTenantSection" , true);
        component.set("v.buttonNoClicked" , true);
        
        component.set("v.RepaymentoptionsBlankValidation" , false);*/
    },
    
    insertRequestRepaymentRecord : function(component, event, helper) {
        console.log('tenInfo weird 434- >> '+JSON.stringify(component.get("v.tenInfo")));
        console.log('depositAllocation weird 442 - >> '+JSON.stringify(component.get("v.depositAllocation")));
        console.log(`currentUser -> ${component.get("v.currentUser.ContactId")}`);
        if(!component.get("v.otherAmtValidationError")) {
            helper.insertRequestRepaymentRecord(component); 
        }  
	},
    
    handleAgree : function(component, event, helper) {
        var ys =  component.find("agreeCompYes");
        var no =   component.find("agreeCompNo");
        
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        component.set("v.dontAgreeSection" , false);
        component.set("v.agreeSection" , false);
        component.set("v.iAgree" , true);
    },
    
    handleDontAgree : function(component, event, helper) {
        var ys =  component.find("agreeCompYes");
        var no =   component.find("agreeCompNo");
        
        $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");  
        component.set("v.dontAgreeSection" , true);
        component.set("v.agreeSection" , false);
        component.set("v.iAgree" , false);
    },
    
    /* This method was called on final submit previously */
    submitTheForm : function(component, event, helper) {
        
        if(component.get("v.iAgree") && !component.get("v.disableSumbit")) {
            
            component.set("v.disableSumbit",true);
            console.log("I agree");
            component.set("v.agreeSection" , false);
            //helper.insertRequestRepaymentRecord(component);        
            //helper.submitTheForm(component);
            
            /* console.log("Line 474 depositRecordId -> ",component.get("v.depositRecordId"));
            console.log("Line 474 cleanAmt -> ",component.get("v.cleanAmt"));
            console.log("Line 474 damageAmt -> ",component.get("v.damageAmt"));
            console.log("Line 474 gardeningAmt -> ",component.get("v.gardeningAmt"));
            console.log("Line 474 redecorationAmt -> ",component.get("v.redecorationAmt"));
            console.log("Line 474 arrearsAmt -> ",component.get("v.arrearsAmt"));
            console.log("Line 474 otherAmt -> ",component.get("v.otherAmt"));
            console.log("Line 474 otherAmtReason -> ",component.get("v.otherAmtReason"));
            console.log("Line 474 tenantAmt -> ",component.get("v.depositRecordId"));
            console.log("Line 474 deposit.Customer__c -> ",component.get("v.deposit.Customer__c"));
            console.log("Line 474 buttonText -> ",component.get("v.buttonText"));
            console.log("Line 474 totalNoTenant -> ",component.get("v.totalNoTenant"));
            console.log("Line 474 myDate -> ",component.get("v.myDate"));
            console.log("Line 474 tenInfo -> ",JSON.stringify(component.get("v.tenInfo")));
            console.log("Line 474 repaymentRequestRecordId -> ",component.get("v.repaymentRequestRecordId"));
            console.log("Line 474 currentUser.ContactId -> ",component.get("v.currentUser.ContactId")); */
            
            /* Newly added code START */
            var action = component.get('c.insertRepaymentReq');
			action.setParams({
                depositId : component.get("v.depositRecordId"),
                clnAmt : component.get("v.cleanAmt"),
                dmgAmt : component.get("v.damageAmt"),
                grdAmt : component.get("v.gardeningAmt"),
                redAmt : component.get("v.redecorationAmt"),
                arrAmt : component.get("v.arrearsAmt"),					
                othAmt : component.get("v.otherAmt"),
                othReason : component.get("v.otherAmtReason"),
                tenAmt : component.get("v.tenantAmt"),
                accId : component.get("v.deposit.Customer__c"),
                btnTxt : component.get("v.buttonText"),
                tenCount : component.get("v.totalNoTenant"),
                tenancyDate : component.get("v.myDate"),
                values : JSON.stringify(component.get("v.tenInfo")),
                repayRequestId : component.get("v.repaymentRequestRecordId"),
                AGLLContactId : component.get("v.currentUser.ContactId")
			});
			action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result!=null) {
                        component.set("v.repaymentId" , result);
                        console.log('Line 517 result -> '+component.get("v.repaymentId"));
                        //component.set("v.repaymentRequestRecordId", result);
                        //this.getRepaymentRequest(component);
                        //this.getRepaymentRequestLine(component);
                        /*const queryString = window.location.search;
                        const urlParams = new URLSearchParams(queryString);
                        const branchId = urlParams.get('branchId');
                        var state;
                        if(branchId != null) {
                            state = {
                                repaymentrequest : repaymentRecordId,
                                branchId : branchId
                            };
                        } else {
                            state = {
                                repaymentrequest : repaymentRecordId
                            };
                        }*/
                        const queryString = window.location.search;
                        const urlParams = new URLSearchParams(queryString);
                        const depositId = urlParams.get('depositId');
                        component.find("navService").navigate({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "repaymentrequestsuccess"
                            }, 
                            state: {id: depositId}
                        }); 
                    }
                } else if (state === "ERROR") {
                //    console.log("In Error mode");
                    var errors = action.getError();
                    console.log('errors---'+JSON.stringify(errors));
                } else {
                  //  console.log('Some other reasons');
                }
			});        
			$A.enqueueAction(action); 
            /* Newly added code END */
          //  console.log("Line 506");
        }
        else {
            component.set("v.agreeSection" , true);
            component.set("v.dontAgreeSection" , false);
        }
    },
    
    editDetailsOfRequest: function(component, event, helper) {
        helper.editDetailsOfRequest(component);
	},
        
    handleComponentEvent : function(cmp, event) {
        
		
        // set the handler attributes based on event data
        cmp.set("v.showAddressFlag", false);
        
    },
        
})