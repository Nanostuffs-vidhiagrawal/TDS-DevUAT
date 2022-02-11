({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Evidence_Attachment__c',
            'category_apiname': 'Evidence_Categories__c',
            'userType_apiname': 'User_Type__c'
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.category", a.getReturnValue().category);
                component.set("v.userType", a.getReturnValue().userType);
            }
        });
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getSecureURI"); 
        action1.setParams({
            scheme : 'Zero Deposite'
        });
        action1.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                let ReturnValue = a.getReturnValue();
                console.log('ReturnValue '+ReturnValue);
                component.set("v.secureURI", ReturnValue); 
            }
        });
        $A.enqueueAction(action1);
        
    },
    next : function(component, event, helper) {
        component.set("v.showEvidenceCmp", true);
        console.log('categorySelVal '+component.get("v.categorySelVal"));
        var action = component.get("c.getDisputeItem");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'catName': component.get("v.categorySelVal")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                console.log(' a.getReturnValue() '+ a.getReturnValue());
                console.log('ddf lin  '+ a.getReturnValue().id);
                component.set("v.disputeItemId", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    handleFilesChange : function(component, event, helper) {
        //var files = event.getSource().get("v.files");
        component.set("v.message", "");
        var filess = component.set("v.fileList",component.get("v.fileList")); 
        var files = component.get("v.fileList");
        let icon = files[0].name.toLowerCase();
        component.set("v.fileName", files[0].name);
        //const ext = ['.png', '.jpeg', '.jpg', '.gif', '.tiff', '.tif', '.bmp'];
        const ext = ['.pngooo099'];
        var fileTypeCheck = ext.some(el => icon.endsWith(el));
        if(fileTypeCheck==true){
            component.set("v.fileLableVisible", true);
        } 
    },
    addEvidence : function(component, event, helper) {
        //var files = event.getSource().get("v.files");
        var files = component.get("v.fileList"); 
        var getFileLabel = document.getElementById("filelabel").value;
        if(getFileLabel=='' && component.get("v.fileLableVisible")==true){
            component.set("v.fileLable", 'Please provide a lable to upload image.');
        }else if(getFileLabel.length > 50){
            component.set("v.fileLable", 'Character limit is 50.');
        }else{
            var action = component.get("c.getSecureURI"); 
            action.setParams({
                scheme : 'SDS'
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                let errors = a.getError();            
                if (state == "SUCCESS") {
                    let ReturnValue = a.getReturnValue();
                    component.set("v.secureURI", ReturnValue); 
                }
            });
            $A.enqueueAction(action);
            
            component.set("v.fileLable", '');
            helper.readFile(component, helper, files[0],getFileLabel);
        }
    }
})