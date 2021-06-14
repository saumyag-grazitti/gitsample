trigger TerritorySharingTrigger on Territory_Sharing__c (before delete) {

    TerritorySharingTriggerHandler handler = new TerritorySharingTriggerHandler();
    
    if (Trigger.isBefore && Trigger.isDelete) {
    	handler.onBeforeDelete(Trigger.oldMap);    
    }
}