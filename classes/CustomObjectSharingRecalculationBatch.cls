/**
 * Created by yanagerasimchuk on 5/30/18.
 */

global with sharing class CustomObjectSharingRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private CustomObjectSharingHandler sharingHandler;
    private Set<Id> objIds;
    private Set<Id> updatedAccountIds;
    private String operation;

    public CustomObjectSharingRecalculationBatch(Set<Id> objIds, Set<Id> updatedAccountIds, Set<Id> oldAccountIds, String operation) {
        this.objIds = objIds;
        this.updatedAccountIds = updatedAccountIds;
        this.operation = operation;

        if (this.operation != SharingConstants.ADD_OPERATION) {
            this.sharingHandler = new CustomObjectSharingHandler(objIds, oldAccountIds, SharingConstants.DELETE_OPERATION);
        } else {
            this.sharingHandler = new CustomObjectSharingHandler(objIds, updatedAccountIds, this.operation);
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
        if (this.operation  != SharingConstants.UPDATE_OPERATION) {
            EmailHelper.sendFinishedJobStatus(BC.getJobId());
        } else {
            Database.executeBatch(new CustomObjectSharingRecalculationBatch(this.objIds, this.updatedAccountIds, null, SharingConstants.ADD_OPERATION), 200);
        }
    }
}