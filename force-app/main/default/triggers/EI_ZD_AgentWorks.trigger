trigger EI_ZD_AgentWorks on AgentWork (before update) {
        EI_ZDAgentWorkTriggerHandler.beforeUpdate(trigger.newmap, trigger.oldmap); 
}