public with sharing class TerritorySharingWrapper {
    
    public Territory_Sharing__c sharing { get; set; }
    public List<Territory_Sharing_Criterion__c> criteria { get; set; }
    public List<Territory_Sharing_Criterion__c> accountCriteria { get; set; }
    public List<Territory_Sharing_Criterion__c> leadCriteria { get; set; }
    
    public TerritorySharingWrapper(Territory_Sharing__c sharing, List<Territory_Sharing_Criterion__c> criteria) {
        this.sharing = sharing;
        this.criteria = criteria;
        this.accountCriteria = filterCriteria(criteria, SharingConstants.ACCOUNT_CRITERIA);
        this.leadCriteria = filterCriteria(criteria, SharingConstants.LEAD_CRITERIA);
    }
    
    private List<Territory_Sharing_Criterion__c> filterCriteria(List<Territory_Sharing_Criterion__c> criteria, String criterionName) {

        List<Territory_Sharing_Criterion__c> filteredCriteria = new List<Territory_Sharing_Criterion__c>();

        for (Territory_Sharing_Criterion__c criterion : criteria) {

            if (criterion.RecordType.DeveloperName.equals(criterionName)) {
                filteredCriteria.add(criterion);
            }
        }
        return filteredCriteria;
    }
    
    public List<Territory_Sharing_Criterion__c> getCriteriaByObjectName(String objectName) {
        
        if (objectName == SharingConstants.ACCOUNT_OBJECT) {
            return this.accountCriteria;
        }
        return this.leadCriteria;
    }
}