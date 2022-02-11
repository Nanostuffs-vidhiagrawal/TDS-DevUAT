({
    onInit: function(component) {
        console.log('recordid => ' + component.get("v.recordId") );
        
        var action = component.get("c.fetchRecipients"); 
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError(); 
            console.log('fetchCP  : ' + a.getReturnValue());
            if (state == "SUCCESS") {
                console.log(JSON.stringify(a.getReturnValue()));
                component.set("v.to", a.getReturnValue()); 
            }
        });
        $A.enqueueAction(action);
        
        //alert(JSON.stringify(component.get('v.to')) );
        
        // get Templates
        var action = component.get("c.getAllMetaDataList"); 
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                console.log("getReturnValue : " + a.getReturnValue());
                component.set("v.templates", a.getReturnValue()); 
            }
        });
        $A.enqueueAction(action);
       
    },
    
    handleTemplateChange : function(component, event, helper){
        //alert('handleTemplateChange ');
        component.set("v.PageSpinner", true);
        //alert('PageSpinner '+ component.get("v.PageSpinner"));
    	let selectedEMail = component.get("v.toRecAccEmail");
        var tempId = component.get("v.selectedTemplate");
        //alert('selectedEMail '+ selectedEMail);
        var recordId = component.get('v.recordId');
        //alert('recordId' + recordId);
        var toRecConId = component.get("v.toRecConId");
        var action = component.get("c.getMailJetTextBody"); 
        //alert('toRecConId' + toRecConId);
        
        action.setParams({
            tempId : tempId,
            toEMail : selectedEMail,
            recordId : recordId,
            toRecConId : toRecConId
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                var res = a.getReturnValue();
                console.log("res : " + res.subject);
                console.log("res : " + res.body);
   			    component.set("v.body", res.body); 
               	component.set("v.subject", res.subject);
                component.set("v.PageSpinner",false); 
            }
        });
        $A.enqueueAction(action);
	},
    
    handleUploadFinished : function(component, event, helper)
    {
        var uploadedFiles = component.get("v.fileList");
 		
        try{
            let filesToUpload = [];  
            var fileNames = [];
            for (let i=0; i< uploadedFiles.length ; i++){
                let file = uploadedFiles[i];   
                
                let icon = file.name.toLowerCase();
                const ext = ['.pdf', '.doc', '.docx', '.txt', '.rtf','.odt', '.xls', '.xlsx', '.ods', '.msg', '.csv', '.png', '.jpeg', '.jpg', '.gif', '.tiff', '.tif', '.bmp', '.mp3', '.mp4', '.wmv', '.wav', '.ppt', '.pptx'];
                var fileTypeCheck = ext.some(el => icon.endsWith(el));
                if (!fileTypeCheck) {
                    return alert("File type not supported!");
                }
                console.log(i+icon);
                var sizeInMB = (file.size / (1024*1024)).toFixed(2);
                if(sizeInMB > 20){
                    return alert("File size is greater than 20mb");
                }
                
                let reader = new FileReader();
                reader.onload = function() {
                    // var str = 'fileName:' + file.name +';DataUrl '+reader.result;
                    var dataURL = reader.result;
                    var str = 'fileName:' + file.name +';'+ dataURL;
                    console.log(str); //File data
                    filesToUpload.push(str);
                    fileNames.push(file.name);
                }
                reader.readAsDataURL(file);             
            }
            
            setTimeout(function(){
                helper.helperGetFiles(component, helper, filesToUpload);
                console.log("Base64 ===>>> " + filesToUpload);
                console.log("fileNames ===>>> " + fileNames);
                component.set("v.base64", filesToUpload);
                component.set("v.fileName", fileNames);
            }, 1000);
            
        }catch(e){
            console.log('Exception : ' + e);
        }
      //  console.log('filesToUpload<<<<<<<'+filesToUpload.length)
    },

    
 /*   handleUploadFinished : function(component, event, helper)
    {
        var uploadedFiles = component.get("v.fileList");
        var file = uploadedFiles[0];   
        component.set("v.fileName", file.name);
        console.log("Selected file : " + file.documentId);
        try{
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
            
            var reader = new FileReader();
            reader.onload = $A.getCallback(function(r) {
                var dataURL = reader.result;
                var str = 'fileName:' + file.name +';'+ dataURL;
                component.set("v.base64", str);                 
            });
            reader.readAsDataURL(file);                           
            
        }catch(e){
            console.log('Exception : ' + e);
        }
    }, 
    */
    handleChangeTo : function(component, event, helper){
        //alert("to receipints => " + JSON.stringify(component.get("v.to")));
        var toReceipeints = component.get("v.to");
        for(var i in toReceipeints){
            //alert("selected value email => " + toReceipeints[i].Id  + " = " + component.get("v.toRecConId") );
            if(toReceipeints[i].Id == component.get("v.toRecConId")){
                 //alert("selected value Id => " + toReceipeints[i].Id );
                component.set("v.toRecAccEmail" , toReceipeints[i].email);
                //alert("toRecConId => " + toRecConId);
			}
        }
        component.set("v.selectedTemplate", "");
        component.set("v.body", "");
    },
    
	sendEmail : function(component, event, helper) {  
      /*   var uploadedFiles = component.get('v.base64');
            var action = component.get("c.createListOfEmails");
            // var action = component.get("c.sendEmailFromActivityTab"); 
            action.setParams({
                caseId : component.get('v.recordId'),
                // templateId : component.get('v.selectedTemplate'),
                fromEmail : component.get('v.from'),
                to : component.get('v.toRecAccEmail'),
                mailBody : component.get('v.body'),
                subject : component.get('v.subject'),
                uploadedFiles : uploadedFiles ? uploadedFiles : null
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();            
                if (state == "SUCCESS") {
                    component.set("v.message", true); 
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
            //helper.helperCreateListofEmails(component, helper);
        */
        
        /*var fromEmail = component.get("v.from");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!$A.util.isEmpty(fromEmail)) {
                if(fromEmail.match(regExpEmailformat)){
                    if(fromEmail.includes("@safedepositsscotland.com") || fromEmail.includes("@tenancydepositscheme.com")){
                        component.set("v.fromEmailError", false);
                    }else{
                        component.set("v.fromEmailError", true);
                    }
                }else{
                    component.set("v.fromEmailError", true);
                }
                
               
            }*/
		helper.helperSendEmailList(component, helper);
        
	}
})