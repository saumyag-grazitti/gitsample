public with sharing class DevicesServicesDemosTriggerHandler {

    public void onAfterInsert(List<sObject> objects) {
        
        if (!objects.isEmpty()) {
            
            Set<Id> objIds = new Set<Id>();
        	Set<Id> accountsIds = new Set<Id>();
            String objectName = objects[0].getSObjectType().getDescribe().getName();
            String accountField = SharingConstants.ACCOUNT_LOOKUP_FIELD_BY_CHILD_OBJECT.get(objectName);
            
            for (sObject obj : objects) {
                
                if (obj.get(accountField) != null) {
                    objIds.add(obj.Id);
                    accountsIds.add((Id)obj.get(accountField));    
                }
            }

            if (!accountsIds.isEmpty()) {
                OwnerBasedSharingHandler.addSharings(objIds, accountsIds);
                SharingRecalculationLauncher.addSharings(objIds, accountsIds);
            }
        }
    }
    
    public void onAfterUpdate(List<sObject> updatedObjects, Map<Id, sObject> oldObjects) {
        
        if (!updatedObjects.isEmpty()) {
            
            Set<Id> objectIds = new Set<Id>();
        	Set<Id> updatedAccountIds = new Set<Id>();
        	Set<Id> oldAccountIds = new Set<Id>();

            String objectName = updatedObjects[0].getSObjectType().getDescribe().getName();
            String accountField = SharingConstants.ACCOUNT_LOOKUP_FIELD_BY_CHILD_OBJECT.get(objectName);
            
            for (sObject updatedObject : updatedObjects) {
                
                sObject oldObject = oldObjects.get(updatedObject.Id);
                Object updatedAccount = updatedObject.get(accountField);
                Object oldAccount = oldObject.get(accountField);
                
                if (updatedAccount != oldAccount || FilterHepler.isOwnerChanged(updatedObject, oldObject)) {
                    objectIds.add(updatedObject.Id);
               	 	updatedAccountIds.add((Id)updatedAccount);
                	oldAccountIds.add((Id)oldAccount);
                }
            }  
            
            if (!updatedAccountIds.isEmpty()) {
                SharingRecalculationLauncher.recalculateSharings(objectIds, updatedAccountIds, oldAccountIds);
            	OwnerBasedSharingHandler.recalculateSharings(objectIds, updatedAccountIds, oldAccountIds);
        	}
        }
    }
}