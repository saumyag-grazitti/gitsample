public with sharing class OwnerBasedSharingHandler {

    public static void recalculateSharings(List<Account> updatedAccounts, List<Account> oldAccounts) {
        Map<Id, SharingWrapper> oldSharings = getSharingsByAccountOwners(oldAccounts);
        OwnerBasedSharingRecalculationManager.removeSharings(oldSharings);
        
        Map<Id, SharingWrapper> newSharings = getSharingsByAccountOwners(updatedAccounts);
        OwnerBasedSharingRecalculationManager.addSharings(newSharings);
    }
    
	public static void recalculateSharings(Set<Id> objIds, Set<Id> updatedAccountIds, Set<Id> oldAccountIds) {
        
        String objectName = new List<Id>(objIds)[0].getSobjectType().getDescribe().getName();
        
        List<Account> updatedAccounts = getAccountsByIds(updatedAccountIds);
        List<Account> oldAccounts = getAccountsByIds(oldAccountIds);
        
        Map<Id, SharingWrapper> updatedSharings = getSharingsByAccountOwners(updatedAccounts);
        Map<Id, SharingWrapper> oldSharings = getSharingsByAccountOwners(oldAccounts);
        
        if (objectName == SharingConstants.DEVICES_OBJECT) {
        	OwnerBasedSharingRecalculationManager.removeDeviceSharings(oldSharings, objIds);  
            OwnerBasedSharingRecalculationManager.addDeviceSharings(updatedSharings, objIds);
        }
        
        if (objectName == SharingConstants.SERVICE_DEMOS_OBJECT) {
        	OwnerBasedSharingRecalculationManager.removeServiceDemosSharings(oldSharings, objIds);
        	OwnerBasedSharingRecalculationManager.addServiceDemosSharings(updatedSharings, objIds);
        }
    }

    public static void addSharings(Set<Id> objIds, Set<Id> accountIds) {

        String objectName = new List<Id>(objIds)[0].getSobjectType().getDescribe().getName();
        List<Account> accounts = getAccountsByIds(accountIds);
        Map<Id, SharingWrapper> sharings = getSharingsByAccountOwners(accounts);

        if (objectName == SharingConstants.DEVICES_OBJECT) {
            OwnerBasedSharingRecalculationManager.addDeviceSharings(sharings, objIds);
        }

        if (objectName == SharingConstants.SERVICE_DEMOS_OBJECT) {
            OwnerBasedSharingRecalculationManager.addServiceDemosSharings(sharings, objIds);
        }
    }

    private static List<sObject> getAccountsByIds(Set<Id> accountIds) {
        return [
                SELECT Id, OwnerId
                FROM Account
                WHERE Id IN :accountIds
                LIMIT 10000
        ];
    }

    private static List<sObject> getAccountsByIds(List<Id> accountIds) {
        return [
            SELECT Id, OwnerId
            FROM Account
            WHERE Id IN :accountIds
            LIMIT 10000
        ];
    }

    public static Map<Id, SharingWrapper> getSharingsByAccountOwners(List<Account> accounts) {

        Map<Id, Id> accountOwners = new Map<Id, Id>();

        for (Account acc : accounts) {
            accountOwners.put(acc.Id, acc.OwnerId);
        }

        Map<Id, SharingWrapper> sharings = new Map<Id, SharingWrapper>();
        Map<Id, Id> partnerAccountIds = getPartnerAccountIds(accountOwners.values());
        Map<Id, Set<Id>> partnerUserIds = getPartnerUserIdsByAccountIds(partnerAccountIds.values());
        Map<Id, Account_Owner_Sharing__c> ownerBasedSharings =  AccountOwnerSharingSelector.getSharingsByPartnerAccountIds(partnerAccountIds.values());

        for (Id accountId : accountOwners.keySet()) {

            Id ownerId = accountOwners.get(accountId);
            Id partnerAccountId = partnerAccountIds.get(ownerId);

            if (partnerAccountId != null) {

                Set<Id> userIds = partnerUserIds.get(partnerAccountId);
                Account_Owner_Sharing__c sharing = ownerBasedSharings.get(partnerAccountId);

                if (sharing != null && userIds != null) {
                    sharings.put(accountId, new SharingWrapper(sharing, userIds));
                }
            }
        }
        return sharings;
    }

    public static Map<Id, SharingWrapper> getSharingsByAccountOwners(List<Account> accounts, Map<Id, Account_Owner_Sharing__c> ownerBasedSharings) {

        Map<Id, Id> accountOwners = new Map<Id, Id>();

        for (Account acc : accounts) {
            accountOwners.put(acc.Id, acc.OwnerId);
        }

        Map<Id, SharingWrapper> sharings = new Map<Id, SharingWrapper>();
        Map<Id, Id> partnerAccountIds = getPartnerAccountIds(accountOwners.values());
        Map<Id, Set<Id>> partnerUserIds = getPartnerUserIdsByAccountIds(partnerAccountIds.values());

        for (Id accountId : accountOwners.keySet()) {

            Id ownerId = accountOwners.get(accountId);
            Id partnerAccountId = partnerAccountIds.get(ownerId);

            if (partnerAccountId != null) {

                Set<Id> userIds = partnerUserIds.get(partnerAccountId);
                Account_Owner_Sharing__c sharing = ownerBasedSharings.get(partnerAccountId);

                if (sharing != null && userIds != null) {
                    sharings.put(accountId, new SharingWrapper(sharing, userIds));
                }
            }
        }
        return sharings;
    }

    private static  Map<Id, Id> getPartnerAccountIds(List<Id> accountOwnerIds) {

        Map<Id, Id> partnerAccountIds = new Map<Id, Id>();

        for (User userDetails : [
                SELECT Id, UserRole.PortalAccountId
                FROM User
                WHERE (UserRole.PortalAccountId != null
                    AND Id IN: accountOwnerIds)
                LIMIT 10000
        ]) {
            partnerAccountIds.put(userDetails.Id, userDetails.UserRole.PortalAccountId);
        }
        return partnerAccountIds;
    }

    private static  Map<Id, Set<Id>> getPartnerUserIdsByAccountIds(List<Id> partnerAccountIds) {

        Map<Id, Set<Id>> partnerUserIds = new Map<Id, Set<Id>>();

        for (User userDetails : [
                SELECT Id, UserRole.PortalAccountId, IsPortalEnabled
                FROM User
                WHERE (IsPortalEnabled = true
                    AND UserRole.PortalAccountId != null
                    AND UserRole.PortalAccountId IN :partnerAccountIds)
                LIMIT 10000
        ]) {

            Set<Id> userIds = partnerUserIds.get(userDetails.UserRole.PortalAccountId);

            if (userIds == null) {
                userIds = new Set<Id>();
            }

            userIds.add(userDetails.Id);
            partnerUserIds.put(userDetails.UserRole.PortalAccountId, userIds);
        }
        return partnerUserIds;
    }
  }