/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @when 25/11/2019
 */
trigger ErrorLogEventTrigger on Error_Log_Event__e (after insert) {
    FC_TriggerDispatcher.run(new FC_ErrorLogEventTriggerHandler());
}