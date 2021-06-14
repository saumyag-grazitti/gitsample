trigger AccountOwnerSharingTrigger on Account_Owner_Sharing__c (after insert, after update, before delete) {
	
    AccountOwnerSharingTriggerHandler handler = new AccountOwnerSharingTriggerHandler();
    
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new, Trigger.old);
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        handler.onBeforeDelete(Trigger.old);
    }
}