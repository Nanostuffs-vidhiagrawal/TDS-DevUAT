({
  CSV2JSON: function (component,csv,filename) {
      //  alert('Incoming csv = ' + filename);
      
      //var array = [];
      var arr = []; 
      
      arr =  csv.split('\n');
      //console.log('Array  = '+array);
      // console.log('arr = '+arr);
      arr.pop();
      var count = 0;
      var jsonObj = [];
      var errorObj = [];
      var headers = arr[0].split(',');
      for(var i = 1; i < arr.length; i++) {

        var data = arr[i].replaceAll(',', '');
        // console.log("data => " + data);

          if(data.trim() != ''){

            data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
              obj[headers[j].trim()] = data[j].trim();
              console.log('obj headers = ' + headers[j].trim() + ' => ' + data[j].trim());
                if(j%2 == 1){
                    var errordata =  {rowNo: i, tenants: i+j*5, landlords: i+j*2, 
                        status: "Failed", fieldName: headers[j].trim(), 
                        datainField: data[j].trim(), error: "error found in data" };
                        
                    errorObj.push(errordata);
                }
            }

            jsonObj.push(obj);
            count++;
          }
          
      }

      console.log("jsonObj => " + jsonObj);
      console.log("errorObj => " + errorObj);

      // all Tenancies Data List
      component.set("v.ListOfTenancies", jsonObj);

      // CSV Validation Errors
      component.set("v.validationErrorList", errorObj);

      // CSV Validation Result
     
      var todate = $A.localizationService.formatDate(new Date(), "dd/MM/yyyy");
      var validationResult = [ {date: todate, validateOnly: "Yes", fileName: filename, totalTenancies: count, failures: 0, status: "Failed"} ];
      component.set("v.validateCSVResult", validationResult);
      console.log("validationResult => " + component.get("v.validateCSVResult"));

    // return jason of tenancy Data List
    var json = JSON.stringify(jsonObj);
    return json;
      
  },
  
  CreateDeposits : function (component,jsonstr){
      alert('jsonstr' + jsonstr);
      var action = component.get('c.insertData');
      // action.setParams({
      //     strfromle : jsonstr
      // });
      // action.setCallback(this, function(response) {
      //     var state = response.getState();
      //     if (state === "SUCCESS") {  
      //         var result=response.getReturnValue();
      //         alert("Accounts Inserted Succesfully");
              
      //     }
      //     else if (state === "ERROR") {
      //         var errors = response.getError();
      //         if (errors) {
      //             if (errors[0] && errors[0].message) {
      //                 //console.log("Error message: " + errors[0].message);
      //             }
      //         } else {
      //             //console.log("Unknown error");
      //             //alert('Unknown');
      //         }
      //     }
      // }); 
      
      // $A.enqueueAction(action);    
      
  },
    
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
    component.set("v.showImportLogsList", Paginationlist);
  },

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
    component.set("v.showImportLogsList", Paginationlist);
  }, 

  
})