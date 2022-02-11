/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Handles the Case team changes on Owner change. Assigns Case Team role based on custom metadata Case_Statuses_Per_Role	
 *
 * @when 05/11/2019
 */
public with sharing class FC_CaseTeamHandler {
    /**
    * Deletes existing team member if role matches the current status, assigns new team member instead
    * @param newCases List of cases to be affected
    */
    public static void setCaseTeamForCase(List<Case> newCases){
        Map<Id,Case> casesWithMembersMap = new Map<Id,Case>
                ([SELECT Id, OwnerId, (SELECT Id, MemberId, TeamRole.Name FROM TeamMembers) FROM Case WHERE Id IN :newCases]);
        
        List<CaseTeamMember> membersToDelete = new List<CaseTeamMember>();
        List<CaseTeamMember> membersToUpdate = new List<CaseTeamMember>();
        List<CaseTeamMember> membersToInsert = new List<CaseTeamMember>();
        
        for(Case newCase : newCases) {
            if(!caseStatusToTeamRoleMap.containsKey(newCase.Status)) {
                continue;
            }
            
            //do not attempt to create case team if creator is API User (Site guest user) 
            if(UserInfo.getLastName() == 'Site Guest User') {
                continue;
            }
            
            String currentTeamRoleName = caseStatusToTeamRoleMap.get(newCase.Status); 
            String currentTeamRoleId = teamRoleIdByName.get(currentTeamRoleName); 
            
            Case caseWithMembers = casesWithMembersMap.get(newCase.Id);
            
            if(caseWithMembers != null && caseWithMembers.TeamMembers != null && !caseWithMembers.TeamMembers.isEmpty()) {
                Boolean hasCurrentTeamRole = false;
                for(CaseTeamMember caseTeamMember : caseWithMembers.TeamMembers) {

                    if(caseTeamMember.TeamRole.Name == FC_Constant.CaseTeamRole_DRE
                            && (newCase.Status == FC_Constant.Case_Status_Adjudication || newCase.Status == FC_Constant.Case_Status_Closed)
                            && newCase.OwnerId == caseTeamMember.MemberId) {
                        caseTeamMember.TeamRoleId = teamRoleIdByName.get(FC_Constant.CaseTeamRole_DreAdjudication);
                        membersToUpdate.add(caseTeamMember);
                    }
                    else if (caseTeamMember.TeamRole.Name == currentTeamRoleName){
                        membersToDelete.add(caseTeamMember);
                        if(!hasCurrentTeamRole) {
                            membersToInsert.add(
                                    new CaseTeamMember(MemberId = newCase.OwnerId, TeamRoleId = currentTeamRoleId, ParentId = newCase.Id));
                        }
                        hasCurrentTeamRole = true;
                    }
                    else if (!hasCurrentTeamRole){
                        membersToInsert.add(
                                new CaseTeamMember(MemberId = newCase.OwnerId, TeamRoleId = currentTeamRoleId, ParentId = newCase.Id));
                        hasCurrentTeamRole = true;
                    }
                }                
            }
            else {
                membersToInsert.add(
                        new CaseTeamMember(MemberId = newCase.OwnerId, TeamRoleId = currentTeamRoleId, ParentId = newCase.Id));
            }
        }
        
        try {
            delete membersToDelete;
            update membersToUpdate;
            insert membersToInsert;
        }
        catch(DmlException dmle) {
            FC_ErrorLogger.error(dmle, newCases[0].Id);
            System.debug('### Failed to update members on setCaseTeamForCase():' + dmle.getMessage());
        }
    }

    private static Map<String,String> teamRoleIdByName {
        get {
            if(teamRoleIdByName == null) {
                teamRoleIdByName = new Map<String,String>();

                List<CaseTeamRole> caseTeamRoles = [SELECT Id, Name FROM CaseTeamRole];

                for(CaseTeamRole caseTeamRole : caseTeamRoles) {
                    teamRoleIdByName.put(caseTeamRole.Name, caseTeamRole.Id);
                }
            }
            return teamRoleIdByName;
        }
        set;
    }    
    
    private static Map<String,String> caseStatusToTeamRoleMap {
        get {
            if(caseStatusToTeamRoleMap == null) {
                caseStatusToTeamRoleMap = new Map<String,String>();

                Boolean isTest = Test.isRunningTest();
                Case_Statuses_Per_Role__mdt[] caseStatusToTeamRoleMetadata = [
                        SELECT Label, Role_Name__c
                        FROM Case_Statuses_Per_Role__mdt
                        WHERE IsTest__c = :isTest
                ];

                for(Case_Statuses_Per_Role__mdt statusToRole : caseStatusToTeamRoleMetadata) {
                    caseStatusToTeamRoleMap.put(statusToRole.Label, statusToRole.Role_Name__c);
                }
            }
            return caseStatusToTeamRoleMap;
        }
        set;
    }
}