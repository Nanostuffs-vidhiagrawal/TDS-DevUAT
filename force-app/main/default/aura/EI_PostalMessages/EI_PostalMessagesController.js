({
	doInit : function(component, event, helper) { 
        component.set("v.checkedCount",0);
        var action = component.get("c.returnMessages");
        action.setParams({
           source : 'SDS Custodial' 
        });
        
        action.setCallback(this, function(response) {
            component.set("v.spinner",true);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                
                component.set("v.messageList" ,result);
                component.set("v.spinner",false);
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                // alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            // component.set("v.spinner",false);
                            
                            //  alert("Error message: " +  errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        //  component.set("v.spinner",false);
                        
                        //  alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    searchData : function(component, event, helper) { 
        
        component.set("v.spinner",true);
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");

        var action = component.get("c.returnMessagesFilter");

        if(endDate == null || endDate == undefined || endDate == '' || startDate == null || startDate == undefined || startDate == ''){
            helper.showToast('Error!','Please enter start and end date','error');
            component.set("v.spinner",false);
            return ;
        }
        action.setParams({
            startDate : startDate,
            endDate : endDate,
            source : 'SDS Custodial'
        });
        
        action.setCallback(this, function(response) {
            component.set("v.spinner",true);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.messageList" ,result);
                component.set("v.spinner",false);
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                // alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            // component.set("v.spinner",false);
                            
                            //  alert("Error message: " +  errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        //  component.set("v.spinner",false);
                        
                        //  alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },

    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        
        component.set("v.spinner", true); 
        
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false); 
    },
    
    downloadAllPDF : function (component,event,helper) { 
        
        var messageList = component.get("v.messageList");
        var printList = [];
        var idList = '';
        for(var i = 0; i < messageList.length; i++){
            var message = messageList[i];
            
            //if(message.objMessage.Contact__c != undefined && message.objMessage.Contact__c != "" && message.objMessage.Content_Populated__c == true){
                printList.push(message.objMessage.Id);
                if(idList == ''){
                    idList += message.objMessage.Id;
                }else{
                    idList  += ','+message.objMessage.Id;
                }
            //}
        }

        if(idList != ''){
            window.location ="/apex/EI_DownloadPostMulti?Id="+idList+"&isDownload=true&source=SDS_Custodial";
            //helper.downloadPdfFile(component,event,helper,printList);  
        }else{
            helper.showToast('Error!','No downloads available','error');
        }
        
    },
    downloadSelectedPDF : function (component,event,helper) { 
        
        var messageList = component.get("v.messageList");
        var printList = [];
        var idList = '';
        for(var i = 0; i < messageList.length; i++){
            var message = messageList[i];
            
            if(message.isSelected /*&& message.objMessage.Contact__c != undefined && message.objMessage.Contact__c != "" && message.objMessage.Content_Populated__c == true*/){
                printList.push(message.objMessage.Id);
                if(idList == ''){
                    idList += message.objMessage.Id;
                }else{
                    idList  += ','+message.objMessage.Id;
                }
            }
        }
        if(idList != ''){
            window.location ="/apex/EI_DownloadPostMulti?Id="+idList+"&isDownload=true&source=SDS_Custodial";
            //helper.downloadPdfFile(component,event,helper,printList);  
        }else{
            helper.showToast('Error!','Please select the valid post','error');
        }
        
    },
    printAllPDF : function (component,event,helper) { 
        
        var messageList = component.get("v.messageList");
        var printList = [];
        var idList = '';
        for(var i = 0; i < messageList.length; i++){
            var message = messageList[i];
            
            //if(message.objMessage.Contact__c != undefined && message.objMessage.Contact__c != "" && message.objMessage.Content_Populated__c == true){
                printList.push(message.objMessage.Id);
                if(idList == ''){
                    idList += message.objMessage.Id;
                }else{
                    idList  += ','+message.objMessage.Id;
                }
            //}
        }

        if(idList != ''){
            window.location ="/apex/EI_DownloadPostMulti?Id="+idList+'&source=SDS_Custodial';
            //helper.downloadPdfFile(component,event,helper,printList);  
        }else{
            helper.showToast('Error!','No downloads available','error');
        }
        
    },
    printSelectedPDF : function (component,event,helper) { 
        
        var messageList = component.get("v.messageList");
        var printList = [];
        var idList = '';
        for(var i = 0; i < messageList.length; i++){
            var message = messageList[i];
            
            if(message.isSelected /*&& message.objMessage.Contact__c != undefined && message.objMessage.Contact__c != "" && message.objMessage.Content_Populated__c == true*/){
                printList.push(message.objMessage.Id);
                if(idList == ''){
                    idList += message.objMessage.Id;
                }else{
                    idList  += ','+message.objMessage.Id;
                }
            }
        }
        if(idList != ''){
            window.location ="/apex/EI_DownloadPostMulti?Id="+idList+'&source=SDS_Custodial';
            //helper.downloadPdfFile(component,event,helper,printList);  
        }else{
            helper.showToast('Error!','Please select the valid post','error');
        }
        
    },
})