/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Runs case assignment rules on the set of cases
 *
 * @when 31/10/2019
 */
public with sharing class FC_CaseAssignmentHandler {
    private Case myCase;
    private static AssignmentRule caseAssignmentRule;

    private FC_CaseAssignmentHandler(Case myCase){
        this.myCase = myCase;
    }

    private Boolean runAssigmentRulesForCase(){
        AssignmentRule caseAssignmentRule = getCaseAssignmentRule();
        if(caseAssignmentRule != null){
            try {
                // create assignment rule dml options
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignmentRule.Id;
                // assign options to our case
                mycase.setOptions(dmlOpts);
                return  true;
            }
            catch(Exception e){
                FC_ErrorLogger.error(e, myCase.Id);
                System.debug('### Failed to assign Case Assignment rule to Case ID ' + myCase.Id + ': ' + e.getMessage());
            }
        }
        return false;
    }

    /**** getters & setters  ****/

    private Case getCase(){
        return this.myCase;
    }
    /**
    * Loops through segregated case list and binds case AR via caseHandler
    * @param newCases with segregated cases
    */
    public static void processCaseAssignmentRuleTrigger(List<Case> newCases){
        List<Case> casesToUpdate = new List<Case>();
        for(Case newCase : newCases){
            Case fakeClone = new Case(Id = newCase.Id);
            // loop and bind AR to case via handler
            FC_CaseAssignmentHandler handler = new FC_CaseAssignmentHandler(fakeClone);
            if(handler.runAssigmentRulesForCase()) casesToUpdate.add(handler.getCase());
        }
        // run dml to trigger AR
        if(!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate;
            }
            catch(DmlException dme) {
                FC_ErrorLogger.error(dme);
                System.debug('### Failed to update Cases on FC_CaseAssignmentHandler.processCaseAssignmentRuleTrigger():' + dme.getMessage());
            }
        }
    }

    /**
     * Get Case Assignment rules
     *
     * @return
     */
    public static AssignmentRule getCaseAssignmentRule() {
        if(caseAssignmentRule == null) {
            List<AssignmentRule> ars = [
                    SELECT Id
                    FROM AssignmentRule
                    WHERE SObjectType = 'Case'
                    AND Active = TRUE
                    LIMIT 1
            ];
            if (!ars.isEmpty()) {
                caseAssignmentRule = ars.get(0);
            }
        }
        return caseAssignmentRule;
    }
}