({
	downloadPdfFile : function(component,event,helper,IdList){

        
        
        this.downloadPdfFile2(IdList,0,helper)
        
            
},
    downloadPdfFile2 : function(IdList,idx,helper){
        window.location ="/apex/EI_DownloadPost?Id="+IdList[idx];
        if(idx < IdList.length - 1){
            
            window.setTimeout(helper.downloadPdfFile2,2000,IdList, idx+1,helper);
        }
    
    },
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:msg,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
            
        });
        toastEvent.fire();
    },
    
})