({
    getDepositDetails :function(component) {
        var action = component.get('c.getDepositInformation');
        action.setParams({depositRecordId : component.get("v.depositRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null){
            //    console.log('allValues display-- >> ' + allValues);
                component.set("v.deposit", allValues);
            }
        });        
        $A.enqueueAction(action);
    },
    
    getTenantDetails :function(component) {
        
        var blankAllocationList = [];
        var action = component.get('c.getTenantsInformation');
        //  console.log('11111-- >> '+component.get("v.depositRecordId"));
        action.setParams({depositRecordId : component.get("v.depositRecordId")});
        action.setCallback(this, function(response){
            //     console.log('ddhk-->'+JSON.stringify(response.getReturnValue()));
            var allValues = response.getReturnValue();
            
            if(allValues!=null){
                component.set("v.depositAllocation", allValues); 
                component.set("v.totalNoTenant", allValues.length);
                console.log('IN TEN');
                //    console.log('allValues.length-- >> '+allValues.length);
                //    console.log('allValues-- >> '+allValues);
                if(allValues.length == 1){
                    console.log('IN IF 1');
                    component.set("v.displayAllTenantButton" , false);
                    var rounded = (component.get("v.deposit.Protected_Amount__c")).toFixed(2);
                    component.set("v.amountDividedByTenant", rounded);
                }
                if(allValues.length > 1){
                    component.set("v.displayAllTenantButton" , true);
                    var rounded = (component.get("v.deposit.Protected_Amount__c")/allValues.length).toFixed(2);
                    component.set("v.amountDividedByTenant", rounded);
                    var totalLenRound = rounded*allValues.length;
                    var protectAmt = component.get("v.deposit.Protected_Amount__c");
                    console.log('rounded TEN '+totalLenRound +' && '+protectAmt);
                    if(parseFloat(totalLenRound) > parseFloat(protectAmt)){
                        var deductedAmt = parseFloat(parseFloat(totalLenRound.toFixed(2)) - parseFloat(protectAmt.toFixed(2)));
                        console.log(rounded+'@@## '+deductedAmt.toFixed(2));
                        var lastTenantAmt = parseFloat(parseFloat(rounded) - parseFloat(deductedAmt.toFixed(2)));
                        console.log('lastTenantAmt '+lastTenantAmt.toFixed(2));
                        component.set("v.lastTenantAmount",lastTenantAmt.toFixed(2));
                    }
                    
                    
                }
                //for forwardingAddress
                for (var i=0; i < allValues.length; i++) {
                    
                    
                    if((allValues[i].Deposit_Holder__r.PersonEmail == undefined || allValues[i].Deposit_Holder__r.PersonEmail == '')
                       &&(allValues[i].Deposit_Holder__r.PersonMailingStreet == undefined || allValues[i].Deposit_Holder__r.PersonMailingStreet == '')
                       &&(allValues[i].Deposit_Holder__r.PersonMailingCity == undefined || allValues[i].Deposit_Holder__r.PersonMailingCity == '')
                       &&(allValues[i].Deposit_Holder__r.PersonMailingCountry == undefined || allValues[i].Deposit_Holder__r.PersonMailingCountry == '')
                       &&(allValues[i].Deposit_Holder__r.PersonMailingPostalCode == undefined || allValues[i].Deposit_Holder__r.PersonMailingPostalCode == '')){
                        
                        blankAllocationList.push(allValues[i]);
                        
                    }
                    
                }
                
                if(blankAllocationList.length > 0){
                    
                    // make flag here 
                    //blankAllocationList
                    
                    component.set("v.blankAllocationList",blankAllocationList);
                    component.set("v.showAddressFlag",true);
                }
                
            }
        });        
        $A.enqueueAction(action);
    },
    
    insertRequestRepaymentRecord :function(component) {
        var isValid = true;
        var blankTenantAmountValue = false;
        let tenancyStartDate = document.getElementById("tenancyStartDate").value;
        let tenancyStartMonth = document.getElementById("tenancyStartMonth").value;
        let tenancyStartYear = document.getElementById("tenancyStartYear").value;
        let tenancyDate = tenancyStartDate+'-'+tenancyStartMonth+'-'+tenancyStartYear;
        let tenancyDateYMD = tenancyStartYear+'-'+tenancyStartMonth+'-'+tenancyStartDate;
        
        var blankDate = requiredFieldValidation(tenancyDate);        
        console.log('tenancyDate - >> ' + tenancyDate); 
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
        
        var todayFormattedDate = dd+'-'+mm+'-'+yyyy;
        console.log('todayFormattedDate - >> ' + todayFormattedDate);
        if(!blankDate){console.log('blankDate11111 - >> ' + blankDate); 
                       component.set("v.dateBlankValidation" , true);
                       component.set("v.dateValidationError" , false);
                       component.set("v.futureValidationError" , false);
                       isValid = false;
                       $('#dateError', window.parent.document).get(0).scrollIntoView();
                      }
        else{
            console.log('blankDate - >> ' + blankDate); 
            console.log('tenancyDate - >> ' + tenancyDate);
            component.set("v.dateBlankValidation" , false);
            var todayDate = new Date(yyyy,mm,dd);
            var tenancyDateValue = new Date(tenancyStartYear,tenancyStartMonth,tenancyStartDate);
            var tenancyDateYearValue = new Date(tenancyStartDate,tenancyStartMonth,tenancyStartYear);
            var allValid = validatedate(tenancyDate);
            if(!allValid){
                component.set("v.dateValidationError" , true);                
                component.set("v.futureValidationError" , false);
                isValid = false;
                $('#dateError', window.parent.document).get(0).scrollIntoView();
            }
            
            if(tenancyDateValue > todayDate){
                component.set("v.futureValidationError" , true);
                component.set("v.dateValidationError" , false);
                isValid = false;
                $('#dateError', window.parent.document).get(0).scrollIntoView();
                console.log('98-- >> '+component.get("v.futureValidationError"));
            }
            else{console.log('100-- >> '+component.get("v.futureValidationError"));
                 component.set("v.futureValidationError" , false);
                }
        }
        
        //GOD Class for Required Field Validation
        function requiredFieldValidation(x) {
            if(x==undefined || x==null || x=="" || x== "--"){             
                return false;  
            }
            else{
                return true;  
            }  
        }
        
        //GOD class to check date validity
        function validatedate(d) {
            var dateformat = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
            // Match the date format through regular expression
            if(d.match(dateformat))
            {     
                var splittedDate = d.split('-');
                var splittedDateLength = splittedDate.length;
                if (splittedDateLength>1)
                {
                    var pdate = d.split('-');
                }
                var dd = parseInt(pdate[0]);
                var mm  = parseInt(pdate[1]);
                var yy = parseInt(pdate[2]);
                
                // Create list of days of a month [assume there is no leap year by default]
                var ListofDays = [31,28,31,30,31,30,31,31,30,31,30,31];
                if (mm==1 || mm>2)
                {
                    if (dd>ListofDays[mm-1])
                    {
                        return false;
                    }
                }
                if (mm==2)
                {
                    var lyear = false;
                    if ( (!(yy % 4) && yy % 100) || !(yy % 400)) 
                    {
                        lyear = true;
                    }
                    if ((lyear==false) && (dd>=29))
                    {
                        return false;
                    }
                    if ((lyear==true) && (dd>29))
                    {
                        return false;
                    }
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        
        if(!component.get("v.yesButton") && !component.get("v.noButton")){
            console.log('163-- >> '+component.get("v.futureValidationError"));            
            component.set("v.RepaymentoptionsBlankValidation" , true);
            isValid = false;
        }
        if(component.get("v.noButton")) 
        {
            var tenantsAmount = 0.0;
            if(!component.get("v.noButtonOnCommit")) {
                component.set("v.buttonText","no");
                component.set("v.remainderAmt",component.get("v.deposit.Protected_Amount__c"));
                component.set("v.blankTenantAmountValidationNoButton" , false);	
            }
            else{
                component.set("v.buttonText","novvalueafterchange");
                var tenantsAmountInfo = component.get("v.tenInfo");
                if(component.get("v.tenInfo")==null || component.get("v.tenInfo")==undefined || 
                   component.get("v.tenInfo")=="") 
                {
                    // Newly added code
                    /*component.set("v.blankTenantAmountValidationNoButton" , true);
                    isValid = false;*/
                    
                } else {
                    console.log('9999999999999999 '+component.get("v.totalNoTenant"));
                    console.log('88888888 '+tenantsAmountInfo.length);
                    if(component.get("v.totalNoTenant")!=tenantsAmountInfo.length) {
                        // Newly added code
                        /*component.set("v.blankTenantAmountValidationNoButton" , true);
                        isValid = false;*/
                    }
                    else {					
                        for(let i=0;i<tenantsAmountInfo.length;i++) {
                            // Newly added code
                            /*if(tenantsAmountInfo[i].value==undefined || tenantsAmountInfo[i].value==null || 
                               tenantsAmountInfo[i].value=="") 
                            { 
								blankTenantAmountValue = true;
								break;
                                
							} else {
								tenantsAmount = tenantsAmount + tenantsAmountInfo[i].value;
							}*/
                            if(tenantsAmountInfo[i].value!=undefined && tenantsAmountInfo[i].value!=null && 
                               tenantsAmountInfo[i].value!="") 
                            { 
                                tenantsAmount = tenantsAmount + tenantsAmountInfo[i].value;
                            }
                        }
                        // Newly added code
                        /*if(blankTenantAmountValue) {
                            component.set("v.blankTenantAmountValidationNoButton" , true);
                            isValid = false;
                            
                        } else {
							component.set("v.blankTenantAmountValidationNoButton" , false);
						}*/
                    }
                }
                console.log('7777 '+component.get("v.blankTenantAmountValidationNoButton"));
                console.log('Line 258 -->> ',tenantsAmount);
                // Newly added code
                /*if(tenantsAmount == undefined || tenantsAmount == 0.0 || tenantsAmount == null) {
					console.log('210- >> ');
					component.set("v.leftToAllocate" , true);
					component.set("v.leftToAllocateMessage" , 'There is still £'+component.get("v.deposit.Protected_Amount__c")+' left to allocate.');
					isValid = false;
				}*/
                if(tenantsAmount!=component.get("v.deposit.Protected_Amount__c")) {
                    console.log('216- >> ');
                    component.set("v.leftToAllocate" , true);
                    var difference = component.get("v.deposit.Protected_Amount__c") - tenantsAmount;
                    component.set("v.leftToAllocateMessage" , 'There is still £'+difference+' left to allocate.');
                    isValid = false;
                }
            }
            
            component.set("v.cleanAmt",0);
            component.set("v.damageAmt",0);
            component.set("v.redecorationAmt",0);
            component.set("v.gardeningAmt",0);
            component.set("v.arrearsAmt",0);
            component.set("v.otherAmt",0);
            component.set("v.otherAmtReason",'');
            component.set("v.totalAmtToAgent",0);
        }
        
        if(component.get("v.yesButton")) {
            component.set("v.buttonText","yes")
            var tenantsAmountInfo = component.get("v.tenInfo");
            var tenantsAmount = 0.0;
            var clnAmt = Number(component.get("v.cleanAmt"));
            var dmgAmt = Number(component.get("v.damageAmt"));
            var redAmt = Number(component.get("v.redecorationAmt"));
            var garAmt = Number(component.get("v.gardeningAmt"));
            var arrAmt = Number(component.get("v.arrearsAmt"));
            var othAmt = Number(component.get("v.otherAmt"));
            
            if(clnAmt != null && clnAmt != NaN && clnAmt >= 0) {
                component.set("v.cleanAmtValidation" , false);
                tenantsAmount = tenantsAmount + clnAmt;
            } else {
                component.set("v.cleanAmtValidation" , true);
            }
            
            if(dmgAmt != null && dmgAmt != NaN && dmgAmt >= 0) {
                component.set("v.damageAmtValidation" , false);
                tenantsAmount = tenantsAmount + dmgAmt;
            } else {
                component.set("v.damageAmtValidation" , true);
            }
            
            if(redAmt != null && redAmt != NaN && redAmt >= 0) {
                component.set("v.redecorationAmtValidation" , false);
                tenantsAmount = tenantsAmount + redAmt;
            } else {
                component.set("v.redecorationAmtValidation" , true);
            }
            
            if(garAmt != null && garAmt != NaN && garAmt >= 0) {
                component.set("v.gardeningAmtValidation" , false);
                tenantsAmount = tenantsAmount + garAmt;
            } else {
                component.set("v.gardeningAmtValidation" , true);
            }
            
            if(arrAmt != null && arrAmt != NaN && arrAmt >= 0) {
                component.set("v.arrearsAmtValidation" , false);
                tenantsAmount = tenantsAmount + arrAmt;
            } else {
                component.set("v.arrearsAmtValidation" , true);
            }
            
            if(othAmt != null && othAmt != NaN && othAmt >= 0){
                component.set("v.otherAmtValidation" , false);
                tenantsAmount = tenantsAmount + othAmt;
            } else{
                component.set("v.otherAmtValidation" , true);
            } 
            console.log('tenantsAmount '+tenantsAmount);
            if(tenantsAmount == 0){
                component.set("v.blankAgentAmountValidation",true);
                isValid = false;
                $('#errorShow', window.parent.document).get(0).scrollIntoView();
                
            }else{
                component.set("v.blankAgentAmountValidation",false);
            }
            component.set("v.totalAmtToAgent",tenantsAmount);
            
            console.log('55555555555 '+component.get("v.tenInfo"));
            if(component.get("v.tenInfo")==null || component.get("v.tenInfo")==undefined || 
               component.get("v.tenInfo")=="") 
            {
                // Newly added code
                /*component.set("v.blankTenantAmountValidation" , true);
                isValid = false;
                $('#errorShow', window.parent.document).get(0).scrollIntoView();*/
                
            } else {
                
                console.log('9999999999999999 '+component.get("v.totalNoTenant"));
                console.log('88888888 '+tenantsAmountInfo.length);
                if(component.get("v.totalNoTenant")!=tenantsAmountInfo.length) {
                    // Newly added code
                    /*component.set("v.blankTenantAmountValidation" , true);
                    isValid = false;
                    $('#errorShow', window.parent.document).get(0).scrollIntoView();*/
                } else {
                    var totalTenantAmount=0;
                    for(let i=0;i<tenantsAmountInfo.length;i++) {
                        totalTenantAmount = totalTenantAmount+tenantsAmountInfo[i].value;
                        console.log('222222222222 '+tenantsAmountInfo[i].value);
                        if(tenantsAmountInfo[i].value==undefined || tenantsAmountInfo[i].value==null || 
                           tenantsAmountInfo[i].value=="") 
                        {  console.log('323');
                         //	blankTenantAmountValue = true;
                         //break;
                         
                        } else { console.log('324');
                                tenantsAmount = tenantsAmount + tenantsAmountInfo[i].value;
                                
                                //    blankTenantAmountValue= false;
                               }
                    }
                    console.log('totalTenantAmount '+totalTenantAmount);
                    if(totalTenantAmount == 0){
                        blankTenantAmountValue = true; 
                    }
                    // Newly added code
                    if(blankTenantAmountValue) {
						component.set("v.blankTenantAmountValidation" , true);
                        isValid = false;
                         $('#errorShow', window.parent.document).get(0).scrollIntoView();
					} else {
						component.set("v.blankTenantAmountValidation" , false);
					}
                }
            }
            console.log('7777296 '+component.get("v.blankTenantAmountValidation"));
            if(tenantsAmount == undefined || tenantsAmount == 0.0 || tenantsAmount == null) {
                console.log('311- >> ');
                component.set("v.leftToAllocate" , true);
                component.set("v.leftToAllocateMessage" , 'There is still £'+component.get("v.deposit.Protected_Amount__c")+' left to allocate.');
                isValid = false;
            }
            if(tenantsAmount!=component.get("v.deposit.Protected_Amount__c")) {
                console.log('317- >> ');
                component.set("v.leftToAllocate" , true);
                var difference = component.get("v.deposit.Protected_Amount__c") - tenantsAmount;
                component.set("v.leftToAllocateMessage" , 'There is still £'+difference+' left to allocate.');
                isValid = false;
            }
            
        }
        
        if(isValid) {
            
            component.set("v.leftToAllocate" , false);
            //component.set("v.myDate",tenancyDateYMD);
            component.set("v.myDate",tenancyDateYMD);
            console.log('Line 327 - >> '+JSON.stringify(component.get("v.tenInfo")));
            //alert('myDate -> '+component.get("v.myDate"));
            
            /* Newly added code START */
            var jsonArrayData = component.get("v.tenInfo");
            var totalAmtToTenant = 0.00;
            var totalAmtToAgent = 0.00;
            for(let i=0; i<jsonArrayData.length; i++)
            {	
                if(jsonArrayData[i].value != NaN && jsonArrayData[i].value != null && jsonArrayData[i].value != undefined) 
                {  
                    totalAmtToTenant = totalAmtToTenant+jsonArrayData[i].value;
                }
            }
            component.set("v.totalAmtToTenant",totalAmtToTenant);
            
            /* Newly added code END */
            
            /* var action = component.get('c.insertRepaymentReq');
			action.setParams({
                depositId : component.get("v.depositRecordId"),
                clnAmt : component.get("v.cleanAmt"),
                dmgAmt : component.get("v.damageAmt"),
                redAmt : component.get("v.redecorationAmt"),
                grdAmt : component.get("v.gardeningAmt"),						
                othAmt : component.get("v.otherAmt"),
                arrAmt : component.get("v.arrearsAmt"),
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
				var result = response.getReturnValue();
				if(result!=null) {
                    console.log('result- >> '+component.set("v.repaymentId",result));
                    component.set("v.repaymentId" , result);
                    component.set("v.repaymentRequestRecordId", result);
                    this.getRepaymentRequest(component);
        			this.getRepaymentRequestLine(component);
                }
			});        
			$A.enqueueAction(action); */
            
            component.set("v.displaySummarySection" , true);
            component.set("v.displayRequestSection" , false);
        }
        /*else{
              $('#errorCon', window.parent.document).get(0).scrollIntoView();
        }*/
    },
    
    /*getRepaymentRequest :function(component) {
        var action = component.get('c.getRepaymentRequestDetails');
        console.log('++++++++++4444+++'+component.get("v.repaymentRequestRecordId"));
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(!$A.util.isEmpty(allValues) && !$A.util.isUndefined(allValues)){
                component.set("v.repaymentRequest", allValues);
            }
        });        
        $A.enqueueAction(action);
    },*/
    
    getRepaymentRequestLine :function(component) {
        var total = 0.0
        var action = component.get('c.getRepaymentRequestLineDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            if(allValues!=null) {
                component.set("v.repaymentRequestLine", allValues);
                for(var i = 0; i < allValues.length; i++) {
                    console.log('++++++++++111+++'+allValues[i].AL_ReqAmt__c);
                    total = total + allValues[i].AL_ReqAmt__c;                    
                } component.set("v.repaymentRequestLineTotal", total);
            }
        });        
        $A.enqueueAction(action);
    },
    
    editDetailsOfRequest :function(component) {
        component.set("v.displayRequestSection" , true);
        component.set("v.displaySummarySection" , false);
        var endDate =  component.get("v.myDate");
        console.log('Date '+endDate);
        let depositRecievedDate = endDate.split("-")[2];
        let depositRecievedMonth = endDate.split("-")[1];
        let depositRecievedYear = endDate.split("-")[0];
        console.log(endDate +' ## '+'goEdit '+depositRecievedDate+depositRecievedMonth+depositRecievedYear); 
        setTimeout(function(){
            var ys =  component.find("landlordCompYes");
            var no =   component.find("landlordCompNo");
            console.log('yes '+component.get("v.yesButton"));
            if( component.get("v.yesButton")) {
                $A.util.addClass(ys, "clickButton");
                $A.util.removeClass(no, "clickButton");
                
            } else {
                console.log('no '+no);
                $A.util.removeClass(ys, "clickButton");
                $A.util.addClass(no, "clickButton");
            }
            document.getElementById("tenancyStartDate").value = depositRecievedDate;
            document.getElementById("tenancyStartMonth").value = depositRecievedMonth;
            document.getElementById("tenancyStartYear").value = depositRecievedYear;
        }, 200);
        //  component.set("v.remainderAmt",0);
    },
    
    /*editDetailsOfRequest :function(component) {
        component.set("v.displayRequestSection" , true);
        component.set("v.displaySummarySection" , false);
        component.set("v.remainderAmt",0);
    },*/
    
    submitTheForm :function(component) {
        const queryString = window.location.search;
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
        }
        var repaymentRecordId = component.get("v.repaymentRequestRecordId");
        var action = component.get('c.submitRepaymentRequestDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRequestRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null) {
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "repaymentrequestsuccess"
                    },
                    state: state
                }); 
            }
        });        
        $A.enqueueAction(action);
    },
    
    getError:function (component, event, helper) {       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.errorList",response.getReturnValue());
                var errorList= component.get("v.errorList");                 
                var userErr;
                
                for(var i=0; i<errorList.length; i++) {
                    if(errorList[i].MasterLabel === 'Tenancy Date') {
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.futureDateErrorNew",userErr);
                    }
                     else if(errorList[i].MasterLabel === 'Tenant Repayment Request') {
                            userErr = errorList[i].Error_Message__c;
                            component.set("v.repTenantErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'allocate total deposit amount.') {
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.totalDepositErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Amount for all Tenants') {
                    	userErr = errorList[i].Error_Message__c;
                        component.set("v.tenantAmountErrorNew",userErr);
                    } 
                    else if(errorList[i].MasterLabel === 'Amount for Agents') {
                    	userErr = errorList[i].Error_Message__c;
                  		component.set("v.agentAmountErrorNew",userErr);
                    }
                  	else if(errorList[i].MasterLabel === 'Negative Amount') {
                    	userErr = errorList[i].Error_Message__c;
                  		component.set("v.negativeAmountErrorNew",userErr);
                  	}
                  	else if(errorList[i].MasterLabel === 'Submit Page') {
                    	userErr = errorList[i].Error_Message__c;
                  		component.set("v.agreeErrorNew",userErr);
                    }    
                    else if(errorList[i].MasterLabel === 'Submit page Not Agree') {
                    	userErr = errorList[i].Error_Message__c;
                        component.set("v.doNotAgreeErrorNew",userErr);
                  	}
                  	else if(errorList[i].MasterLabel === 'Blank Date') {
                      	userErr = errorList[i].Error_Message__c;
                  		component.set("v.blankDateErrorNew",userErr);
                  	}  
                }
            }
            else {
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
})