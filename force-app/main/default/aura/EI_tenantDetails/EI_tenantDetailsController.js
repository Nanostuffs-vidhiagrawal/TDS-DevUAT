({
   doInit: function (component, event, helper) {
       
        helper.getError(component, event, helper);
        
        helper.apex(component,'getPhoneCodePiclistValues',{ })
        .then(function(result){
            console.log('Call 1 : ' , result );
            component.set("v.phoneCodePicklist", result );
            
            var IsLeadTenant = component.get("v.IsLeadTenant");
            
            console.log('beforeTitle '+component.get("v.title"));
            
            if (!IsLeadTenant) {
                var item = component.get("v.item");
                var arrObj = component.get("v.arrObj");
                console.log("line 12 arrObj "+ JSON.stringify(arrObj));
                console.log('item13 '+item)
                if (arrObj.length > 0) {
                    for (var i = 1; i <= arrObj.length; i++)
                        
                        if(arrObj[item - 1].IsOrg)
                        {
                            component.set("v.email", arrObj[item - 1].email);
                            component.set("v.phoneCode", arrObj[item - 1].phoneCode);
                            component.set("v.phone", arrObj[item - 1].phone);
                            component.set("v.companyName", arrObj[item - 1].companyName);
                            component.set("v.IsOrg", true);
                            
                            var valcode = arrObj[item - 1].phoneCode;
                            //$('#selectPhoneCode'+item).val(valcode);
                            document.getElementById("selectPhoneCode"+item).value = arrObj[item - 1].phoneCode; 
                            
                        }
                        else
                        {
                            component.set("v.title", arrObj[item - 1].title);
                            component.set("v.FirstName", arrObj[item - 1].firstName);
                            component.set("v.SurName", arrObj[item - 1].SurName);
                            component.set("v.phoneCode", arrObj[item - 1].phoneCode);
                            component.set("v.email", arrObj[item - 1].email);
                            component.set("v.phone", arrObj[item - 1].phone);
                            
                            var valcode = arrObj[item - 1].phoneCode;
                            //$('#selectPhoneCode'+item).val(valcode);
                            console.log("cod ephone " + arrObj[item - 1].phoneCode);
                            document.getElementById("selectPhoneCode"+item).value = arrObj[item - 1].phoneCode; 
                            
                            setTimeout(function(){ 
                                
                                console.log(item +'titlenot item'+ document.getElementById("titleId"+item));   
                                
                                if( arrObj[item - 1].title != ''){
                                    component.set("v.isClicked", true);
                                    var ys =  document.getElementById("orgBtn"+item);
                                    var no =   document.getElementById("personBtn"+item);
                                    $A.util.removeClass(ys, "clickButton");
                                    $A.util.addClass(no, "clickButton");
                                    document.getElementById("titleId"+item).value = arrObj[item - 1].title;   
                                }
                            }, 500);
                            /*   if( arrObj[item - 1].title != ''){
                        document.getElementById("titleId"+arrObj[item - 1]).value = arrObj[item - 1].title;   
                    }*/
                    console.log('titlenotlead '+component.get("v.title"));
                    component.set("v.IsOrg", false);
                    
                }    
                
            }
        } else {
            var leadTenantObj = component.get("v.leadTenantObj");
            console.log("line 35 leadTenantObj "+ JSON.stringify(leadTenantObj));
            if(leadTenantObj != null)
            {
                
                if ( leadTenantObj.IsOrg == false) {
                    component.set("v.title", leadTenantObj.title);
                    component.set("v.FirstName", leadTenantObj.firstName);
                    component.set("v.SurName", leadTenantObj.SurName);
                    component.set("v.email", leadTenantObj.email);
                    component.set("v.phoneCode", leadTenantObj.phoneCode);
                    component.set("v.phone", leadTenantObj.phone);
                    component.set("v.companyName", "");
                    component.set("v.IsOrg", false);
                    setTimeout(function(){ 
                        component.set("v.isClicked", true);
                        console.log('titlelead '+ document.getElementById("titleId"));    
                        if(leadTenantObj.title != ''){
                            var ys = document.getElementById("orgBtn");
                            var no =   document.getElementById("personBtn");
                            $A.util.removeClass(ys, "clickButton");
                            $A.util.addClass(no, "clickButton");
                            document.getElementById("titleId").value = leadTenantObj.title;
                        }
                    }, 500);
                    
                    var valcode = leadTenantObj.phoneCode;
                    $('#selectPhoneCode').val(valcode);
                    
                    /*      console.log('titlelead '+ document.getElementById("titleId"));
                    if(leadTenantObj.title != ''){
                   document.getElementById("titleId").value = leadTenantObj.title;
                    }*/
                    console.log('titlelead '+component.get("v.title"));
                    
                } else if ( leadTenantObj.IsOrg == true) {
                    component.set("v.email", leadTenantObj.email);
                    component.set("v.phoneCode", leadTenantObj.phoneCode);
                    component.set("v.phone", leadTenantObj.phone);
                    component.set("v.companyName", leadTenantObj.companyName);
                    component.set("v.IsOrg", true);
                    
                    var valcode = leadTenantObj.phoneCode;
                    $('#selectPhoneCode').val(valcode);
                }
            }
            
        }
            console.log('titleOut '+component.get("v.title"));
        });
    },
    
    doInit2: function (component, event, helper) {
         // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        
        var IsLeadTenant = component.get("v.IsLeadTenant");
         console.log('IsLeadTenant '+IsLeadTenant);
        console.log('beforeTitle '+component.get("v.title"));
        console.log('beforephoneCode '+component.get("v.phoneCode"));
 		
        if (!IsLeadTenant) {
            var item = component.get("v.item");
            var arrObj = component.get("v.arrObj");
           console.log("line 12 arrObj "+ JSON.stringify(arrObj));
            console.log('item13 '+item)
            if (arrObj.length > 0) {
                for (var i = 1; i <= arrObj.length; i++)
                    
                    if(arrObj[item - 1].IsOrg)
                    {
                        component.set("v.email", arrObj[item - 1].email);
                        //component.set("v.phoneCode", arrObj[item - 1].phone_Code__pc);
                        component.set("v.phone", arrObj[item - 1].phone);
                        component.set("v.companyName", arrObj[item - 1].companyName);
                        component.set("v.IsOrg", true);
                        var valcode = arrObj[item - 1].phoneCode;
                        //$('#selectPhoneCode'+item).val(valcode);
                        document.getElementById("selectPhoneCode"+item).value = arrObj[item - 1].phoneCode; 
                    }
                else
                {
                    component.set("v.title", arrObj[item - 1].title);
                    component.set("v.FirstName", arrObj[item - 1].firstName);
                    component.set("v.SurName", arrObj[item - 1].SurName);
                    component.set("v.email", arrObj[item - 1].email);
                    component.set("v.phone", arrObj[item - 1].phone);
                    var valcode = arrObj[item - 1].phoneCode;
                    //$('#selectPhoneCode'+item).val(valcode);
                    console.log("cod ephone " + arrObj[item - 1].phoneCode);
                   document.getElementById("selectPhoneCode"+item).value = arrObj[item - 1].phoneCode; 
                    
                    setTimeout(function(){ 
                        
                        console.log(item +'titlenot item'+ document.getElementById("titleId"+item));   
                        
                       if( arrObj[item - 1].title != ''){
                                  component.set("v.isClicked", true);
							   var ys =  document.getElementById("orgBtn"+item);
   						 var no =   document.getElementById("personBtn"+item);
                          $A.util.removeClass(ys, "clickButton");
      					  $A.util.addClass(no, "clickButton");
                        document.getElementById("titleId"+item).value = arrObj[item - 1].title;  
                           console.log('line 51 ' + document.getElementById("titleId"+item));
                    }
                                         }, 500);
                    
                    
                 /*   if( arrObj[item - 1].title != ''){
                        document.getElementById("titleId"+arrObj[item - 1]).value = arrObj[item - 1].title;   
                    }*/
                    console.log('titlenotlead '+component.get("v.title"));
                    component.set("v.IsOrg", false);
                   
                }    
                 
            }
        } else {
            var leadTenantObj = component.get("v.leadTenantObj");
         	console.log("line 35 leadTenantObj "+ JSON.stringify(leadTenantObj));
            if(leadTenantObj != null)
            {
         
                if ( leadTenantObj.IsOrg == false) {
                    component.set("v.title", leadTenantObj.title);
                    component.set("v.FirstName", leadTenantObj.firstName);
                    component.set("v.SurName", leadTenantObj.SurName);
                    component.set("v.email", leadTenantObj.email);
                    //document.getElementById("selectPhoneCode").value = leadTenantObj.phone_Code__pc; 
                    component.set("v.phone", leadTenantObj.phone);
                    component.set("v.companyName", "");
                    component.set("v.IsOrg", false);
                    setTimeout(function(){ 
                              component.set("v.isClicked", true);
                           console.log('titlelead '+ document.getElementById("titleId"));    
                        if(leadTenantObj.title != ''){
                            var ys = document.getElementById("orgBtn");
                            var no =   document.getElementById("personBtn");
                            $A.util.removeClass(ys, "clickButton");
                            $A.util.addClass(no, "clickButton");
                            document.getElementById("titleId").value = leadTenantObj.title;
                        }
                                         }, 500);

                    var valcode = leadTenantObj.phoneCode;
                    $('#selectPhoneCode').val(valcode);
                    
               /*      console.log('titlelead '+ document.getElementById("titleId"));
                    if(leadTenantObj.title != ''){
                   document.getElementById("titleId").value = leadTenantObj.title;
                    }*/
                    console.log('titlelead '+component.get("v.title"));
                    
                } else if ( leadTenantObj.IsOrg == true) {
                    component.set("v.email", leadTenantObj.email);
                    component.set("v.phone", leadTenantObj.phone);
                    //document.getElementById("selectPhoneCode").value = leadTenantObj.phone_Code__pc; 
                    component.set("v.companyName", leadTenantObj.companyName);
                    component.set("v.IsOrg", true);
                    var valcode = leadTenantObj.phoneCode;
                    $('#selectPhoneCode').val(valcode);
                }
            }
            
        }
         console.log('titleOut '+component.get("v.title"));
       
        
    },
    
    doEnableOrg: function (component, event, helper) {
        
           var item = component.get("v.item");
        console.log('TEST '+event.currentTarget.id);
         console.log('item '+item);
        if(item != undefined){
            component.set("v.isClicked", true);
             var ys =  document.getElementById("orgBtn"+item);
   		 var no =   document.getElementById("personBtn"+item);
  		console.log('ys '+ys+' ' +no);
 		  $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
      component.set("v.IsOrg", true);
        }else{
            component.set("v.isClicked", true);
               var ys =  document.getElementById("orgBtn"); //component.find("orgBtn");
   			 var no =  document.getElementById("personBtn"); //component.find("personBtn");
 
 		  $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
            component.set("v.IsOrg", true);
          
        }
       
        
        
      /*  component.set("v.FirstName", "");
        component.set("v.SurName", "");
        component.set("v.email", "");
        component.set("v.phone", "");
        component.set("v.title", "");*/
    },
    
    doPerson: function (component, event, helper) {
            
          var item = component.get("v.item");
       console.log('TEST '+event.currentTarget.id);
        console.log('item '+item);
        if(item != undefined){
         var ys =  document.getElementById("orgBtn"+item);
   		 var no =   document.getElementById("personBtn"+item);
  		console.log('ys '+ys+' ' +no);
 		  $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");
             component.set("v.isClicked", true);
              component.set("v.IsOrg", false);
        }else{
              var ys =  document.getElementById("orgBtn"); //component.find("orgBtn");
   			 var no =  document.getElementById("personBtn"); //component.find("personBtn");
 
 		  $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");
           component.set("v.isClicked", true);
              component.set("v.IsOrg", false);
        }
     
     
      
       component.set("v.companyName", "");
    //    component.set("v.email", "");
     //   component.set("v.phone", "");
    },
    
    onChangeTitle: function (component, event, helper) {
    // $("#titleId option:selected").attr("selected", "true");
   var map1 = new Map();
    var item = component.get("v.item");
        if(item != undefined){
             console.log('item '+item);
          console.log('TEST '+event.currentTarget.id);
       var title = document.getElementById(event.currentTarget.id).value;
       console.log('title '+title);
            map1.set(item,title);
            component.set("v.title",title);
        }else{
             console.log('event.currentTarget.id '+event.currentTarget.id);
             var title = document.getElementById(event.currentTarget.id).value;
       console.log('title '+title);
            map1.set('leadtenant',title);
              component.set("v.title",title);
        }
    
      // var optionText = $("#titleId option:selected").text();
     //    console.log('optionText '+optionText);

    },
    
    handleEmailBlur: function (component, event, helper) {
        let email = component.get("v.email");
        component.set("v.changeInEmail",true);
        //component.set("v.duplicateEmailError",false);
        helper.checkEmailDuplicacy(component, email);
    },
    
    handlePhoneBlur: function (component, event, helper) {
        let phone = component.get("v.phone");
          component.set("v.changeInPhone",true);
        helper.checkPhoneDuplicacy(component, phone);
    },
    
    doSubmit: function (component, event, helper) {
        //alert("do submit ===>>>");
        var isValid = true;
        var IsDuplicateEmail = true;
        
        component.set("v.yesNoError", false);		
        component.set("v.companyNameError", false);
        component.set("v.companyEmailError", false);
        component.set("v.companyPhoneError", false);
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailMobileError", false);
        component.set("v.invalidEmailFormatError", false);
        component.set("v.PhonelengthError",false);    
        component.set("v.invalidPhoneFormatError", false);
        component.set("v.succeessmessage", false);
        //component.set("v.duplicateEmailError", false);
        component.set("v.duplicateEmailInDepositError", false);
        component.set("v.duplicatePhoneInDepositError", false);
        		
       console.log('org '+component.get("v.IsOrg") +' clicked '+component.get("v.isClicked"));
		 if(component.get("v.IsOrg") == undefined ||  (!component.get("v.isClicked") || component.get("v.isClicked") == 'undefined' )){
			 console.log('139');
              component.set("v.yesNoError", true);
              isValid = false;
             
        }
        else if(component.get("v.IsOrg"))
        {
			 component.set("v.yesNoError", false);
            var companyNamecheck = component.find("compNameId").get("v.value");
            var emailCheck = component.find("emailID").get("v.value");
            var phoneCode = component.get("v.phoneCode"); //document.getElementById("selectPhoneCode").value;
        	var mobileCheck = component.find("mobileId").get("v.value");
            
            var email = emailCheck;
            var isValidEmailFormat = false;
            var isValidPhoneFormat = false;
            
            let leadRec = component.get("v.leadTenantObj");
            let tenantRec= component.get("v.arrObj");

            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null) {
                component.set("v.companyNameError",true);    
                isValid = false;

            }
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;

            }
            else
            {

                if(emailCheck)
                {

                    isValidEmailFormat = helper.emailFormatChecker(component, email);
					console.log("isValidEmailFormat",isValidEmailFormat);
                    if(!isValidEmailFormat)
                    {
                 		console.log("Line 129");
                        isValid = false;

                        component.set("v.invalidEmailFormatError",true);
                    }
                    else
                    {
                        console.log("Line 259");
                        
						/* var emailChecker = helper.checkEmailInSystem(component, email);
                        
                        console.log("emailChecker 136 ",emailChecker);
                        if(emailChecker){
                            isValid = false;
                            component.set("v.duplicateEmailError",true);
                        }*/
                        
                        
                       IsDuplicateEmail = component.get("v.IsDuplicateEmail");
                        
                        if(IsDuplicateEmail) {
            
                           isValid = false;
                           
                            component.set("v.duplicateEmailError",true);
                        }
                        //Arrobject duplicates
                        	// let leadRec = component.get("v.leadTenantObj");
                           // let tenantRec= component.get("v.arrObj");
                        	//console.log("tenantRec 147",tenantRec);
                       console.log('210 ');
                        if(leadRec != null)
                        {
                            if(component.get("v.email") && component.get("v.email") != null ){
                                console.log('Line 118');
                                if(leadRec.email == component.get("v.email") && component.get("v.changeInEmail"))
                                {
                                    isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    //alert("This email Id is already used for other tenant");
                                }
                            }
                          
                        }
                        console.log('223');
                            for(let k=0; k<tenantRec.length ;k++ )
                            {console.log('225');
                                if(component.get("v.email") && component.get("v.email") != null){
                                    if(tenantRec[k].email ==component.get("v.email") && k+1 != tenantRec[k].item)
                                    {
                                        //validatearr = false;
                                        component.set("v.duplicateEmailInDepositError",true);
                                        isValid = false;
                                       // alert("This email Id is already used for other tenant in this deposit");
                                        break;
                                    }
                                    console.log('235 '+leadRec);
									if(leadRec != null)
										{  console.log('237 '+leadRec.email+' '+tenantRec[k].email);
									 if(tenantRec[k].email == leadRec.email && component.get("v.changeInEmail")){
										 isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
									 break;
										}
										}
                                }
                            }
                        console.log("161 isValid",isValid);
                            
 
                    }
                }
               if(mobileCheck)
                {
                    isValidPhoneFormat = helper.phoneFormatChecker(component, phoneCode, mobileCheck);

                    if(!isValidPhoneFormat)
                    {
                        if(phoneCode == "+44"){
                            isValid = false;
                            component.set("v.PhonelengthError",true);
                        }else{
                            isValid = false;
                            component.set("v.invalidPhoneFormatError",true);
                        }
                    }else{
                        if(leadRec != null)
                        {
                            if(component.get("v.phone").length>0){
                                if(leadRec.phone == component.get("v.phone") && component.get("v.changeInPhone"))
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                }
                    }
                          
                        }
                        
                            for(let k=0; k<tenantRec.length ;k++ )
                            {
                                if(component.get("v.phone").length>0){
                                    if(tenantRec[k].phone ==component.get("v.phone") && k+1 != tenantRec[k].item)
                                    {
                                        isValid = false;
                                        component.set("v.duplicatePhoneInDepositError",true);
                                        //alert("This Phone is already used for other tenant");
                                        break;
                                    }
                                    if(leadRec != null)
									{  console.log('237 '+leadRec.email+' '+tenantRec[k].email);
									 if(tenantRec[k].phone == leadRec.phone && component.get("v.changeInPhone")){
										 isValid = false;
                                    	component.set("v.duplicatePhoneInDepositError",true);
										 break;
										}
									}
                                }
                            }
                    }
                }
            }
            
        }
        else
        {
			// component.set("v.yesNoError", false);
        //     var title = document.getElementById("titleId").value; 
         //   var titleCheck = component.get("v.title");
      
         console.log('&&title254 '+component.get("v.title"));
            var titleCheck = component.get("v.title");
            var firstNameCheck = component.find("firstNameId").get("v.value");
            var surnameCheck = component.find("surNameId").get("v.value");
            var emailCheck = component.find("emailID").get("v.value");
            var phoneCode = component.get("v.phoneCode");
        	var mobileCheck = component.find("mobileId").get("v.value");
            if(component.get("v.IsOrg") == undefined || (!component.get("v.isClicked") || component.get("v.isClicked") == undefined )){
              component.set("v.yesNoError", true);
              isValid = false;
             
       		 }
            var email = emailCheck;
            console.log('emailvia tenant '+email);
            var emailChecker = helper.checkEmailInSystem(component, email);
            
            var isValidEmailFormat = false;
            var isValidPhoneFormat = false;
            
            let leadRec = component.get("v.leadTenantObj");
            let tenantRec= component.get("v.arrObj");
            
			console.log('titleCheck327 '+titleCheck);
            if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {
               		console.log('titleCheck329 '+titleCheck);
                component.set("v.titleError",true);    
                isValid = false;
            }
           // console.log('Working1');
            if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {
                component.set("v.firstNameError",true);    
                isValid = false;
            }
           // console.log('Working2');
            if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
                component.set("v.surNameError",true);    
                isValid = false;
            }
         //   console.log('Working3');
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;
            }else{
                if(emailCheck)
                {
                    isValidEmailFormat = helper.emailFormatChecker(component, email);
					console.log("isValidEmailFormat",isValidEmailFormat);
                    if(!isValidEmailFormat)
                    {
                 		console.log("Line 272");
                        isValid = false;

                        component.set("v.invalidEmailFormatError",true);
                    }
                    else
                    {
                        console.log("Line 353");
                        
						/* var emailChecker = helper.checkEmailInSystem(component, email);
                        
                        console.log("emailChecker 136 ",emailChecker);
                        if(emailChecker){
                            isValid = false;
                            component.set("v.duplicateEmailError",true);
                        }*/
                        
                        
                       IsDuplicateEmail = component.get("v.IsDuplicateEmail");
                        
                        if(IsDuplicateEmail) {
            
                           isValid = false;
                           
                            component.set("v.duplicateEmailError",true);
                        }
                   
                        //Arrobject duplicates
                        	// let leadRec = component.get("v.leadTenantObj");
                           // let tenantRec= component.get("v.arrObj");
                        	//console.log("tenantRec 147",tenantRec);
                        if(leadRec != null)
                        {
                                  console.log("Line 379 leadRec "+leadRec.email);
                            if(component.get("v.email") && component.get("v.email") != null ){
                                console.log('Line 380');
                                if(leadRec.email == component.get("v.email") && component.get("v.changeInEmail"))
                                {
                                    isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    //alert("This email Id is already used for other tenant");
                                }
                            }
                          
                        }
                          console.log("Line 390 tenantRec "+tenantRec);
                        for(let k=0; k<tenantRec.length ;k++ )
                        {   console.log("Line 393 tenantRec " + tenantRec[k].email +' '+component.get("v.email") +' '+tenantRec[k].item);
                            if(component.get("v.email") && component.get("v.email") != null){
                                if(tenantRec[k].email ==component.get("v.email") && k+1 != tenantRec[k].item)
                                {console.log("Line 396 tenantRec ");
                                    //validatearr = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    isValid = false;
                                    // alert("This email Id is already used for other tenant in this deposit");
                                    break;
                                }
                                  console.log("Line 402 leadRec ");
								if(leadRec != null)
										{
                                             console.log(component.get("v.email") + "Line 406 leadRec.email "+tenantRec[k].email + ' && ' + component.get("v.changeInEmail"));
									 if(tenantRec[k].email == component.get("v.email")  && component.get("v.changeInEmail")){
										 isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
									 break;
										}
										}
                            }
                        }
                        console.log("161 isValid",isValid);
                            
 
                    }
                }
               if(mobileCheck)
                {
                    isValidPhoneFormat = helper.phoneFormatChecker(component, phoneCode, mobileCheck);

                    if(!isValidPhoneFormat)
                    {
                        if(phoneCode == "+44"){
                            isValid = false;
                            component.set("v.PhonelengthError",true);
                        }else{
                            isValid = false;
                            component.set("v.invalidPhoneFormatError",true);
                        }
                    }
                    else{
                        if(leadRec != null)
                        {
                            if(component.get("v.phone").length>0){
                                
                                if(leadRec.phone == component.get("v.phone") && component.get("v.changeInPhone"))
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                }
                            }
                        }
                        for(let k=0; k<tenantRec.length ;k++ )
                        {
                            if(component.get("v.phone").length>0){
                                if(tenantRec[k].phone ==component.get("v.phone") && k+1 != tenantRec[k].item)
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                    break;
                                }
                                 if(leadRec != null)
									{  console.log('237 '+leadRec.email+' '+tenantRec[k].email);
									 if((leadRec.phone !== "" && tenantRec[k].phone !== "") && tenantRec[k].phone == leadRec.phone && component.get("v.changeInPhone")){
										 isValid = false;
                                         console.log('@#702 '+isValid);
                                    	component.set("v.duplicatePhoneInDepositError",true);
										 break;
										}
									}
                            }
                        }
                    }
                    
                }
            }
             
          
        }


        var companyName = component.get("v.companyName");
		console.log("451 companyName "+companyName);
		  console.log('org452 '+component.get("v.IsOrg"));
        if (companyName) {
			console.log("454 companyName "+companyName);
		  console.log('org455 '+component.get("v.IsOrg"));
              if(component.get("v.IsOrg") == undefined || (!component.get("v.isClicked") || component.get("v.isClicked") == undefined )){
              component.set("v.yesNoError", true);
              isValid = false;
             
       		 }
            if(isValid){
                var person = new Object();
            person.email = component.get("v.email");
            person.phoneCode = component.get("v.phoneCode");
            person.phone = component.get("v.phone");
            person.companyName = component.get("v.companyName");
            person.LeadSummary = component.get("v.LeadSummary");
            person.IsOrg = component.get("v.IsOrg");
            person.item = component.get("v.item");
            person.IsformSubmitted = true;
            //   Disable button and the class
            component.find("doSubmit").set("v.disabled", true);
            
          
            // Fire the Event
            var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
            EI_tenantDetailEvent.setParams({
                arrObj: person
            });
            EI_tenantDetailEvent.fire();
            console.log(" Line 196 person : ",person);
            var cmpTarget = component.find("changeIt");
            $A.util.addClass(cmpTarget, "changeMe");
            }
            else{
                 document.getElementById("sf-tabContent").scrollIntoView();
            }
            
        } 
        else {
			
		  console.log('org491 '+component.get("v.IsOrg"));
			if(component.get("v.IsOrg") == undefined ||  (!component.get("v.isClicked") || component.get("v.isClicked") == undefined )){
				console.log('487');
              component.set("v.yesNoError", true);
              isValid = false;
             
       		 }

                let leadRec = component.get("v.leadTenantObj");
                let tenantRec= component.get("v.arrObj");
                var inputCmp = component.find("emailfield");
            let validateEmail  = true;
            let validatePhone  = true;
      console.log("Line 516 tenantRec "+leadRec);
                if(leadRec != null)
                {

                    if(component.get("v.email") && component.get("v.email") != null ){
                        console.log('Line 118component.get("v.IsLeadTenant") '+component.get("v.IsLeadTenant"));
                        if(leadRec.email == component.get("v.email") && component.get("v.changeInEmail"))
                        {
                            validateEmail = false;
                            component.set("v.duplicateEmailInDepositError",true);
                            //alert("This email Id is already used for other tenant");
                        }
                    }
              
                    if(component.get("v.phone").length>0){
               
                        if(leadRec.phone == component.get("v.phone") && component.get("v.changeInPhone"))
                        {
                            validatePhone = false;
                            component.set("v.duplicatePhoneInDepositError",true);
                            //alert("This Phone is already used for other tenant");
                        }
                    }
                }
                let validatearr = true;
            	let validatePhonearr = true;
            	  console.log('Line 542');
                for(let k=0; k<tenantRec.length ;k++ )
                {
                     console.log('Line 545');
                    if(component.get("v.email") && component.get("v.email") != null){
                         console.log('Line 333 tenantRec[k].item '+tenantRec[k].item);
                        if(tenantRec[k].email ==component.get("v.email") && k+1 != tenantRec[k].item)
                        {
                            validatearr = false;
                            component.set("v.duplicateEmailInDepositError",true);
                             console.log('Line 641');
                            //alert("This email Id is already used for other tenant");
                            break;
                        }
						if(leadRec != null)
										{
                            console.log(component.get("v.email") + "Line 4647 leadRec.email "+tenantRec[k].email + ' && ' + component.get("v.changeInEmail") +' @@ '+leadRec.email);                 
									 if(tenantRec[k].email == leadRec.email && component.get("v.changeInEmail") && tenantRec[k].email != ''){
                                            console.log('Line 648');
										 isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
									 break;
										}
										}
                    }
                    
                    if(component.get("v.phone").length>0){
                        if(tenantRec[k].phone ==component.get("v.phone") && k+1 != tenantRec[k].item)
                        {
                            validatePhonearr = false;
                            component.set("v.duplicatePhoneInDepositError",true);
                            //alert("This Phone is already used for other tenant");
                            break;
                        }
                           if(leadRec != null)
									{  console.log(component.get("v.phone")+' @ 666 '+leadRec.phone+' @@ '+tenantRec[k].phone +' ## '+component.get("v.changeInPhone"));
									 if( (component.get("v.phone") === tenantRec[k].phone || component.get("v.phone") === leadRec.phone) && component.get("v.changeInPhone")){
										 isValid = false;
                                    	component.set("v.duplicatePhoneInDepositError",true);
										 break;
										}
									}
                    }
                }
            console.log('isValid843',isValid);
            console.log('validatearr',validatearr);
            console.log('validateEmail',validateEmail);
            console.log('validatePhone',validatePhone);
            console.log('validatePhonearr',validatePhonearr);
            
            //   If fields are populated correctly
            if (isValid && validatearr && validateEmail &&  validatePhone && validatePhonearr) {
                    //   Pass all attributes values as Object to parent with the component Event
                    var person = new Object();
             //   alert('component.get("v.editMode") '+component.get("v.editMode"));
             // component.set("v.title",document.getElementById("titleId").value);
                //	person.CustId = component.get("v.item");
                //	alert("comp phonecode : " + component.get("v.phoneCode"))	;
                    person.firstName = component.get("v.FirstName");
                    person.SurName = component.get("v.SurName");
                    person.email = component.get("v.email");
                person.phoneCode = component.get("v.phoneCode");
                    person.phone = component.get("v.phone");
                    person.title = component.get("v.title");
                    person.companyName = component.get("v.companyName");
                    person.LeadSummary = component.get("v.LeadSummary");
                    person.IsOrg = component.get("v.IsOrg");
                    person.item = component.get("v.item");
                    person.IsformSubmitted = true;
             //   alert("comp phonecode : " + person.phoneCode);
                   var cmpTarget = component.find("changeIt");
                   $A.util.addClass(cmpTarget, "changeMe");
                   component.set("v.isClicked", false);
                console.log('component.get("v.isClicked") '+component.get("v.isClicked"));
                    // Fire the Event
                    var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
                     console.log('Line 352');
                    EI_tenantDetailEvent.setParams({
                        arrObj: person
                    });
                     console.log('Line 356');
                    EI_tenantDetailEvent.fire();
                     console.log('Line 357');
                
              //  component.set("v.title","");
                }
                // Is fields are not populated correctly give warning
                else {
                     document.getElementById("sf-tabContent").scrollIntoView();
                    if(validatearr && validateEmail)
                    {
                        //alert("Please update the invalid form entries and try again.");
                    }
                }
            }
        //}
    },
        
    doSubmit11: function (component, event, helper) {
        var isValid = true;
        
        if(component.get("v.IsOrg"))
        {
            var companyNamecheck = component.find("compNameId").get("v.value");
            var emailCheck = component.find("emailID").get("v.value");
        	var mobileCheck = component.find("mobileId").get("v.value");

            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null) {  
                component.set("v.companyNameError",true);    
                isValid = false;
            }
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;
            }
        }
        else
        {
            var titleCheck = component.find("titleId").get("v.value");
            var firstNameCheck = component.find("firstNameId").get("v.value");
            var surnameCheck = component.find("surNameId").get("v.value");
            var emailCheck = component.find("emailID").get("v.value");
        	var mobileCheck = component.find("mobileId").get("v.value");
         //   console.log('titleCheck',titleCheck);
        //    console.log('firstnamecheck',firstNameCheck);
         //   console.log('surnamecheck',surnameCheck);
         //   console.log('emailcheck',emailCheck);
         //   console.log('mobileCheck',mobileCheck);
            if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {
                component.set("v.titleError",true);    
                isValid = false;
            }
           // console.log('Working1');
            if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {
                component.set("v.firstNameError",true);    
                isValid = false;
            }
           // console.log('Working2');
            if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
                component.set("v.surNameError",true);    
                isValid = false;
            }
         //   console.log('Working3');
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;
            }
            //console.log('Working4');
        }

        if(isValid)
        {
            component.set("v.succeessmessage",true);
           
        }
       
        //---------------------------------------------------------------------------------------------------------------
        
        var companyName = component.get("v.companyName");
        if (companyName) {
            var person = new Object();
            person.email = component.get("v.email");
            person.phone = component.get("v.phone");
            person.companyName = component.get("v.companyName");
            person.LeadSummary = component.get("v.LeadSummary");
            person.IsOrg = component.get("v.IsOrg");
            //   Disable button and the class
            component.find("doSubmit").set("v.disabled", true);
            var cmpTarget = component.find("changeIt");
            $A.util.addClass(cmpTarget, "changeMe");
            
            // Fire the Event
            var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
            EI_tenantDetailEvent.setParams({
                arrObj: person
            });
            EI_tenantDetailEvent.fire();
        } 
        else {
            /*
            //   Check Input Validity
            var fields = component.find("field");
            // console.log("typeof fields:", typeof fields);
            var phonefield = component.find("phonefield");
            var emailfield = component.find("emailfield");
            
            if((phonefield.get("v.value")==undefined || phonefield.get("v.value") == null || phonefield.get("v.value") == "") && 
               (emailfield.get("v.value")==undefined || emailfield.get("v.value")==null  || emailfield.get("v.value")== "")){
                alert('Please provide either Phone or Email address');
            }
            else{   
                fields.push(phonefield);
                fields.push(emailfield);
                var allValid = fields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true); */
                let leadRec = component.get("v.leadTenantObj");
                let tenantRec= component.get("v.arrObj");
                var inputCmp = component.find("emailfield");
                let validateEmail  = true;
                
               // console.log('Line 115');
                if(leadRec != null)
                {
                    if(component.get("v.email") && component.get("v.email") != null ){
                        console.log('Line 118');
                        if(leadRec.email == component.get("v.email") )
                        {
                            validateEmail = false;
                            alert("This email Id is already used for other tenant");
                        }
                    }
                }
                let validatearr = true;
                for(let k=0; k<tenantRec.length ;k++ )
                {
                    if(component.get("v.email") && component.get("v.email") != null){
                        if(tenantRec[k].email ==component.get("v.email"))
                        {
                            validatearr = false;
                            alert("This email Id is already used for other tenant");
                            break;
                        }
                    }
                }
                
                
                //   If fields are populated correctly
         //   console.log(`validatearr : ${validatearr} && allValid : ${allValid} && validateEmail :${validateEmail}`);  
                if (isValid && validatearr && validateEmail) {
                    //   Pass all attributes values as Object to parent with the component Event
                    var person = new Object();
                    person.firstName = component.get("v.FirstName");
                    person.SurName = component.get("v.SurName");
                    person.email = component.get("v.email");
                    person.phone = component.get("v.phone");
                    person.title = component.get("v.title");
                    person.companyName = component.get("v.companyName");
                    person.LeadSummary = component.get("v.LeadSummary");
                    person.IsOrg = component.get("v.IsOrg");
                    person.item = component.get("v.item");
                    
                   console.log('Line 872');
                    component.set("v.changeInEmail",false);
                    //   Disable button and the class
                    //component.find("doSubmit").set("v.disabled", true);
                    
                    /*-------------------------------*/
                    var noOfTenantCount = component.get("v.noOfTenants");
                    console.log("noOfTenantCount",noOfTenantCount);
                    var itemCount = component.get("v.item");
                    console.log("itemCount",itemCount);
                    var itemListlengthCount = component.get("v.itemListlength");
                    console.log("itemListlengthCount",itemListlengthCount);
                    
                    var depositDetailClass = document.getElementsByClassName("cEI_depositDetail");
                    
                    if(noOfTenantCount>1){
                        console.log("More than 1 tenant");
                         depositDetailClass[0].style.display = "none";
                         depositDetailClass[1].style.display = "block";
                        console.log("First form class remove successfully");
                    }
                    
                    if(itemListlengthCount>=1){
                        console.log("form remaining");
                        depositDetailClass[itemCount].style.display = "none";
                        console.log("current form removed");
                        var showVar = itemListlengthCount - itemCount; 
                        console.log("showVar",showVar);
                        depositDetailClass[showVar].style.display = "block";
                        while(itemListlengthCount>showVar){
                            console.log("itemListlengthCount>=showVar",itemListlengthCount>=showVar);
                             depositDetailClass[itemListlengthCount].style.display = "none";
                            console.log("268");
                           // remove element(itemListlengthCount);
                            itemListlengthCount--;
                            console.log("271");
                        }
                    }
                    
                     /*-------------------------------*/
                    var cmpTarget = component.find("changeIt");
                    $A.util.addClass(cmpTarget, "changeMe");
                 /* var formValue = component.get("v.formNumber");
                  var cEI_depositDetail = document.getElementsByClassName("cEI_depositDetail");  
                    console.log("formValue   244-->",formValue);
                    if(formValue==0){
                        console.log("form value is 0");
                        component.set("v.formNumber",1);
                        //var cmpTarget = component.find("changeIt");
                        //$A.util.addClass(cmpTarget, "changeMe");
                        console.log("form number in comp", component.get("v.formNumber"));
                        
                        cEI_depositDetail[0].style.display = "none";
                        cEI_depositDetail[1].style.display = "block";
                        console.log("258");
                    }else{
                         console.log("form value is in else");
                         console.log("form number in else comp", component.get("v.formNumber"));
                          cEI_depositDetail[formValue].style.display = "none";
                        formValue++;
                        console.log("formValue",formValue);
                        component.set("v.formNumber",formValue);
                        cEI_depositDetail[formValue].style.display = "block";
                    }*/
                    // Fire the Event
                    
                    var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
                    EI_tenantDetailEvent.setParams({
                        arrObj: person,
                        PageNumber :component.get("v.formNumber")
                    });
                    EI_tenantDetailEvent.fire();
                }
                // Is fields are not populated correctly give warning
                else {
                    if(validatearr && validateEmail)
                    {
                      //  alert("Please update the invalid form entries and try again.");
                    }
                }
            }
        //}
    },   
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
              case "fillFormBtn":
                component.set("v.fillForm", false);
                break; 
			 case "yesNoMsg":
                component.set("v.yesNoError", false);
                break;   
            case "companyName":
                component.set("v.companyNameError", false);
                break;
            case "companyEmail":
                component.set("v.companyEmailError", false);
                break;
            case "companyPhone":
                component.set("v.companyPhoneError", false);
                break;
            case "title":
                component.set("v.titleError", false);
                break;
            case "firstName":
                component.set("v.firstNameError", false);
                break;
            case "surName":
                component.set("v.surNameError", false);
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
            case "Phonelength":
                component.set("v.PhonelengthError",false);    
                break;
            case "duplicatePhoneInDepositError":
                component.set("v.duplicatePhoneInDepositError", false);
                break;    
                
        }
    },
    
    handlePhoneCode: function(component, event, helper) {
       /* var code = document.getElementById("selectPhoneCode").value;
        component.set("v.phoneCode", code);
        component.set("v.phone", '');
       */ 
        var map1 = new Map();
        var item = component.get("v.item");
        if(item != undefined){
            console.log('item '+item);
            console.log('TEST '+event.currentTarget.id);
            var code = document.getElementById(event.currentTarget.id).value;
            console.log('item phonecode '+code);
            map1.set(item,code);
            component.set("v.phoneCode",code);
            component.set("v.phone", '');
        }else{
            console.log('event.currentTarget.id '+event.currentTarget.id);
            var code = document.getElementById(event.currentTarget.id).value;
            console.log('code '+code);
            map1.set('leadtenant',code);
            component.set("v.phoneCode",code);
            component.set("v.phone", '');
        }
    }
    
});