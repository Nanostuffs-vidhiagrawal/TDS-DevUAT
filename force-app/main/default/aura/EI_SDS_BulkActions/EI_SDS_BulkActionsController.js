({
	doInit : function(component, event, helper) {
        //alert("dinit start");
        //$(".org-detail-list").slideToggle();
        //var hlink= document.getElementById("left_nav-sf-bulkimport-tab");
        //console.log('hlink -> '+hlink);
        //$(".org-detail-list").slideToggle();
        //$(hlink).toggleClass("open");
        //alert("dinit end");
        var regMultDepTab =  component.find("leftSideSubTabs");
        console.log('weird regMultDepTab -> '+regMultDepTab);
        $A.util.addClass(regMultDepTab, "openSubTab");
	},
    
    transferMultipleDepositSubTabs : function(component, event, helper) {
        /*component.find("navServiceToOtherSection").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "bulkactions"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {  }
            }); 
        }
	},
    
    regMultipleDepositSubTabs : function(component, event, helper) {
        component.set("v.fileList", "");
        component.set("v.flType", "");
        component.set("v.flName", "No file Selected");
        component.set("v.success", "");
        component.set("v.upload", false);
        component.set("v.uploadBar", "0");
        component.set("v.uploadingFileSize", "0"); 
        component.set("v.totalFileSize", "0"); 
        //$(".org-detail-list").slideToggle();
        
        if(component.get("v.showSubTabs")) {
            var regMultDepTab =  component.find("leftSideSubTabs");
            $A.util.removeClass(regMultDepTab, "openSubTab");
            $A.util.addClass(regMultDepTab, "closeSubTab");
            component.set("v.showSubTabs", false);
        } else {
            var regMultDepTab =  component.find("leftSideSubTabs");
            $A.util.removeClass(regMultDepTab, "closeSubTab");
            $A.util.addClass(regMultDepTab, "openSubTab");
            component.set("v.showSubTabs", true);
        }
    },
    
    downloadMultiplecertificatesTabs : function(component, event, helper) {
        /*component.find("navServiceToOtherSection").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "downloadbulkcertificates"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadbulkcertificates"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadbulkcertificates"
                },
                state: {  }
            }); 
        }
    },
    
    downloadPIFormsTabs : function(component, event, helper) {
        /*component.find("navServiceToOtherSection").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "downloadpiforms"
            },
            state: {  }
        });*/
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadpiforms"
                },
                state: {
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navServiceToOtherSection").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "downloadpiforms"
                },
                state: {  }
            }); 
        }
    },
    
    handleFilesChange : function(component, event, helper) {
        //var filess = component.set("v.fileList",component.get("v.fileList")); 
        var files = component.get("v.fileList");
        let icon = files[0].name.toLowerCase();
        var fileName = files[0].name;
        var fileSize = parseInt(files[0].size * 0.0009765625) ;
        console.log('files[0] '+ JSON.stringify(files) + files); //1 byte = 0.0009765625 Kilobytes
        if(!fileName.match(/\.(csv||CSV)$/)){
                //return alert('only support csv files');
                component.set("v.showFileTypeError", true);
        }else{
            console.log('files[0].name '+ fileName);
            console.log('files[0].size '+ fileSize+"kb");
            component.set("v.flType", fileName.split(".")[1]);
            component.set("v.flName", files[0].name);
            component.set("v.success", " success");
            component.set("v.totalFileSize", fileSize); 
            component.set("v.upload", true);
            for(var i=0; i<fileSize+1; i++){
                component.set("v.uploadBar", (i/fileSize)*100); 
                component.set("v.uploadingFileSize", i); 
            }
            component.set("v.showFileTypeError", false);
        }
        //helper.readFile(component,helper,files[0]);
        
        // Second approach
		/* alert('Kuch hua');
        var files=event.dataTransfer.files;
        alert('file'+files[0].name); */
	},
    
    validatingTheFile : function(component, event, helper) {
        if(!component.get("v.showFileTypeError")){
            var filess = component.set("v.fileList",component.get("v.fileList")); 
            var files = component.get("v.fileList");
            if(!files[0]) {
                alert('Add the file and then either Validate or Import it')
            } else {
                if(!files[0].name.toLowerCase().match(/\.(csv||CSV)$/)){
                    return alert('only support csv files');
                }else{
                    let icon = files[0].name.toLowerCase();
                    component.set("v.flName", files[0].name);
                    //helper.readFile(component,helper,files[0]);
                    
                    component.set("v.isValidateOnly", true);
                    component.set("v.isAddTheFileSection",false);
                    component.set("v.showFileUpload",false);
                    component.set("v.isShowValidating",true);
                    component.set("v.isSummSecFileValidate",true);
                    component.set("v.showChildSection",false);
                }
            }
        }
	},
    
    ImportingTheFile : function(component, event, helper) {
        if(!component.get("v.showFileTypeError")){
            var filess = component.set("v.fileList",component.get("v.fileList")); 
            var files = component.get("v.fileList");
            if(!files[0]) {
                alert('Add the file and then either Validate or Import it')
            } else {
                let icon = files[0].name.toLowerCase();
                component.set("v.flName", files[0].name);
                //helper.readFile(component,helper,files[0]);
                
                component.set("v.isValidateOnly", false);
                component.set("v.isAddTheFileSection",false);
                component.set("v.showFileUpload",false);
                component.set("v.isShowValidating",true);
                component.set("v.isSummSecFileValidate",true);
                component.set("v.showChildSection",false);
            }
        }
	},    
    
    handleUnsuccessful : function(component, event, helper) {
        component.set("v.showFileUpload",false);
        component.set("v.isAddTheFileSection",false);
        component.set("v.isShowValidating",false);
        component.set("v.isSummSecFileValidate",false);
        component.set("v.showChildSection",true);
    },

    handleClickNewUpload : function(component, event, helper){
        component.set("v.showFileUpload",true);
        component.set("v.isAddTheFileSection",true);
        component.set("v.isShowValidating",false);
        component.set("v.isSummSecFileValidate",false);
        component.set("v.showChildSection",false);
        component.set("v.isShowViewImportLog",false);
        component.set("v.isViewBulkImportLog",false);
        component.set("v.showImportDetails",false);
        component.set("v.fileList", "");
        component.set("v.flType", "");
        component.set("v.flName", "No file Selected");
        component.set("v.success", "");
        component.set("v.upload", false);
        component.set("v.uploadBar", "0");
        component.set("v.uploadingFileSize", "0"); 
        component.set("v.totalFileSize", "0"); 
    },
    
    handleClickViewImportLogs : function(component, event, helper){
        component.set("v.showFileUpload",false);
        component.set("v.isAddTheFileSection",false);
        component.set("v.isShowValidating",false);
        component.set("v.isSummSecFileValidate",false);
        component.set("v.showChildSection",false);
        component.set("v.isShowViewImportLog",true);
        component.set("v.isViewBulkImportLog",true);
        component.set("v.showImportDetails",false);
        component.set("v.fileList", "");
        component.set("v.flType", "");
        component.set("v.flName", "No file Selected");
        component.set("v.upload", false);
        component.set("v.uploadBar", "0");
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {                
             case "fileTypeErrorAlert":
                component.set("v.showFileTypeError", false);
                break; 
        }
    },
    
    getGuidanceDocument:function(component, event, helper){
        //alert("call get guide doc");
        var action = component.get("c.getguidanceDocument");
        action.setCallback(this, function(a) {
            var state = a.getState();
            //alert(state);
            if (state === "SUCCESS"){
                var res = a.getReturnValue();
                console.log("Guidance document Id => " + res);
                window.open("/servlet/servlet.FileDownload?file="+res); 
                setTimeout(function(){ 
                    helper.deleteAttacRecord(component, event, helper);
                }, 1000);
            } 
        });
        $A.enqueueAction(action);
    }
    
})