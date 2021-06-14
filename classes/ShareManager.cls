public with sharing abstract class ShareManager {
    
    protected final String MANUAL_CAUSE = 'Manual';
    protected Map<Id, List<SharingWrapper>> sharings;
    protected Set<Id> userOrGroupIds;
    
    public ShareManager(Map<Id, List<SharingWrapper>> sharings) {
        this.sharings = sharings;
        this.userOrGroupIds = new Set<Id>();
        
        for (Id sharingId : this.sharings.keySet()) {
            for (SharingWrapper sharing : this.sharings.get(sharingId)) {
                this.userOrGroupIds.addAll(sharing.usersOrGroupId);
            }
        }
    }
    
    public ShareManager(Map<Id, SharingWrapper> sharings) {
        this.sharings = new Map<Id, List<SharingWrapper>>();
        this.userOrGroupIds = new Set<Id>();
        
        for (Id accountId : sharings.keySet()) {
            this.sharings.put(accountId, new List<SharingWrapper>{sharings.get(accountId)});
        }
        
        for (Id sharingId : this.sharings.keySet()) {
            for (SharingWrapper sharing : this.sharings.get(sharingId)) {
                this.userOrGroupIds.addAll(sharing.usersOrGroupId);
            }
        }
    }
    
    public abstract List<sObject> getSharesToInsert();
    public abstract List<sObject> getSharesToDelete();
}