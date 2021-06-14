public without sharing class CustomObjectSharingHandler {

    private Set<Id> objIds;
    private List<Account> accounts;
    private String operation;

    public CustomObjectSharingHandler(Set<Id> objIds, Set<Id> accountIds, String operation) {
        this.objIds = objIds;
        this.accounts = getAccountsByIds(accountIds);
        this.operation = operation;
    }

	public void recalculateSharings() {

        List<TerritorySharingWrapper> sharings = getTerritorySharingsToProcess(this.accounts);

        if (this.operation == SharingConstants.DELETE_OPERATION) {
             removeSharings(sharings);
        }

        if (this.operation == SharingConstants.ADD_OPERATION) {
			insertSharings(sharings);
        }
    }

    public void recalculateSharings(List<TerritorySharingWrapper> sharings) {
        
        if (this.operation == SharingConstants.DELETE_OPERATION) {
            removeSharings(sharings);
        }
        
        if (this.operation == SharingConstants.ADD_OPERATION) {
            insertSharings(sharings);
        }
    }
    
    private void insertSharings(List<TerritorySharingWrapper> sharings) {
        
        Map<Id, List<SharingWrapper>> objectSharingRules = ObjectAndSharingRuleMapper.getSharingRulesForObjects(sharings, this.accounts);
        
        if (!objectSharingRules.isEmpty()) {
        
            ShareManager serviceDemosManage = getShareManagerInstance(objectSharingRules, this.objIds);
            List<sObject> shares = serviceDemosManage.getSharesToInsert();
            
            if (!shares.isEmpty()) {
                insert shares;    
            }
        }
    }

    private void removeSharings(List<TerritorySharingWrapper> sharings) {

        Map<Id, List<SharingWrapper>> objectSharingRules = ObjectAndSharingRuleMapper.getSharingRulesForObjects(sharings, this.accounts);
        
        if (!objectSharingRules.isEmpty()) {
        
            ShareManager serviceDemosManage = getShareManagerInstance(objectSharingRules, this.objIds);
            List<sObject> shares = serviceDemosManage.getSharesToDelete();
            
            if (!shares.isEmpty()) {
                delete shares;    
            }
        }
    }

    private ShareManager getShareManagerInstance(Map<Id, List<SharingWrapper>> sharings, Set<Id> recordIds) {

        Id recordId = (new List<Id>(recordIds))[0];
        String objectName = recordId.getSobjectType().getDescribe().getName();
        
        if (objectName == SharingConstants.SERVICE_DEMOS_OBJECT) {
            return new ServicesDemosShareManager(sharings, recordIds);
        } else {
            return new DeviceShareManager(sharings, recordIds);
        }
    }

    private List<Account> getAccountsByIds(Set<Id> accountIds) {

        List<String> fieldsToRetrieve = SharingSettingsHelper.getFieldsToProcessByObjectName(SharingConstants.ACCOUNT_OBJECT);
        String query = 'SELECT OwnerId, ' + String.join(fieldsToRetrieve, ',');
        query += ' FROM Account WHERE Id IN :accountIds';

        return Database.query(query);
    }
    
    private List<TerritorySharingWrapper> getTerritorySharingsToProcess(List<sObject> objects) {
        String query = getTerritorySharingsByBusinessUnitsQuery(objects);
  		List<Territory_Sharing__c> sharings = Database.query(query);
		return TerritorySharingSelector.wrapSharingRulesAndCriteria(sharings);
    }
    
    private String getTerritorySharingsByBusinessUnitsQuery(List<Account> accounts) {
        
        Set<String> businessUnits = new Set<String>();
        
        for (Account acc : accounts) {
            
            if (String.isNotBlank(acc.sf42_Business_Unit__c)) {
                businessUnits.add(acc.sf42_Business_Unit__c);
            }
        }
        return QueryBuilder.getTerritorySharingsByBusinessUnitsQuery(businessUnits); 
    }

    public String getTerritorySharingsByBusinessUnitsQuery() {
        return getTerritorySharingsByBusinessUnitsQuery(this.accounts);
    }
}