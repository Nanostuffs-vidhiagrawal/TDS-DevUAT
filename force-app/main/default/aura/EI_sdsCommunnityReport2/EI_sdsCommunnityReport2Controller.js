({
	   
    downloadCsv : function(component,event,helper){
       
        var stockData = component.get("v.listOfdepositDownload");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData,'csv');   
         if (csv == null){return;} 
        
           
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'Closed deposits.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
       },
    
    
    
    searchrecord :  function(component, event, helper) {

        let depositeStartDate = document.getElementById("depositeStartDate").value;        
        let depositeStartMonth = document.getElementById("depositeStartMonth").value;       
        let depositeStartYear = document.getElementById("depositeStartYear").value;
        
        let depositeEndDate = document.getElementById("depositeEndDate").value;       
        let depositeEndMonth = document.getElementById("depositeEndMonth").value;        
        let depositeEndYear = document.getElementById("depositeEndYear").value;        
              
        let startDate = depositeStartYear+'-'+depositeStartMonth+'-'+depositeStartDate;
        component.set('v.startDateByTenant',startDate);
        console.log('line 44 startDate '+startDate);
        let startDateYMD =depositeStartYear+'-'+depositeStartMonth+'-'+depositeStartDate;
        let jsDataStart =   depositeStartMonth+'-'+ depositeStartDate+'-'+depositeStartYear;
          
        
        let EndDate = depositeEndYear+'-'+depositeEndMonth+'-'+depositeEndDate;
        component.set('v.endDateByTenant',EndDate);
        console.log('line 41 EndDate '+EndDate);
        let EndDateYMD =depositeEndYear+'-'+depositeEndMonth+'-'+depositeEndDate;
        let jsDataEnd =   depositeEndMonth+'-'+ depositeEndDate+'-'+depositeEndYear;   
         
          if(startDate == undefined || startDate == "" || startDate==null ){
        // alert('Please enter  Start date');
              
          }
        else if(EndDate == undefined || EndDate == "" || EndDate==null ) {
            //alert('please enter End date');
            
        }
            else{  
               // alert('line no 60');
                
                console.log('line 54 - > '+component.get("v.startDateByTenant"));
                console.log('line 68 - > '+component.get("v.endDateByTenant"));
                
                var action = component.get("c.fetchdeposit2");
                action.setParams({
                   
                    startDate: startDate, endDate: EndDate
                });
                action.setCallback(this, function(response){                    
                    
                	console.log('line-->7');
                    var state = response.getState();
                    console.log('line67'+state);
                    
                    if (state == "SUCCESS") {
                        
                        console.log('line-->11'+JSON.stringify(response.getReturnValue()));
                        var result = response.getReturnValue();
                      
                        if(result!= null){
                            var listofdeposit = [];
                            for(var i=0; i< result.length; i++){
                                var prop =result[i];                                                               
                                var dan = result[i].Deposit_Account_Number__c != undefined ? result[i].Deposit_Account_Number__c:"";
                                                    
                                var address = result[i].Property_Address__c != undefined ? result[i].Property_Address__c:" ";
								 var repaidreason = result[i].Repaid_reason_status__c != undefined ? result[i].Repaid_reason_status__c:" ";                                
                                var depamount = result[i].Deposit_Amount__c != undefined ? result[i].Deposit_Amount__c:" ";
                                                                            
                                var amttenant = result[i].Amount_paid_to_TenantNew__c != undefined ? result[i].Amount_paid_to_TenantNew__c:" ";
                                var amtagll = result[i].Amount_paid_to_AG_LL__c != undefined ? result[i].Amount_paid_to_AG_LL__c:" ";
                                
                                
                                var curOBJ = new Object();   
                                curOBJ['dan'] = dan;
                                curOBJ['address'] = address;
								curOBJ['repaidreason'] = repaidreason;                                
                                curOBJ['depamount'] = depamount;                               
                                curOBJ['amttenant'] = amttenant;
                                curOBJ['amtagll'] = amtagll;                                
                               // console.log("obj after => " +JSON.stringify(curOBJ));
                                listofdeposit.push(curOBJ); 
                            }
                            
                            component.set('v.deplist',result);
                            component.set("v.listOfdepositDownload",listofdeposit);
                            
                                 //pagination code                  
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = result;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.deplist").length > i) {
              PaginationLst.push(result[i]);
            }
          }
          component.set("v.PaginationList", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                        }
                        
                        else {
             console.log("line-->9 ELSE" );
 			component.set("v.PaginationList", "");
            // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        
                        }           
                    }            
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("result:", result);
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }  
    },
    
      backtoList :  function(component, event, helper) {
          
          //alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "sdscommunityreport"
            },
            state: {
               // depositId: depositId
            }
         });
          
      },
    
     onDepositePageController :function(component, event, helper){
         console.log('Line no 11--->',event.target.id);
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id: event.target.id
            }
        });        
        
    },navigation :  function(component, event, helper){
         var sObjectList = component.get("v.deplist");
    var end = component.get("v.endPage");
    var start = component.get("v.startPage");
    var pageSize = component.get("v.pageSize");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPage", component.get("v.currentPage") + 1);
      helper.next(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPage", component.get("v.currentPage") - 1);
      helper.previous(component, event, sObjectList, end, start, pageSize);
    }
        
    } 
    
    
    
    
})