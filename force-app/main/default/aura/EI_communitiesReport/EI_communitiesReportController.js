({
  init: function (component, event, helper) {
    var actions = [
      { label: "View/Edit Branch", name: "view_edit_branch" },
      { label: "Login As Branch", name: "login_as_branch" }
    ];
    component.set("v.columns", [
      { label: "Property Postcode", fieldName: "Branch_Name__c", type: "text" },
      { label: "Address", fieldName: "completeAddress", type: "text" },
      { label: "Agent", fieldName: "Branch_Name__c", type: "text" },
      { label: "Landlord registration number", fieldName: "completeAddress", type: "text" }, 
      { label: "Landlord Name", fieldName: "Branch_Name__c", type: "text" },
      { label: "Landlord address", fieldName: "completeAddress", type: "text" },
      { label: "Tenants Name", fieldName: "Branch_Name__c", type: "text" },
      { label: "Deposit Received Date", fieldName: "completeAddress", type: "text" },       
        
      { label: "Active", fieldName: "Is_Active__c", type: "boolean" },
      { type: "action", typeAttributes: { rowActions: actions } }
    ]);

    var action = component.get('c.getBranchList');
    action.setCallback(this,function(response) {
      var state = response.getState();
        
      console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
		console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
           if(result.length == 0){
               component.set("v.currentPageLandlord",0);
           }else{
               component.set("v.currentPageLandlord",1);
           }
          
      if (result.length > 0) {
          component.set("v.listOfPropertyAlocations", result);
          
          //component.set("v.listOfPropertyAlocations", result);

          var pageSize = component.get("v.pageSizeLandlord");
          var totalRecordsList = result;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCountLandlord", totalLength);
        //  alert("totalRecordsCountLandlord" + component.get("v.totalRecordsCountLandlord"));
          component.set("v.startPageLandlord", 0);
        //  alert("startPageLandlord" + component.get("v.startPageLandlord"));
          component.set("v.endPageLandlord", pageSize - 1); 
        //  alert("endPageLandlord" + component.get("v.endPageLandlord"));
          
          var PaginationLst = [];
          for (let i = 0; i < pageSize; i++) {
            if (component.get("v.listOfPropertyAlocations").length > i) {
              //  alert("result[i]" + result[i]);
              PaginationLst.push(result[i]);
            }
          }
         
          component.set("v.PaginationLandlordList", PaginationLst);
         // alert("PaginationLandlordList : " + component.get("v.PaginationLandlordList"));
        //  component.set("v.branchlist", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
        }
		else {
          // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
        }
        else if (state === "ERROR") {
        var errors = response.getError();
        console.log(`${errors}`);
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
    
    downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.listOfPropertyAlocations");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData, 'csv');   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
    
    downloadXlsx : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.listOfPropertyAlocations");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData, 'xls');   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);       
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.xls';           
          
            // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
    
    
    
    
    /* Search Code*/
    handleSearch : function(component, event, helper) {
        
         /* if (event.keyCode === 13) {
                     var sel = document.getElementById("SelectItemPick");
    var selPickListValue = sel.options[sel.selectedIndex].value;
        helper.getMyLandlords(component, event, helper,selPickListValue);  
          }*/
        
        var searchKey = document.getElementById("searchValue").value;//component.find("searchValue").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.myPropertyList");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                console.log('Success = '+a.getReturnValue());
               //  component.set("v.PaginationLandlordList", a.getReturnValue());
                var result = a.getReturnValue();
                //alert("length search => " + result);
                if(result.length == 0){
                    component.set("v.currentPageLandlord",0);
                }else{
                    component.set("v.currentPageLandlord",1);
                }
                    
                if (result.length > 0) {
                    component.set("v.listOfPropertyAlocations", result);
                    
                    var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = result;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    //  alert("totalRecordsCountLandlord" + component.get("v.totalRecordsCountLandlord"));
                    component.set("v.startPageLandlord", 0);
                    //  alert("startPageLandlord" + component.get("v.startPageLandlord"));
                    component.set("v.endPageLandlord", pageSize - 1); 
                    //  alert("endPageLandlord" + component.get("v.endPageLandlord"));
                    
                    var PaginationLst = [];
                    for (let i = 0; i < pageSize; i++) {
                        if (component.get("v.listOfPropertyAlocations").length > i) {
                            //  alert("result[i]" + result[i]);
                            PaginationLst.push(result[i]);
                        }
                    }
                    
                    component.set("v.PaginationLandlordList", PaginationLst);
                    alert("PaginationLandlordList : " + component.get("v.PaginationLandlordList"));
                    component.set("v.selectedCount", 0);
                    component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
                }else {
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound", true);
                }
            }
        });
        $A.enqueueAction(action);    
               
    },
   
    
    navLandlordPage: function(component, event, helper) {
        var sObjectList = component.get("v.listOfPropertyAlocations");
        var end = component.get("v.endPageLandlord");
        var start = component.get("v.startPageLandlord");
        var pageSize = component.get("v.pageSizeLandlord");
        //var whichBtn = event.getSource().get("v.name");
        //
        // check if whichBtn value is 'next' then call 'next' helper method
        if (event.target.id == "nextId") {
            component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") + 1);
            helper.nextLandlord(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (event.target.id == "previousId") {
            component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") - 1);
            helper.previousLandlord(component, event, sObjectList, end, start, pageSize);
        }
    },
});