trigger ptt_Device_Trigger_Old on sf42_Devices__c (before insert, before update, after insert, after update, after delete) {

    if (Trigger.isBefore && Trigger.isInsert) {
        updateUserFieldOnChild();
    }

    if (Trigger.isBefore && Trigger.isUpdate){ 
        updateUserFieldOnChild();
    } 
    
    if (Trigger.isAfter && Trigger.isInsert ){ 
        createReference(Trigger.New);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate ){ 
        changeOwnerOfSubdevice();
        updateReference();
    }
    
    if (Trigger.isAfter && Trigger.isDelete ){ 
        deleteReference();
    }
    
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/
    
    /* Change Owner of child device when owner of parent is changed */
    public static void changeOwnerOfSubdevice() {       
        List<sf42_Devices__c> recordsToUpdate = new List<sf42_Devices__c>();
        
        for (sf42_Devices__c device : Trigger.New) {
            sf42_Devices__c oldDev = Trigger.oldMap.get(device.ID);
            sf42_Devices__c newDev = Trigger.newMap.get(device.ID);
            
            if (oldDev.OwnerId != newDev.OwnerId) {
                List<sf42_Devices__c> allChildRecords = [SELECT ID FROM sf42_Devices__c WHERE Parent_Device__c = :device.ID] ;
                if (allChildRecords.size() > 0) {
                    for (sf42_Devices__c oneChild : allChildRecords) {
                        oneChild.OwnerID = newDev.OwnerID;
                        recordsToUpdate.add(oneChild);
                    }     
                }       
            }
        }
        if (!recordsToUpdate.isEmpty()) update recordsToUpdate;
    }
    
    /* Update filed User [sf42_de_User__c] when device has Parent Device [Parent_Device__c] with value from parent. */
    public static void updateUserFieldOnChild() {
        for (sf42_Devices__c deviceNew : Trigger.New) {
            if (deviceNew.Parent_Device__c != null) {
                Id Parent_device_id =  deviceNew.Parent_Device__c;
                sf42_Devices__c ParentDevice = [Select d.sf42_de_User__c From sf42_Devices__c d where sf42_Devices__c.Id = :Parent_device_id];
                deviceNew.sf42_de_User__c = ParentDevice.sf42_de_User__c;
            }
        }
    }
    
    /* Create reference entry when device is created */
    public static void createReference(List<sf42_Devices__c> devicesList ) {
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
    public static void updateReference() {
        // Get ID of all modified device records
        Set <Id> devicesID = new Set<Id>(); 
        for (sf42_Devices__c device : Trigger.New) {
            devicesID.add(device.ID);       
        }
        // Get data Map for modified records
        Map <Id, sf42_Devices__c> updatedDevices = new Map <Id, sf42_Devices__c> ();
        updatedDevices.putAll([SELECT Name, sf42_Account__c, sf42_Serial_Number__c, sf42_de_Product__c FROM sf42_Devices__c WHERE Id IN :devicesID]);
        
        // Get list of all connected refference records
        List<Reference__c> refToUpdate = new List<Reference__c>(); 
        refToUpdate = [SELECT Id, ptt_Device__c FROM Reference__c WHERE ptt_Device__c IN :updatedDevices.keySet()];
        
        // Update existing references records
        for (Reference__c ref : refToUpdate) {
            ref.Name = updatedDevices.get(ref.ptt_Device__c).Name;
            ref.ptt_Account__c = updatedDevices.get(ref.ptt_Device__c).sf42_Account__c;
            //ref.ptt_Serial_Number__c = updatedDevices.get(ref.ptt_Device__c).sf42_Serial_Number__c;
            //ref.ptt_Product__c = updatedDevices.get(ref.ptt_Device__c).sf42_de_Product__c;    
            // Remove from update list
            updatedDevices.remove(ref.ptt_Device__c);   
        }
        update refToUpdate;
        
        // Insert missing references (what left from update list)
        if (updatedDevices.size() > 0) createReference(updatedDevices.values());
        
    }

    /* Delete reference entry when Device is deleted */ 
    public static void deleteReference() {
        Database.Delete([SELECT ID, Name FROM Reference__c WHERE ptt_Device_id__c IN :Trigger.oldMap.keySet()]);
    }
}