/**
 * Created by yanagerasimchuk on 5/30/18.
 */

global with sharing class ObjectSharingRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private ObjectSharingHandler sharingHandler;
    private List<sObject> updatedObjects;
	private String operation;
    
    public ObjectSharingRecalculationBatch(List<sObject> updatedObjects, List<sObject> oldObjects, String operation) {
        this.operation = operation;
        this.updatedObjects = updatedObjects;
        
        if (this.operation != SharingConstants.ADD_OPERATION) {
            this.sharingHandler = new ObjectSharingHandler(oldObjects, SharingConstants.DELETE_OPERATION);
        } else {
            this.sharingHandler = new ObjectSharingHandler(updatedObjects, this.operation);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        String query = this.sharingHandler.getTerritorySharingsByBusinessUnitsQuery();
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<Territory_Sharing__c> sharings) {
		List<TerritorySharingWrapper> sharingWrappers = TerritorySharingSelector.wrapSharingRulesAndCriteria(sharings);
        this.sharingHandler.recalculateSharings(sharingWrappers);
    }

    global void finish(Database.BatchableContext BC){
        if (this.operation != SharingConstants.UPDATE_OPERATION) {
        	EmailHelper.sendFinishedJobStatus(BC.getJobId());
        } else {
		 	Database.executeBatch(new ObjectSharingRecalculationBatch(this.updatedObjects, null, SharingConstants.ADD_OPERATION), 200);   
       	}
    }
}