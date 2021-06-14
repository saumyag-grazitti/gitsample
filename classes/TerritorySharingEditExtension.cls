public class TerritorySharingEditExtension {
    
    private Map<Id, String> groupNames;
    private List<Territory_Sharing_Criterion__c> criteriaToRemove;
    private ApexPages.StandardController cntr;
    
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

    public TerritorySharingEditExtension(ApexPages.StandardController cntr) {
        this.cntr = cntr;
        
        TerritorySharingWrapper sharingWrapper = TerritorySharingSelector.getSharingById(cntr.getId());
		this.sharing = sharingWrapper.sharing;
		this.accountCriteria = sharingWrapper.accountCriteria;
		this.leadCriteria = sharingWrapper.leadCriteria;   
		this.criteriaToRemove = new List<Territory_Sharing_Criterion__c>();
        this.groupNames = SelectOptionsHelper.getPartnerExecutiveGroups();
         
        if (this.accountCriteria.isEmpty()) {
            this.accountCriteria.add(new Territory_Sharing_Criterion__c());
        }
        
        if (this.leadCriteria.isEmpty()) {
            this.leadCriteria.add(new Territory_Sharing_Criterion__c());
        }
    }
    
    public PageReference updateAndRecalculate() {
        
        TerritorySharingWrapper oldSharing = TerritorySharingSelector.getSharingById(this.sharing.Id);
        
        this.sharing.UserRoleName__c = groupNames.get(this.sharing.Group_Id_To_Share_Record_With__c);
        List<Territory_Sharing_Criterion__c> filteredAccountCriteria = filterCriteria(this.accountCriteria);
        List<Territory_Sharing_Criterion__c> filteredLeadCriteria = filterCriteria(this.leadCriteria);
     
        if (sharingNameIsNotBlank() && !existDuplicatedCriteria() &&
                areMandatoryCriteriaSet(filteredAccountCriteria, filteredLeadCriteria) &&
                TerritorySharingExtensionHelper.isSharingUnique(filteredAccountCriteria, filteredLeadCriteria, this.sharing)) {
            
            update this.sharing;
            
            if (!this.criteriaToRemove.isEmpty()) {
                delete this.criteriaToRemove;
            }
            
            TerritorySharingExtensionHelper.upsertCriteria(this.sharing.Id, filteredLeadCriteria, SharingConstants.LEAD_CRITERIA);  
			TerritorySharingExtensionHelper.upsertCriteria(this.sharing.Id, filteredAccountCriteria, SharingConstants.ACCOUNT_CRITERIA);  

            TerritorySharingWrapper updatedSharing = TerritorySharingSelector.getSharingById(this.sharing.Id);
            SharingRecalculationLauncher.recalculateSharingsAsync(updatedSharing, oldSharing);
            return cntr.view();
        }
        
        return null;
    }
    
    private List<Territory_Sharing_Criterion__c> filterCriteria(List<Territory_Sharing_Criterion__c> criteriaToUpdate) {
        
        List<Territory_Sharing_Criterion__c> criteria = new List<Territory_Sharing_Criterion__c>();
        
        for (Territory_Sharing_Criterion__c criterion : criteriaToUpdate) {
			
            if (String.isNotBlank(criterion.Field_Value__c)) {
				criteria.add(criterion);
            } else if (criterion.Id != null) {                    
            	this.criteriaToRemove.add(criterion);
			} 
        }
        return criteria;
    }
    
    public PageReference addRowToAccountPanel() {
        if (!existDuplicateAccount() && !isBlankAccountValue()) {
            this.accountCriteria.add(new Territory_Sharing_Criterion__c());
        }
        return null;
    }
    
    public PageReference addRowToLeadPanel() {
        if (!existDuplicateLead() && !isBlankLeadValue()) {
            this.leadCriteria.add(new Territory_Sharing_Criterion__c());
        }
        return null;
    }
    
    public PageReference removeLastAccountCriteria() {
        
        Integer itemToRemove = this.accountCriteria.size() - 1;
        Territory_Sharing_Criterion__c criterionToRemove = accountCriteria.get(itemToRemove);
        
        if (criterionToRemove.Id != null) {
 			this.criteriaToRemove.add(criterionToRemove);
        }
       
		this.accountCriteria.remove(itemToRemove);
        return null;
    }
    
    public PageReference removeLastLeadCriteria() {
        
        Integer itemToRemove = leadCriteria.size() - 1;
        Territory_Sharing_Criterion__c criterionToRemove = this.leadCriteria.get(itemToRemove);
        
        if (criterionToRemove.Id != null) {
 			this.criteriaToRemove.add(criterionToRemove);
        }
       
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
}