({
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
    },
    convertArrayOfObjectsToCSV : function(component,objectRecords){


        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['FirstName','LastName','Department','MobilePhone','Id' ];
        
        csvStringResult = '';
        //csvStringResult += keys.join(columnDivider);
        //csvStringResult += lineDivider;
        for(var i=0; i < objectRecords.length; i++){   

            var amount = objectRecords[i].objInstallment.Amount__c
            var sortCode = objectRecords[i].objInstallment.Bank_Sort_Code__c
            var accountNumber = objectRecords[i].objInstallment.Bank_Account_Number__c
            var DAN =objectRecords[i].objInstallment.Deposit__r.Deposit_Account_Number__c
            var holderName = objectRecords[i].objInstallment.Bank_Account_Holder_Name__c;
            var wokingDate = objectRecords[i].workingDate;
            //toRemoveSpecialCharacter
            holderName = holderName.replace(/[^a-zA-Z0-9 ]/g, "")
            csvStringResult += ',,,01,,,,,,,,,83060812313511,,,,'+amount.toFixed(2)+',,'+wokingDate+',,,,,,'+sortCode+',,,,,,'+accountNumber+',,'+holderName+',,,,SDS '+DAN+',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'; 
            csvStringResult += lineDivider;
          } 
       // return the CSV formate String 
        return csvStringResult;        
    },
})