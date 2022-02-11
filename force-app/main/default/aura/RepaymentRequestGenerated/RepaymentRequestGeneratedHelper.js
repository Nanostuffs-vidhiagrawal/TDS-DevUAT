({
    getRepaymentReqLines :function(component) {
        var action = component.get('c.getRepaymentRequestLineDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRecordId")});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            if(allValues!=null){
                component.set("v.repaymentRequestLine", allValues);
                for(var i = 0; i < allValues.length; i++){
                     console.log('++++++++++111+++'+allValues[i].AL_ReqAmt__c);
                    total = total + allValues[i].AL_ReqAmt__c;                    
                } component.set("v.repaymentRequestLineTotal", total);
            }
        });        
        $A.enqueueAction(action);
    },
    
    getRepaymentRequest :function(component) {
        var action = component.get('c.getRepaymentRequestDetails');
        action.setParams({repaymentRecordId : component.get("v.repaymentRecordId")});
        action.setCallback(this, function(response){
            console.log('ddhk-->'+JSON.stringify(response.getReturnValue()));
            var allValues = response.getReturnValue();            
            if(!$A.util.isEmpty(allValues) && !$A.util.isUndefined(allValues)){
                component.set("v.repaymentRequest", allValues);
                var d = new Date();
                d = allValues.Tenancy_End_Date__c;
                //console.log('++++++++++d+++'+d.getDate());
                document.getElementById("tenancyStartDate").innerHTML ='01';
                console.log('++++++++++111+++'+document.getElementById("tenancyStartDate").value);
       			document.getElementById("tenancyStartMonth").value = d.getMonth();
        		document.getElementById("tenancyStartYear").value = d.getFullYear();
            }
        });        
        $A.enqueueAction(action);
    },
    
    getDepositLeadTenantsInformation :function(component) {
        component.set("v.displayLeadTenantSection" , true); 
        component.set("v.displayAllTenantSection" , false);
        component.set("v.buttonText" , $A.get("$Label.c.OnlyLead"));
    },
    
    getDepositAllTenantsInformation :function(component) {
        component.set("v.displayAllTenantSection" , true);
        component.set("v.displayLeadTenantSection" , false);
        component.set("v.buttonText" , $A.get("$Label.c.AllTenantEqual"));
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
            }
            
            if(tenancyDateValue > todayDate){
                component.set("v.futureValidationError" , true);
                component.set("v.dateValidationError" , false);
                isValid = false;
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
		if(component.get("v.noButton")){
			var tenantsAmount = 0.0;
			if(!component.get("v.noButtonOnCommit")){
				component.set("v.buttonText","no");
				component.set("v.remainderAmt",component.get("v.deposit.Protected_Amount__c"));
				component.set("v.blankTenantAmountValidationNoButton" , false);	
			}
			else{
				component.set("v.buttonText","novvalueafterchange");
				var tenantsAmountInfo = component.get("v.tenInfo");
				if(component.get("v.tenInfo")==null || component.get("v.tenInfo")==undefined || component.get("v.tenInfo")==""){
					component.set("v.blankTenantAmountValidationNoButton" , true);
				}
				else{
					console.log('9999999999999999 '+component.get("v.totalNoTenant"));
					console.log('88888888 '+tenantsAmountInfo.length);
					if(component.get("v.totalNoTenant")!=tenantsAmountInfo.length){
						component.set("v.blankTenantAmountValidationNoButton" , true);
					}
					else{					
						for(let i=0;i<tenantsAmountInfo.length;i++){console.log('222222222222 '+tenantsAmountInfo[i].value);
							if(tenantsAmountInfo[i].value==undefined || tenantsAmountInfo[i].value==null || tenantsAmountInfo[i].value==""){ 
								blankTenantAmountValue = true;
								break;
							}
							else{
								tenantsAmount = tenantsAmount + tenantsAmountInfo[i].value;
							}
						}
						if(blankTenantAmountValue){
							component.set("v.blankTenantAmountValidationNoButton" , true);
						}
						else{
							component.set("v.blankTenantAmountValidationNoButton" , false);
						}
					}
				}
				console.log('7777 '+component.get("v.blankTenantAmountValidationNoButton"));
				if(tenantsAmount == undefined || tenantsAmount == 0.0 || tenantsAmount == null){
					console.log('210- >> ');
					component.set("v.leftToAllocate" , true);
					component.set("v.leftToAllocateMessage" , 'There is still £'+component.get("v.deposit.Protected_Amount__c")+' left to allocate.');
					isValid = false;
				}
				if(tenantsAmount!=component.get("v.deposit.Protected_Amount__c")){
					console.log('216- >> ');
					component.set("v.leftToAllocate" , true);
					var difference = component.get("v.deposit.Protected_Amount__c") - tenantsAmount;
					component.set("v.leftToAllocateMessage" , 'There is still £'+difference+' left to allocate.');
					isValid = false;
				}
			}	
		}
		if(component.get("v.yesButton")){
			component.set("v.buttonText","yes")
			var tenantsAmountInfo = component.get("v.tenInfo");
			var tenantsAmount = 0.0;
			var clnAmt= Number(component.get("v.cleanAmt"));
			var dmgAmt = Number(component.get("v.damageAmt"));
			var redAmt= Number(component.get("v.redecorationAmt"));
			var garAmt = Number(component.get("v.gardeningAmt"));
			var arrAmt= Number(component.get("v.arrearsAmt"));
			var othAmt = Number(component.get("v.otherAmt"));
			
			if(clnAmt != null && clnAmt != NaN && clnAmt >= 0){
				component.set("v.cleanAmtValidation" , false);
				tenantsAmount = tenantsAmount + clnAmt;
			}
			else{
				component.set("v.cleanAmtValidation" , true);
			}
			if(dmgAmt != null && dmgAmt != NaN && dmgAmt >= 0){
				component.set("v.damageAmtValidation" , false);
				tenantsAmount = tenantsAmount + dmgAmt;
			}
			else{
				component.set("v.damageAmtValidation" , true);
			}
			if(redAmt != null && redAmt != NaN && redAmt >= 0){
				component.set("v.redecorationAmtValidation" , false);
				tenantsAmount = tenantsAmount + redAmt;
			}
			else{
				component.set("v.redecorationAmtValidation" , true);
			}
			if(garAmt != null && garAmt != NaN && garAmt >= 0){
				component.set("v.gardeningAmtValidation" , false);
				tenantsAmount = tenantsAmount + garAmt;
			}
			else{
				component.set("v.gardeningAmtValidation" , true);
			}
			if(arrAmt != null && arrAmt != NaN && arrAmt >= 0){
				component.set("v.arrearsAmtValidation" , false);
				tenantsAmount = tenantsAmount + arrAmt;
			}
			else{
				component.set("v.arrearsAmtValidation" , true);
			}
			if(othAmt != null && othAmt != NaN && othAmt >= 0){
				component.set("v.otherAmtValidation" , false);
				tenantsAmount = tenantsAmount + othAmt;
			}
			else{
				component.set("v.otherAmtValidation" , true);
			}
			console.log('55555555555 '+component.get("v.tenInfo"));
			if(component.get("v.tenInfo")==null || component.get("v.tenInfo")==undefined || component.get("v.tenInfo")==""){
				component.set("v.blankTenantAmountValidation" , true);
			}
			else{
				console.log('9999999999999999 '+component.get("v.totalNoTenant"));
				console.log('88888888 '+tenantsAmountInfo.length);
				if(component.get("v.totalNoTenant")!=tenantsAmountInfo.length){
					component.set("v.blankTenantAmountValidation" , true);
				}
				else{
					for(let i=0;i<tenantsAmountInfo.length;i++){console.log('222222222222 '+tenantsAmountInfo[i].value);
						if(tenantsAmountInfo[i].value==undefined || tenantsAmountInfo[i].value==null || tenantsAmountInfo[i].value==""){ 
							blankTenantAmountValue = true;
							break;
						}
						else{
							tenantsAmount = tenantsAmount + tenantsAmountInfo[i].value;
						}
					}
					if(blankTenantAmountValue){
						component.set("v.blankTenantAmountValidation" , true);
					}
					else{
						component.set("v.blankTenantAmountValidation" , false);
					}
				}
			}
			console.log('7777 '+component.get("v.blankTenantAmountValidation"));
			if(tenantsAmount == undefined || tenantsAmount == 0.0 || tenantsAmount == null){
				component.set("v.leftToAllocate" , true);
				component.set("v.leftToAllocateMessage" , 'There is still £'+component.get("v.deposit.Protected_Amount__c")+' left to allocate.');
				isValid = false;
			}
			if(tenantsAmount!=component.get("v.deposit.Protected_Amount__c")){
				component.set("v.leftToAllocate" , true);
				var difference = component.get("v.deposit.Protected_Amount__c") - tenantsAmount;
				component.set("v.leftToAllocateMessage" , 'There is still £'+difference+' left to allocate.');
				isValid = false;
			}
			
		}		
		if(isValid){
			console.log('66- >> ');
			component.set("v.leftToAllocate" , false);
			component.set("v.myDate",tenancyDateYMD)
			var action = component.get('c.insertRepaymentReq');
			
			console.log('1113333444- >> '+JSON.stringify(component.get("v.tenInfo")));
			action.setParams({depositId : component.get("v.depositRecordId"),
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
							  values : JSON.stringify(component.get("v.tenInfo"))
							 });
			action.setCallback(this, function(response){
				var result = response.getReturnValue();
				if(result!=null){
                    console.log('result- >> '+component.set("v.repaymentId",result));
                    component.set("v.repaymentId" , result);
					component.find("navService").navigate({
						type: "comm__namedPage",
						attributes: {
							pageName: "repaymentrequestsummary"
						},
						state: {
							repaymentrequest : result
						}
					});             
				 }
			});        
			$A.enqueueAction(action);
		}        
    }
})