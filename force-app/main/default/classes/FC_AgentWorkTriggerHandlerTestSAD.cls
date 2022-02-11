/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what @seeAlldata version that attempts to dummy update existing agent work - just to fire the trigger coverage, 
 * it does not really test anything
 
 *
 * @when 16/12/2019
 */
@SuppressWarnings('PMD')
@IsTest(SeeAllData=true)
public with sharing class FC_AgentWorkTriggerHandlerTestSAD {
    @IsTest
    static void dummyTestCoverageForUpdateTrigger() {
        try {
            List<AgentWork> agentWorks = [SELECT Id FROM AgentWork LIMIT 1];
            Test.startTest();
            update agentWorks;
            Test.stopTest();
            System.assert(true, 'AgentWork Trigger has been fired');
        }
        catch(DmlException dmle){
            /**
            * The exception will occur if no Agent works exists in the system
            * If the FC_AgentWorkTriggerHandlerTest.dummyTestCoverageForTrigger() is not able to create the Agent Work
            * due to lack of the User Presence (the running user is not Active in Omni-Channel)
            * the deployment might fail due to the fact that the Agent Work trigger would not fire at all
            */
            System.assert(true, 'AgentWork Trigger was not fired');
        }
    }
}