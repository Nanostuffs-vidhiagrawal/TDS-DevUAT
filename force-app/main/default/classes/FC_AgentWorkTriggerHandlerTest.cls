/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Tests for Agent Work Trigger handled in FC_CaseTriggerHandler
 * 1. Change Case team if the work is accepted by the user through omnichannel
 *
 * @when 14/11/2019
 */
@IsTest
private class FC_AgentWorkTriggerHandlerTest {
    public static Integer NUMBER_OF_RECORDS_TO_TEST = 200;

    @TestSetup
    static void setup() {
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(), NUMBER_OF_RECORDS_TO_TEST, 'FC_TestFactoryDefaults.CaseDefaults', true);
    }

    /**
     * this method only covers the trigger itself as you cannot insert the new AgentWork if user presence is not set
     * and you cannot update the Agent Work status in the unit tests 
     */
    @IsTest
    static void dummyTestCoverageForTrigger() {
        try {
            ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'Disputes'];

            List<AgentWork> agentWorks = new List<AgentWork>();
            for(Case c : [SELECT Id FROM Case]) {
                AgentWork agentWork = (AgentWork) FC_TestFactory.createSObject(
                        new AgentWork(ServiceChannelId = serviceChannel.Id, WorkItemId = c.Id)
                        , 'FC_TestFactoryDefaults.AgentWorkDefaults', false);
                agentWorks.add(agentWork);
            }
            insert agentWorks;

            Test.startTest();
            update agentWorks;
            Test.stopTest();
            System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId IN (SELECT Id FROM Case)]);
        }
        catch(DmlException dmle){
            //the exception will occur if the user presence is not set in Omnichannel
            System.assertEquals('The agent\'s status is not associated with the channel for this work.', dmle.getDmlMessage(0));
        }
    }

    /**
    * this method tests the actual method being called by the trigger by passing newList and oldMap 
    */
    @IsTest
    static void testAgentWorkHandler() {
        IDGenerator idGenerator = new IDGenerator();
        ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'Disputes'];

        List<AgentWork> newAgentWorks = new List<AgentWork>();
        Map<Id,AgentWork> oldAgentWorksMap = new Map<Id, AgentWork>();
        
        List<Case> casesToProcess = [SELECT Id FROM Case];
        for(Case c : casesToProcess) {
            c.Status = FC_Constant.Case_Status_Review_Complete;
        }
        update casesToProcess;
        for(Case c : casesToProcess) {
            AgentWork newAgentWork = (AgentWork)FC_TestFactory.createSObject(
                    new AgentWork(ServiceChannelId = serviceChannel.Id, WorkItemId = c.Id)
                    , 'FC_TestFactoryDefaults.AgentWorkDefaults', false);
            
            //serialize / deserialize to map to be able to set id and status for the fake AgentWork record
            Map<String,Object> newAgentWorkSObjectMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(newAgentWork));
            newAgentWorkSObjectMap.put('Status', FC_Constant.Agent_Work_Status_Opened);
            //generate fake id for AgentWork as we can't insert one
            newAgentWorkSObjectMap.put('Id', idGenerator.generate(AgentWork.SObjectType));
            String objString = JSON.serialize(newAgentWorkSObjectMap);
            newAgentWork = (AgentWork)JSON.deserialize(objString,AgentWork.class);
            newAgentWorks.add(newAgentWork);

            //add a 'copy' of an object with changed status and add it to old map
            newAgentWorkSObjectMap.put('Status', FC_Constant.Agent_Work_Status_Assigned);
            AgentWork oldAgentWork = (AgentWork)JSON.deserialize(JSON.serialize(newAgentWorkSObjectMap),AgentWork.class);
            oldAgentWorksMap.put(oldAgentWork.Id, oldAgentWork);
        }
        
        Test.startTest();
        new FC_AgentWorkHandler.BulkAgentWorkHandler().handleAgentWorkAssignment(newAgentWorks,oldAgentWorksMap);
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId IN (SELECT Id FROM Case)]);
        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Adjudication]);
    }
    
    private class IDGenerator {
        private Integer fakeIdCount = 0;
        private final String ID_PATTERN = '000000000000';

        /**
         * Generate a fake Salesforce Id for the given SObjectType
         */
        public Id generate(Schema.SObjectType sobjectType)
        {
            String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
            fakeIdCount++;
            String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
            return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
        }
    }
}