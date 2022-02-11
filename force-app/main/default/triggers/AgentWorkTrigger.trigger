/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Trigger on the Agent Work object
 *
 * @when 14/11/2019
 */
trigger AgentWorkTrigger on AgentWork (before update) {
    FC_TriggerDispatcher.run(new FC_AgentWorkTriggerHandler());
}