/**
 * Created by yanagerasimchuk on 5/30/18.
 */

public with sharing class FilterHepler {

    public static List<sObject> getObjectsWithChangedCriteria(List<sObject> updatedObjects, Map<Id, sObject> oldObjects) {

        List<sObject> filteredObjects = new List<sObject>();

        if (updatedObjects != null && !updatedObjects.isEmpty()) {
            
            String objectName = updatedObjects.getSObjectType().getDescribe().getName();
            List<String> criteriaFieldsToCheck = SharingSettingsHelper.getFieldsToProcessByObjectName(objectName);
    
            for (sObject updatedObj : updatedObjects) {
    
                sObject oldObj = oldObjects.get(updatedObj.Id);
                
                if (isOwnerChanged(updatedObj, oldObj)) {
                    filteredObjects.add(updatedObj); 
                    continue;
                }
                
                for (String field: criteriaFieldsToCheck) {
    
                    Object updatedValue = updatedObj.get(field);
                    Object oldValue = oldObj.get(field);
    
                    if (updatedValue != oldValue) {
                        filteredObjects.add(updatedObj);
                        break;
                    }
                }
            }    
        }
        
        return filteredObjects;
    }

    public static List<Account> getAccountsWithChangedOwners(List<Account> updatedObjects, Map<Id, Account> oldObjects) {

        List<Account> filteredObjects = new List<Account>();

        for (Account updatedObject : updatedObjects) {
            if (isOwnerChanged(updatedObject, oldObjects.get(updatedObject.Id))) {
                filteredObjects.add(updatedObject);
            }
        }
        return filteredObjects;
    }

    public static Boolean isOwnerChanged(sObject updatedObj, sObject oldObj) {
       
        Id updatedOwner = (Id)updatedObj.get(SharingConstants.OWNER_ID_FIELD);
        Id oldOwner = (Id)oldObj.get(SharingConstants.OWNER_ID_FIELD);

        return updatedOwner != oldOwner;
    }
    
    public static Set<String> getBusinessUnits(List<TerritorySharingWrapper> sharings) {

        Set<String> businessUnits = new Set<String>();

        for (TerritorySharingWrapper wrapper : sharings) {
            businessUnits.add(wrapper.sharing.Business_Unit__c);
        }

        return businessUnits;
    }

    public static Set<String> getBusinessUnits(List<sObject> objects) {

        Set<String> businessUnits = new Set<String>();
        String objectName = objects[0].getSObjectType().getDescribe().getName();
        String businessUnitField = SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(objectName);

        for (sObject obj : objects) {

            Object fieldValue = obj.get(businessUnitField);

            if (fieldValue != null) {
                businessUnits.add((String)fieldValue);
            }
        }

        return businessUnits;
    }
}