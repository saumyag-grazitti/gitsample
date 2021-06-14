public with sharing class TerritorySharingViewExtension {

    public ApexPages.StandardController cntr { get; set; }
    public List<Territory_Sharing_Criterion__c> leadCriteria { get; set; }
    public List<Territory_Sharing_Criterion__c> accountCriteria { get; set; }
    
    public TerritorySharingViewExtension(ApexPages.StandardController cntr) {
        this.cntr = cntr;
		this.leadCriteria = TerritorySharingSelector.getTerritorySharingCriteria(cntr.getId(), SharingConstants.LEAD_CRITERIA);
        this.accountCriteria = TerritorySharingSelector.getTerritorySharingCriteria(cntr.getId(), SharingConstants.ACCOUNT_CRITERIA);
    }
    
    public PageReference recalculate() {
        PageReference page = cntr.edit();
        page.setRedirect(true);
        return page;
    }
    
 	public PageReference back() {
		Schema.DescribeSObjectResult result = Territory_Sharing__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
}