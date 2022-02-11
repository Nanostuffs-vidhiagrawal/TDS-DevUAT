({
    doInit : function(component, event, helper) {
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        var depositId = urlParams.get('depositId');
        //  var userId = $A.get("$SObjectType.CurrentUser.Id");
        //	component.set('v.userId', userId);
        component.set("v.depositRecordId", depositId);        
        helper.getDepositDetails(component);
        helper.getTenantDetails(component);
        helper.bankDetails(component, event, helper);
        helper.getError(component, event, helper);
    },
        
    doReplytoMo: function (component, event, helper) {
		/* var ys =  document.getElementById("RepayMe");
   		var no =   document.getElementById("Repayalltenants");
  		
 		$A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton"); */
        console.log('doReplytoMo');
        
        /* var Other = component.find("Other");
        console.log('OthersetTome '+Other);
        Other.set("v.value","");
        console.log('Other get '+ Other.get("v.value")); */
        console.log('replyToMe'+component.get("v.replyToMe"));
        component.set("v.replyToMe",true);
        component.set("v.replyToAll",false);
        console.log('replyToMe'+component.get("v.replyToMe"));
        
    },
    
    doYes: function (component, event, helper) {
        console.log('component.get("v.yesClick") '+component.get("v.yesClick"));
        if(!component.get("v.yesClick")) {
               var ys =  document.getElementById("yesButton");
            var no =   document.getElementById("noButton");
            
            $A.util.addClass(ys, "clickButton");
            $A.util.removeClass(no, "clickButton");
            component.set("v.noClick",false);
            component.set("v.yesClick",true);
            component.set("v.replyToMe",false);
            component.set("v.replyToAll",false);
            component.set('v.ShowBankDetails',false);
            component.set('v.ShowErrorBank',false);
             var Other = component.find("Other2");
             var Other2Repay = component.find("Other2Repay");
             var Other2RepayAll = component.find("Other2RepayAll");
            
            if(Other != undefined) {
                console.log('Other.length '+Other.length+' ** '+Other);
                if(typeof Other.length === 'undefined') {
                    Other.set("v.value","");
                }
                else {
                    if(Other.length >1) {
                        console.log(Other.length +'Otherset '+Other);
                        for(var i =0;i<Other.length;i++) {
                            Other[i].set("v.value","");
                        }
                        
                    }
                    else {
                        console.log(Other.length+ 'else');
                        Other[0].set("v.value","");
                    }
                }
            }
            if(Other2Repay != undefined) {
                console.log('Other2Repay.length '+Other2Repay.length+' ** '+Other2Repay);
                if(typeof Other2Repay.length === 'undefined') {
                    Other2Repay.set("v.value","");
                }
                else {
                    if(Other2Repay.length >1) {
                        console.log(Other2Repay.length +'Otherset '+Other2Repay);
                        for(var i =0;i<Other2Repay.length;i++) {
                            Other2Repay[i].set("v.value","");
                        }
                        
                    }
                    else {
                        console.log(Other2Repay.length+ 'else');
                        Other2Repay[0].set("v.value","");
                    }
                }
            }
            if(Other2RepayAll != undefined) {
                console.log('Other2RepayAll.length '+Other2RepayAll.length+' ** '+Other2RepayAll);
                if(typeof Other2RepayAll.length === 'undefined') {
                    Other2RepayAll.set("v.value","");
                }
                else {
                    if(Other2RepayAll.length >1) {
                        console.log(Other2RepayAll.length +'Other2RepayAll '+Other2RepayAll);
                        for(var i =0;i<Other2RepayAll.length;i++) {
                            Other2RepayAll[i].set("v.value","");
                        }
                        
                    }
                    else {
                        console.log(Other2RepayAll.length+ 'else');
                        Other2RepayAll[0].set("v.value","");
                    }
                }
            }
            
            component.set("v.tenInfo" , null);
            component.set("v.tenInfoTenant" , null);
            
            var clean = component.get("v.cleaningAmount");
            var damage = component.get("v.damageAmount");
            var redecor = component.get("v.redecorationAmount");
            var gardening = component.get("v.gardeningAmount");
            var rent = component.get("v.rentAmount");
            var other = component.get("v.OtherAmount");
            
            console.log('1st place '+clean,damage,redecor,gardening,rent,other);
            if(clean == 0) {
                clean=0;
                component.set("v.cleaningAmount","");
            }
            if(damage == 0) {
                damage=0;
                component.set("v.damageAmount","");
            }
            if(redecor == 0) {
                redecor=0;
                component.set("v.redecorationAmount","");
            }
            if(gardening == 0) {
                gardening=0;
                component.set("v.gardeningAmount","");
            }
            if(rent == 0) {
                rent=0;
                component.set("v.rentAmount","");
            }
            if(other == 0) {
                other=0;
                component.set("v.OtherAmount","");
            }
            
         
        }
		component.set('v.remainderAmt',component.get("v.deposit.Protected_Amount__c").toFixed(2));
    },
    
    doNo: function (component, event, helper) {
        console.log('TestclickNo '+component.get("v.noClick"));
        if(!component.get("v.noClick")) {
            
               var ys =  document.getElementById("yesButton");
            var no =   document.getElementById("noButton");
            
            $A.util.removeClass(ys, "clickButton");
            $A.util.addClass(no, "clickButton");
            component.set("v.noClick",true);
            component.set("v.yesClick",false);
            component.set("v.textArea",false);
            component.set('v.ShowBankDetails',false);
            component.set('v.ShowErrorBank',false);
            
            var Other = component.find("Other2");
             var Other2Repay = component.find("Other2Repay");
             var Other2RepayAll = component.find("Other2RepayAll");
            if(Other != undefined ) {
                 if(typeof Other.length != 'undefined') {
                if( Other.length >1) {
                    console.log(Other.length +'Otherset '+Other);
                    for(var i =0;i<Other.length;i++) {
                        console.log('Otherset '+Other[i].get);
                        Other[i].set("v.value","");
                    }
                    
                    // console.log('Other get '+ Other.get("v.value"));
                }
                else {
                    Other[0].set("v.value","");
                    //  console.log('Other else '+ Other.get("v.value"));
                }
                 }
            }
            if(Other2Repay != undefined ) {
                 if(typeof Other2Repay.length != 'undefined') {
                if( Other2Repay.length >1) {
                    console.log(Other2Repay.length +'Otherset '+Other);
                    for(var i =0;i<Other2Repay.length;i++) {
                        Other2Repay[i].set("v.value","");
                    }
                    
                    // console.log('Other get '+ Other.get("v.value"));
                }
                else {
                    Other2Repay[0].set("v.value","");
                    //  console.log('Other else '+ Other.get("v.value"));
                }
                 }
            }
            if(Other2RepayAll != undefined ) {
                 if(typeof Other2RepayAll.length != 'undefined') {
                if( Other2RepayAll.length >1) {
                    console.log(Other2RepayAll.length +'Otherset '+Other);
                    for(var i =0;i<Other2RepayAll.length;i++) {
                        Other2RepayAll[i].set("v.value","");
                    }
                    
                    // console.log('Other get '+ Other.get("v.value"));
                }
                else {
                    Other2RepayAll[0].set("v.value","");
                    //  console.log('Other else '+ Other.get("v.value"));
                }
                 }
            }
            component.set("v.tenInfo" , null);
            component.set("v.tenInfoTenant" , null);
            component.set("v.agentAmountIssue",false);
            component.set("v.cleaningAmount","");
            component.set("v.damageAmount","");
            component.set("v.redecorationAmount","");
            component.set("v.gardeningAmount","");
            component.set("v.rentAmount","");
            component.set("v.OtherAmount","");
            component.set("v.totalAmount",0.0);   
            
         
        }
    },
    
    doReplytoMe: function (component, event, helper) {
        var Other = component.find("Other2");
          var Other2RepayAll = component.find("Other2RepayAll");
        console.log('Other '+ Other);
        if(Other != undefined) {
            if(Other.length >1) {
                console.log(Other.length +'Otherset '+Other);
                for(var i =0;i<Other.length;i++) {
                    Other[i].set("v.value","");
                }
                
                // console.log('Other get '+ Other.get("v.value"));
            }
            else {
                Other[0].set("v.value","");
                //  console.log('Other else '+ Other.get("v.value"));
            }
        }
                   if(Other2RepayAll != undefined ) {
                 if(typeof Other2RepayAll.length != 'undefined') {
                if( Other2RepayAll.length >1) {
                    console.log(Other2RepayAll.length +'Otherset '+Other2RepayAll);
                    for(var i =0;i<Other2RepayAll.length;i++) {
                        Other2RepayAll[i].set("v.value","");
                    }
                    
                    // console.log('Other get '+ Other.get("v.value"));
                }
                else {
                    Other2RepayAll[0].set("v.value","");
                    //  console.log('Other else '+ Other.get("v.value"));
                }
                 }
            }
        component.set("v.tenInfo" , null);
        component.set("v.tenInfoTenant" , null);
        
        var contactId = component.get("v.currentUser.ContactId");
        var depositall = component.get("v.depositAllocation");
        
        for(let i=0; i<depositall.length; i++) {
            if(contactId==depositall[i].Deposit_Holder__r.PersonContactId) {
                component.set("v.loggedindepositholder",depositall[i]);
            }   
        }
        
        var protAmount =  component.get("v.deposit.Protected_Amount__c");
        console.log('protAmount '+protAmount);
        // component.set("v.repayToMeAmount",protAmount);
        component.set("v.loggedindepositholder[0].value",protAmount); 
        console.log('doReplytoMe');
        component.set("v.replyToMe",true);
        component.set("v.replyToAll",false);
        component.set('v.ShowBankDetails',false);
        component.set('v.ShowErrorBank',false);
    },
    
    doReplytoAll: function (component, event, helper) {
        
        console.log('doReplytoAll');
        setTimeout(function() {
             component.set("v.replyToMe",false);
        component.set("v.replyToAll",true);
        var Other = component.find("Other2");
         var Other2RepayAll = component.find("Other2RepayAll");
        console.log(Other2RepayAll + ' ALLOther '+Other);
            if(Other != undefined){
                console.log('len '+Other.length);
                if(Other.length == undefined) {  
                    if(Other.length > 1) {
                        console.log(Other.length +'Otherset '+Other);
                        for(var i =0;i<Other.length;i++) {
                            Other[i].set("v.value","");
                        }
                        
                        // console.log('Other get '+ Other.get("v.value"));
                    }
                    else {
                        console.log('Other else ');
                        Other.set("v.value","");
                        
                    }
                } else {
                    
                }
            }
           if(Other2RepayAll != undefined ) {
                 if(typeof Other2RepayAll.length != 'undefined') {
                if( Other2RepayAll.length >1) {
                    console.log(Other2RepayAll.length +'Otherset '+Other2RepayAll);
                    for(var i =0;i<Other2RepayAll.length;i++) {
                        Other2RepayAll[i].set("v.value","");
                    }
                    
                    // console.log('Other get '+ Other.get("v.value"));
                }
                else {
                    Other2RepayAll[0].set("v.value","");
                    //  console.log('Other else '+ Other.get("v.value"));
                }
                 }
            }
        component.set("v.tenInfo" , null);
        component.set("v.tenInfoTenant" , null);
        
        console.log('doReplytoAll');
       
        component.set('v.ShowBankDetails',false);
        component.set('v.ShowErrorBank',false);
        component.set('v.remainderAmt',component.get("v.deposit.Protected_Amount__c").toFixed(2));
            }, 200);
    },
    
    handleBlur : function (component, event, helper) {
        let othAmount = component.get("v.OtherAmount");
        console.log('othAmount '+othAmount);
        if( othAmount == '') {
            component.set("v.textArea",false);
        }
        
    },
    
    handleAllPress :function (component, event, helper) {
        component.set("v.totalAmount",0.0);
        var whichOne = event.getSource().getLocalId();
        
        var total = component.get("v.totalAmount");
        
        console.log(component.get("v.cleaningAmount")+ ' total1 '+total);
        
        var clean = component.get("v.cleaningAmount");
        var damage = component.get("v.damageAmount");
        var redecor = component.get("v.redecorationAmount");
        var gardening = component.get("v.gardeningAmount");
        var rent = component.get("v.rentAmount");
        var other = component.get("v.OtherAmount");
        //   console.log('1st place '+clean,damage,redecor,gardening,rent,other);
        
        console.log('1st place '+clean,damage,redecor,gardening,rent,other);
        if(clean == undefined || clean =='') {
            clean=0;
            //  component.set("v.cleaningAmount",0.0);
            console.log('If1st place '+clean,damage,redecor,gardening,rent,other);
        }
        if(damage == undefined || damage == '') {
            damage=0;
            //  component.set("v.damageAmount",0.0);
            console.log('IF2st place '+clean,damage,redecor,gardening,rent,other);
        }
        if(redecor == undefined || redecor == '') {
            redecor=0;
            //   component.set("v.redecorationAmount",0.0);
        }
        if(gardening == undefined || gardening == '') {
            gardening=0;
            //   component.set("v.gardeningAmount",0.0);
        }
        if(rent == undefined || rent == '') {
            rent=0;
            //   component.set("v.rentAmount",0.0);
        }
        if(other == undefined || other == '') {
            other=0;
            //   component.set("v.OtherAmount",0.0);
        }
        if(whichOne == 'Other') {
            let othAmount = component.get("v.OtherAmount");
            if(othAmount >0)
                component.set("v.textArea",true);
            else
                component.set("v.textArea",false);
        }
        
        console.log('2nd place '+clean,damage,redecor,gardening,rent,other);
        total = parseFloat(clean) + parseFloat(damage) + parseFloat(redecor) + parseFloat(gardening)+parseFloat(rent) + parseFloat(other);
        component.set("v.totalAmount",total.toFixed(2));
        
        /* Newly added code for remainder START */
        let remainderAmt = parseFloat(component.get("v.deposit.Protected_Amount__c")) - parseFloat(total) - parseFloat(component.get("v.totaltenantAmount"));
        component.set("v.remainderAmt",parseFloat(remainderAmt.toFixed(2)));
        console.log(component.get("v.totaltenantAmount") + ' Line 291 weird -> ',component.get("v.totalAmount"));
        console.log('Line 292 weird remainderAmt ->',component.get("v.remainderAmt"));
        /* Newly added code for remainder END */
        
        helper.helperAgentTotal(component, event, helper, total);
    },
    
    handlePress : function (component, event, helper) {
        let othAmount = component.get("v.OtherAmount");
        console.log('othAmount '+othAmount);
        if(othAmount >0)
            component.set("v.textArea",true);
        else
            component.set("v.textArea",false);
    },
    
    editBankDetails : function(component, event, helper) {
        component.set("v.bankDetailSection", true);
    },
    
    enableBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldBankDetailsEdit", false);
        component.set("v.toggleBankDetails", false);
    }, 
    
    cancelBankDetailsEdit: function (component, event, helper) {
        component.set("v.bankDetailSection", false);
        component.set("v.fieldBankDetailsEdit", true);
        component.set("v.toggleBankDetails", true);
    },
    
    updateBankDetails: function (component, event, helper) {
        helper.updateBankDetails(component, event);
    },
    
    updateInternationalBankDetails: function (component, event, helper) {
        helper.updateInternationalBankDetails(component, event);
    },
    
    goBackHandle : function(component, event, helper) {
        component.set("v.amntLessThenTotal",false);
        var Other = component.find("Other");
        if(Other != undefined) {
            console.log(Other.length +'OthersetTome '+Other);
            if(Other.length != undefined) {
                for(var i =0;i<Other.length;i++) {
                    Other[i].set("v.value","");
                }
            }
            else {
                Other.set("v.value","");
            }
            
            //  console.log('Other get '+ Other.get("v.value"));
        }
        window.history.back();
    },
    
    goEdit:  function(component, event, helper) {
        component.set("v.repaymentSummary",false);
        var endDate =  component.get("v.depositRecievedDate");
        let depositRecievedDate = endDate.split("-")[2];
        let depositRecievedMonth = endDate.split("-")[1];
        let depositRecievedYear = endDate.split("-")[0];
        console.log(endDate +' ## '+'goEdit '+depositRecievedDate+depositRecievedMonth+depositRecievedYear); 
        
        setTimeout(function(){
            var ys =  document.getElementById("yesButton");
            var no =   document.getElementById("noButton");
            console.log('yes '+component.get("v.yesClick"));
            if( component.get("v.yesClick")) {
                $A.util.addClass(ys, "clickButton");
                $A.util.removeClass(no, "clickButton");
                
            } else {
                console.log('no '+no);
                $A.util.removeClass(ys, "clickButton");
                $A.util.addClass(no, "clickButton");
            }
            
            var clean = component.get("v.cleaningAmount");
            var damage = component.get("v.damageAmount");
            var redecor = component.get("v.redecorationAmount");
            var gardening = component.get("v.gardeningAmount");
            var rent = component.get("v.rentAmount");
            var other = component.get("v.OtherAmount");
            
            console.log('1st place '+clean,damage,redecor,gardening,rent,other);
            if(clean == 0) {
                clean=0;
                component.set("v.cleaningAmount","");
                
            }
            if(damage == 0) {
                damage=0;
                component.set("v.damageAmount","");
                
            }
            if(redecor == 0) {
                redecor=0;
                component.set("v.redecorationAmount","");
            }
            if(gardening == 0) {
                gardening=0;
                component.set("v.gardeningAmount","");
            }
            if(rent == 0) {
                rent=0;
                component.set("v.rentAmount","");
            }
            if(other == 0) {
                other=0;
                component.set("v.OtherAmount","");
            }
            document.getElementById("tenancyStartDate").value = depositRecievedDate;
            document.getElementById("tenancyStartMonth").value = depositRecievedMonth;
            document.getElementById("tenancyStartYear").value = depositRecievedYear;
        }, 200);
        
    },
    
    submitDetails :  function(component, event, helper) {
        console.log( component.find("Other2")+' clicked ' +component.find("Other2Repay"));
      console.log(component.get("v.replyToAll") +' toALL # '+component.get("v.noClick"));
          var allValid = true;
        if(component.get("v.replyToMe")){
            var otherValid = component.find("Other2Repay").get("v.validity");
             allValid =  otherValid.valid;
        }else if( component.get("v.replyToAll")){
             console.log( '425 clicked ' +component.find("Other2RepayAll"));
             var otherValid = component.find('Other2RepayAll').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
             allValid =  otherValid;
        }
     
	
 		 console.log('allValid '+allValid);
        
        if( component.get("v.yesClick")) {
       var validClean = component.find("Cleaning").get("v.validity");
       var validDmg = component.find("Damage").get("v.validity");
       var validRed = component.find("Redecoration").get("v.validity");
           var validGard = component.find("Gardening").get("v.validity");
           var validRent = component.find("Rent").get("v.validity");
         var validOthr = component.find("Other").get("v.validity");
   //  console.log('allValid ' +allValid); 
        console.log('validClean ' +validClean.valid); 
        console.log('validDmg ' +validDmg.valid); 
        console.log('validRed ' +validRed.valid); 
        console.log('validGard ' +validGard.valid); 
        console.log('validRent ' +validRent.valid); 
        console.log('validOthr ' +validOthr.valid); 
              
                if( validClean.valid && validDmg.valid && validRed.valid && validGard.valid && validRent.valid && validOthr.valid){
                    allValid = true;
                }else{
                    allValid = false;
                }
            
        }
        var isValid = true;
        helper.chDate(component, event, helper); 
        var tenancyDate = component.get("v.depositRecievedDate");
        console.log('tenancyDate '+tenancyDate);
        
        var yesNoClicked = false;
        console.log('component.get("v.noBankDetails") ' +component.get("v.noBankDetails"));
        if(component.get("v.noBankDetails"))
        {
            var bankAccountName=component.get("v.bankAccountName");
            var accountNumber=component.get("v.accountNumber");
            var sortCode=component.get("v.sortCode");
            var bankName=component.get("v.bankName");
            
            if(bankAccountName==null || bankAccountName=='' || accountNumber==null || accountNumber=='' || sortCode==null || sortCode=='' || bankName==null || bankName=='')
            {
                component.set("v.ShowErrorBank",true);
                console.log('component.get("v.ShowErrorBank") ' +component.get("v.ShowErrorBank"));
                isValid = false;
            }
        }
        //component.set("v.repaymentSummary",true);
        if( !component.get("v.yesClick") && !component.get("v.noClick")) {
            component.set("v.deductionYesNo", true);
            isValid = false;
        }
        else {
            yesNoClicked = true;
        }
        console.log('test');
        if(component.get("v.yesClick")) {
            /*	 if(component.get("v.cleaningAmount") == undefined || component.get("v.damageAmount") == undefined || component.get("v.redecorationAmount") == undefined || component.get("v.gardeningAmount") == undefined || component.get("v.rentAmount") == undefined)
       	 {
       		 component.set("v.amountNotZero", true);
        	   isValid = false; 
        	}*/
        }
        console.log('test2');
        
        console.log('component.get("v.textArea") '+component.get("v.textArea"));
        if(component.get("v.textArea")) {
            var tArea=component.find("texArea").get("v.value")
            // var tArea= document.getElementById("texArea").value;
            if(tArea == undefined || tArea == '') {
                component.set("v.textAreaMust", true);
                
                isValid = false; 
                console.log(isValid +'isValid');
            }
        }
        
        var amount = 0.0;
        
        var totalamt = component.get("v.depositAllocation[0].Deposit__r.Protected_Amount__c");
        console.log('test2totalamt '+totalamt);
        var tenantsAmountInfo = component.get("v.tenInfo");
        var tenantTotal = component.get("v.totaltenantAmount");
        var agentTotal = component.get("v.totalAmount");
        console.log(agentTotal +'tenantTotal '+ tenantTotal);
        console.log('testtenantsAmountInfo2 '+ JSON.stringify(tenantsAmountInfo));
        console.log('repaytoMe '+component.get("v.replyToMe"));
        if(tenantsAmountInfo == null && component.get("v.replyToMe")) {
            amount =  component.get("v.depositAllocation[0].Deposit__r.Protected_Amount__c");
            component.set("v.totaltenantAmount",amount.toFixed(2));
        }
        else if(tenantsAmountInfo != null) {
			/* for(let i=0;i<tenantsAmountInfo.length;i++) {
           		if(tenantsAmountInfo[i].value != '') 
            		amount = parseFloat(amount) + parseFloat(tenantsAmountInfo[i].value);
        	} */
            if(tenantTotal == undefined ) {tenantTotal = 0.0;}
            if(agentTotal == undefined) {agentTotal = 0.0;}
            console.log('repaytoMe526 '+component.get("v.replyToMe"));
            
            amount = parseFloat(tenantTotal)+parseFloat(agentTotal);            
            console.log(agentTotal+'+amount++'+amount);
            
            if((agentTotal == 0.0 || agentTotal == '') &&  component.get("v.yesClick")) {
                console.log('+inIF++');
                component.set("v.agentAmountIssue",true);
                isValid = false;
            }
            if(component.get("v.myDate")== null || component.get("v.myDate")==undefined || component.get("v.myDate")== '') {
                // alert('Date shuld not be blank');
                //  isValid = false;
            }
            console.log('+totalamt++'+totalamt.toFixed(2));
            console.log('+amount++'+amount.toFixed(2));
            if(amount.toFixed(2) > totalamt.toFixed(2)) {
                component.set("v.amntGreatTotal",true);
                isValid = false;
            }
            if(amount.toFixed(2) < totalamt.toFixed(2)) {
                component.set("v.amntLessThenTotal",true);
                isValid = false;
                   $('#errorDiv', window.parent.document).get(0).scrollIntoView();
            }
           
        }
        if(amount==0.0) {
            component.set("v.amntLessThenTotal",true);
            isValid = false;
               $('#errorDiv', window.parent.document).get(0).scrollIntoView();
        }
        if(tenancyDate == '' || tenancyDate == null || tenancyDate ==undefined) {
            isValid = false;
              $('#dateDiv', window.parent.document).get(0).scrollIntoView();
        }
         console.log('551+isValid++'+isValid);
        if(isValid && allValid) {
          
            component.set("v.agentAmountIssue",false);
            component.set("v.amntGreatTotal",false);
            component.set("v.deductionYesNo", false);
            component.set("v.textAreaMust", false);
            component.set("v.dateCantGreat", false);
            component.set("v.deductionYesNo", false);
            component.set("v.amountNotZero", false);
            component.set("v.textAreaMust", false);
            component.set("v.amntLessThenTotal", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankErrorMessage", false);
            component.set("v.nameOnAccountBlankError", false);
            component.set("v.accountNumberBlankError", false);
            
            component.set("v.invalidAccountNumberError", false);        
            component.set("v.sortCodeBlankError", false);
            component.set("v.invalidSortCodeError", false);
            component.set("v.intbankSuccessMessage", false);
            component.set("v.intbanknameerror", false);
            component.set("v.intbankaccounterror", false);
            
            component.set("v.repaymentSummary",true);
            var clean = component.get("v.cleaningAmount");
            var damage = component.get("v.damageAmount");
            var redecor = component.get("v.redecorationAmount");
            var gardening = component.get("v.gardeningAmount");
            var rent = component.get("v.rentAmount");
            var other = component.get("v.OtherAmount");
            
            console.log('1st place '+clean,damage,redecor,gardening,rent,other);
            if(clean == undefined || clean =='') {
                clean=0;
                component.set("v.cleaningAmount",0.0);
                console.log('If1st place '+clean,damage,redecor,gardening,rent,other);
            }
            if(damage == undefined || damage == '') {
                damage=0;
                component.set("v.damageAmount",0.0);
                console.log('IF2st place '+clean,damage,redecor,gardening,rent,other);
            }
            if(redecor == undefined || redecor == '') {
                redecor=0;
                component.set("v.redecorationAmount",0.0);
            }
            if(gardening == undefined || gardening == '') {
                gardening=0;
                component.set("v.gardeningAmount",0.0);
            }
            if(rent == undefined || rent == '') {
                rent=0;
                component.set("v.rentAmount",0.0);
            }
            if(other == undefined || other == '') {
                other=0;
                component.set("v.OtherAmount",0.0);
            }
            
        }
        else {
            if(!allValid){
                  $('#maincon', window.parent.document).get(0).scrollIntoView();
            }
            else if(!validClean.valid || !validDmg.valid || !validRed.valid || !validGard.valid || !validRent.valid || !validOthr.valid){
                 $('#miscCatgories', window.parent.document).get(0).scrollIntoView();
            }
            else{
                document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            }
            
        }
        /* if(bankDetails) {
             toastEvent.setParams({
                title : 'Error',
                message:'You must provide your payment details before you can submit your response. SafeDeposits Scotland will then make payment to you within 5 working days.',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            var elem = component.find('addPayment');
            $A.util.removeClass(elem, '#2574b9');
            $A.util.addClass(elem, 'clrRed');
            isValid = false;
        }
        if(isValid) {
            helper.insertRequestRepaymentRecord(component);  
        }*/
    },
    
    insertRequestRepaymentRecord : function(component, event, helper) {
        console.log('@');
        helper.insertRequestRepaymentRecord(component); 
    },
    
    depositSummary: function(component, event) {
        
        var retdepositId= component.get("v.depositRecordId");
        //alert('clicked '+retdepositId);
        if(retdepositId != null) {
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "depositsummarypage"
                },
                state: {id: retdepositId}
            });
        }
        
    },
    
    calculateAmount : function(component, event, helper) {       
        var amountValue = event.getSource().get('v.value');
        if(amountValue == '') {
            amountValue = 0;
        }
        
        var tenantName = event.getSource().get('v.label'); //alert(tenantName);
        var tenantTitle = event.getSource().get("v.title"); //alert(tenantTitle);
        var jsonArrayData = component.get("v.tenInfo");
        var jsonArrayData2 = component.get("v.tenInfoTenant");
        
        
        let keyfound=false;
        if(jsonArrayData2 == undefined || jsonArrayData2 == null) {
            jsonArrayData2=[];
            jsonArrayData2.push({key:tenantTitle,value:Number(amountValue)});
        }
        else {
            console.log(' 1111jsonArrayData1'+jsonArrayData);
            if(jsonArrayData2.length>0)
            {
                for(let i=0;i<jsonArrayData2.length;i++)
                {	
                    console.log(' 222333333333333333333333322');
                    let tempobj= jsonArrayData2[i];
                    // let tempobj2= jsonArrayData2[i];
                    console.log(tenantTitle+' tenantTitle tempobj[keyName]'+tempobj[tenantTitle]);
                    console.log(' jsonArrayData[i]'+jsonArrayData2[i].key);
                    /* if(tempobj[keyName]!=undefined)
					{
						tempobj[keyName]=tenAmt;
						keyfound=true;
						break;
					} */
                    console.log('@@ 449 '+jsonArrayData2[i].key +' ++ ' +tenantTitle);
                    if(jsonArrayData2[i].key == tenantTitle) {
                        //jsonArrayData[i].value = amountValue;
                        jsonArrayData2[i].value = amountValue;
                        //  console.log(jsonArrayData[i].value +' jsonArrayData2[i].value ');
                        console.log(jsonArrayData2[i].value +' jsonArrayData2[i].value ');
                        keyfound=true;
                        break;
                    }
                }
                if(!keyfound)
                {
                    //	jsonArrayData.push({key:tenantTitle,value:Number(amountValue)}); 
                    jsonArrayData2.push({key:tenantTitle,value:Number(amountValue)}); 
                }
            }
            else
            {
                console.log(' 4444444444444444'+jsonArrayData2);
                //jsonArrayData=[];
                //jsonArrayData.push({key:tenantTitle,value:Number(amountValue)});
                jsonArrayData2=[];
                jsonArrayData2.push({key:tenantTitle,value:Number(amountValue)});
                console.log(' 470'+jsonArrayData2);
            }
            
        }
        let tempamount1 =0;
        // alert(jsonArrayData.length);
        for (let i=0;i<jsonArrayData2.length;i++) {
            // alert(jsonArrayData[i]);
            console.log("line 467 " + jsonArrayData2[i].value);
            // let tempobj= jsonArrayData[i];
            tempamount1 = tempamount1+parseFloat(jsonArrayData2[i].value);
        }
        console.log("check 410 amount" + tempamount1);
        component.set("v.totaltenantAmount",tempamount1.toFixed(2));
        // jsonArrayData.push({key:keyName,value:tenAmt}); 
        // component.set("v.tenInfo" , jsonArrayData);
        component.set("v.tenInfoTenant" , jsonArrayData2);
        // console.log(' 55555'+component.get("v.tenInfo"));
        console.log('+++++++tenInfoTenant++++++++'+JSON.stringify(component.get("v.tenInfoTenant")));
        // console.log('+++++++490++++++++'+JSON.stringify(component.get("v.tenInfo")));
        
        //--------------------------
        
        if(jsonArrayData == undefined || jsonArrayData == null ) 
        {	
            console.log(' 11111');
            jsonArrayData=[];
            jsonArrayData.push({key:tenantTitle,value:Number(amountValue)});
        }
        else
        {	
            console.log(' 1111jsonArrayData1'+jsonArrayData);
            if(jsonArrayData.length>0)
            {
                for(let i=0;i<jsonArrayData.length;i++)
                {	
                    console.log(' 222333333333333333333333322');
                    let tempobj= jsonArrayData[i];
                    //	let tempobj2= jsonArrayData2[i];
                    console.log(tenantTitle+' tenantTitle tempobj[keyName]'+tempobj[tenantTitle]);
                    console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
                    /*if(tempobj[keyName]!=undefined)
					{
						tempobj[keyName]=tenAmt;
						keyfound=true;
						break;
					}*/
                    console.log('@@ 449 '+jsonArrayData[i].key +' ++ ' +tenantTitle);
                    if(jsonArrayData[i].key == tenantTitle) {
                        jsonArrayData[i].value = amountValue;
                        //	jsonArrayData2[i].value = amountValue;
                        console.log(jsonArrayData[i].value +' jsonArrayData2[i].value ');
                        //	console.log(jsonArrayData2[i].value +' jsonArrayData2[i].value ');
                        keyfound=true;
                        break;
                    }
                }
                if(!keyfound)
                {
                    jsonArrayData.push({key:tenantTitle,value:Number(amountValue)}); 
                    //jsonArrayData2.push({key:tenantTitle,value:Number(amountValue)}); 
                }
            }
            else
            {
                console.log(' 4444444444444444'+jsonArrayData);
                jsonArrayData=[];
                jsonArrayData.push({key:tenantTitle,value:Number(amountValue)});
                //jsonArrayData2=[];
                //jsonArrayData2.push({key:tenantTitle,value:Number(amountValue)});
                console.log(' 470'+jsonArrayData);
            }
        }
        
        let tempamount =0;
        // alert(jsonArrayData.length);
        for (let i=0;i<jsonArrayData.length;i++) {
            // alert(jsonArrayData[i]);
			console.log("line 467 " + jsonArrayData[i].value);
            // let tempobj= jsonArrayData[i];
            tempamount = tempamount+parseFloat(jsonArrayData[i].value);
        }
        console.log("check 410 amount -> " + tempamount);
        
        /* Newly added code for remainder START */
        let remainderAmt = parseFloat(component.get("v.deposit.Protected_Amount__c")) - 
            				parseFloat(component.get("v.totalAmount")) - parseFloat(component.get("v.totaltenantAmount"));
        console.log("check 755 amount weird remainderAmt -> " +remainderAmt.toFixed(2));
        component.set("v.remainderAmt",parseFloat(remainderAmt.toFixed(2)));
        console.log("check 757 amount weird -> " + component.get("v.totaltenantAmount"));
        console.log("check 758 amount weird -> " + component.get("v.totalAmount"));
        /* Newly added code for remainder END */
        
        // component.set("v.totaltenantAmount",tempamount);
        // jsonArrayData.push({key:keyName,value:tenAmt}); 
        component.set("v.tenInfo" , jsonArrayData);
        // component.set("v.tenInfoTenant" , jsonArrayData2);
        console.log(' 55555'+component.get("v.tenInfo"));
        // console.log('+++++++tenInfoTenant++++++++'+JSON.stringify(component.get("v.tenInfoTenant")));
        console.log('+++++++490++++++++'+JSON.stringify(component.get("v.tenInfo")));
    },
    
    dateUpdate : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10) {
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10) {
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        console.log('+++++++++++++++++'+todayFormattedDate);
        console.log('++++++++++++111+++++'+component.get("v.myDate"));
        if(component.get("v.myDate")!= null || component.get("v.myDate")!=undefined) {            
            component.set("v.dateBlankValidation" , false);
        }
        if(component.get("v.myDate") != '' && component.get("v.myDate") > todayFormattedDate) {
            component.set("v.dateValidationError" , true);
        } else {
            component.set("v.dateValidationError" , false);
        }
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "submitErrorBtn":
                component.set("v.submitError", false);
                break;
            case "agentZeroAmount":
                component.set("v.agentAmountIssue", false);
                break;
            case "dateCantGreat":
                component.set("v.dateCantGreat", false);
                break;
            case "deductYesNo":
                component.set("v.deductionYesNo", false);
                break;
            case "amountNotZero":
                component.set("v.amountNotZero", false);
                break;
            case "textAreaMust":
                component.set("v.textAreaMust", false);
                break;
            case "amntGreatTotal":
                component.set("v.amntGreatTotal", false);
                break;
            case "amntLessThenTotal":
                component.set("v.amntLessThenTotal", false);
                break;
            case "bankSuccessMessage":
                component.set("v.bankSuccessMessage", false);
                break;
            case "bankErrorMessage":
                component.set("v.bankErrorMessage", false);
                break;
            case "nameOnAccountBlankError":
                component.set("v.nameOnAccountBlankError", false);
                break;
            case "accountNumberBlankError":
                component.set("v.accountNumberBlankError", false);
                break;
            case "invalidAccountNumberError":
                component.set("v.invalidAccountNumberError", false);
                break;
            case "sortCodeBlankError":
                component.set("v.sortCodeBlankError", false);
                break;
            case "invalidSortCodeError":
                component.set("v.invalidSortCodeError", false);
                break;
            case "intbankSuccess":
                component.set("v.intbankSuccessMessage", false);
                break;
            case "intbankname":
                component.set("v.intbanknameerror", false);
                break;
            case "intbankaccount":
                component.set("v.intbankaccounterror", false);
                break;
        }
    },
    
    enableInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldInternationalBankDetailsEdit", false);
        component.set("v.toggleInternationalBankDetails", false);
    }, 
    
    cancelInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.bankDetailSection", false);
        component.set("v.fieldInternationalBankDetailsEdit", true);
        component.set("v.toggleInternationalBankDetails", true);
    },
    
    BankDetailsAdd: function (component, event, helper) {
        console.log('In BankDetailsAdd')
        component.set('v.ShowBankDetails',true);
        component.set('v.ShowErrorBank',false);
    },
    
    CancelBankDetails: function (component, event, helper) {
        console.log('In BankDetailsAdd')
        component.set('v.ShowBankDetails',false);
        component.set('v.ShowErrorBank',false);
    },
    
})