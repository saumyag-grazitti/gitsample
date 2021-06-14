public without sharing class ptt_DeviceManager {

	/****************************************/
    /*** Class specific helper functions ****/
    /****************************************/
	
    
    /* Change Owner of child device when owner of parent is changed */
	public static void changeOwnerOfSubdevice(Map<Id,sf42_Devices__c> newDevices, Map<Id,sf42_Devices__c> oldDevices) {
         
		List<sf42_Devices__c> recordsToUpdate = new List<sf42_Devices__c>();
        Set<Id> deviceIdsWithChangedOwner = getDeviceIdsWithChangedOwner(newDevices, oldDevices);
        Map<Id, List<sf42_Devices__c>> childRecordsForParentId = getChildDevices(deviceIdsWithChangedOwner);
        
		for (Id parentDeviceId : childRecordsForParentId.keySet()) {
        
            sf42_Devices__c parentDevice = newDevices.get(parentDeviceId);
            List<sf42_Devices__c> allChildRecords = childRecordsForParentId.get(parentDeviceId);
                
            for (sf42_Devices__c oneChild : allChildRecords) {
	        	oneChild.OwnerID = parentDevice.OwnerID;
	       	}
               
            recordsToUpdate.addAll(allChildRecords);
		}
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        } 
	}
    
    private static Set<Id> getDeviceIdsWithChangedOwner(Map<Id,sf42_Devices__c> newDevices, Map<Id,sf42_Devices__c> oldDevices) {
        
        Set<Id> deviceIdsWithChangedOwner = new Set<Id>();
        
        for (sf42_Devices__c newDev : newDevices.values()) {
            
            sf42_Devices__c oldDev = oldDevices.get(newDev.ID);
            
            if (oldDev.OwnerId != newDev.OwnerId) {
            	deviceIdsWithChangedOwner.add(newDev.Id);     	
            }
		}
        
        return deviceIdsWithChangedOwner;
    }
    
    private static Map<Id, List<sf42_Devices__c>> getChildDevices(Set<Id> deviceIds) {
        
         Map<Id, List<sf42_Devices__c>> childRecordsForParentId = new Map<Id, List<sf42_Devices__c>>();
        
        for (sf42_Devices__c device : [
            SELECT ID, OwnerId, Parent_Device__c 
            FROM sf42_Devices__c 
            WHERE Parent_Device__c IN :deviceIds
            LIMIT 50000
        ]) {
            
            List<sf42_Devices__c> childRecords = childRecordsForParentId.get(device.Parent_Device__c);
            
            if (childRecords == null) {
				childRecords = new List<sf42_Devices__c>();
            }
            
            childRecords.add(device);
            childRecordsForParentId.put(device.Parent_Device__c, childRecords);
        }
        
        return childRecordsForParentId;
    }
    
    /* Update filed User [sf42_de_User__c] when device has Parent Device [Parent_Device__c] with value from parent. */
	public static void setUserFieldOnChild(List<sf42_Devices__c> newDevices) {
        
        Map<Id, sf42_Devices__c> parentDevices = getParentDevices(newDevices);
        
        for (sf42_Devices__c newDevice : newDevices) {
         
			sf42_Devices__c parentDevice = parentDevices.get(newDevice.Parent_Device__c);
                
            if (parentDevice != null) {
            	newDevice.sf42_de_User__c = parentDevice.sf42_de_User__c;   
        	}
        }
	}
   
    private static Map<Id, sf42_Devices__c> getParentDevices(List<sf42_Devices__c> newDevices) {
        
        Set<Id> parentDeviceIds = new Set<Id>();
        
        for (sf42_Devices__c newDevice : newDevices) {
            
            if (newDevice.Parent_Device__c != null) {
                parentDeviceIds.add(newDevice.Parent_Device__c);
            }
        }
        
        return new Map<Id, sf42_Devices__c>([
        	SELECT Id, sf42_de_User__c 
            FROM sf42_Devices__c 
            WHERE Id IN :parentDeviceIds  
            LIMIT 50000
        ]);
    }
    
	/* Create reference entry when device is created */
	public static void createReference(List<sf42_Devices__c> devicesList) {
        
		List<Reference__c> refToInsert = new List<Reference__c>();   
        
		for (sf42_Devices__c device : devicesList) {
			Reference__c ref = new Reference__c();
			ref.ptt_Device__c = device.Id;
			ref.ptt_Device_id__c = device.Id;
			ref.Name = device.Name;
			ref.ptt_Account__c = device.sf42_Account__c;
			//ref.ptt_Serial_Number__c = device.sf42_Serial_Number__c;
			//ref.ptt_Product__c = device.sf42_de_Product__c;
			refToInsert.add(ref);
		}
		insert refToInsert;
	}
    
    
	/* Update reference entry on Device edit or create if there is no reference record */
	public static void updateReference(Map<Id, sf42_Devices__c> newDevices) {
        
        // Get data Map for modified records
		Map <Id, sf42_Devices__c> updatedDevices = new Map <Id, sf42_Devices__c> ([
            SELECT Name, sf42_Account__c, sf42_Serial_Number__c, sf42_de_Product__c 
            FROM sf42_Devices__c 
            WHERE Id IN :newDevices.keySet()
            LIMIT 50000
        ]);
        
		// Get list of all connected refference records
		List<Reference__c> refToUpdate = [
            SELECT Id, ptt_Device__c 
            FROM Reference__c 
            WHERE ptt_Device__c IN :updatedDevices.keySet()
            LIMIT 50000
        ];
		
        if (refToUpdate != null && !refToUpdate.isEmpty()) {
         
            // Update existing references records
            for (Reference__c ref : refToUpdate) {
                ref.Name = updatedDevices.get(ref.ptt_Device__c).Name;
                ref.ptt_Account__c = updatedDevices.get(ref.ptt_Device__c).sf42_Account__c;
                //ref.ptt_Serial_Number__c = updatedDevices.get(ref.ptt_Device__c).sf42_Serial_Number__c;
                //ref.ptt_Product__c = updatedDevices.get(ref.ptt_Device__c).sf42_de_Product__c;	
            	updatedDevices.remove(ref.ptt_Device__c);	
            }
            System.debug('refToUpdate ' + refToUpdate);
            update refToUpdate;   
        }
		
		// Insert missing references (what left from update list)
        if (!updatedDevices.isEmpty())  { 
        	createReference(updatedDevices.values());
        }
	}
    
	/* Delete reference entry when Device is deleted */	
	public static void deleteReference(Set<Id> deviceIds) {
		Database.Delete([SELECT ID, Name FROM Reference__c WHERE ptt_Device_id__c IN :deviceIds]);
	}
}