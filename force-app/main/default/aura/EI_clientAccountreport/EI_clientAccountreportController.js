({
	showdata : function(component, event, helper) {
        var startDate= component.find("FRD").get("v.value");
        var endDate= component.find("ToD").get("v.value");
        if(startDate == undefined || startDate == "" || startDate==null ){
         alert('Please enter  Start date');

        }
         else if(endDate == undefined || endDate == "" || endDate==null ) {
             alert('please enter End date');
           
         }
            else{   
        var action = component.get("c.fetchdeposit");
        action.setParams({startDate : startDate,endDate : endDate});
        console.log('line-->7');
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfContact attribute on component.
                console.log('line-->11'+JSON.stringify(response.getReturnValue()));
                var allValues = response.getReturnValue();
                if(allValues!=null){
                    component.set('v.deplist', allValues);
                }
            }
        });
        $A.enqueueAction(action);
            }
   },
   
    downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.deplist");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
       }
    
})