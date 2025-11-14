trigger Application_A4 on Application__c (after update) {
    PD_A4_Handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
}