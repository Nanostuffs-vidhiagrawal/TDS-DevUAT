({
     handleLeadTenant : function(cmp, event, depositId){
          console.log('handle '+depositId);
        let action = cmp.get('c.getLeadTenant');
        action.setParams({
            depositId : depositId
        });
        action.setCallback(this,result=>{
             
            let state = result.getState();
            if (state === "SUCCESS") {
            console.log('state '+state);
            	//cmp.set('v.isLeadTenant',result.getReturnValue());
              let isLeadTT = result.getReturnValue();
             console.log('isLeadTT '+isLeadTT);
                  if(!isLeadTT){
                cmp.set('v.isLeadTenant',true);
                cmp.set('v.backgroundColor','background-color: #EFEFEF;');
                cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
            }
            }else{
                let errors = result.getError();
                console.log('---Error--->>> '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
            }
        });
        $A.enqueueAction(action);
    },
	loadData : function(cmp, event, depositId) {
        let totalamount = 0;
        let totalamountAGLL = 0;
        let disputOldRecMap = new Map();
        let action = cmp.get('c.getCaseAndDisputeItemDetails');
        action.setParams({
            depositId : depositId 
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
                let resultValue = result.getReturnValue();
            	let caseInstance = resultValue.caseObject;
           		caseInstance.Total_Agreed_by_AG_LL__c = caseInstance.Total_Agreed_by_AG_LL__c != null ? caseInstance.Total_Agreed_by_AG_LL__c : caseInstance.Total_Claimed_by_Landlord__c;
            	caseInstance.Total_Agreed_by_Tenant__c = caseInstance.Total_Agreed_by_Tenant__c != null ? caseInstance.Total_Agreed_by_Tenant__c : caseInstance.Claimed_by_Tenant__c;
                cmp.set("v.totalprotectedamount" ,caseInstance.Deposit_Account_Number__r.Protected_Amount__c);
                cmp.set('v.profileName',resultValue.profileName); 
                for(let i=0;i<resultValue.caseObject.Dispute_Items__r.length;i++){
                	resultValue.caseObject.Dispute_Items__r[i].other = '£'+resultValue.caseObject.Dispute_Items__r[i].Claimed_by_Landlord__c+'.00'+'\n'+resultValue.caseObject.Dispute_Items__r[i].Other_Reason__c;
           			resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c = resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c != null ? resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c : resultValue.caseObject.Dispute_Items__r[i].Claimed_by_Landlord__c;
            		resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c = resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c != null ? resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c : resultValue.caseObject.Dispute_Items__r[i].Tenant_Response__c;
        			resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_TT = resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_TT__c//(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c/resultValue.caseObject.Dispute_Items__r[i].Tenant_Response__c)*100;
            		resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_AGLL = resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_AGLL__c//(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c/resultValue.caseObject.Dispute_Items__r[i].Claimed_by_Landlord__c)*100;
        			resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_TT__c = (resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c/resultValue.caseObject.Dispute_Items__r[i].Claimed_by_Landlord__c)*100;
        			resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_AGLL__c = (resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c/resultValue.caseObject.Dispute_Items__r[i].Claimed_by_Landlord__c)*100;		
                
                 if(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c)
                  {
              totalamount = parseFloat(totalamount)+ parseFloat(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c);
                        }
                           if(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c)
                       {
                           totalamountAGLL = parseFloat(totalamountAGLL)+ parseFloat(resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c);
                       } 
        
       var AmountObj = new Object();
        if(resultValue.profileName == 'Tenant'){
            AmountObj.Amount = resultValue.caseObject.Dispute_Items__r[i].Agreed_by_Tenant__c;
            AmountObj.Percentage = resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_TT__c;
            //disputOldRecMap.set(resultValue.caseObject.Dispute_Items__r[i].Id,AmountObj);
            disputOldRecMap[resultValue.caseObject.Dispute_Items__r[i].Id] = AmountObj;
        }
        else{
            AmountObj.Amount = resultValue.caseObject.Dispute_Items__r[i].Agreed_by_AGLL__c;
            AmountObj.Percentage = resultValue.caseObject.Dispute_Items__r[i].Adjustment_Percentage_by_AGLL__c;
            //disputOldRecMap.set(resultValue.caseObject.Dispute_Items__r[i].Id,AmountObj); 
            disputOldRecMap[resultValue.caseObject.Dispute_Items__r[i].Id] = AmountObj;
            console.log('line--> 41' , resultValue.caseObject.Dispute_Items__r[i].Id);
            console.log('line--> 42' , AmountObj);
          //  console.log('line--> 47' , disputOldRecMap);
            // cmp.set("v.disputOldRecMap",disputOldRecMap);
       }
                }
    //debugger;
    console.log('line 52' , disputOldRecMap);
    
    console.log('line 533' , typeof disputOldRecMap);
    cmp.set("v.disputeOldRecMap",disputOldRecMap);
    console.log('line--> 53 map value' , JSON.stringify(cmp.get("v.disputeOldRecMap")));
   // alert('>>>>')
    cmp.set("v.totalTenantAmount",totalamount);
    cmp.set("v.totalAGLLAmount",totalamountAGLL);
    
               
                caseInstance.sumOfDisputeLandlord =   caseInstance.Total_Agreed_by_AG_LL__c -caseInstance.Total_Agreed_by_Tenant__c;
                caseInstance.totalAgreebyTenant = caseInstance.Total_Agreed_by_Tenant__c;
                cmp.set('v.caseObject',caseInstance);
            	cmp.set('v.disputeItemList',resultValue.caseObject.Dispute_Items__r);
                if((resultValue.profileName == 'Tenant' && resultValue.caseObject.TT_Made_offer__c) ||
                   ((resultValue.profileName == 'Landlord' || resultValue.profileName == 'Agent') && resultValue.caseObject.AGLL_made_Offer__c)){
                    
                    if((resultValue.caseObject.TT_Offer_Amount__c && (resultValue.caseObject.TT_Offer_Response__c != 'Accept' || resultValue.caseObject.TT_Offer_Response__c != 'Counter Offer' || resultValue.caseObject.TT_Offer_Response__c != 'Reject'))
                       || (resultValue.caseObject.AGLL_Offer_Amount__c && (resultValue.caseObject.AGLL_Offer_Response__c != 'Accept' || resultValue.caseObject.AGLL_Offer_Response__c != 'Counter Offer' || resultValue.caseObject.AGLL_Offer_Response__c != 'Reject'))){
                        cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                          console.log('Test1');
                    	cmp.set('v.cancelOffer',true);
                          cmp.set('v.madeAnOffer',false);
                    } 
                }else{
                    if((resultValue.profileName == 'Tenant' && resultValue.caseObject.AGLL_made_Offer__c) ||
                       ((resultValue.profileName == 'Landlord' || resultValue.profileName == 'Agent') && resultValue.caseObject.TT_Made_offer__c)){
                        cmp.set('v.btnBackgroundColor','background-color: #EFEFEF;');
                        console.log('Test2');
                        cmp.set('v.madeAnOffer',true);
                        cmp.set('v.cancelOffer',false);
                    }
                }
            	console.log('<<<caseObject>>> ',JSON.stringify(resultValue))
            	console.log('<<<disputeItemList>>> ',JSON.stringify(resultValue.caseObject.Dispute_Items__r));
            	console.log('<<<profileName>>> ',JSON.stringify(resultValue.profileName));
            }
    
       
                    else{
                         let errors = result.getError();
                         console.log('---Error--->>>97 '+JSON.stringify(errors));
                         console.log("Error message>>>: " +JSON.stringify(errors[0].message));
         }
  
        });
        $A.enqueueAction(action);
	},
    createPaymentAndInstalmentsData : function(cmp, event){
            
        let action = cmp.get('c.createPaymentAndInstalmentsRecord');
        action.setParams({
            CaseInst : cmp.get('v.caseObject'),
            protectedamount:cmp.get('v.totalprotectedamount')
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	console.log('<<<result>>> ',JSON.stringify(result.getReturnValue()));
            	cmp.set('v.isError',false);
            	cmp.set('v.isSubmit',true);
            }else{
                let errors = result.getError();
                console.log('---Error--->>>119 '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
        		//cmp.set('v.errorMsg',errors[0].message);
        		cmp.set('v.isError',true);
        cmp.set('v.errorMsg','There is some issue with submitting this data. Please contact SafeDeposits Scotland support');
         
        		window.scrollTo(500, 200);
            }
        });
        $A.enqueueAction(action);
    },
    updatemakeadjustment : function(cmp, event){
        console.log('>><<',cmp.get('v.disputeItemList'));
        let action = cmp.get('c.makeAdjustments');
        action.setParams({
            caseInst : cmp.get('v.caseObject'),
            disputeItems : JSON.stringify(cmp.get('v.disputeItemList')),
            profileName : cmp.get('v.profileName')
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	console.log('<<<result>>> ',JSON.stringify(result.getReturnValue()));
            	cmp.set('v.isError',false);
            	cmp.set('v.isSubmit',true);
            }else{
                let errors = result.getError();
                console.log('---Error--->>>145 '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
            	//cmp.set('v.errorMsg',errors[0].message);
            	cmp.set('v.isError',true);
         cmp.set('v.errorMsg','There is some issue with submitting this data. Please contact SafeDeposits Scotland support');
       
        		window.scrollTo(500, 200);
            }
        });
        $A.enqueueAction(action);
    },
    settlementCommentOROfferMade : function(cmp, event,OfferMade,offeramount){
        // Update settlement comment on case object    
        let action = cmp.get('c.updateCaseFields');
        action.setParams({
            caseInst : cmp.get('v.caseObject'),
            profilename : cmp.get('v.profileName'),
            operation : OfferMade,
            offeramount:parseFloat(offeramount)
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	console.log('<<<result>>> ',JSON.stringify(result.getReturnValue()));
            	cmp.set('v.isError',false);
            	cmp.set('v.isSubmit',true);
            }else{
                let errors = result.getError();
                console.log('---Error--->>>171 '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
            	//cmp.set('v.errorMsg',errors[0].message);
            	cmp.set('v.isError',true);
         cmp.set('v.errorMsg','There is some issue with submitting this data. Please contact SafeDeposits Scotland support');
       
        		window.scrollTo(500, 200);
            }
        });
        $A.enqueueAction(action);
    },
    OfferRejected : function(cmp, event,OfferRejected,offeramount){
        // Updating Case Agent/Landlord Or Tenant offer Reply   
        let action = cmp.get('c.updateCaseFields');
        action.setParams({
            caseInst : cmp.get('v.caseObject'),
            profileName : cmp.get('v.profileName'),
            operation : OfferRejected,
            offeramount:offeramount
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	console.log('<<<result>>> ',JSON.stringify(result.getReturnValue()));
            	cmp.set('v.isError',false);
                if(OfferRejected =='cancelOffer')
            	cmp.set('v.isSubmit',false);
                else
                cmp.set('v.isSubmit',true);
            }else{
                let errors = result.getError();
                console.log('---Error--->>>199 '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
        		//cmp.set('v.errorMsg',errors[0].message);
        		cmp.set('v.isError',true);
        		window.scrollTo(500, 200);
            }
        });
        $A.enqueueAction(action);
    },
        manageTotalAgreefield : function(cmp,disputeItemList,totalsumofAgreed,profilename){
            for(let dispurItem in disputeItemList){
                if(profilename == 'Tenant')
               		totalsumofAgreed =  totalsumofAgreed + disputeItemList[dispurItem].Agreed_by_Tenant__c;
                else
                    totalsumofAgreed =  totalsumofAgreed + disputeItemList[dispurItem].Agreed_by_AGLL__c;
            }
            console.log('>>>>>',totalsumofAgreed);
            console.log('totalsumofAgreed>>>',totalsumofAgreed);
            var caseObject = cmp.get('v.caseObject');
            if(profilename != 'Tenant'){
                caseObject.sumOfDisputeLandlord = totalsumofAgreed;
                //caseObject.totalAgreebyTenant = 
            }else{
                
            }                
        },
            
 getError:function (component, event, helper){
                
     var action = component.get("c.fetchErrorLabel");
     action.setCallback(this, function(response){
         var state = response.getState();
         if (state === "SUCCESS"){               
             //console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
             component.set("v.errorList",response.getReturnValue());
             var   errorList= component.get("v.errorList");                 
             var userErr;
             
             for(var i=0; i<errorList.length; i++){
                 //console.log("line-->9  " +errorList[i].MasterLabel );
                 // console.log("line-->9  " +errorList[i].Error_Message__c );
                 if(errorList[i].MasterLabel === 'Make Offer'){
                     userErr = errorList[i].Error_Message__c;
                     component.set("v.offerErrorNew",userErr);
                 }
                /* else if(errorList[i].MasterLabel === 'Make Offer by Tenant'){
                     userErr = errorList[i].Error_Message__c;
                     component.set("v.landlordOfferErrorNew", userErr);
                 } */ 
                 
                     else if(errorList[i].MasterLabel === 'Make Offer By Tenant New'){
                         userErr = errorList[i].Error_Message__c;
                         component.set("v.tenantErrorNew", userErr);
                     }         
                 
             }
         }
         else{
             console.log('something went wrong');
         }
     });
     $A.enqueueAction(action);
 },
     
     
     getError:function (component, event, helper){
                
     var action = component.get("c.fetchErrorLabel");
     action.setCallback(this, function(response){
         var state = response.getState();
         if (state === "SUCCESS"){               
             //console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
             component.set("v.errorList",response.getReturnValue());
             var   errorList= component.get("v.errorList");                 
             var userErr;
             
             for(var i=0; i<errorList.length; i++){
                 //console.log("line-->9  " +errorList[i].MasterLabel );
                 // console.log("line-->9  " +errorList[i].Error_Message__c );
                 if(errorList[i].MasterLabel === 'Make Offer'){
                     userErr = errorList[i].Error_Message__c;
                     component.set("v.offerErrorNew",userErr);
                 }
                 else if(errorList[i].MasterLabel === 'Make Offer by Tenant'){
                     userErr = errorList[i].Error_Message__c;
                     component.set("v.landlordOfferErrorNew", userErr);
                 }  
                 
                     else if(errorList[i].MasterLabel === 'Make Offer By Tenant New'){
                         userErr = errorList[i].Error_Message__c;
                         component.set("v.tenantErrorNew", userErr);
                     }         
             }
         }
         else{
             console.log('something went wrong');
         }
     });
     $A.enqueueAction(action);
 },
     openChatBoxHelper:function (cmp, event, helper){
         
        // data needs to be loaded here 
        
        var wrap = cmp.get('v.chatWrap'); 
        var caseObject = cmp.get('v.caseObject');

        var action = cmp.get("c.updateChatFields");
        action.setParams({
            caseId : caseObject.Id
        });
        action.setCallback(this, function(response) {
			
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                
                cmp.set("v.chatWrap" ,result);
                if(wrap.ChatList.length != result.ChatList.length){
                    document.getElementById('scrollView').scrollIntoView(true); 
                }
                
                
            }
            else if (state === "INCOMPLETE") {
                
                
                
                // alert('INCOMPLETE');
            }else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });
        
        $A.enqueueAction(action);         
		
         var chatOpen = cmp.get('v.chatOpen');
         if(chatOpen == true){

             setTimeout($A.getCallback(() => this.openChatBoxHelper(cmp, event, helper)), 2000)
         }
        
 	},
    openChat : function(cmp, event, helper){
        
        
        cmp.set('v.chatOpen',true);
        
        var caseObject = cmp.get('v.caseObject');
        
        var action = cmp.get("c.updateChatFields");
        action.setParams({
            caseId : caseObject.Id
        });
        action.setCallback(this, function(response) {
			
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                cmp.set("v.chatWrap" ,result);
                if(result.chatList.length > 0){
					setTimeout(
                        function() {
                          document.getElementById('scrollView').scrollIntoView(true); 
                        }, 500);
                    
                    cmp.set("v.unreadMessageCount", 0); 
                     
                }
                
                
                
            }
            else if (state === "INCOMPLETE") {
                
            }else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });
        
        $A.enqueueAction(action); 

        helper.openChatBoxHelper(cmp, event, helper); 
        
    },
    readFile: function(component, helper, file,fileLable) {
        
        var caseObject = component.get('v.caseObject');
        var recordId = caseObject.Id;
        
        const currentDate = new Date();
        const timestamp = currentDate.getTime();
        
        if (!file) {return;}
        

        let icon = file.name.toLowerCase();
        const ext = ['.pdf', '.doc', '.docx', '.txt', '.rtf','.odt', '.xls', '.xlsx', '.ods', '.msg', '.csv', '.png', '.jpeg', '.jpg', '.gif', '.tiff', '.tif', '.bmp', '.mp3', '.mp4', '.wmv', '.wav', '.ppt', '.pptx'];
        var fileTypeCheck = ext.some(el => icon.endsWith(el));
        if (!fileTypeCheck) {
           return alert("File type not supported!");
        }
        
        var sizeInMB = (file.size / (1024*1024)).toFixed(2);
        if(sizeInMB > 20){
             return alert("File size is greater than 20mb");
        }         
        var baseUrl = component.get("v.secureURI");

        var baseUrlLength = baseUrl.length;
        var indexOfQueryStart = baseUrl.indexOf("?");
        var sasKeys = baseUrl.substring(indexOfQueryStart, baseUrlLength);
        
        var submitUri = baseUrl.substring(0, indexOfQueryStart) + '/'+recordId+'-'+timestamp +'-'+ file.name+ baseUrl.substring(indexOfQueryStart);
        
        component.set("v.azureLink", baseUrl.substring(0, indexOfQueryStart) + '/'+recordId+'-'+timestamp +'-'+ file.name+sasKeys);
        component.set("v.fileNameInAzure", recordId+'-'+timestamp +'-'+ file.name);
        
        var reader = new FileReader();
        reader.onload = function() {
            var dataURL = reader.result;
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1],submitUri,fileLable);
        };
        reader.readAsDataURL(file);
    },
    
    upload: function(component, file, base64Data,submitUri,fileLable) {
        
        
        var caseObject = component.get('v.caseObject');
        var chatWrap = component.get("v.chatWrap");

        var xhr = new XMLHttpRequest();
        var endPoint = submitUri;
        component.set("v.message", "Uploading...");
        
        xhr.open("PUT", endPoint, true);
        xhr.setRequestHeader('x-ms-blob-type', 'BlockBlob');
        xhr.setRequestHeader('Content-Type', file.type);


        xhr.onreadystatechange = function () {
            
            if (xhr.readyState === 4 && xhr.status === 201) {               
                var action = component.get("c.saveFile"); 
                action.setParams({

                    caseId : caseObject.Id,
                    fromId : chatWrap.currentContactId,
                    toId : chatWrap.otherPartyContactId,
                    fileName: file.name,
                    azureLink: component.get('v.azureLink'),
					fileType :(file.name).split('.').pop(),	
                    fileSize :file.size,
                    fileLable :fileLable,
					fileNameInAzure : component.get('v.fileNameInAzure'),
					scheme : 'SDS'
                     
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        let result = a.getReturnValue();
                        
                        component.set("v.chatWrap" ,result);
                        component.set("v.fileLableVisible", false); 
                        component.set("v.fileName", "");
                        component.set('v.showEvidenceCmp',false);
						
						setTimeout(
                        function() {
                          document.getElementById('scrollView').scrollIntoView(true); 
                        }, 500);                         
						// Close upload file
                    }
                });
                $A.enqueueAction(action);
                
            }else{
                //image error code
            }
        };
        xhr.send(file);
    },





})