({
	readFile: function(component, helper, file,fileLable) {
        let recordId = component.get("v.recordId");
        const currentDate = new Date();
        const timestamp = currentDate.getTime();
        if (!file) return;
        
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
                    parentId: component.get("v.recordId"),
                    disputeId :component.get("v.disputeItemId"),
                    fileName: file.name,
                    azureLink: component.get('v.azureLink'),
                    userType: component.get('v.userTypeSelVal'),
                    fileType :(file.name).split('.').pop(),	
                    fileSize :file.size,
                    fileLable :fileLable,
                    evidenceCategories : component.get('v.categorySelVal'),
                    fileNameInAzure : component.get('v.fileNameInAzure'),
                    source : 'Adjudicator',
                   scheme : 'SDS'
                   
                    
                });
                action.setCallback(this, function(a) {
                    let state = a.getState();
                    let errors = a.getError();
                    if (state == "SUCCESS") {
                        let ReturnValue = a.getReturnValue();
                        console.log('line 68 '+ReturnValue);
                        component.set("v.message", "File uploaded");
                        component.set("v.fileLableVisible", false); 
                        component.set("v.fileName", "");
                        
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: 'File Uploaded Successfully',
                            duration:' 5000',
                            key: 'success_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
                
            }else{
                //image error code
            }
        };
        xhr.send(file);
    }
})