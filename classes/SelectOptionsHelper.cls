public with sharing class SelectOptionsHelper {

    public static List<SelectOption> getAccessLevelOptions() {
        
        List<SelectOption> accessLevelOptions = new List<SelectOption>();
        List<Schema.PicklistEntry> pickListValues = SObjectType.Territory_Sharing__c.fields.getMap().get('Account_Access_Level__c').getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry entry : pickListValues) {
        
            if (entry.isActive()) { 
                accessLevelOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        }
        return accessLevelOptions;
    }
    
    public static List<SelectOption> getAccountAccessLevelOptions() {
        
        List<SelectOption> accessLevelOptions = new List<SelectOption>();
        List<Schema.PicklistEntry> pickListValues = SObjectType.Territory_Sharing__c.fields.getMap().get('Account_Access_Level__c').getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry entry : pickListValues) {
        
            if (entry.isActive() && entry.getValue() != SharingConstants.DEFAULT_LEVEL_ACCESS) { 
                accessLevelOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        }
        return accessLevelOptions;
    }
    
    public static List<SelectOption> getGroupsOptions(Map<Id,String> groupNames) {
        List<SelectOption> groups = new List<SelectOption>();
        for (Id groupId : groupNames.keySet()) {
            groups.add(new SelectOption(groupId, groupNames.get(groupId)));   
        }
        return groups;
    }

    public static Map<Id, String> getPartnerExecutiveGroups() {

        Map<Id, String> groups = new Map<Id, String>();
        Map<Id, Id> userRoleGroups = new Map<Id, Id>();

        for (Group groupDetails : GroupSelector.getPartnerExecutiveGroups()) {
            userRoleGroups.put(groupDetails.RelatedId, groupDetails.Id);
        }

        for (UserRole role : GroupSelector.getGroupRoles(userRoleGroups.keySet())) {
                groups.put(userRoleGroups.get(role.Id), role.Name);
        }
        return groups;
    }

    public static List<SelectOption> getOperatorsOptions() {
                        
        List<SelectOption> operators = new List<SelectOption>();
        List<Schema.PicklistEntry> pickListValues = Schema.getGlobalDescribe().get('Territory_Sharing_Criterion__c').getDescribe().fields.getMap().get('Operator__c').getDescribe().getPicklistValues();

        for (Schema.PicklistEntry entry :pickListValues) {
                    
            if (entry.isActive()) {
                operators.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        }
        return operators;
    }
    
    public static List<SelectOption> getBusinessUnitsOptions() {
        
        List<SelectOption> businessUnits = new List<SelectOption>();

        for (Schema.PicklistEntry entry : sObjectType.User.fields.getMap().get('sf42_Business_Unit__c').getDescribe().getPicklistValues()) {
            
            if (entry.isActive()) {
                businessUnits.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        } 
        return businessUnits;
    }
    
    public static List<SelectOption> getCriteriaFieldsOptionsByObjectName(String objectName) {
        
        List<SelectOption> criteriaFields = new List<SelectOption>();
        List<String> fieldApiNames = SharingSettingsHelper.getCommonSharingFieldsByObjectName(objectName);  
        Map<String, String> apiNamesToLabels = getFieldLabelsByApiNames(objectName, fieldApiNames);
        
        for (String field : fieldApiNames) {
            criteriaFields.add(new SelectOption(field, apiNamesToLabels.get(field)));
        }
        return criteriaFields;
    }
    
     private static Map<String, String> getFieldLabelsByApiNames(String sObjectType, List<String> apiNames) {
         
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType typeOfObject = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = typeOfObject.getDescribe().fields.getMap();
        Map<String, String> result = new Map<String, String>();
         
        for (String apiName : apiNames) {
            result.put(apiName, fieldMap.get(apiName).getDescribe().getLabel());
        }
        return result;
    }

    public static List<SelectOption> getPartnerAccountsByBusinessUnit(String businessUnit) {

        List<SelectOption> partnerAccounts = new List<SelectOption>();
		partnerAccounts.add(new SelectOption('', 'Select Partner Account'));     
        
        for (Account account : [
                SELECT Id, Name, isPartner
                FROM Account
                WHERE (isPartner = true AND
                    sf42_Business_Unit__c = :businessUnit)
                ORDER BY Name
                LIMIT 10000
            ]) {
            partnerAccounts.add(new SelectOption(account.Id, account.Name));
        }
        return partnerAccounts;
    }
}