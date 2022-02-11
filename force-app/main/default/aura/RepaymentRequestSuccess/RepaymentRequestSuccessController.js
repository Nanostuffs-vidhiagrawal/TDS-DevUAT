({
    doInit : function(component, event, helper) {
        var url = window.location.href.slice(window.location.href.indexOf('?') + 1);
        var repaymentRecordId = url.split("repaymentrequest=")[1];
        console.log('+++++++++++repaymentRecordId++'+repaymentRecordId);
        component.set("v.repaymentRequestRecordId", repaymentRecordId);
        //helper.getRepaymentRequest(component);
    },
    
    goBackDepositRecord : function(component, event, helper) {
        //var depositId = component.get("v.repaymentRequest.Deposit__c");
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id : depositId
            }
        }); 
    },
    
    reviewRepaymentRequest : function(component, event, helper) {
        console.log('+++++++++++repaymentRecordId++');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "repaymentrequestrecordsummary"
            },
            state: {
                repaymentrequest : component.get("v.repaymentRequestRecordId")
            }
        });
    },
})