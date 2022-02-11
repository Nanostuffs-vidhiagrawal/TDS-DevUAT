/*
@TestClassName  :    EI_updateDepositFields_TestClass
@date  :    21/12/2020

*/
trigger Updatedepositfields on Case (after insert, after update, before update) {
    // putting a check in trigger 24 June 2021 by Tajinder
    QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits'); 
    if(querylimit.CheckOn__c) {
        
        Map<ID, Deposit__c> parentOpps = new Map<ID, Deposit__c>();
        List<Id> listIds = new List<Id>();
        List<case> caselist = new List<case>();
        //NPP-29 AC13 and NPP-27 AC7 (Deposit to be repaid - court case)
        List<Case> lstOfCourtCases = new List<Case>(); 
        List<Case> lstOfEvidGathCases = new List<Case>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        if(trigger.isAfter  && (trigger.isUpdate ||trigger.isInsert) ) {
            for (case childObj : Trigger.new ) {
                if(childObj.RecordtypeId==devRecordTypeId && childObj.Deposit_Account_Number__c !=null ){
                    listIds.add(childObj.Deposit_Account_Number__c);
                }
            }
            if(listIds.size()>0) {
                parentOpps = new Map<Id, Deposit__c>([SELECT id,ChangeOver_CaseStatus__c ,Amount_Paid_to_Tenant__c,Amount_Paid_to_Landlord__c,(SELECT ID,ChangeOver_Status__c,status,Deposit_Account_Number__c,Amount_Paid_to_Tenant__c,Amount_Paid_to_Landlord__c FROM Cases__r  limit 1) FROM Deposit__c WHERE ID IN :listIds]);
                for (case nls: Trigger.new){
                    Deposit__c myParentOpp = parentOpps.get(nls.Deposit_Account_Number__c);
                    myParentOpp.Amount_Paid_to_Tenant__c = nls.Amount_Paid_to_Tenant__c;
                    myParentOpp.Amount_Paid_to_Landlord__c = nls.Amount_Paid_to_Landlord__c;
                    myParentOpp.Case_Status__c = nls.status;
                    myParentOpp.ChangeOver_CaseStatus__c = nls.ChangeOver_Status__c;
                    myParentOpp.caseId__c = nls.Id;
                    if((nls.RecordtypeId==devRecordTypeId) && (nls.Status=='Repayment disputed - self-resolution')  && (Trigger.oldMap.get(nls.Id).Status !=nls.Status ) && (Trigger.oldMap.get(nls.Id).Status !='On Hold' ) ) {
                        caselist.add(nls);  
                    }
                    
                     if(nls.Status == 'Deposit to be repaid - court case' &&
                       trigger.oldMAp.get(nls.Id).Status != nls.Status && trigger.newMap.get(nls.Id).RecordTypeId == devRecordTypeId ) {
                           lstOfCourtCases.add(nls);
                       }
                    if(nls.Status == 'Evidence review complete' && trigger.oldMAp.get(nls.Id).Status != nls.Status && 
                       (trigger.oldMAp.get(nls.Id).Status == 'Evidence gathering AA/LL' 
                        || trigger.oldMAp.get(nls.Id).Status == 'Evidence Gathering TT') 
                       && trigger.newMap.get(nls.Id).RecordTypeId == devRecordTypeId ) {
                           lstOfEvidGathCases.add(nls);
                       }
                    
                }
                update parentOpps.values();
                if(!caselist.isEmpty()){
                    EI_UpdateRepaymentRequestToCase.updatecaseandrelateditems(caselist);   
                }
                
                 if(!lstOfCourtCases.isEmpty())
                {
                    EI_SdsColleagueChangesCaseStatus.depositToBeRepaidCourtCase(lstOfCourtCases);
                }
                if(!lstOfEvidGathCases.isEmpty())
                {
                    EI_SdsColleagueChangesCaseStatus.evidenceReviewComplete(lstOfEvidGathCases);
                }
            }            
            
            if(trigger.isUpdate) {
                //NPP-41
              //  EI_EvidenceGatheringMails.createPaymentAndInstalmentsRecord(trigger.new, trigger.oldMap,trigger.newMap);
                
                //NPP-41
                EI_SdsColleagueChangesCaseStatus.handleCaseAssignmentRuleforselfresolution(trigger.newmap, trigger.oldmap);
                
                // NPP-4 and NPP-5
                Set<Id> casIdsForLL = new Set<Id>();
                Set<Id> casIdsForTT = new Set<Id>();
                Set<Id> casIdsSet = new Set<Id>();
                // NPP-37
                Set<Id> caseIdsForRDSF = new Set<Id>(); // Repayment disputed - self-resolution
                for(Case casinst : trigger.new) {
                    if(casinst.RecordtypeId==devRecordTypeId) {
                        if(casinst.Status == 'Evidence gathering AA/LL' &&
                           trigger.oldMAp.get(casinst.Id).Status == 'Repayment disputed - self-resolution') 
                        {
                            // Gather evidence from landlord/agent
                            casIdsForLL.add(casinst.Id);
                        }
                        if(casinst.Status == 'Evidence Gathering TT' &&
                           (trigger.oldMAp.get(casinst.Id).Status != 'Evidence Gathering TT' || trigger.oldMAp.get(casinst.Id).Status != 'On Hold')) 
                        {
                            // Gather evidence from tenant
                            casIdsForTT.add(casinst.Id);
                        }
                        if(casinst.Status == 'Repayment disputed - self-resolution' &&
                           (trigger.oldMAp.get(casinst.Id).Status != 'Repayment disputed - self-resolution' && trigger.oldMAp.get(casinst.Id).Status != 'On Hold')) 
                        {
                            caseIdsForRDSF.add(casinst.Id);
                        }
                        //NPP-41 AC6.5 
                        if(trigger.oldMAp.get(casinst.Id).Status != casinst.Status && trigger.oldMAp.get(casinst.Id).Status !='Repayment requested - tenant' 
                           && casinst.Status == 'Deposit to be repaid - repayment agreed') 
                        {
                            //call method to send email
                            casIdsSet.add(casinst.Id);
                        }
                    }
                }
                //if(!casIdsForLL.isEmpty()) EI_EvidenceGatheringMails.notifyLandlordandTenant(casIdsForLL,'LandlordEvdStage');
                //if(!casIdsForTT.isEmpty()) EI_EvidenceGatheringMails.notifyLandlordandTenant(casIdsForTT,'TenantEvdStage');
                if(!caseIdsForRDSF.isEmpty()) EI_EvidenceGatheringMails.inviteAATTfornegotiate(caseIdsForRDSF);
                //if(!casIdsSet.isEmpty() && !EI_selfresolutionsummaryviewtenant.AgreedByCasePar) EI_EvidenceGatheringMails.notifyLandlordandTenant(casIdsSet,'TenantEvdStage');
                
                
            }
            
            // To track the Case Status History on Insert
            /* if(trigger.isInsert) {
                EI_CaseStatusHistory.caseStatusHistoryOnInsert(trigger.new, trigger.newMap); 
            } */
            
        }
        
        /* SDS - conditions for before trigger in case update scenarios START */
        if(Trigger.isBefore && Trigger.isUpdate) {
            
            //NPP-4 & 5
            EI_EvidenceGatheringMails.notifyLandlordandTenant(trigger.new, trigger.newMap, trigger.oldMap);
            
            //NPP-41
            EI_EvidenceGatheringMails.createPaymentAndInstalmentsRecord(trigger.new, trigger.oldMap,trigger.newMap);
            
            //NPP-29
            EI_SdsColleagueChangesCaseStatus.resolvedWithoutAdjudication(trigger.new, trigger.oldMap,trigger.newMap);
            
            //NPP-265
            EI_SdsColleagueChangesCaseStatus.paymentkpiforfinance(trigger.new, trigger.oldMap);
            
            // NPP-13
            EI_Adjudicationreviewdecisionbyparty.beforeupdatecaseandrelateditems(trigger.new);
            
            //NPP-8
            EI_Adjudicationreviewdecisionbyparty.beforeupdatecaseholdandrelateditems(trigger.new, trigger.oldMap);
            
            //NPP-14
            EI_Adjudicationreviewdecisionbyparty.createPaymentAndInstalmentsRecordNew(trigger.new, trigger.oldMap, trigger.newMap);
            
            // NPP-15
            EI_SdsColleagueChangesCaseStatus.adjReviewReqAcceptance(trigger.new, trigger.oldMap);
                
            // NPP-15   
            EI_SdsColleagueChangesCaseStatus.adjDecisionIssued(trigger.new, trigger.oldMap);
            
            // NPP-540 -> AC-4, AC-11
            EI_SdsColleagueChangesCaseStatus.caseMovesBackToEvidenceStages(trigger.new, trigger.newMap, trigger.oldMap);
            
            // NPP-540 -> AC-7, AC-14
            EI_SdsColleagueChangesCaseStatus.caseEntersDepositToBeRepaidNoEvidence(trigger.new, trigger.newMap, trigger.oldMap);
            
            // To track the Case Status History
            //EI_CaseStatusHistory.caseStatusHistoryOnUpdate(trigger.new, trigger.newMap, trigger.oldMap); 
          
           //For update respond date as per onhold functionality 
           EI_Sds_OnholdStatus.updateResponddate(trigger.newmap, trigger.oldmap);
          
            
        }  
        /* SDS - conditions for before trigger in case update scenarios END */
        
        
        /*
* 
* 
* Espire ZD -March 18,2021
* 
*/
        
        if(trigger.isafter && Trigger.isUpdate)
        {
                        
            
            // if(!system.isBatch())
            //{
            
            /*  ====== Send Email to invite perties  =====  */
            
            
            if(!EI_ZDCaseTriggerHandler.IsMailExecuted && !system.isBatch()){
                EI_ZDCaseTriggerHandler.sendmailToInviteAGLLTT(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.sendmailToSelfResolution(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.sendmailToInviteEvidenceAGLL(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.sendmailToInviteEvidenceTT(trigger.newmap, trigger.oldmap);
               // EI_ZDCaseTriggerHandler.handleCloseCaseEmail(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.makePayment(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.handleStatusCaseMail(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.IsMailExecuted = true;
            }
            /*
* 
* fire Assignment Rule  June16,2021
* 
*/
                EI_ZDCaseTriggerHandler.handleCaseAssignmentRuleTrigger(trigger.newmap, trigger.oldmap);
                EI_ZDCaseTriggerHandler.handleCasePartiAssignmentRuleTrigger(trigger.newmap, trigger.oldmap);
            
            
            
        }
        //}
        
        // To track the Case Status History on Insert
        if(trigger.isafter && Trigger.isInsert)
        {
            EI_CaseStatusHistory.caseStatusHistoryOnInsert(trigger.new, trigger.newMap); 
        }
        
        if(!EI_ZDCaseTriggerHandler.isExecuted && trigger.isBefore && Trigger.isUpdate)
        {
            EI_ZDCaseTriggerHandler.updateResponddate(trigger.newmap, trigger.oldmap);
            
            // To track the Case Status History
            EI_CaseStatusHistory.caseStatusHistoryOnUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
        /*
* 
* 
* Espire ZD 
* 
*/        
        
    }
    
}