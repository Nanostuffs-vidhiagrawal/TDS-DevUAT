({
	
      doInitHelper: function(component, event,selPickListValue) {
       console.log('Helper +++');
    var action = component.get("c.getLandLordStatus");
        action.setParams({
             status : selPickListValue
        }); 
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var depositResponse = response.getReturnValue();
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
          console.log(':::lenght='+depositResponse.length);
        if (depositResponse.length > 0) {
            component.set("v.bNoRecordsFound", false);
        //component.set("v.depositeList", oRes);
            
         /*   for(var i=0;i<depositResponse.length; i++){
                console.log('::Deposit Response'+depositResponse[i]);
                console.log('::Result='+depositResponse[i].LastModifiedDate);
                var today =  new Date(depositResponse[i].LastModifiedDate);
               
                    var perdate = today.getDate() ;
                console.log('::perDate='+perdate);
                    if(perdate == 1){
                    perdate = perdate + 'st';
                    }else if(perdate == 2){
                    perdate = perdate + 'nd';
                    } else if(perdate == 3){
                    perdate = perdate + 'rd';
                    } else if(perdate > 3){
                    perdate = perdate + 'th';
                    }
              var   monthNames = ["January", "February", "March", "April", "May", "June",
			  "July", "August", "September", "October", "November", "December"];
             	var date = perdate   + ' ' +(monthNames[today.getMonth()]) +  ' ' +today.getFullYear();
                console.log('::Date='+date);
                depositResponse[i].LastModifiedDate = date; 
              
                console.log('::Date='+ date);
                console.log('::DateNew='+  depositResponse[i].LastModifiedDate);
		}*/
             component.set("v.depositeList", depositResponse);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = depositResponse;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.depositeList").length > i) {
              PaginationLst.push(depositResponse[i]);
            }
          }
          component.set("v.PaginationList", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        } else {
             console.log("line-->9 ELSE" );
 			component.set("v.PaginationList", "");
            // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
      } else {
        //alert('Error...');
      }
    });
    $A.enqueueAction(action);
   // $A.get("e.force:refreshView").fire();
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
  } 
});