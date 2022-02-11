({
    ABC: function(component, event, helper){
        console.log('xyz');
        var selectedDeposits = [];
        selectedDeposits = component.get("v.selectedDepositIds");
        console.log('selectedDeposits => ' + selectedDeposits);
        var azureLocation = [];
        var azureFileName = [];
        for(var i =0; i<selectedDeposits.length; i++){
            azureLocation.push(selectedDeposits[i].DPCLink); //"https://sdsevidencedev.blob.core.windows.net/evidence/a0L8E0000075FohUAE.pdf?sp=rw&st=2021-06-18T15:27:12Z&se=2031-06-18T23:27:12Z&spr=https&sv=2020-02-10&sr=c&sig=ny8xLiSPlms%2FpN%2FtAIYuJaJI7VNQBqc9eqL7V%2BlrQLs%3D"
            azureFileName.push(selectedDeposits[i].DPCName);
        }
        console.log('azureLocation -> ', azureLocation);
        console.log('azureFileName -> ', azureFileName);
        console.log('beforeinst')
        
        var setTimeDelay;
        if(azureLocation.length<=100){
            setTimeDelay = 30000;
        }
        else if(azureLocation.length<=200){
            setTimeDelay = 60000;
        }
        else if(azureLocation.length<=300){
            setTimeDelay = 90000;
        }
        else if(azureLocation.length<=400){
            setTimeDelay = 120000;
        }
        
        var zipFile = new JSZip();
        var count = 1;
        console.log('afterinst')
        console.log("<=== START FOR LOOP ===> ");
        for(let i=0;i < azureLocation.length;i++){       
            console.log("azureFileName[i] " + azureFileName[i]);
            helper.toDataURL(azureLocation[i], function(dataUrl) {
                var base64String = dataUrl.substring(dataUrl.indexOf("base64")+7,dataUrl.length);
                console.log('base64String -> '+ i +' => '+  base64String);
                zipFile.file(azureFileName[i], base64String, {base64: true});
                count++;
            });
        }
        console.log("count => " + count + " azureFileName => " + azureFileName.length);
       // if(count == azureFileName.length){
        window.setTimeout(
            $A.getCallback(function() {
                zipFile.generateAsync({type:"blob"})
                .then(function(content) {
                    saveAs(content, "Evidence.zip");
                    component.set("v.disbleDownloadButton", false);
                });
            })
            , setTimeDelay );
       // }
    },
    
    toDataURL: function(url, callback){
        var xhr = new XMLHttpRequest();
        xhr.onload = function() {
            var reader = new FileReader();
            reader.onloadend = function() {
                callback(reader.result);
            }
            reader.readAsDataURL(xhr.response);
        };
        xhr.open('GET', url); 
        xhr.responseType = 'blob';
        xhr.send();
    },
            
    // navigate to next pagination record set
    next: function(component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                {
                    Paginationlist.push(sObjectList[i]);
                }
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set("v.PaginationList", Paginationlist);
    },
    // navigate to previous pagination record set
    previous: function(component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                {
                    Paginationlist.push(sObjectList[i]);
                }
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set("v.PaginationList", Paginationlist);
    },
})