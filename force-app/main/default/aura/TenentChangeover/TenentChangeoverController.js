({
    doInit : function(component, event, helper) {
        
        helper.getError(component, event, helper);
        
        helper.getloggedInTenants(component, event, helper);
        var currentURL = window.location.href;
        var depositId;
        var tenantChangeOver;
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        depositId = urlParams.get('id');
        tenantChangeOver = urlParams.get('tchange');
        var bankDetails = urlParams.get('bankDetails');
        //alert('34'+depositId +bankDetails+tenantChangeOver);
        
        component.set("v.depositId",depositId);
        var action = component.get("c.getdeposittenantdetails");
        action.setParams({
            depositId:depositId,
            tchange : tenantChangeOver
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                
                component.set("v.deptenantlist",result.getReturnValue());
                var resResult = result.getReturnValue();
                //console.log('line-->13' + JSON.stringify(result.getReturnValue()));
                //   console.log('line-->26'+resResult.length + JSON.stringify(resResult[1].Depallobject));
                component.set("v.olddepositid",depositId);
                
                component.set("v.newtenancycomponent",false);
                
                var House = new Array();
                //       console.log('31 '+House);
                var i;
                for(i = 1;i<resResult.length;i++){
                    //   console.log('istenantmove '+resResult[i].Depallobject.Istenantmoved__c);
                    if(resResult[i].Depallobject.Istenantmoved__c){
                        House.push(resResult[i].Depallobject);  
                    }
                }
                if(tenantChangeOver == 'true'){
                    component.set("v.tenantChangeOver","true"); 
                    component.set("v.updatechangeovertenant",House); 
                    var alltenant = component.find('alltenant');
                    $A.util.addClass(alltenant, 'alltenantshow');
                    component.set("v.changeovertenants",true);
                    component.set("v.viewCorrectButton",true);
                    
                }
                else if(bankDetails == 'true'){
                    
                    component.set("v.tenantChange",true);
                    component.set("v.updatechangeovertenant",House); 
                    var alltenant = component.find('alltenant');
                    $A.util.removeClass(alltenant, 'alltenantshow');
                    
                }
                    else{
                        
                        var alltenant = component.find('alltenant');
                        $A.util.removeClass(alltenant, 'alltenantshow');
                    }
                
            }
        });
        $A.enqueueAction(action);
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
    
    onNo : function(component, event, helper) {
        //     alert( component.get("v.olddepositid"));
        var action = component.get("c.updateCase");
        action.setParams({
            depositId: component.get("v.olddepositid")
        });
        
        action.setCallback(this, function(result){
            var resResult = result.getReturnValue();
            
            if(resResult == 'Successfully updated'){
                alert('We have cancelled tenant change over request');
                component.find("navService").navigate({
                    type: "comm__namedPage",
                    attributes: {
                        pageName: "viewdeposit"
                    },
                    state: {
                        
                        
                    }
                });
                
                
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    onYes : function(component, event, helper) {
        component.set("v.changeovertenants",false);
        component.set("v.newtenancycomponent",true);
    },
    
    /* handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },*/
    //Process the selected contacts
    
    handleSelectedtenents: function(component, event, helper) {
        var selectedtenents = [];
        var checkvalue = component.find("checkContact");
        //   alert(checkvalue.length);
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedtenents.push(checkvalue.get("v.text"));
            }
        }else{
            
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedtenents.push(checkvalue[i].get("v.text"));
                }
                
                
            }
            //  alert(component.get("v.tenantChange") );
            if(component.get("v.tenantChange") ){
                selectedtenents.push(component.get("v.loggedinTenant"));    }
        }
        
        component.set("v.selectedtenantids" ,selectedtenents);
    },
    
    savetenantstatus: function(component, event, helper) {
        console.log('test '+component.find("tenAmt"))
      //  var tenAmtvalidity = component.find("tenAmt").get("v.validity");
           
     var tenAmtvalidity = component.find('tenAmt').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
  console.log('tenAmtvalidity ' +tenAmtvalidity);
       
        if(tenAmtvalidity)
       {
        component.set("v.isValidTenantCount", false);
        component.set("v.isValidEnteredAmt", false);
        component.set("v.isValidTotalAmt", false);
        
        var selectedtenents = [];
        if( component.get("v.selectedtenantids" ) == '')
        {
            if(component.get("v.tenantChange")) {
                selectedtenents.push(component.get("v.loggedinTenant"));  
                component.set("v.selectedtenantids" ,selectedtenents);
            }
        }
        var olddepositid = component.get("v.deptenantlist[0].Depositobject.Id");
        var selectedtenantids = component.get("v.selectedtenantids");
        let depositAllocationRec=[];
        let depositRec=component.get("v.deptenantlist");
        for(let k=0; k<depositRec.length; k++)
        {
            if(depositRec[k].Depallobject)
            {
                depositAllocationRec.push(depositRec[k].Depallobject);
            }
        }
        let selectedTenantsRec=[] ;
        for(let i=0;i< depositAllocationRec.length ;i++)
        {
            for(let j=0;j< selectedtenantids.length ;j++)
            {
                if(depositAllocationRec[i].Deposit_Holder__c ==selectedtenantids[j] )
                {
                    selectedTenantsRec.push(depositAllocationRec[i]);
                }
            }
        }
        component.set("v.updatechangeovertenant",selectedTenantsRec);
        //let depositamount = Number(component.get("v.deptenantlist[0].Depositobject.Deposit_Amount__c"));
        let depositamount = Number(component.get("v.deptenantlist[0].Depositobject.Protected_Amount__c"));
        let changeoverdetails = component.get("v.updatechangeovertenant");
        let total = 0;
        var isValidSelectedTntCount = true;
        var isValidTotalAmt = true;
        var isValidTenacyChangeoverAmt = true;
        
        for(let i = 0; i <selectedTenantsRec.length; i++) {
            if(selectedTenantsRec[i].Tenencychangeoveramount__c!=='' &&
               selectedTenantsRec[i].Tenencychangeoveramount__c!==null &&
               selectedTenantsRec[i].Tenencychangeoveramount__c!==undefined)
            {
                total += parseInt(selectedTenantsRec[i].Tenencychangeoveramount__c); 
                if(parseInt(selectedTenantsRec[i].Tenencychangeoveramount__c)<0 || 
                   isNaN(selectedTenantsRec[i].Tenencychangeoveramount__c))
                {
                    isValidTenacyChangeoverAmt = false;
                    component.set("v.isValidEnteredAmt", true);
                }
            }
            else
            {
                isValidTenacyChangeoverAmt = false;
                component.set("v.isValidEnteredAmt", true);
            }
            //alert(`Valid ${selectedTenantsRec[i].Tenencychangeoveramount__c} -> ${isNaN(parseInt(selectedTenantsRec[i].Tenencychangeoveramount__c))}`);
        }
        //Validating maximum number of tenants valid for the changeover
		let isValidMaxTenant = true;
        if(selectedTenantsRec.length >= depositAllocationRec.length)
        {
            isValidMaxTenant = false;
            component.set("v.isValidTotalTenants", true);
        }
        
        if(selectedTenantsRec.length > 0)
        {
            if(total >= depositamount) {
                isValidTotalAmt = false;
                component.set("v.isValidTotalAmt", true);
            }
            else {
                // component.set("v.showContinueBttn",false);
                //    alert(component.get("v.tenantChange"));
                if(component.get("v.tenantChange") == true) {
                    //console.log('--225--');  
                    var action = component.get("c.updatechchangeoverdetails");
                    action.setParams({
                        Depolist : component.get("v.updatechangeovertenant")
                    });
                    action.setCallback(this, function(result){
                        var state = result.getState();
                        if (component.isValid() && state === "SUCCESS"){
                            
                            alert('Saved ChangeOver Details, Now we are transfering to bank ');
                            const queryString = window.location.search;
                            const urlParams = new URLSearchParams(queryString);
                            const depositId = urlParams.get('id');
                            
                            component.find("navService").navigate({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName: "changeover"
                                },
                                state: {
                                    id : depositId,
                                    bankDetails:true
                                }
                            });
                            
                        }
                    });
                    $A.enqueueAction(action);  
                    
                }
                else{
                    // $A.enqueueAction(component.get("c.dochangeover")); 
                    //component.set("v.changeovertenants",true);
                    //component.set("v.newtenancycomponent",false);
                    
                }
            }
        }
        else
        {
            //alert('Please Select atleast once tenant');
            isValidSelectedTntCount = false;
            component.set("v.isValidTenantCount", true);
        }
        if(isValidTenacyChangeoverAmt && isValidTotalAmt && isValidSelectedTntCount && isValidMaxTenant)
        {
            let action5 = component.get("c.getTenantsInformation");
            action5.setParams({
                allocationIds: component.get("v.selectedtenantids"),
                depId : component.get("v.depositId")
            });
            action5.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    
                    if(result != '' && result != null && result != undefined){
                        
                        if(result.length > 0){
                            
                            component.set("v.blankAllocationList",result);
                            component.set("v.showAddressFlag",true);
                        }else{

                            component.set("v.windowNum","Window 2");
                            component.set("v.isWindow1",false);
                            component.set("v.changeovertenants",true);
                            var step2 = component.find('step2');
                            $A.util.addClass(step2, 'active');
                        }
                    }else{
                        
                        component.set("v.windowNum","Window 2");
                        component.set("v.isWindow1",false);
                        component.set("v.changeovertenants",true);
                        var step2 = component.find('step2');
                        $A.util.addClass(step2, 'active');
                    }
                    
                }
                // Handle Error
                else if (state === "ERROR") {
                    console.log(errors);
                    var errors = response.getError();
                    
                } else {
                    console.log("Unknown error");
                }
            });
            $A.enqueueAction(action5); 
        }
    }
        else{
            console.log('testfail');
        }
        //console.log('---selectedTenantsRec--->>>'+JSON.stringify(selectedTenantsRec));
        
        /*  alert(selectedtenantids);
        var action = component.get("c.changeovertenantlist");
        action.setParams({
            selectedtenantids : selectedtenantids,
            olddepositid:olddepositid
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
			//	 alert('JSON '+JSON.stringify(result.getReturnValue()));
                component.set("v.updatechangeovertenant",result.getReturnValue()); 
                var alltenant = component.find('alltenant');
                
                //component.set("v.showalltenants",false);
                //component.set("v.newtenancycomponent",false);
                $A.util.addClass(alltenant, 'alltenantshow');
                component.set("v.changeovertenants",true);
                
            }
        });
        $A.enqueueAction(action);*/
    },
    
    backonfirst:function(component, event, helper){
        var alltenant = component.find('alltenant');
        $A.util.removeClass(alltenant, 'alltenantshow');
        component.set("v.showalltenants",true);  
        component.set("v.changeovertenants",false); 
        
    },
    
    backtodeposithome:function(component, event, helper){
        
        if( component.get("v.tenantChangeOver") == true){
            component.set("v.changeovertenants",true);
            component.set("v.newtenancycomponent",false);
            
        } 
        else{
            var depositsummarypageid = component.get("v.deptenantlist[0].Depositobject.Id"); 
            
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "depositsummarypage"
                },
                state: {
                    id :depositsummarypageid
                    
                }
            });
            
        }
    },
    
    dochangeover:function(component, event, helper) {
        //let depositamount = Number(component.get("v.deptenantlist[0].Depositobject.Deposit_Amount__c"));
        let depositamount = Number(component.get("v.deptenantlist[0].Depositobject.Protected_Amount__c"));
        let changeoverdetails = component.get("v.updatechangeovertenant");
        let total = 0;
        for(let i = 0; i <changeoverdetails.length; i++){
            if(changeoverdetails[i].Tenencychangeoveramount__c)
            {
                total += parseInt(changeoverdetails[i].Tenencychangeoveramount__c); 
            }
            
        }
        
        if(total >=depositamount){
            alert('You are unable to pay the tenant more than the deposit amount held by SafeDeposits Scotland.');
        }
        else{
            //    alert(component.get("v.tenantChange"));
            if(component.get("v.tenantChange") == true){
                
                var action = component.get("c.updatechchangeoverdetails");
                action.setParams({
                    Depolist : component.get("v.updatechangeovertenant")
                });
                action.setCallback(this, function(result){
                    var state = result.getState();
                    if (component.isValid() && state === "SUCCESS"){
                        
                        alert('Saved ChangeOver Details, Now we are transfering to bank ');
                        const queryString = window.location.search;
                        const urlParams = new URLSearchParams(queryString);
                        const depositId = urlParams.get('id');
                        
                        component.find("navService").navigate({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "changeover"
                            },
                            state: {
                                id : depositId,
                                bankDetails:true
                            }
                        });
                        
                    }
                });
                $A.enqueueAction(action);  
                
            }
            else{
                component.set("v.changeovertenants",false);
                component.set("v.newtenancycomponent",true);
            }
        }
    },
    
    onClickCheckBox:function(component, event, helper) {
        var checkBoxV=document.getElementById("checkBoxId").checked;
        //var checkBoxV = component.find("checkBoxId").get("v.checked");
        component.set("v.startdatecheck", checkBoxV);  
        var cb = component.get("v.startdatecheck"); 
        
        var olddepositdate =component.get("v.deptenantlist[0].Depositobject.Start_Date__c");
        let dat =new Date(olddepositdate);
        
        //alert(`date1 ${dat.getDate()} month1 ${dat.getMonth() + 1} year1 ${dat.getFullYear()}`);
        if(cb==true){
            component.set("v.newdepositstartdate",olddepositdate);
            component.set("v.startdatebox", true);
            /*component.set("v.startdateDay", dat.getDate());
            component.set("v.startdateMonth", dat.getMonth()+1);
            component.set("v.startdateYear", dat.getFullYear());*/
            //alert(dat.getMonth());
            if(dat.getDate()<10)
            {
                document.getElementById("startDateId").value = "0"+dat.getDate();
            }
            else
            {
                document.getElementById("startDateId").value = dat.getDate();
            }
            let monthToBeSet = dat.getMonth()+1;
            if(monthToBeSet<10)
            {
                document.getElementById("startMonthId").value = "0"+monthToBeSet;
            }
            else
            {
                document.getElementById("startMonthId").value = dat.getMonth()+1;
            }
            document.getElementById("startYearId").value = dat.getFullYear();
        }   
        else{
            component.set("v.startdatebox", false);
            component.set("v.newdepositstartdate", " ");
            /*component.set("v.startdateDay","");
            component.set("v.startdateMonth", "");
            component.set("v.startdateYear", "");*/
            document.getElementById("startDateId").value="";
            document.getElementById("startMonthId").value = "";
            document.getElementById("startYearId").value = "";
    	}
    },
    
    createdeposit:function(component, event, helper) {
        component.set("v.isValidTenancyStartDate",false);
        component.set("v.isValidDepositAmt",false);
        component.set("v.isValidNumOfTenants",false);
        component.set("v.isValidMaxTenants",false);
        component.set("v.amountCantBeLessThan1Error",false);
        
        let newtenantsNo = component.get("v.newtenantnumber");
        let newdepositamt =component.get("v.newdepositamount");
        let newdepositstartdate = component.get("v.newdepositstartdate");
        let alltenants = component.get("v.deptenantlist[0].Depositobject.Number_of_Tenants__c");
        let changeovertenants = component.get("v.updatechangeovertenant").length;
        let selectedtenantids = component.get("v.selectedtenantids");
        let changeovertenantslist =component.get("v.updatechangeovertenant");
        var depositId = component.get("v.deptenantlist[0].Depositobject.Id");
        var tenantChange = component.get("v.tenantChangeOver");
        var startDate = document.getElementById("startDateId").value;
        var startMonth = document.getElementById("startMonthId").value;
        var startYear = document.getElementById("startYearId").value;

        let tenancyStartDate = startDate+'-'+startMonth+'-'+startYear;
        let isValidDate = validatedate(tenancyStartDate);
        //component.set("v.isValidTenancyStartDate",isValidDate);
        
        //GOD class to check date validity
        function validatedate(d)
        {
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
        
        var isValid = true;
		if((startDate=="" || startDate==undefined || startDate==null) || 
            (startMonth=="" || startMonth==undefined || startMonth==null)  || 
            (startYear=="" || startYear==undefined || startYear==null) || !isValidDate)
        {
            isValid = false;
            component.set("v.isValidTenancyStartDate",true);
        }
        if(newdepositamt<0 || newdepositamt=="" || newdepositamt==undefined || newdepositamt==null)
        {
            isValid = false;
            component.set("v.isValidDepositAmt",true);
            
        } else if(newdepositamt<1) {
            isValid = false;
            component.set("v.amountCantBeLessThan1Error",true);
        }
        if((newtenantsNo-(alltenants-selectedtenantids.length))<0 || newtenantsNo=="" || newtenantsNo==undefined || 
            newtenantsNo==null)
        {
            isValid = false;
            component.set("v.isValidNumOfTenants",true);
        }
        if((newtenantsNo-(alltenants-selectedtenantids.length))>99)
        {
            isValid = false;
            component.set("v.isValidMaxTenants",true);
        }
        
        var allValid = component.find("newtenancy")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
      	//alert('allValid '+allValid);
        if(allValid) {
            
            //alert('@@ '+JSON.stringify(changeovertenantslist));
            if((parseInt(newtenantsNo)) < ((alltenants)-(changeovertenants))) { 
                //alert('No. of tenants cannot be less then remaining tenants of previous deposit'); 
            }
            else if((parseInt(newtenantsNo)) == ((alltenants)-(changeovertenants))) {
                isValid = false;  
  				//alert('@@ '+depositId);
     			//alert('553state '+tenantChange);
                
                var action = component.get("c.createnewdeposit");
                action.setParams({
                    depositid:depositId,  
                    newdepositamount:newdepositamt,
                    newtenantsnumber:newtenantsNo,
                    newdepositstartdate:newdepositstartdate,
                    Depolist:JSON.stringify(changeovertenantslist),
                    tenantChange :tenantChange
                    //Depolist:selectedtenantids
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert('553state '+state);
                    console.log('Line 574');
                    /* var retNewDepositId = response.getReturnValue();
                    retNewDepositId = retNewDepositId.split("=")[1];
                    const queryString = window.location.search;
                    const urlParams = new URLSearchParams(queryString);
                    const branchId = urlParams.get('branchId');
                    var stateRtrn;
                    if(branchId != null){
                        stateRtrn = {
                            id : depositid,
                            branchId : branchId
                        };
                    }else{
                        stateRtrn = {
                            id : depositid
                        };
                    } */
                    if(state === "SUCCESS") {
                        if(tenantChange == 'true') {
                            /*component.find("navService").navigate({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName: "depositsummarypage"
                                },
                                state: stateRtrn
                            });*/                        
                            window.history.back(); 
                        }
                        else {
                            /*component.find("navService").navigate({
                                type: "comm__namedPage",
                                attributes: {
                                    pageName: "depositsummarypage"
                                },
                                state: stateRtrn
                            });*/
                            window.history.back();
                        }
                        
                    }
                    else if (state === "INCOMPLETE") {
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.log('!! '+errors);
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                
                                console.log("Error message: " + JSON.stringify(errors[0].message)
                                           );
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                
                $A.enqueueAction(action);
            }
			else {
                    let NoOfTenant = newtenantsNo -(alltenants-changeovertenants);
                    let newNoOfTenant =parseInt(NoOfTenant);
                    let itemList = [];
                    let emptylist = component.get("v.arrObj");
                    if (!isNaN(newNoOfTenant)) {
                        for (let i = 1; i <= newNoOfTenant; i++) {
                            itemList.push(i);
                        }
                    }
                    let listcount = emptylist.length;
                    
                    for (let j = 1; j <= newNoOfTenant ; j++) {
                        var person = new Object();
                        person.firstName = "";
                        person.SurName = "";
                        person.email = "";
                        person.phone = "";
                        person.title = "";
                        person.item = j + listcount;
                        emptylist.push(person);
                    }
                    component.set("v.arrObj", emptylist);
                    component.set("v.tenantItemList",itemList);
                    //component.set("v.newtenancycomponent",false);
                    component.set("v.itemListlength", itemList.length); 
            }
        }
        
        if(isValid)
        {
            // for closing Window 1
            component.set("v.isWindow1",false);
            // for closing Window 2
            component.set("v.changeovertenants",false);
            //for opening Window 3
            component.set("v.moretenantsection",true);
            var step3 = component.find('step3');
            $A.util.addClass(step3, 'active');
        }
    },
    
    depositdetails:function(component, event, helper) {
        component.set("v.newtenancycomponent",true);
        component.set("v.moretenantsection",false);
    },
    
    clickYes: function (component, event, helper) {
        component.set("v.registerTenant", false);
        component.set("v.alreadyregistertenant", true);
        
        var ys = component.find("alrRegTentYes");
        var no = component.find("alrRegTentNo");
        
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
    },
    
    clickNo: function (component, event, helper) {
        component.set("v.registerTenant", true);
        component.set("v.alreadyregistertenant", false);
        component.set("v.registertenantbutton", false);
        
        var ys = component.find("alrRegTentYes");
        var no = component.find("alrRegTentNo");
        
        $A.util.addClass(no, "clickButton");
        $A.util.removeClass(ys, "clickButton");
    },
    
    hideDepositList: function (component, event, helper) {
        /*
        let inputOnBlurId = event.getSource().getLocalId();
        alert(inputOnBlurId);
         var abc = component.find('searchField').value;
        if(abc==undefined)
        {
			component.set("v.showdepositlist",false);
        }
        var selecteddeposit = component.get("v.selecteddeposit");
        alert(selecteddeposit.length);
        if(selecteddeposit.length>0)
        {
            component.set("v.isWin2BtnDisabled",false);
        }*/
    },
    
    searchKeyChange: function (component, event) {
        var searchField = component.find("searchField").get("v.value");
        var olddepositid = component.get("v.olddepositid");
        var action = component.get("c.getDeposit");
        action.setParams({
            searchField: searchField,
            olddepositid:olddepositid
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                console.log('line-->33'+ JSON.stringify(result));
                component.set("v.depositlist", a.getReturnValue());
                component.set("v.showdepositlist", true);
                // console.log(JSON.stringify(result));
                /* if (a.getReturnValue() != null) {
          component.set("v.Continuebtnflag", false);
        } else {
          component.set("v.Continuebtnflag", true);
        }
      } else {*/
            } 
        });
        $A.enqueueAction(action);
    },
    
    selectedRecord: function (component, event, helper) {
        let selectRecord = event.target.id;
        if(selectRecord)
        {
            component.set("v.isWin2BtnDisabled",false);
        }
        //alert(selectRecord);
        //alert(component.get("v.isWin2BtnDisabled"));
        let recordID = selectRecord.slice(0, 18);
        var action = component.get("c.getselectedDeposit");
        action.setParams({
            selecteddepositid: recordID
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                console.log('line-->61'+ JSON.stringify(result));
                component.set("v.selecteddeposit", a.getReturnValue());
                component.set("v.showdepositlist", false);
                // console.log(JSON.stringify(result));
                /* if (a.getReturnValue() != null) {
          component.set("v.Continuebtnflag", false);
        } else {
          component.set("v.Continuebtnflag", true);
        }
      } else {*/
            } 
        });
        $A.enqueueAction(action);
        
    },
    
    dochangeover2:function (component, event, helper) {
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var selecteddeposit = component.get("v.selecteddeposit");
        let changeovertenantslist =component.get("v.updatechangeovertenant");
        var tenantChange = component.get("v.tenantChangeOver"); 
        var depositId = component.get("v.deptenantlist[0].Depositobject.Id");
        console.log(JSON.stringify(selecteddeposit)+' -dep&&tenchange- '+tenantChange+' --depositId-- '+depositId);
         console.log(JSON.stringify(selecteddeposit)+' -** -- '+JSON.stringify(changeovertenantslist));
        // depositid:component.get("v.deptenantlist[0].Depositobject.Id"),
        // alert(JSON.stringify(selecteddeposit)); 
        var action = component.get("c.changeoverrequest2");
        action.setParams({
            depositid:depositId,  
            Depolist:JSON.stringify(changeovertenantslist),
            selecteddeposit:JSON.stringify(selecteddeposit),
            tenantChange:tenantChange
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retNewDepositId = response.getReturnValue();
            console.log('retNewDepositId '+retNewDepositId);
          //  retNewDepositId = retNewDepositId.split("=")[1];
            	var stateRtrn;
			if(branchId != null){
           		  stateRtrn = {
         	 	  id : depositId,
                branchId : branchId
        		};
            }else{
                  stateRtrn = {
                   id : depositId
                };
            }
              console.log(JSON.stringify(stateRtrn)+' stateRtrn '+state);
            if (state === "SUCCESS") {
               
                if(tenantChange == 'true'){
                     console.log('if');
                    /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Changeover Request approved successfully."
                    });
                    toastEvent.fire(); */
                    
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: stateRtrn
                    });
                    
                }else{
                    console.log('else');
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Tenancy Changeover Request initiated."
                    });
                    toastEvent.fire(); */
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: stateRtrn
                    });
                    
                }
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            console.log("Error message: " + JSON.stringify(errors[0].message)
                                       );
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    
    dochangeover3:function (component, event, helper) {
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        let newtenantsNo = component.get("v.newtenantnumber");
        let newdepositamt =component.get("v.newdepositamount");
        let newdepositstartdate = component.get("v.newdepositstartdate");
        let alltenants = component.get("v.deptenantlist[0].Depositobject.Number_of_Tenants__c");
        let changeovertenants = component.get("v.updatechangeovertenant").length;
        let selectedtenantids = component.get("v.selectedtenantids");
        let changeovertenantslist =component.get("v.updatechangeovertenant"); 
        let newtenantlist = component.get("v.arrObj");
        var tenantChange = component.get("v.tenantChangeOver"); 
        var depositId = component.get("v.deptenantlist[0].Depositobject.Id");

    	console.log(`746 newtenantlist -->> ${JSON.stringify(newtenantlist)}`);
        var action = component.get("c.changeoverrequest3");
        action.setParams({
            depositid:depositId,  
            newdepositamount:newdepositamt,
            newtenantsnumber:newtenantsNo,
            newdepositstartdate:newdepositstartdate,
            Depolist:JSON.stringify(changeovertenantslist),
            newtenantlist:JSON.stringify(newtenantlist),
            tenantChange : tenantChange
            //Depolist:selectedtenantids
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retNewDepositId = response.getReturnValue();
         //   retNewDepositId = retNewDepositId.split("=")[1];
            	var stateRtrn;
			if(branchId != null){
           		  stateRtrn = {
         	 	  id : depositId,
                branchId : branchId
        		};
            }else{
                  stateRtrn = {
                   id : depositId
                };
            }
            if (state === "SUCCESS") {
                console.log('723');
                if(tenantChange == 'true'){
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Changeover Request approved successfully."
                    });
                    toastEvent.fire(); */
                    
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: stateRtrn
                    });
                    
                }else{
                    console.log('744');
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Tenancy Changeover Request initiated."
                    });
                    toastEvent.fire();*/ 
                    component.find("navService").navigate({
                        type: "comm__namedPage",
                        attributes: {
                            pageName: "depositsummarypage"
                        },
                        state: stateRtrn
                    });
                    
                }
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            console.log("Error message: " + JSON.stringify(errors[0].message)
                                       );
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        console.log('782');
    },

    EI_Tenantchangeoverdetails: function (component, event, helper) {
        console.log('Line 877');
        //Get and set the parameters recieved from component event to cmp attribute
        var arrObj = event.getParam("arrObj");
        console.log('Line 880');
        console.log('Line 881 arrObj',JSON.stringify(arrObj));
        // alert(arrObj.item);
        //console.log("arrObj item:", arrObj.item);
        let arr = [];
        arr = component.get("v.arrObj");
        if (arr.length > 0) {
            for (let i = 0; i < arr.length; i++) {
                if (arr[i].item == arrObj.item) {
                    arr[i] = arrObj;
                }
            }
        } else {
            arr.push(arrObj);
        }
        component.set("v.arrObj", arr);
        console.log('Line 897 arrObj',JSON.stringify(arr));
    },
    
    handleGoBack : function(component, event, helper) {
        history.back();
        /*
        var depositId = component.get("v.deptenantlist[0].Depositobject.Id");
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositId
                
            }
        });*/
	},
    
    handleComponentEvent : function(cmp, event) {
        
        // set the handler attributes based on event data
        cmp.set("v.showAddressFlag", false);
        cmp.set("v.windowNum","Window 2");
        cmp.set("v.isWindow1",false);
        cmp.set("v.changeovertenants",true);
        var step2 = cmp.find('step2');
        $A.util.addClass(step2, 'active');
        
    },
        
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "selectedTenants":
                component.set("v.isValidTenantCount", false);
                break;
            case "validAmount":
                component.set("v.isValidEnteredAmt", false);
                break;
            case "validTotalAmount":
                component.set("v.isValidTotalAmt", false);
                break;
            case "totalTenants":
                component.set("v.isValidTotalTenants", false);
                break;
            case "tenancyStartDate":
                component.set("v.isValidTenancyStartDate", false);
                break;
            case "depositAmount":
                component.set("v.isValidDepositAmt", false);
                break;
            case "numOfTenants":
                component.set("v.isValidNumOfTenants", false);
                break;
            case "emailMobile":
                component.set("v.emailMobileError", false);
                break;
            case "invalidEmailFormat":
                component.set("v.invalidEmailFormatError", false);
                break;
            case "invalidPhoneFormat":
                component.set("v.invalidPhoneFormatError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;   
            case "duplicateEmailError":
                component.set("v.duplicateEmailError", false);
                break;
            case "duplicateEmailInDepositError":
                component.set("v.duplicateEmailInDepositError", false);
                break;
            case "duplicatePhoneInDepositError":
                component.set("v.duplicatePhoneInDepositError", false);
                break;   
            case "maxTenants":
                component.set("v.isValidMaxTenants", false);
                break;
            case "amountCantBeLessThan1Error":
                component.set("v.amountCantBeLessThan1Error", false);
                break;
        }
    },
    
})