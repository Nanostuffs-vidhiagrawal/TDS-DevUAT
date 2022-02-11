({
    
    doInit : function(component, event, helper) {
        component.set("v.remainderAmt" , 0);
        var url = window.location.href.slice(window.location.href.indexOf('?') + 1);
        var repaymentRecordId = url.split("repaymentId=")[1];
        console.log('+++++++++++repaymentRecordId++'+repaymentRecordId);
        component.set("v.repaymentRecordId", repaymentRecordId);
        //helper.getDepositDetails(component);
        //helper.getTenantDetails(component);
        helper.getRepaymentRequest(component);
        helper.getRepaymentReqLines(component);
        
    },
    
    goBackHandle : function(component, event, helper) {
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
        }
    },
    numberCheck : function(component, event, helper){
        var charCode = (event.which) ? event.which : event.keyCode;
        if(charCode < 48 || (charCode > 57 && charCode != 110) ){//&& charCode != 110
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
	
	calculateTenAmount : function(component, event, helper) { 
		component.set("v.noButtonOnCommit" , true);
		var value = event.getSource().get('v.value');
        //alert(value);
        var value1 = event.getSource().get('v.label');
        var value2 = event.getSource().getGlobalId();
        var value3 = event.getSource().get("v.title");
		
		var jsonArrayData = component.get("v.tenInfo");
		var keyName = value3;
		let keyfound=false;
		var tenAmt= Number(value);
		if(jsonArrayData == undefined || jsonArrayData == null)
		{	console.log(' 11111');
			jsonArrayData=[];
			jsonArrayData.push({key:keyName,value:tenAmt});
			console.log(' 1111jsonArrayData1'+jsonArrayData);
		}
		else
		{	console.log(' 1111jsonArrayData2'+jsonArrayData);
			if(jsonArrayData.length>0)
			{
				for(let i=0;i<jsonArrayData.length;i++)
				{	console.log(' 222333333333333333333333322');
					let tempobj= jsonArrayData[i];console.log(' tempobj[keyName]'+tempobj[keyName]);
					console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
					if(jsonArrayData[i].key == keyName){
						jsonArrayData[i].value = tenAmt;
						keyfound=true;
						break;
					}
				}
				if(!keyfound)
				{
					jsonArrayData.push({key:keyName,value:tenAmt}); 
				}
			}
			else
			{console.log(' 4444444444444444'+jsonArrayData);
				jsonArrayData=[];
				jsonArrayData.push({key:keyName,value:tenAmt});
				
			}
		}
        var leftAmt = 0;
        leftAmt = Number(component.get("v.deposit.Protected_Amount__c")); 
        component.set("v.tenInfo" , jsonArrayData);
        for(let i=0;i<jsonArrayData.length;i++)
        {	console.log(' Deduction');            
         	var tenAm = jsonArrayData[i].value
         	leftAmt = leftAmt - tenAm;             
        }
        component.set("v.remainderAmt" , leftAmt);
        console.log('++++++remain+++++++++++'+component.get('v.remainderAmt'));	
		//jsonArrayData.push({key:keyName,value:tenAmt}); 
        component.set("v.tenInfo" , jsonArrayData);
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
	},
	
    calculateTenRemainder : function(component, event, helper) {       
        var value = event.getSource().get('v.value');
       // alert(value);
        var value3 = event.getSource().get("v.title");
        console.log('++++++In Yes tenant+++++++++++'+value);
        console.log('++++++In Yes value3+++++++++++'+value3);
        var prevAmt = component.get("v.tenantAmt");
        console.log('++++++In Yes Init prevAmt+++++++++++'+prevAmt);
        var tenAmt= Number(value);
        var leftAmt = 0;
		if(prevAmt != "" && prevAmt != NaN && prevAmt > 0 && tenAmt != NaN && tenAmt > 0){
            prevAmt = prevAmt + tenAmt;
        }else{
            prevAmt = tenAmt;
        }
		component.set("v.tenantAmt" , prevAmt);        
		var jsonArrayData = component.get("v.tenInfo");
		var keyName = value3;
		let keyfound=false;
		if(jsonArrayData == undefined || jsonArrayData == null)
		{	console.log(' 11111');
			jsonArrayData=[];
			jsonArrayData.push({key:keyName,value:tenAmt}); 
		}
		else
		{	console.log(' 1111jsonArrayData1'+jsonArrayData);
			if(jsonArrayData.length>0)
			{
				for(let i=0;i<jsonArrayData.length;i++)
				{	console.log(' 222333333333333333333333322');
					let tempobj= jsonArrayData[i];console.log(' tempobj[keyName]'+tempobj[keyName]);
					console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
					if(jsonArrayData[i].key == keyName){
						jsonArrayData[i].value = tenAmt;
						keyfound=true;
						break;
					}
				}
				if(!keyfound)
				{
					jsonArrayData.push({key:keyName,value:tenAmt}); 
				}
			}
			else
			{console.log(' 4444444444444444'+jsonArrayData);
				jsonArrayData=[];
				jsonArrayData.push({key:keyName,value:tenAmt});
				
			}
		}
		//jsonArrayData.push({key:keyName,value:tenAmt});
		leftAmt = Number(component.get("v.deposit.Protected_Amount__c")); 
        component.set("v.tenInfo" , jsonArrayData);
        for(let i=0;i<jsonArrayData.length;i++)
        {	console.log(' Deduction');            
         	var tenAm = jsonArrayData[i].value
         	leftAmt = leftAmt - tenAm;             
        }
        // New Added
        var clnAmt= Number(component.get("v.cleanAmt"));
        var dmgAmt = Number(component.get("v.damageAmt"));
        var redAmt= Number(component.get("v.redecorationAmt"));
        var garAmt = Number(component.get("v.gardeningAmt"));
        var arrAmt= Number(component.get("v.arrearsAmt"));
        var othAmt = Number(component.get("v.otherAmt"));
        if(clnAmt != "" && clnAmt != NaN && clnAmt > 0){
            leftAmt = leftAmt - clnAmt; 
        }
        if(dmgAmt != "" && dmgAmt != NaN && dmgAmt > 0){
            leftAmt = leftAmt - dmgAmt;
        }
        if(redAmt != "" && redAmt != NaN && redAmt > 0){
            leftAmt = leftAmt - redAmt;
        }
        if(garAmt != "" && garAmt != NaN && garAmt > 0){
            leftAmt = leftAmt - garAmt;
        }
        if(arrAmt != "" && arrAmt != NaN && arrAmt > 0){
            leftAmt = leftAmt - arrAmt;
        }
        if(othAmt != "" && othAmt != NaN && othAmt > 0){
            leftAmt = leftAmt - othAmt;
        }
        // New Added
        component.set("v.remainderAmt" , leftAmt);
        console.log('++++++remain+++++++++++'+component.get('v.remainderAmt'));				
        console.log('+++++++tenInfo++++++++'+component.get('v.tenInfo'));
        console.log('+++++++5454++++++++'+JSON.stringify(component.get("v.tenInfo")));       
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
    },
    
    calculateRemainder : function(component, event, helper) {       
        var clnAmt= parseInt(component.get("v.cleanAmt"));
        var dmgAmt = parseInt(component.get("v.damageAmt"));
        var redAmt= parseInt(component.get("v.redecorationAmt"));
        var garAmt = parseInt(component.get("v.gardeningAmt"));
        var arrAmt= parseInt(component.get("v.arrearsAmt"));
        var othAmt = parseInt(component.get("v.otherAmt"));
        var tntAmt= parseInt(component.get("v.tenantAmt"));
        /*console.log('++++++clnAmt+++++++++++'+clnAmt);
        console.log('+++++++dmgAmt++++++++'+dmgAmt);
        console.log('++++++redAmt+++++++++++'+redAmt);
        console.log('+++++++garAmt++++++++'+garAmt);
        console.log('++++++arrAmt+++++++++++'+arrAmt);
        console.log('+++++++othAmt++++++++'+othAmt);
        console.log('++++++tenant+++++++++++'+tntAmt);*/
        
        var leftAmt = 0;
        var amt = component.get("v.remainderAmt");
        console.log('++++++amt+++++++++++'+amt);
        if(amt == "" || amt != NaN || amt == 0){
            leftAmt = parseInt(component.get("v.deposit.Protected_Amount__c"));
        }else{
            leftAmt = parseInt(component.get("v.remainderAmt"));
        }
        console.log('+++++++ Ded leftAmt++++++++'+leftAmt);
		if(tntAmt != "" && tntAmt != NaN && tntAmt > 0){
            leftAmt = leftAmt - tntAmt;
        }console.log('+++++++ 259++++++++'+typeof clnAmt);
		console.log('+++++++ 259++++++++'+clnAmt);
        if(clnAmt != null && clnAmt != NaN && clnAmt>=0){console.log('+++++++ clnAmt1++++++++'+clnAmt);
			component.set("v.cleanAmtValidation" , false);
            leftAmt = leftAmt - clnAmt; 
        }
		else{
			component.set("v.cleanAmtValidation" , true);console.log('+++++++ clnAmt2++++++++'+clnAmt);
		}
        if(dmgAmt != null && dmgAmt != NaN && dmgAmt>=0){
			component.set("v.damageAmtValidation" , false);
            leftAmt = leftAmt - dmgAmt;
        }
		else{
			component.set("v.damageAmtValidation" , true);
		}
        if(redAmt != null && redAmt != NaN && redAmt>=0){
			component.set("v.redecorationAmtValidation" , false);
            leftAmt = leftAmt - redAmt;
        }
		else{
			component.set("v.redecorationAmtValidation" , true);
		}
        if(garAmt != null && garAmt != NaN && garAmt>=0){
			component.set("v.gardeningAmtValidation" , false);
            leftAmt = leftAmt - garAmt;
        }
		else{
			component.set("v.gardeningAmtValidation" , true);
		}
        if(arrAmt != null && arrAmt != NaN && arrAmt>=0){
			component.set("v.arrearsAmtValidation" , false);
            leftAmt = leftAmt - arrAmt;
        }
		else{
			component.set("v.arrearsAmtValidation" , true);
		}
        if(othAmt != null && othAmt != NaN && othAmt>=0){
			component.set("v.otherAmtValidation" , false);
            leftAmt = leftAmt - othAmt;
        }
		else{
			component.set("v.otherAmtValidation" , true);
		}        
        console.log('+++++++leftAmt++++++++'+leftAmt);        
        component.set("v.remainderAmt" , leftAmt);
        var action = component.get('c.calculateTotalDeposited');
        $A.enqueueAction(action);
    },
    
    calculateTotalDeposited : function(component, event, helper) {
        var remAmt = Number(component.get("v.remainderAmt")); 
        var sharedAmt = Number(component.get("v.deposit.Protected_Amount__c")) - remAmt;
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
        component.set("v.displaySplitSection" , true);
        component.set("v.displayNoSection" , false);
        component.set("v.yesButton" , true);
        component.set("v.noButton" , false);
        console.log('111111yesButton11111-- >> '+component.get("v.yesButton"));
        console.log('>>>>>>remainder>>>>'+component.get("v.deposit.Protected_Amount__c"));
        component.set("v.remainderAmt" , component.get("v.deposit.Protected_Amount__c"));
        /*component.set("v.totalAmount" , 0);        
        component.set("v.displayRepayTenantSection" , false);
        component.set("v.displayLeadTenantSection" , false);
        component.set("v.displayAllTenantSection" , false);
        component.set("v.RepaymentoptionsBlankValidation" , false);
        component.set("v.buttonText" , 'DivideAmount');*/
    },
    
    handleOnNoClick : function(component, event, helper) {
        component.set("v.displayNoSection" , true);
        component.set("v.displaySplitSection" , false);
        component.set("v.noButton" , true);
        component.set("v.yesButton" , false);
        /*console.log('111111noButton11111-- >> '+component.get("v.noButton"));
        component.set("v.displayRepayTenantSection" , true);
        component.set("v.buttonNoClicked" , true);
        
        component.set("v.RepaymentoptionsBlankValidation" , false);*/
    },
    
    repayFullAmountToLeadTenant : function(component, event, helper) {
        helper.getDepositLeadTenantsInformation(component);        
    },
    
    repayFullAmountToAllTenantsEqually : function(component, event, helper) {
        helper.getDepositAllTenantsInformation(component);        
    },
    
    insertRequestRepaymentRecord : function(component, event, helper) {
        helper.insertRequestRepaymentRecord(component);        
    },
})