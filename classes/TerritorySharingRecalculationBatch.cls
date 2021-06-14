global with sharing class TerritorySharingRecalculationBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private TerritorySharingRecalculation recalculationManager;
    private List<TerritorySharingWrapper> updatedSharings;
    private String operationType;
    private String criteriaToProcess;
    
    public TerritorySharingRecalculationBatch(List<TerritorySharingWrapper> updatedSharings, List<TerritorySharingWrapper> oldSharings, 
                                              String operationType, String criteriaToProcess) {
        this.operationType = operationType;
    	this.updatedSharings = updatedSharings;
        this.criteriaToProcess = criteriaToProcess;
                                                  
		if (operationType != SharingConstants.ADD_OPERATION) {
        	this.recalculationManager = new TerritorySharingRecalculation(oldSharings, criteriaToProcess, SharingConstants.DELETE_OPERATION);                                              
        } else {
            this.recalculationManager = new TerritorySharingRecalculation(updatedSharings, criteriaToProcess, operationType);             
        }
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        String query = this.recalculationManager.getObjectsQuery();
        System.debug(query);
        return Database.getQueryLocator(query);
    }     
 
    global void execute(Database.BatchableContext info, List<sObject> objects) {
		this.recalculationManager.recalculateSharings(objects);
    }     

    global void finish(Database.BatchableContext BC) {
        
        
             AsyncApexJob asyncJob = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus 
                FROM AsyncApexJob 
                WHERE Id = :BC.getJobId()
                LIMIT 1
            ];
            
            Map<String, String> labelStatuses = SharingConstants.CRITERIA_TO_OPERATION_TO_LABEL.get(this.criteriaToProcess);
            String labelStatus = this.operationType == SharingConstants.UPDATE_OPERATION ? 
                labelStatuses.get(SharingConstants.DELETE_OPERATION) : 
        		labelStatuses.get(this.operationType);  
            String logStatus = String.isNotBlank(asyncJob.ExtendedStatus) ? asyncJob.ExtendedStatus : labelStatus;
            String textBody = '<br/><p>' +  labelStatus + '</p>';
            
            for (TerritorySharingWrapper wrapper : this.recalculationManager.territorySharings) {
                textBody += '<br/><p>' +  wrapper.sharing.Name + '</p>';
            }
            
            SharingLoggerHelper.logOperation(this.updatedSharings, asyncJob.Status, logStatus);
            
        if (this.operationType != SharingConstants.UPDATE_OPERATION) {
       		EmailHelper.sendFinishedJobStatus(asyncJob.Status, textBody);     
        } else {
            Database.executeBatch(new TerritorySharingRecalculationBatch(this.updatedSharings, null, 
                                                                     SharingConstants.ADD_OPERATION,this.criteriaToProcess), 1000);
        }
    }
}