({
    helperGetFiles : function(component, helper, filesToUpload){
      
        
         console.log(filesToUpload.length+' filesToUpload<<<<<<< '+filesToUpload)   
      
    },
    helperCreateListofEmails : function(component, helper){
        //alert("callled helper");
        var listOfEmails = [];
        
       // for(let i = 0 ; i<2; i++){    
            var uploadedFiles = component.get('v.base64');
            var caseId = component.get('v.recordId');
            var fromEmail = component.get('v.from');
            var to = component.get('v.toRecAccEmail');
            var mailBody = component.get('v.body');
            var subject = component.get('v.subject');
            var uploadedFiles = uploadedFiles ? uploadedFiles : null;
            //alert(" helper 14");
            var email = new Object(); //(caseId, fromEmail, to, mailBody, subject, uploadedFiles);
            alert(" helper 16");
            email.caseId = component.get('v.recordId');
            email.fromEmail = component.get('v.from');
            email.to = component.get('v.toRecAccEmail');
            email.mailBody = component.get('v.body');
            email.subject = component.get('v.subject');
            email.uploadedFiles = component.get('v.base64'); //uploadedFiles ? uploadedFiles : null;
            
            //alert(email);
            
            component.set("v.wrapedEmail", email); 
            console.log( "wrapedEmail", component.get("v.wrapedEmail") );
            
            listOfEmails.push(email); 
            console.log( "listOfEmails : " + JSON.stringify(listOfEmails));
            
            component.set("v.listOfEmails", listOfEmails);
            console.log( "listOfEmails cmp : " + component.get("v.listOfEmails"));
        //}
        //alert("end of For");
        var listemail = listOfEmails;
        helper.helperSendEmailList(component, listemail);
    },
    
    helperSendEmailList : function(component, helper) { // listemail
      //  var listemail = component.get("v.listOfEmails");
        //alert("helper helperSendEmailList  : " );
        //console.log("emailDetailList  : " + JSON.stringify(listemail));
        
        var action = component.get("c.sendEmailFromActivityTab"); //sendEmailsofList
        action.setParams({
            //emailDetails : JSON.stringify(listemail)
            recordId : component.get('v.recordId'),
            tempId : component.get('v.selectedTemplate'),
            fromEmail : component.get('v.from'),
            to : component.get('v.toRecAccEmail'),
            mailBody : component.get('v.body'),
            subject : component.get('v.subject'),
            uploadedFiles : component.get('v.base64')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();  
            console.log("state =>> " + a.getReturnValue());
            //if (state == "SUCCESS") {
                
                if(a.getReturnValue() == 'kpiNotPasses'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'You cannot send Decline email before kpi been passed.',
                        duration:' 50000',
                        key: 'success_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            	else if(a.getReturnValue() == 'CaseNUll'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Case is not there.',
                        duration:' 50000',
                        key: 'success_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                 else if(a.getReturnValue() == 'Success'){
                    component.set("v.successMessage", true); 
                    $A.get('e.force:refreshView').fire();
                }
            //}else{
             //   console.log("errors =>> " + JSON.stringify(errors));
            //}
        });
        $A.enqueueAction(action);
    },
        
	helperStoreBase64 : function(component, str) {
        let filesToUpload = [];  
        filesToUpload = component.get("v.to");
        console.log("before push : " + filesToUpload);
        alert("str helper : " + str);
        var base64str = str;
        
       
        var action = component.get("c.saveAttachments");
        action.setParams({
            attachment : base64str
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError(); 
            console.log('fetchCP State : ' + state);
            if (state == "SUCCESS") {
                var attach = a.getReturnValue();
                console.log("return val => " + attach);
                filesToUpload.push(attach);
            }
        });
        $A.enqueueAction(action);
        console.log("After push filesToUpload => " + filesToUpload);
        component.set("v.to", filesToUpload);  
        console.log("After push to => " + component.get("v.to"));
    }
})