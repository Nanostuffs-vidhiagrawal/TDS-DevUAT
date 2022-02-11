({
         nextLandlord: function(component, event, sObjectList, end, start, pageSize) {
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
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  },
     previousLandlord: function(component, event, sObjectList, end, start, pageSize) {
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
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  }, 
  getMyLandlords : function(component, event, helper,selPickListValue) {
      console.log('@@ mylandlord');
 //      var sel = document.getElementById("SelectItem");
    
          var searchTextValue =$("#searchValue").val();
      if(searchTextValue == null){
          searchTextValue = '';
      }
              const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var action = component.get("c.myLandlordList");
         action.setParams({
            searchVar: searchTextValue,
             status : selPickListValue,
             branchId:branchId
        }); 
       console.log('@@ action '+action );
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            console.log('landsearch '+state);
            if (state == "SUCCESS") {
               console.log('returned value '+a.getReturnValue());
                if(a.getReturnValue()!=null ){
                    if(a.getReturnValue() == ''){
                        component.set("v.currentPageLandlord",0);
                    }else{
                        component.set("v.currentPageLandlord",1);
                    }
                    
                 //    document.getElementById("SelectItem").value = '-- Please select --';
                    component.set("v.LandlordListView",a.getReturnValue());
                 //   console.log('+++++++++LandlordListView++++'+component.get("v.LandlordListView"));
                  //  component.set("v.strRecordId",propertyRecId);                    
                    var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = a.getReturnValue();
                //    console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    component.set("v.startPageLandlord", 0);
                    component.set("v.endPageLandlord", pageSize - 1);
                    var PaginationLandlordList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.LandlordListView").length > i) {
                            PaginationLandlordList.push(a.getReturnValue()[i]);
                        }
                    }//console.log('+++++++++PaginationLandlordList++++'+JSON.stringify(PaginationLandlordList));
                    component.set("v.PaginationLandlordList", PaginationLandlordList);
                  //  console.log('++++++PaginationLandlordList+++++++'+component.get("v.PaginationLandlordList"));
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
                 //   var xyz = getElementsByClassName("dataTables_empty");
                    for(i = 0; i < xyz.length; i++) {
                        xyz.style.visibility = 'hidden';
                    }
                   
                   // document.getElementsByClassName("dataTables_empty").style.visibility = 'hidden';
                }
                
            }else{
             //   alert('error '+ JSON.stringify(errors));
            }
            
        });
        
        $A.enqueueAction(action);
     setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 3000);
    },
    
    fetchPhoneCodePicklist : function(component, event, helper){
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phoneCodePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
         
    }
})