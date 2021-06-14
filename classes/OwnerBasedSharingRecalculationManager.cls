/**
 * Created by yanagerasimchuk on 6/14/18.
 */

public without sharing class OwnerBasedSharingRecalculationManager {

    public static void removeServiceDemosSharings(Map<Id, SharingWrapper> sharings, Set<Id> objectIds) {

         if (!sharings.isEmpty()) {
             
            ShareManager serviceManager = new ServicesDemosShareManager(sharings, objectIds);
			List<sObject> shares = serviceManager.getSharesToDelete();
             
            if (!shares.isEmpty()) {
                delete shares;
            }
         }
	}
    
    public static void removeDeviceSharings(Map<Id, SharingWrapper> sharings, Set<Id> objectIds) {

         if (!sharings.isEmpty()) {
             
            ShareManager deviceManager = new DeviceShareManager(sharings, objectIds);
			List<sObject> shares = deviceManager.getSharesToDelete();
             
            if (!shares.isEmpty()) {
                delete shares;
            }
         }
	}
    
	public static void addDeviceSharings(Map<Id, SharingWrapper> sharings, Set<Id> objectIds) {

         if (!sharings.isEmpty()) {
             
            ShareManager deviceManager = new DeviceShareManager(sharings, objectIds);
			List<sObject> shares = deviceManager.getSharesToInsert();

            if (!shares.isEmpty()) {
                insert shares;
            }
         }
	}
    
    public static void addServiceDemosSharings(Map<Id, SharingWrapper> sharings, Set<Id> objectIds) {

         if (!sharings.isEmpty()) {
             
            ShareManager serviceManager = new ServicesDemosShareManager(sharings, objectIds);
			List<sObject> sharingsToInsert = serviceManager.getSharesToInsert();

            if (!sharingsToInsert.isEmpty()) {
                insert sharingsToInsert;
            }
         }
	}
    
	public static void addSharings(Map<Id, SharingWrapper> sharings) {

        if (!sharings.isEmpty()) {

            ShareManager deviceManage = new DeviceShareManager(sharings);
            List<sObject> deviceShares = deviceManage.getSharesToInsert();
            
            ShareManager servicesDemosManage = new ServicesDemosShareManager(sharings);
            List<sObject> serviceDemosShares = servicesDemosManage.getSharesToInsert();

            if (!deviceShares.isEmpty()) {
          		insert deviceShares;
            }

            if (!serviceDemosShares.isEmpty()) {
               insert serviceDemosShares;
            }
        }
    }

    public static void removeSharings(Map<Id, SharingWrapper> sharings) {

        if (!sharings.isEmpty()) {

            ShareManager deviceManage = new DeviceShareManager(sharings);
            List<sObject> deviceShares = deviceManage.getSharesToDelete();
            
            ShareManager servicesDemosManage = new ServicesDemosShareManager(sharings);
            List<sObject> serviceDemosShares = servicesDemosManage.getSharesToDelete();

            if (!deviceShares.isEmpty()) {
                delete deviceShares;
            }

            if (!serviceDemosShares.isEmpty()) {
                delete serviceDemosShares;
            }
        }
    }
}