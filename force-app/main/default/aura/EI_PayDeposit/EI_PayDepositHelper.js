({
    setDepositParameters : function(component,event,helper) {
        
        /*var depositList = component.get("v.depositList");
        var depositToPay =0;
        var TotalDeposits = 0;
        var depositsToBeProtected = '';
        var selectedDeposits = [];
        for(var deposit in depositList){
            if(deposit.isSelected == true){
                
                TotalDeposits += 1;
                depositToPay += deposit.objDeposit.Protected_Amount__c;
                if(depositsToBeProtected == ''){
                    depositsToBeProtected = deposit.objDeposit.Deposit_Account_Number__c;
                }else{
                    depositsToBeProtected = depositsToBeProtected+';'+deposit.objDeposit.Deposit_Account_Number__c;
                }
                selectedDeposits.push(deposit);
            }
            
        }
        component.set("v.DepositsToBeProtected", depositsToBeProtected);
        component.set("v.AmountToBePaid", depositToPay);
        component.set("v.TotalDeposits", TotalDeposits);
        component.set("v.selectedDeposits", selectedDeposits);*/
    },
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:msg,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
            
        });
        toastEvent.fire();
    }
})