public with sharing class AccountOwnerSharingExtension {
	
    public Account_Owner_Sharing__c sharing { get; set;}
    public String selectedBusinessUnit { get; set; }
    public ApexPages.StandardController cntr;
        
		//adding comment to commit
    public List<SelectOption> accessLevelOptions {
        get {
            if (accessLevelOptions == null) {
                accessLevelOptions = SelectOptionsHelper.getAccessLevelOptions();
            }
            return accessLevelOptions;
        }
        set;
    }

    public List<SelectOption> businessUnits {
        get {
            if (businessUnits == null) {
                businessUnits = SelectOptionsHelper.getBusinessUnitsOptions();
            }
            return businessUnits;
        }
        set;
    }

    public List<SelectOption> partnerAccounts {
        get {
            return SelectOptionsHelper.getPartnerAccountsByBusinessUnit(selectedBusinessUnit);
        }
        set;
    }

    public AccountOwnerSharingExtension(ApexPages.StandardController cntr) {
        this.cntr = cntr;
        if(!Test.isRunningTest()) {
            this.cntr.addFields(SharingConstants.ACCOUNT_OWNER_FIELDS);
        }
        this.sharing = (Account_Owner_Sharing__c)cntr.getRecord();
        this.selectedBusinessUnit = this.sharing.Partner_Account__c != null ?
                    this.sharing.Partner_Account__r.sf42_Business_Unit__c : businessUnits[0].getValue();
    }
    
    public PageReference save() {

        Boolean ruleNameIsBlank = AccountOwnerSharingHelper.ruleNameIsBlank(this.sharing.Name);
        Boolean isDuplicate = AccountOwnerSharingHelper.isDuplicate(this.sharing);
        
        if (ruleNameIsBlank || isDuplicate) {
            return null;
        }
        upsert this.sharing;
        
        PageReference pageRef = new PageReference('/' + this.sharing.Id); 
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel() {
		Schema.DescribeSObjectResult result = Account_Owner_Sharing__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        return pageRef;
    }
    
}