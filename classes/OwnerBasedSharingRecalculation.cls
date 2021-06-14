public with sharing class OwnerBasedSharingRecalculation {

    public List<Account_Owner_Sharing__c> sharings { get; set;}
    private Map<Id, Account_Owner_Sharing__c> sharingByPartnerAccounts;
    private Map<Id, Id> partnerUserAccount;
 	private String operation;
    
    public OwnerBasedSharingRecalculation(List<Account_Owner_Sharing__c> sharings, String operation) {
        this.sharingByPartnerAccounts = new Map<Id, Account_Owner_Sharing__c>();
        this.sharings = sharings;
        this.operation = operation;

        Set<Id> partnerAccounts = new Set<Id>();
        
        for (Account_Owner_Sharing__c sharing : sharings) {
            this.sharingByPartnerAccounts.put(sharing.Partner_Account__c, sharing);
            partnerAccounts.add(sharing.Partner_Account__c);
        }
        this.partnerUserAccount = GroupSelector.getPartnerUserAccounts(partnerAccounts);
    }
    
    public Set<Id> getPartnerUserIds() {
       return this.partnerUserAccount.keySet();
    }
    
    public void recalculateSharings(List<Account> accounts) {
        
        Map<Id, SharingWrapper> sharings = OwnerBasedSharingHandler.getSharingsByAccountOwners(accounts, this.sharingByPartnerAccounts);

        if (this.operation == SharingConstants.ADD_OPERATION) {
			OwnerBasedSharingRecalculationManager.addSharings(sharings);
        }
        
        if (this.operation == SharingConstants.DELETE_OPERATION) {
            OwnerBasedSharingRecalculationManager.removeSharings(sharings);
        }
    }
}