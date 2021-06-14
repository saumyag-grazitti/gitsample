public with sharing class TerritorySharingExtension {
    
    private Map<Id, String> groupNames;
    private ApexPages.StandardController cntrl;
    public List<Territory_Sharing_Criterion__c> accountCriteria { get; set; }
    public List<Territory_Sharing_Criterion__c> leadCriteria { get; set; }
    public Territory_Sharing__c sharing { get; set; }
    public Boolean ignoreCriteriaValidationRule { get; set;}

    public List<SelectOption> accessLevelOptions {
        get {
            if (accessLevelOptions == null) {
                accessLevelOptions = SelectOptionsHelper.getAccessLevelOptions();
            }
            return accessLevelOptions;
        }
        set;
    }
    
	public List<SelectOption> accountLevelOptions {
        get {
            if (accountLevelOptions == null) {
                accountLevelOptions = SelectOptionsHelper.getAccountAccessLevelOptions();
            }
            return accountLevelOptions;
        }
        set;
    }

    public List<SelectOption> groups { 
        get {
            if (groups == null) {
               	groups = SelectOptionsHelper.getGroupsOptions(this.groupNames);
            }
            return groups;
        }
        set; 
    }
    
    public List<SelectOption> operators {
        get {
            if (operators == null) {
                operators = SelectOptionsHelper.getOperatorsOptions();
            }
            return operators;
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
    
    public List<SelectOption> accountsFromCustomSettings {
        get {
            if (accountsFromCustomSettings == null) {
                accountsFromCustomSettings = SelectOptionsHelper.getCriteriaFieldsOptionsByObjectName(SharingConstants.ACCOUNT_OBJECT);
            }
            return accountsFromCustomSettings;
        } 
        set;
    }
    
    public List<SelectOption> leadFieldsFromCustomSettings {
        get {
            if (leadFieldsFromCustomSettings == null) {
                leadFieldsFromCustomSettings =  SelectOptionsHelper.getCriteriaFieldsOptionsByObjectName(SharingConstants.LEAD_OBJECT);
            }
            return leadFieldsFromCustomSettings;
    	} 
        set;
    }

    public Boolean mandatoryCriteriaFieldsAreSet {
        get {
            return SharingSettingsHelper.areMandatoryCriteriaFieldsSet(this.sharing.Business_Unit__c);
        }
        set;
    }

    public TerritorySharingExtension(ApexPages.StandardController cntr) {
        this.cntrl = cntr;
        this.sharing = (Territory_Sharing__c)cntrl.getRecord();
        this.accountCriteria = new List<Territory_Sharing_Criterion__c>();
    	this.leadCriteria = new List<Territory_Sharing_Criterion__c>();
        this.accountCriteria.add(new Territory_Sharing_Criterion__c());
        this.leadCriteria.add(new Territory_Sharing_Criterion__c());
        this.groupNames = SelectOptionsHelper.getPartnerExecutiveGroups();
        this.sharing.Business_Unit__c =this.businessUnits[0].getValue();
    }
    
    public PageReference save() {
        
		this.sharing.UserRoleName__c = this.groupNames.get(this.sharing.Group_Id_To_Share_Record_With__c);
        List<Territory_Sharing_Criterion__c> filteredAccountCriteria = filterCriteria(this.accountCriteria);
        List<Territory_Sharing_Criterion__c> filteredLeadCriteria = filterCriteria(this.leadCriteria);
     
        if (sharingNameIsNotBlank() && !existDuplicatedCriteria() &&
                areMandatoryCriteriaSet(filteredAccountCriteria, filteredLeadCriteria) &&
                TerritorySharingExtensionHelper.isSharingUnique(filteredAccountCriteria, filteredLeadCriteria, this.sharing)) {
            
            insert sharing;  
        	TerritorySharingExtensionHelper.upsertCriteria(sharing.Id, filteredAccountCriteria, SharingConstants.ACCOUNT_CRITERIA);            
        	TerritorySharingExtensionHelper.upsertCriteria(sharing.Id, filteredLeadCriteria, SharingConstants.LEAD_CRITERIA);  
            SharingRecalculationLauncher.addSharingsAsync(sharing.Id);
       
            PageReference page = new PageReference('/' + this.sharing.Id);
        	page.setRedirect(true);
        	return page;
        }
        return null;
    }
    
 	public PageReference cancel() {
		Schema.DescribeSObjectResult result = Territory_Sharing__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    
    public PageReference addRowToAccountPanel() {
        if (!existDuplicateAccount() && !isBlankAccountValue()) {
            accountCriteria.add(new Territory_Sharing_Criterion__c());
        }
        return null;
    }
    
    public PageReference addRowToLeadPanel() {
        if (!existDuplicateLead() && !isBlankLeadValue()) {
            leadCriteria.add(new Territory_Sharing_Criterion__c());
        }
        return null;
    }
    
    public PageReference removeLastAccountCriteria() {
        Integer itemToRemove = this.accountCriteria.size() - 1;
        this.accountCriteria.remove(itemToRemove);
        return null;
    }
    
    public PageReference removeLastLeadCriteria() {      
        Integer itemToRemove = leadCriteria.size() - 1;
		this.leadCriteria.remove(itemToRemove);
        return null;
    }
    
    private Boolean sharingNameIsNotBlank() {
        Boolean isNotBlank = true;
        if (String.isBlank(this.sharing.Name)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rule Name can not have only whitespaces.'));
            isNotBlank = false;
        }
        return isNotBlank;
    }

    private Boolean existDuplicatedCriteria() {
        return existDuplicateAccount() || existDuplicateLead();
    }

    private Boolean isBlankAccountValue() {
        return TerritorySharingExtensionHelper.isBlankAccountValue(this.accountCriteria);
    }
    
    private Boolean isBlankLeadValue() {
        return TerritorySharingExtensionHelper.isBlankLeadValue(this.leadCriteria);
    }
    
    private Boolean existDuplicateAccount() {
        return TerritorySharingExtensionHelper.existDuplicateAccount(this.accountCriteria);
    }
    
    private Boolean existDuplicateLead() {
        return TerritorySharingExtensionHelper.existDuplicateLead(this.leadCriteria);
    }     

    private Boolean areMandatoryCriteriaSet(List<Territory_Sharing_Criterion__c> filteredAccountCriteria, List<Territory_Sharing_Criterion__c> filteredLeadCriteria) {

        if (mandatoryCriteriaFieldsAreSet && !ignoreCriteriaValidationRule) {
            return TerritorySharingExtensionHelper.areMandatoryCriteriaSet(this.sharing.Business_Unit__c, filteredAccountCriteria, filteredLeadCriteria);
        }
        return true;
    }
    private List<Territory_Sharing_Criterion__c> filterCriteria(List<Territory_Sharing_Criterion__c> criteriaToFilter) {
        
        List<Territory_Sharing_Criterion__c> criteria = new List<Territory_Sharing_Criterion__c>();
        
        for (Territory_Sharing_Criterion__c criterion : criteriaToFilter) {
        
            if (String.isNotBlank(criterion.Field_Value__c)) {
            	criteria.add(criterion);
            }
        }  
        return criteria;
    }
}