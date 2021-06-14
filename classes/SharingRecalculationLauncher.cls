/**
 * Created by yanagerasimchuk on 5/28/18.
 */

public with sharing class SharingRecalculationLauncher {

    public static void addSharingsAsync(Id sharingId) {
        
        TerritorySharingWrapper sharing = TerritorySharingSelector.getSharingById(sharingId);
        List<TerritorySharingWrapper> sharingsToInsert = new List<TerritorySharingWrapper>{sharing};
        
        Database.executeBatch(new TerritorySharingRecalculationBatch(sharingsToInsert, null, 
                                                                     SharingConstants.ADD_OPERATION, SharingConstants.ACCOUNT_CRITERIA), 1000);
        
        if (sharing.sharing.Lead_Access_Level__c != SharingConstants.DEFAULT_LEVEL_ACCESS) {
        	Database.executeBatch(new TerritorySharingRecalculationBatch(sharingsToInsert, null, 
                                                                         SharingConstants.ADD_OPERATION, SharingConstants.LEAD_CRITERIA), 1000);    
        }
    }

    public static void addSharings(List<sObject> objects) {

        if (objects.size() > 10) {
            Database.executeBatch(new ObjectSharingRecalculationBatch(objects, null, SharingConstants.ADD_OPERATION), 1000);
        } else {
            ObjectSharingHandler sharingHandler = new ObjectSharingHandler(objects, SharingConstants.ADD_OPERATION);
            sharingHandler.recalculateSharings();
        }
    }

    public static void addSharings(Set<Id> objIds, Set<Id> accountsIds) {
        if (accountsIds.size() > 10) {
            Database.executeBatch(new CustomObjectSharingRecalculationBatch(objIds, accountsIds, null, SharingConstants.ADD_OPERATION), 1000);

        } else {
            CustomObjectSharingHandler sharingHandler = new CustomObjectSharingHandler(objIds, accountsIds, SharingConstants.ADD_OPERATION);
            sharingHandler.recalculateSharings();
        }
    }

    public static void recalculateSharingsAsync(TerritorySharingWrapper updatedSharing, TerritorySharingWrapper oldSharing) {

        Set<Id> sharingIds = new Set<Id>();
        sharingIds.add(updatedSharing.sharing.Id);

        List<TerritorySharingWrapper> updatedSharings = new List<TerritorySharingWrapper>();
        updatedSharings.add(updatedSharing);

        List<TerritorySharingWrapper> oldSharings = new List<TerritorySharingWrapper>();
        oldSharings.add(oldSharing);

        Database.executeBatch(new TerritorySharingRecalculationBatch(updatedSharings, oldSharings, SharingConstants.UPDATE_OPERATION, SharingConstants.ACCOUNT_CRITERIA), 1000);

        Database.executeBatch(new TerritorySharingRecalculationBatch(updatedSharings, oldSharings, SharingConstants.UPDATE_OPERATION, SharingConstants.LEAD_CRITERIA), 1000);
    }

    public static void recalculateSharings(List<sObject> updatedObjects, List<sObject> oldObjects) {

        if (updatedObjects.size() > 10) {
            Database.executeBatch(new ObjectSharingRecalculationBatch(updatedObjects, oldObjects, SharingConstants.UPDATE_OPERATION), 1000);
        } else {
            ObjectSharingHandler removeSharingsHandler = new ObjectSharingHandler(oldObjects, SharingConstants.DELETE_OPERATION);
            removeSharingsHandler.recalculateSharings();

            ObjectSharingHandler addSharingsHandler = new ObjectSharingHandler(updatedObjects, SharingConstants.ADD_OPERATION);
            addSharingsHandler.recalculateSharings();
        }
    }

    public static void recalculateSharings(Set<Id> objIds, Set<Id> updatedAccountIds, Set<Id> oldAccountIds) {

        if (updatedAccountIds.size() > 10) {
            Database.executeBatch(new CustomObjectSharingRecalculationBatch(objIds, updatedAccountIds, oldAccountIds, SharingConstants.UPDATE_OPERATION), 1000);
        } else {
            CustomObjectSharingHandler deleteSaringHandler = new CustomObjectSharingHandler(objIds, oldAccountIds, SharingConstants.DELETE_OPERATION);
            deleteSaringHandler.recalculateSharings();

            CustomObjectSharingHandler addSaringHandler = new CustomObjectSharingHandler(objIds, updatedAccountIds, SharingConstants.ADD_OPERATION);
            addSaringHandler.recalculateSharings();
        }
    }

    public static void deleteSharingsAsync(Map<Id, Territory_Sharing__c> oldSharings) {

        List<TerritorySharingWrapper> oldSharingWrappers = TerritorySharingSelector.getTerritorySharingsWithCriteria(oldSharings);

        Database.executeBatch(new TerritorySharingRecalculationBatch(null, oldSharingWrappers,
                SharingConstants.DELETE_OPERATION, SharingConstants.ACCOUNT_CRITERIA), 1000);
        Database.executeBatch(new TerritorySharingRecalculationBatch(null, oldSharingWrappers,
                SharingConstants.DELETE_OPERATION, SharingConstants.LEAD_CRITERIA), 1000);
    }
}