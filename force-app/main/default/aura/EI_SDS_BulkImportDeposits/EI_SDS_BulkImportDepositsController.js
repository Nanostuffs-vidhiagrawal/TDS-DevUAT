({
    doInit : function(component, event, helper) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
                console.log('lie 6');
                var str2blob = JSON.stringify(xhttp.responseText);
                //Buffer bb= new Buffer();
                console.log('xhttp.responseText ',unescape(encodeURIComponent(str2blob)).length);
                component.set('v.rec',str2blob);
                console.log('ddd ',component.get('v.rec'));
                /*var reader = new FileReader();
                reader.onload = function() {
                   
                   // helper.csvToArray(component,reader.result);
                    console.log('line 333 ',component.get('v.rec'));
                }
                reader.readAsText(str2blob);*/
            }
        };
        xhttp.open("GET", "https://sdsevidencedev.blob.core.windows.net/evidence/1633453671216-1633351754763-ListofTenancy(1)(3).csv?sp=rw&st=2021-06-18T15:27:12Z&se=2031-06-18T23:27:12Z&spr=https&sv=2020-02-10&sr=c&sig=ny8xLiSPlms%2FpN%2FtAIYuJaJI7VNQBqc9eqL7V%2BlrQLs%3D", true);
        xhttp.send();  
        
     /*   setTimeout(function(){
        console.log('line 19 ',component.get('v.rec'));
            }, 5000);*/
        
        setTimeout(function(){
            console.log('line 24 ',component.get('v.rec'));
        var action = component.get("c.runImportBatch");
        action.setParams({ fileRecords : component.get('v.rec')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // console.log("From server: " + response.getReturnValue());
            }
           
        });
        $A.enqueueAction(action);
            console.log('finish');
            //console.log('line 34 ',component.get('v.rec'));
        }, 10000);
        
    }
})