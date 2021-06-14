/**
 * Created by yanagerasimchuk on 5/25/18.
 */

public with sharing class DeviceShareManager extends ShareManager {

    private Map<Id, sf42_Devices__c> devices;

    public DeviceShareManager(Map<Id, List<SharingWrapper>> sharings) {
        super(sharings);
        this.devices = new Map<Id, sf42_Devices__c>();
        
        for(sf42_Devices__c device : getDevicesByAccountIds()) {
        	devices.put(device.Id, device);
            
            if (device.Parent_Device__c != null) {
                devices.put(device.Parent_Device__c, device);
            }
        }
    }
    
    public DeviceShareManager(Map<Id, List<SharingWrapper>> sharings, Set<Id> devicesIds) {
        super(sharings);
        this.devices = new Map<Id, sf42_Devices__c>();
        
        for(sf42_Devices__c device: getDevicesByIds(devicesIds)) {
        	devices.put(device.Id, device);
            
            if (device.Parent_Device__c != null) {
                devices.put(device.Parent_Device__c, device);
            }
        }
    }
    
    public DeviceShareManager(Map<Id, SharingWrapper> sharings) {
        super(sharings);
        this.devices = new Map<Id, sf42_Devices__c>();
        
        for(sf42_Devices__c device : getDevicesByAccountIds()) {
        	devices.put(device.Id, device);
            
            if (device.Parent_Device__c != null) {
                devices.put(device.Parent_Device__c, device);
            }
        }
    }
    
	public DeviceShareManager(Map<Id, SharingWrapper> sharings, Set<Id> recordIds) {
        super(sharings);
        this.devices = new Map<Id, sf42_Devices__c>();
        
        for(sf42_Devices__c device : getDevicesByIds(recordIds)) {
        	devices.put(device.Id, device);
            
            if (device.Parent_Device__c != null) {
                devices.put(device.Parent_Device__c, device);
            }
        }
    }
    
    private List<sf42_Devices__c> getDevicesByAccountIds() {
    	return [
            SELECT ID, OwnerId, sf42_Account__c, Parent_Device__c
            FROM sf42_Devices__c
            WHERE sf42_Account__c IN :this.sharings.keySet()
            LIMIT 10000
        ];  
    }
    
    private List<sf42_Devices__c> getDevicesByIds(Set<Id> devicesIds) {
    	return [
            SELECT ID, OwnerId, sf42_Account__c, Parent_Device__c
            FROM sf42_Devices__c
            WHERE ID IN :devicesIds
            LIMIT 10000
        ];  
    }
    
    public override List<sObject> getSharesToInsert() {
		
        List<sf42_Devices__Share> shares = new List<sf42_Devices__Share>();
		
        for (Id deviceId : this.devices.keySet()) {

            sf42_Devices__c device = this.devices.get(deviceId);

            for (SharingWrapper sharing : this.sharings.get(device.sf42_Account__c)) {

                for(Id userOrGroupId : sharing.usersOrGroupId) {

                    if (sharing.deviceAccessLevel != SharingConstants.DEFAULT_LEVEL_ACCESS && userOrGroupId != device.OwnerId) {
                        shares.add(new sf42_Devices__Share(
                                ParentId = deviceId,
                                UserOrGroupId = userOrGroupId,
                                AccessLevel = sharing.deviceAccessLevel
                        ));
                    }
                }
            }
        }
        return shares;
    }

    public override List<sObject> getSharesToDelete() {

        List<sf42_Devices__Share> sharesToDelete = new List<sf42_Devices__Share>();

        List<sf42_Devices__Share> sharesByParentId = [
                SELECT Id, ParentId, UserOrGroupId
                FROM sf42_Devices__Share
                WHERE (RowCause = :MANUAL_CAUSE
                    AND ParentId IN :this.devices.keySet())
                LIMIT 10000
        ];

        List<sf42_Devices__Share> sharesByUserId = [
                SELECT Id, ParentId, UserOrGroupId
                FROM sf42_Devices__Share
                WHERE (RowCause = :MANUAL_CAUSE
                    AND UserOrGroupId IN :this.userOrGroupIds)
                LIMIT 10000
        ];
        Set<sf42_Devices__Share> commonShares = new Set<sf42_Devices__Share>();
        commonShares.addAll(sharesByUserId);
        commonShares.retainAll(sharesByParentId);

        sharesToDelete.addAll(commonShares);
        return sharesToDelete;
    }
}