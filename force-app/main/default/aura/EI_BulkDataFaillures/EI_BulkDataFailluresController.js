({
    doInit : function(component, event, helper) {
        var failures = component.get("v.totalfailuresList");
        // for(let i=0; i<10; i++){
        //     var data =  {index: i, rowNo: i+1, tenants: i+1*5, landlords: i+1*2, 
        //                 status: "Failed", fieldName: "date", 
        //                 datainField: "myDate", error: "error found in data" };
        //     failures.push(data);
        // }
        console.log("failures " + failures);
        // component.set("v.totalfailuresList", failures);
        console.log("totalfailuresList " + component.get("v.totalfailuresList"));
        // Pagination
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = failures;
        var totalLength = totalRecordsList.length;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (component.get("v.totalfailuresList").length > i) {
                PaginationList.push(failures[i]);
            }
        }
        component.set("v.showfailuresList", PaginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
    },

    handleUpdateErrors : function(component, event, helper){
        component.set("v.isUpdateError", true);
    },

    handleUpdateFieldData : function(component, event, helper){
        const inputValue = event.getSource().get('v.value');
        console.log("inputValue => " + inputValue);
        // var indexNo = document.getElementById("titleId").indexNo;
        // console.log("indexNo => " + indexNo);
        
        // edit field value in deposit object list
        var totalFailures = component.get("v.totalfailuresList");
        var error = totalFailures[0]; // static 
        console.log("error => " + error);
        var ListTenancies = component.get("v.ListOfTenancies");
        var fieldname = error.fieldName;
        console.log("fieldname => " + fieldname);
        console.log("field value => " + ListTenancies[error.rowNo -1][fieldname]);
        ListTenancies[error.rowNo -1][fieldname] = inputValue;
        console.log("updated value => " + ListTenancies[error.rowNo -1][error.fieldName]);
        component.set("v.ListOfTenancies", ListTenancies);
    },

    handleValidate : function(component, event, helper){
        component.set("v.isUpdateError", false);
    },

    navPage: function(component, event, helper) {
        var sObjectList = component.get("v.totalfailuresList");
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
    },

    handleShowModel: function(component, event, helper) {
       
        component.set("v.showModal", true);
        var indexNo = event.target.id;
        console.log("index No => " + indexNo);
        component.set("v.indextoRemove", indexNo);
    },
    
    hideModel: function(component, event, helper) {
        component.set("v.showModal", false);
    },
    
    handleYes: function(component, event, helper) {
        var indexNo = component.get("v.indextoRemove");
        console.log("indextoRemove => " + indexNo);
        var totalFailures = component.get("v.totalfailuresList");

        // remove row contains error
        var error = totalFailures[indexNo];
        var ListTenancies = component.get("v.ListOfTenancies");
        ListTenancies.splice(error.rowNo -1, 1);
        component.set("v.ListOfTenancies", ListTenancies);

        // remove record from failures list
        for(var i = 0; i < totalFailures.length; i++ ){
            console.log("error.rowNo => " + error.rowNo);
            console.log("totalFailures["+i+"].rowNo =>" + totalFailures[i].rowNo);
            if(totalFailures[i].rowNo == error.rowNo){
                console.log("condition check" +totalFailures[i].rowNo == error.rowNo);
                totalFailures.splice(i, 1);
                i--;
            }
        }
        
        component.set("v.totalfailuresList", totalFailures);
        // console.log("totalFailures => " + totalFailures);

        //Pagination
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = totalFailures;
        var totalLength = totalRecordsList.length;
        component.set("v.totalRecordsCount", totalLength);

        var start = component.get("v.startPage");
        var end = component.get("v.endPage");
        component.set("v.start", 0);
        component.set("v.end", start + pageSize - 1);
        
        var PaginationList = [];
        for (var i = start; i < start + pageSize; i++) {
            if (totalFailures.length > i) {
                PaginationList.push(totalFailures[i]);
            }
        }
        component.set("v.showfailuresList", PaginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        // hide model
        component.set("v.showModal", false);
    }

})