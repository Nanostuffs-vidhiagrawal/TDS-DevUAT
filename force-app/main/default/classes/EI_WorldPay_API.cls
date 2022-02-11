@RestResource(urlMapping='/tds_worldpay_api')
global class EI_WorldPay_API {

    @HttpPost
    global static void postMethod() {
         
        //Update Protected Amount 
        RestRequest req = RestContext.request;
        map<String,String> worldpayParams = req.params;
        system.debug('>>>>>>>>>>>>>>>>>>'+JSON.serializePretty(worldpayParams));
        
        list<String> danToProcess = new list<String>();
        if(worldpayParams != null && !worldpayParams.isEmpty() && worldpayParams.containsKey('authAmountString') && String.isNotBlank(worldpayParams.get('authAmountString'))){
            
            String cartId = worldpayParams.containsKey('cartId')?worldpayParams.get('cartId'):'';
            Decimal amount = worldpayParams.containsKey('amount')?Decimal.valueOf(worldpayParams.get('amount')):null;
            Id inboundReportRecId = Schema.SObjectType.Inbound_Report__c.getRecordTypeInfosByName().get('SDS Inbound Report').getRecordTypeId();
			Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
            if(String.isNotBlank(cartId) && cartId.contains('DAN') && amount != null){

                //Find Installment 
                list<Installment__c> installmentList = [Select Id,Name,Deposit__r.Status__c, Deposit__r.Deposit_Amount__c,Amount__c,Deposit__r.Deposit_Account_Number__c,Deposit__c,Installment_Type__c,Status__c,Deposit__r.Protected_Amount__c from Installment__c
                                                                            where Deposit__r.Deposit_Account_Number__c =: cartId 
                                                                            AND Status__c = 'Pending'
                                                                            AND Installment_Type__c = 'Receivable' 
                                                                            AND Amount__c =: amount ORDER BY LastModifiedDate DESC]; 

                System.debug('>>>>>>>>>>>'+installmentList.size());
                //Create Inbound report
                Inbound_Report__c report = new Inbound_Report__c();
                report.RecordTypeId = inboundReportRecId;
                report.Reference1__c = cartId;
                //?????
                report.Collection_Date__c = System.today();
                if(worldpayParams.containsKey('amount'))
                    report.Amount__c = Decimal.valueOf(worldpayParams.get('amount'));
                if(installmentList != null && !installmentList.isEmpty()){
                    report.Installment__c = installmentList[0].Id;
                    
                }else{
                    report.Matched_Colour__c = 'Red';
                }
                
                report.Payment_Method__c = 'Debit Card';
                if(worldpayParams.containsKey('transId'))
                    report.Transaction_Id__c = worldpayParams.get('transId');

                insert report;

                //Create Payment if Installment found for report

                if(String.isNotBlank(report.Installment__c)){

                   
                    //Create Payment Record
                    Payment__c pay = new Payment__c();
                    pay.Amount__c = report.Amount__c;
                    pay.Collection_Date__c = report.Collection_Date__c;
                    pay.Inbound_Report__c = report.Id;
                    pay.Installment__c = report.Installment__c;
                    pay.DAN__c = installmentList[0].Deposit__c;
                    pay.Transaction_Id__c = report.Transaction_Id__c;
                    pay.Payment_Type__c = 'Receivable';
					pay.Payment_Status__c = 'Paid';
                    pay.RecordTypeId = paymentRecId;
                    
                    insert pay;

                     //update Installment Status 
                     Update new Installment__c(Id= report.Installment__c,Status__c = 'Collected',Payment_Method__c='Debit Card');

                    //Update Deposit status 

                    if(String.isNotBlank(installmentList[0].Deposit__c)){
                        if(installmentList[0].Deposit__r.Status__c == 'Deposits held by scheme'){
                            Decimal protectedAmount = installmentList[0].Deposit__r.Protected_Amount__c+installmentList[0].Amount__c;
                            //Decimal depositAmount = installmentList[0].Deposit__r.Deposit_Amount__c+installmentList[0].Amount__c;
                            
                            if(protectedAmount > installmentList[0].Deposit__r.Deposit_Amount__c){
                                Update new Deposit__c(Id = installmentList[0].Deposit__c, Protected_Amount__c = protectedAmount,Deposit_Amount__c = protectedAmount);
                            }else{
                                Update new Deposit__c(Id = installmentList[0].Deposit__c, Protected_Amount__c = protectedAmount);
                            }
                            
                        }else{
                            Update new Deposit__c(Id = installmentList[0].Deposit__c, Status__c = 'Deposits held by scheme');
                        }
                        
                    } 



                }

            }else if(String.isNotBlank(cartId) && cartId.startswith('BLK') && amount != null){
                
                //Find Installments
                //Check Summ of Install Amounts
                // Check with Payment Amount
                // If Matches Create Multiple Inbound Reports and Associate with Installments     Create Payments     Update Deposit Staus
                //Create Single Inbound Report With Red Matched Color
                list<Installment__c> installmentList = [Select Id,Amount__c,BLK_Number__c,Name,Deposit__r.Status__c, Deposit__r.Deposit_Account_Number__c,Deposit__c,Installment_Type__c,Status__c,Deposit__r.Protected_Amount__c,Deposit__r.Deposit_Amount__c from Installment__c
                                                                            where BLK_Number__c =: cartId 
                                                                            AND Status__c = 'Pending'
                                                                            AND Installment_Type__c = 'Receivable' ORDER BY LastModifiedDate DESC];
                if(installmentList != null && !installmentList.isEmpty()){
                    Decimal amountInstallments = 0;
                    for(Installment__c inst : installmentList){
                        if(inst.Amount__c != null){
                            amountInstallments += inst.Amount__c;
                        }
                    }

                    if(amount == amountInstallments){
                        
                        Inbound_Report__c parentReport = new Inbound_Report__c();
                		parentReport.RecordTypeId = inboundReportRecId;
                        parentReport.Reference1__c = cartId;
                        //?????
                        parentReport.Collection_Date__c = System.today();
                        if(worldpayParams.containsKey('amount'))
                        parentReport.Amount__c = Decimal.valueOf(worldpayParams.get('amount'));
                        
                        parentReport.Status__c = 'Inactive';
                        
                        parentReport.Payment_Method__c = 'Debit Card';
                        if(worldpayParams.containsKey('transId'))
                            parentReport.Transaction_Id__c = worldpayParams.get('transId');

                        insert parentReport;
                        
                        list<Inbound_Report__c> reportsToInsert = new list<Inbound_Report__c>();
                        Map<Id,Id> installmentIdVSDepositID = new map<Id,Id>();
                        list<Installment__c> installmentsToUpdate = new list<Installment__c>();
                        list<Deposit__c> depositToUpdate = new list<Deposit__c>();
                        for(Installment__c inst : installmentList){
                            
                            Inbound_Report__c report = new Inbound_Report__c();
                            report.RecordTypeId = inboundReportRecId;
                            report.Reference1__c = cartId;
                            //?????
                            report.Collection_Date__c = System.today();

                            report.Parent_Report__c = parentReport.Id;
                            
                            report.Amount__c = inst.Amount__c;
                            report.Installment__c = inst.Id;
                            installmentIdVSDepositID.put(inst.Id,inst.Deposit__c);
                            
                            report.Payment_Method__c = 'Debit Card';
                            if(worldpayParams.containsKey('transId'))
                                report.Transaction_Id__c = worldpayParams.get('transId');

                            reportsToInsert.add(report);
                            installmentsToUpdate.add(new Installment__c(Id = inst.Id, Status__c = 'Collected',Payment_Method__c='Debit Card'));
                            
                            if(inst.Deposit__r.Status__c == 'Deposits held by scheme'){
                                Decimal protectedAmount = inst.Deposit__r.Protected_Amount__c+inst.Amount__c;
                                //Decimal depositAmount = inst.Deposit__r.Deposit_Amount__c+inst.Amount__c;
                                
                                if(protectedAmount > inst.Deposit__r.Deposit_Amount__c){
                                    depositToUpdate.add(new Deposit__c(Id = inst.Deposit__c, Protected_Amount__c = protectedAmount,Deposit_Amount__c = protectedAmount));
                                }else{
                                    
                                    depositToUpdate.add(new Deposit__c(Id = inst.Deposit__c, Protected_Amount__c = protectedAmount));
                                }
                                    
                                
                                
                            }else{
                                depositToUpdate.add(new Deposit__c(Id = inst.Deposit__c, Status__c = 'Deposits held by scheme'));
                            }
                            
                                

                        }

                        if(!reportsToInsert.isEmpty()){
                            insert reportsToInsert;
                        }

                        // Create Payments Here 

                        list<Payment__c> paymentToInsert = new list<Payment__c>();

                        for(Inbound_Report__c report : reportsToInsert){
                            
                            Payment__c pay = new Payment__c();
                            pay.RecordTypeId = paymentRecId;
                            pay.Amount__c = report.Amount__c;
                            pay.Collection_Date__c = report.Collection_Date__c;
                            pay.Inbound_Report__c = report.Id;
                            pay.Installment__c = report.Installment__c;
                            pay.DAN__c = installmentIdVSDepositID.containsKey(report.Installment__c)? installmentIdVSDepositID.get(report.Installment__c) : null;
                            pay.Transaction_Id__c = report.Transaction_Id__c;
                            pay.Payment_Type__c = 'Receivable';
                            pay.Payment_Status__c = 'Paid';
                            paymentToInsert.add(pay);
                        }
                        
                        if(!paymentToInsert.isEmpty()){
                            insert paymentToInsert;
                        }

                        //update Installments
                        if(!installmentsToUpdate.isEmpty())
                            update installmentsToUpdate;    

                        //Update Deposits
                        if(!depositToUpdate.isEmpty())
                            update depositToUpdate;  


                    }else{
                        //Create Single Inbound Report Here 
                        Inbound_Report__c report = new Inbound_Report__c();
                		report.RecordTypeId = inboundReportRecId;
                        report.Reference1__c = cartId;
                        //?????
                        report.Collection_Date__c = System.today();
                        if(worldpayParams.containsKey('amount'))
                            report.Amount__c = Decimal.valueOf(worldpayParams.get('amount'));
                        
                        report.Matched_Colour__c = 'Red';
                        
                        report.Payment_Method__c = 'Debit Card';
                        if(worldpayParams.containsKey('transId'))
                            report.Transaction_Id__c = worldpayParams.get('transId');

                        insert report;
                    }
                }else{

                    //Create Single Inbound Report Here 
                    Inbound_Report__c report = new Inbound_Report__c();
                	report.RecordTypeId = inboundReportRecId;
                    report.Reference1__c = cartId;
                    //?????
                    report.Collection_Date__c = System.today();
                    if(worldpayParams.containsKey('amount'))
                        report.Amount__c = Decimal.valueOf(worldpayParams.get('amount'));
                    
                    report.Matched_Colour__c = 'Red';
                    
                    report.Payment_Method__c = 'Debit Card';
                    if(worldpayParams.containsKey('transId'))
                        report.Transaction_Id__c = worldpayParams.get('transId');

                    insert report;
                }



            }
        }

    }
    
    @HttpGet
    global static String getMethod() {
        
        
        return 'Hello From Salesforce';    
    }
}