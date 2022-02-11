({
  init: function (component, event, helper) {  
      //alert("fetch Local Athority records");
    var action = component.get('c.getBranchList');
    action.setCallback(this,function(response) {
       // alert("fetch Local Athority records" + response.getState());
       // alert("values" + response.getReturnValue());
    var state = response.getState();        
      //console.log(`state=> ${state}`);
    if (state === "SUCCESS") {
       var result = response.getReturnValue();
       //console.log(result.length);
       //console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
          if(result.length == 0){
              component.set("v.currentPageLandlord",0);
          }
        else{
              component.set("v.currentPageLandlord",1);
         }
          
          if (result.length > 0) {              
              var listofProperties = [];
              for(var i=0; i< result.length; i++){
               var prop =result[i];
               //console.log("line-->24 " + JSON.stringify(prop));
                 
                  var postcode = result[i].Postal_Code__c != undefined ? result[i].Postal_Code__c:"";
                  //console.log("line-->28" +postcode);   

                  var address1 = result[i].Street__c != undefined ? result[i].Street__c:" ";
                  var address2 =result[i].City__c != undefined ? result[i].City__c:"";
                  
                  var address = address1 + ',' +address2;
                  
                  //console.log("line-->32  " +address)
                  
                  if(result[i].Property_Owner__r.RecordType.Name =='Letting Agent' ||result[i].Property_Owner__r.RecordType.Name =='Organization'){
                      var agentName = result[i].Property_Owner__r.Name!= undefined ? result[i].Property_Owner__r.Name:"";
                      //console.log("line-->36  " +agentName)
                  }else{
                       var agentName = "";
                  }
                  
                  var landlordRegNo = result[i].Landlord_Registration_Number__c != undefined ? result[i].Landlord_Registration_Number__c :  "";
                  console.log("line-->39  " +landlordRegNo)
            
                  if(result[i].Property_Owner__r.RecordType.Name =='Individual Landlord' || result[i].Property_Owner__r.RecordType.Name =='Corporate Landlord'){
                      var landlordName = result[i].Property_Owner__r.Name != undefined ? result[i].Property_Owner__r.Name : "";
                      //console.log("line-->42  " +landlordName)
                  }else{
                       var landlordName = "";
                  }
             
                  var landlordAddress = result[i].Property_Owner__r.Address__pc != undefined ? result[i].Property_Owner__r.Address__pc : "";
                  console.log("line-->53  " +result[i].Property_Owner__r.Address__pc);  
                  landlordAddress = landlordAddress.replaceAll('/n', ' ');
                  result[i].Property_Owner__r.Address__pc = landlordAddress;
          	 var tenantName ='';
              var depositRerceivedDate ='';   
                  if(result[i].Deposits__r){
                      for(var t=0; t<result[i].Deposits__r.length; t++){                    
                           tenantName += result[i].Deposits__r[t].Tenants_Name__c != undefined ? result[i].Deposits__r[t].Tenants_Name__c : "";
                          console.log("line-->57  " +tenantName);
                          tenantName+= ',';
                           depositRerceivedDate +=   result[i].Deposits__r[t].Date_Deposit_Received__c != undefined ? result[i].Deposits__r[t].Date_Deposit_Received__c + "," : " "; 
                          //console.log("line-->59  " +depositRerceivedDate)
                          //depositRerceivedDate+=',';
                      }
                  }else{
                        tenantName = "";
                       depositRerceivedDate = "";
                  }
                  var curOBJ = new Object();   
                  curOBJ['postcode'] = postcode;
                  curOBJ['address'] = address;
                  curOBJ['agentName'] = agentName;
                  curOBJ['landlordRegNo'] = landlordRegNo;
                  curOBJ['landlordName'] = landlordName;
                  curOBJ['landlordAddress'] = landlordAddress;
                  curOBJ['tenantName'] = tenantName;
                  curOBJ['depositRerceivedDate'] = depositRerceivedDate;
                  console.log("obj after => " +JSON.stringify(curOBJ));
                  listofProperties.push(curOBJ); 
              }
          
              //mponent.set("v.listOfPropertyAlocations",listofProperties);
              component.set("v.listOfPropertyAlocationsforDownload",listofProperties);
              component.set("v.listOfPropertyAlocations",result);
              
              var pageSize = component.get("v.pageSizeLandlord");
              var totalRecordsList = result;
              console.log("line 83 => " +totalRecordsList);
              var totalLength = totalRecordsList.length;
              component.set("v.totalRecordsCountLandlord", totalLength);
              // alert("totalRecordsCountLandlord" + component.get("v.totalRecordsCountLandlord"));
              component.set("v.startPageLandlord", 0);
              //  alert("startPageLandlord" + component.get("v.startPageLandlord"));
              component.set("v.endPageLandlord", pageSize - 1); 
              //  alert("endPageLandlord" + component.get("v.endPageLandlord"));
          
              var PaginationLst = [];
              for (let i = 0; i < pageSize; i++) {
                  if (component.get("v.listOfPropertyAlocations").length > i) {
                      //alert("result[i]" + result[i]);
                     PaginationLst.push(result[i]);
                  }
              }
              
              component.set("v.PaginationLandlordList", PaginationLst);
              //console.log("PaginationLandlordList : " + JSON.stringify(component.get("v.PaginationLandlordList")) );
              //  component.set("v.branchlist", PaginationLst);
              component.set("v.selectedCount", 0);
              //use Math.ceil() to Round a number upward to its nearest integer
              component.set("v.totalPagesCountLandlord",Math.ceil(totalLength / pageSize));
              //alert("pageSize => "+ pageSize);
              //alert("totalLength => "+ totalLength);
              //alert("totalPagesCountLandlord => "+ component.get("v.totalPagesCountLandlord"));
              
          }
          else {
              // if there is no records then display message
              component.set("v.bNoRecordsFound", true);
          }
      }
      else if (state === "ERROR") {
            var errors = response.getError();
            //console.log(`${errors}`);
            if (errors) {
                if (errors[0] && errors[0].message) {
                    //console.log("Error message: " + errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        }
    });
    $A.enqueueAction(action);
  },
    
    downloadCsv : function(component,event,helper){        
       
        var stockData = component.get("v.listOfPropertyAlocationsforDownload");        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData, 'csv');   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'SafeDeposits Scotland export data.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
    
    downloadXlsx : function(component,event,helper){        
        
        var stockData = component.get("v.listOfPropertyAlocationsforDownload");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData, 'xls');   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);       
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'SafeDeposits Scotland export data.xls';           
          
            // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        },     
   
    /* Search Code*/
    handleSearch : function(component, event, helper) {      
        
        
        var searchKey = document.getElementById("searchValue").value;               
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.myPropertyList");
        action.setParams({
            "searchKey": searchKey
        });
      action.setCallback(this, function(a) {
          var state = a.getState();
          if(state === 'SUCCESS'){
              // console.log('Success = '+a.getReturnValue());               
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
                  // alert("PaginationLandlordList : " + component.get("v.PaginationLandlordList"));
                  component.set("v.selectedCount", 0);
                  component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
              }else {
                  // if there is no records then display message
                  component.set("v.bNoRecordsFound", false);
              }
            }
        });
        $A.enqueueAction(action);  
        
    },   
 /* javaScript function for pagination */
    
navLandlordPage: function(component, event, helper) {
        var sObjectList = component.get("v.listOfPropertyAlocations");
         console.log('lineno 240 ='+sObjectList);
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
    }    
    

});