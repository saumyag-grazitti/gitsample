public with sharing class ServicesDemosShareManager extends ShareManager {

    private Map<Id, Service_and_Demontration__c> servicesDemos;

    public ServicesDemosShareManager(Map<Id, List<SharingWrapper>> sharings) {
        super(sharings);
        this.servicesDemos = getServiceDemosByAccountIds();
    }

    public ServicesDemosShareManager(Map<Id, List<SharingWrapper>> sharings, Set<Id> serviceDemosIds) {
        super(sharings);
        this.servicesDemos = getServiceDemosByIds(serviceDemosIds);
    }
    
    public ServicesDemosShareManager(Map<Id, SharingWrapper> sharings) {
        super(sharings);
		this.servicesDemos = getServiceDemosByAccountIds();
    }
    
    public ServicesDemosShareManager(Map<Id, SharingWrapper> sharings, Set<Id> serviceDemosIds) {
        super(sharings);
		this.servicesDemos = getServiceDemosByIds(serviceDemosIds);
    }
    
    private Map<Id, Service_and_Demontration__c> getServiceDemosByAccountIds() {
    	return new Map<Id, Service_and_Demontration__c>([
            SELECT ID, OwnerId, sf42_Account__c
            FROM Service_and_Demontration__c
            WHERE sf42_Account__c IN :this.sharings.keySet()
            LIMIT 10000
        ]);    
    }
    
    private Map<Id, Service_and_Demontration__c> getServiceDemosByIds(Set<Id> objectIds) {
    	return new Map<Id, Service_and_Demontration__c>([
            SELECT ID, OwnerId, sf42_Account__c
            FROM Service_and_Demontration__c
            WHERE ID IN :objectIds
            LIMIT 10000
        ]);    
    }
    
    public override List<sObject> getSharesToInsert() {

        List<Service_and_Demontration__Share> shares = new List<Service_and_Demontration__Share>();

        for (Service_and_Demontration__c servicesDemo : this.servicesDemos.values()) {

            for (SharingWrapper sharing : this.sharings.get(servicesDemo.sf42_Account__c)) {

                for(Id userOrGroupId : sharing.usersOrGroupId) {

                    if (sharing.servicesDemosAccessLevel != SharingConstants.DEFAULT_LEVEL_ACCESS && userOrGroupId != servicesDemo.OwnerId) {
                        shares.add(new Service_and_Demontration__Share(
                                ParentId = servicesDemo.Id,
                                UserOrGroupId = userOrGroupId,
                                AccessLevel = sharing.servicesDemosAccessLevel
                        ));
                    }
                }
            }
        }
        return shares;
    }

    public override List<sObject> getSharesToDelete() {

        List<Service_and_Demontration__Share> sharesToDelete = new List<Service_and_Demontration__Share>();
		
        List<Service_and_Demontration__Share> sharesByParentId = [
                SELECT Id, ParentId, UserOrGroupId
                FROM Service_and_Demontration__Share
                WHERE (RowCause = :MANUAL_CAUSE
                    AND ParentId IN :this.servicesDemos.keySet())
                LIMIT 10000
        ];
        
        List<Service_and_Demontration__Share> sharesByUserId = [
                SELECT Id, ParentId, UserOrGroupId
                FROM Service_and_Demontration__Share
                WHERE (RowCause = :MANUAL_CAUSE
                    AND UserOrGroupId IN :this.userOrGroupIds)
                LIMIT 10000
        ];
        
        Set<Service_and_Demontration__Share> commonShares = new Set<Service_and_Demontration__Share>();
        commonShares.addAll(sharesByUserId);
        commonShares.retainAll(sharesByParentId);

        sharesToDelete.addAll(commonShares);
        return sharesToDelete;
    }
}