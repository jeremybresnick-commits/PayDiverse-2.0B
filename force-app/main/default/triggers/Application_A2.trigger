trigger Application_A2 on Application__c (after update) {
    PD_A2_Handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
}