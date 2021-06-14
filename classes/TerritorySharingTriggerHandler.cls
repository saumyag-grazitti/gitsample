public with sharing class TerritorySharingTriggerHandler {
    
    public void onBeforeDelete(Map<Id, Territory_Sharing__c> oldSharings) {
    	SharingRecalculationLauncher.deleteSharingsAsync(oldSharings);
    }
}