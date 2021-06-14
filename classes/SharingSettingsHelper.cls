public with sharing class SharingSettingsHelper {
	
    public static List<String> getCommonSharingFieldsByObjectName(String objectName) {
        Partner_Territory_Sharing_Common_Fields__c fields = Partner_Territory_Sharing_Common_Fields__c.getInstance(objectName);
        return fields == null ? new List<String>() : fields.Field_API_Names__c.split(';');
    }
    
    public static List<String> getFieldsToProcessByObjectName(String objectName) {
        List<String> fields = getCommonSharingFieldsByObjectName(objectName);
        fields.add(SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(objectName));
        return fields;
    }

    public static List<String> getAllFieldsAPINamesByObjectName(String objectName) {

        List<String> fields = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldDetails = schemaMap.get(objectName).getDescribe().fields.getMap();

        fields.addAll(fieldDetails.keySet());
        return fields;
    }

    public static Boolean areMandatoryCriteriaFieldsSet(String businessUnit) {
        Partner_Territory_Criteria_Fields__c criteriaFields = Partner_Territory_Criteria_Fields__c.getInstance(businessUnit);
        return criteriaFields != null;
    }

    public static Map<String, List<String>> getMandatoryCriteriaFields(String businessUnit) {

        Map<String, List<String>> fields = new Map<String, List<String>>();
        Partner_Territory_Criteria_Fields__c criteriaFields = Partner_Territory_Criteria_Fields__c.getInstance(businessUnit);

        if (criteriaFields != null) {
            fields.put(SharingConstants.ACCOUNT_CRITERIA, criteriaFields.Account_Criteria_Fields__c.split(';'));
            fields.put(SharingConstants.LEAD_CRITERIA, criteriaFields.Lead_Criteria_Fields__c.split(';'));
        }
        return fields;
    }
}