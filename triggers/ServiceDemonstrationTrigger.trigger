trigger ServiceDemonstrationTrigger on Service_and_Demontration__c (after insert, after update) {

    DevicesServicesDemosTriggerHandler handler = new DevicesServicesDemosTriggerHandler();
    
    if (Trigger.isAfter && Trigger.isInsert) {
    	handler.onAfterInsert(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
    	handler.onAfterUpdate(Trigger.new, Trigger.oldmap);    
    }
}