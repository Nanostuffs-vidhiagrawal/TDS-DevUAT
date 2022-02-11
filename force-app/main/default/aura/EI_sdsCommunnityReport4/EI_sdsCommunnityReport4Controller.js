({	
    doInit: function (component, event, helper) {  
       
        var action = component.get('c.fetchdeposit4');
        action.setCallback(this, function(response){         
            
            var state = response.getState();         
            if (state == "SUCCESS") {             
                var result = response.getReturnValue();               
                if(result != null){
                    var listofdeposit = [];
                    console.log("result.length() => " + result.length);
                    for(var i=0; i< result.length; i++){
                        var prop =result[i];                                                    
                        var dan = result[i].Deposit_Account_Number__c != undefined ? result[i].Deposit_Account_Number__c:"";                        
                        var address = result[i].Property_Address__c != undefined ? result[i].Property_Address__c:" ";                        
                        var startdate = result[i].Protection_Start_Date__c != undefined ? result[i].Protection_Start_Date__c:" ";
                        var enddate = result[i].End_Date__c != undefined ? result[i].End_Date__c:" ";
                        var repaidreason = result[i].Deposit_repaid_reason_status__c != undefined ? result[i].Deposit_repaid_reason_status__c:" ";
                        var depamount = result[i].Deposit_Amount__c != undefined ? result[i].Deposit_Amount__c:" ";                        
                        
                        var repaymentrequest='';
                       
                        if(result[i].Repayment_Requests__r != null && result[i].Repayment_Requests__r.length > 0){
                            for(var t=0; t<result[i].Repayment_Requests__r.length; t++){                    
                                repaymentrequest += result[i].Repayment_Requests__r[t].Total_Amount_Requested_AL__c != undefined ? result[i].Repayment_Requests__r[t].Total_Amount_Requested_AL__c : "";
                                console.log("line-->57  " +repaymentrequest);
                                repaymentrequest+= ',';
                            }
                        }else{
                            repaymentrequest='';                                    
                        }                                
                        var amttenant = result[i].Amount_paid_to_TenantNew__c != undefined ? result[i].Amount_paid_to_TenantNew__c:" ";
                        var amtagll = result[i].Amount_paid_to_AG_LL__c != undefined ? result[i].Amount_paid_to_AG_LL__c:" ";
                        var amtcasestatus = result[i].Case_Status__c != undefined ? result[i].Case_Status__c:" ";
                        
                        var curOBJ = new Object();   
                        curOBJ['dan'] = dan;
                        curOBJ['address'] = address;
                        curOBJ['startdate'] = startdate;
                        curOBJ['enddate'] = enddate;
                        curOBJ['repaidreason'] = repaidreason;
                        curOBJ['depamount'] = depamount;
                        curOBJ['repaymentrequest'] = repaymentrequest;
                        curOBJ['amttenant'] = amttenant;
                        curOBJ['amtagll'] = amtagll;
                        curOBJ['amtcasestatus'] = amtcasestatus;
                        console.log("obj after => " +JSON.stringify(curOBJ));
                        listofdeposit.push(curOBJ); 
                    }                    
                    console.log("result:", result);
                    component.set("v.deplist",result);
                    component.set("v.listOfdepositDownload",listofdeposit);
                    
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
     },
    
    downloadCsv : function(component,event,helper){
        
       
        var stockData = component.get("v.listOfdepositDownload");        
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData,'csv');   
         if (csv == null){return;}         
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'Archived deposits.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
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
        
    },
    
    navigation :  function(component, event, helper){
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