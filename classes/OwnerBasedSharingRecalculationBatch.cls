global with sharing class OwnerBasedSharingRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private OwnerBasedSharingRecalculation sharingHandler;
   	private List<Account_Owner_Sharing__c> updatedSharings;
    private String operationType;
    
    public OwnerBasedSharingRecalculationBatch(List<Account_Owner_Sharing__c> updatedSharings, List<Account_Owner_Sharing__c> oldSharing, String operationType) {
 		this.operationType = operationType;
    	this.updatedSharings = updatedSharings;
        
        if (this.operationType != SharingConstants.ADD_OPERATION) {
        	this.sharingHandler = new OwnerBasedSharingRecalculation(oldSharing, SharingConstants.DELETE_OPERATION);    
        } else {
			this.sharingHandler = new OwnerBasedSharingRecalculation(updatedSharings, operationType);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext info) {
		Set<Id> ownerIds = this.sharingHandler.getPartnerUserIds();
		return Database.getQueryLocator([
            SELECT Id, OwnerId
            FROM Account
            WHERE OwnerId IN :ownerIds
            LIMIT 100000
        ]);
    }

    global void execute(Database.BatchableContext info, List<Account> accounts) {
		this.sharingHandler.recalculateSharings(accounts);    
    }

    global void finish(Database.BatchableContext BC){
       
            AsyncApexJob asyncJob = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus 
                FROM AsyncApexJob 
                WHERE Id = :BC.getJobId()
                LIMIT 1
            ];
            
            String labelStatus = this.operationType == SharingConstants.UPDATE_OPERATION ? 
                    SharingConstants.OWNER_BASED_SHARINGS_LABEL_BY_OPERATION.get(SharingConstants.DELETE_OPERATION) :  
                    SharingConstants.OWNER_BASED_SHARINGS_LABEL_BY_OPERATION.get(this.operationType);
            String logStatus = String.isNotBlank(asyncJob.ExtendedStatus) ? asyncJob.ExtendedStatus : labelStatus;
            String textBody = '<br/><p>' +  labelStatus + '</p>';
            
            for (Account_Owner_Sharing__c sharing : this.sharingHandler.sharings) {
                textBody += '<br/><p>' + sharing.Name + '</p>';
            }
            
            SharingLoggerHelper.logOperation(this.updatedSharings, asyncJob.Status, logStatus);
           
         if (this.operationType != SharingConstants.UPDATE_OPERATION) {
         	EmailHelper.sendFinishedJobStatus(asyncJob.Status, textBody);    
         } else  {
            Database.executeBatch(new OwnerBasedSharingRecalculationBatch(this.updatedSharings, null, SharingConstants.ADD_OPERATION) , 2000);
         }
    }
}