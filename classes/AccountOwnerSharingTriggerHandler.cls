public with sharing class AccountOwnerSharingTriggerHandler {

    public void onAfterInsert(List<Account_Owner_Sharing__c> sharings) {
		Database.executeBatch(new OwnerBasedSharingRecalculationBatch(sharings, null, SharingConstants.ADD_OPERATION) , 1000);
	}
  
    public void onAfterUpdate(List<Account_Owner_Sharing__c> updatedSharings, List<Account_Owner_Sharing__c> oldSharings) {
		Database.executeBatch(new OwnerBasedSharingRecalculationBatch(updatedSharings, oldSharings, SharingConstants.UPDATE_OPERATION) , 1000);
    }
    
    public void onBeforeDelete(List<Account_Owner_Sharing__c> sharings) {
    	Database.executeBatch(new OwnerBasedSharingRecalculationBatch(null, sharings, SharingConstants.DELETE_OPERATION) , 1000);
    }
}