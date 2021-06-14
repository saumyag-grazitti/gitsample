public class TerritorySharingExtensionHelper {

    public static void upsertCriteria(Id sharingId, List<Territory_Sharing_Criterion__c> criteria, String criteriaName) {
       
        Id criteriaRecordTypeId = RecordTypeSelector.getRecordTypeId(SharingConstants.SHARING_CRITERIA_OBJECT_NAME, criteriaName);
        
        for (Territory_Sharing_Criterion__c criterion : criteria) {
            if (criterion.Id == null) {
            	criterion.Territory_Sharing__c = sharingId;
                criterion.RecordTypeId = criteriaRecordTypeId;
        	}
        }
        
        if (!criteria.isEmpty()) { 
            upsert criteria;
        }
    }

    public static Boolean areMandatoryCriteriaSet(String businessUnit, List<Territory_Sharing_Criterion__c> accountCriteria, List<Territory_Sharing_Criterion__c> leadCiteria) {

        Boolean fieldsAreSet = true;
        Map<String, List<String>> criteriaFields = SharingSettingsHelper.getMandatoryCriteriaFields(businessUnit);

        if (!criteriaFields.isEmpty()) {

            fieldsAreSet = areMandatoryCriteriaSet(accountCriteria, criteriaFields.get(SharingConstants.ACCOUNT_CRITERIA));
			
            if (fieldsAreSet) {
                fieldsAreSet = areMandatoryCriteriaSet(leadCiteria, criteriaFields.get(SharingConstants.LEAD_CRITERIA));
            }
        }
        return fieldsAreSet;
    }

    public static Boolean areMandatoryCriteriaSet(List<Territory_Sharing_Criterion__c> criteria, List<String> mandatoryCriteria) {

        List<String> definedCriteria = new List<String>();

        for(Territory_Sharing_Criterion__c criterion : criteria) {
            definedCriteria.add(criterion.Field_API_Name__c);
        }

        for (String mandatoryCriterion : mandatoryCriteria) {

            if (!definedCriteria.contains(mandatoryCriterion)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step 2. "' + mandatoryCriterion + '" territory criterion is not defined. ' + Label.Criteria_Validation_Warning));
                return false;
            }
        }
        return true;
    }

    public static Boolean existDuplicateLead(List<Territory_Sharing_Criterion__c> leadCriteria) {
        if (leadCriteria.isEmpty()) {
            return false;
        }
        Boolean existDuplicate = false;
        String apiName = leadCriteria[0].Field_API_Name__c;
        for (Integer i = 1; i < leadCriteria.size(); i++) {
            if (leadCriteria[i].Field_API_Name__c.equals(apiName)) {
                existDuplicate = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step 2. Territory criterion is defined twice for ' + apiName));
                break;
            }
        }
        return existDuplicate;
    }   
    
    public static Boolean existDuplicateAccount(List<Territory_Sharing_Criterion__c> accountCriteria) {
        if (accountCriteria.isEmpty()) {
            return false;
        }
        Boolean existDuplicate = false;
        String apiName = accountCriteria[0].Field_API_Name__c;
        for (Integer i = 1; i < accountCriteria.size(); i++) {
            if (accountCriteria[i].Field_API_Name__c.equals(apiName)) {
                existDuplicate = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Step 2. Territory criterion is defined twice for ' + apiName));
                break;
            }
        }
        return existDuplicate;
    }
    
    public static Boolean isBlankLeadValue(List<Territory_Sharing_Criterion__c> leadCriteria) {
        Boolean isBlank = false;
        for (Integer i = 0; i < leadCriteria.size(); i++) {
            if (String.isBlank(leadCriteria[i].Field_Value__c)) {
                isBlank = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step 2. Value is blank on criteria for Lead.'));
                break;
            }
        }
        return isBlank;
    }
    
    public static Boolean isBlankAccountValue(List<Territory_Sharing_Criterion__c> accountCriteria) {
        Boolean isBlank = false;
        for (Integer i = 0; i < accountCriteria.size(); i++) {
            if (String.isBlank(accountCriteria[i].Field_Value__c)) {
                isBlank = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step 2. Value is blank on criteria for Account.'));
                break;
            }
        }
        return isBlank;
    }   
    
    public static Boolean isSharingUnique(List<Territory_Sharing_Criterion__c> accountCriteria, List<Territory_Sharing_Criterion__c> leadCriteria, Territory_Sharing__c sharing) {
		
        Boolean isSharingUnique = true;
        List<TerritorySharingWrapper> duplicateSharings = TerritorySharingSelector.getDuplicateSharings(sharing);
        
        for (TerritorySharingWrapper duplicateSharing : duplicateSharings) {
        	
            isSharingUnique = isCriteriaUnique(duplicateSharing.accountCriteria, accountCriteria);
            if (!isSharingUnique) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Sharing detected. Sharing with the same account criteria already exists.'));     
                break;
            }
            
            isSharingUnique = isCriteriaUnique(duplicateSharing.leadCriteria, leadCriteria);
            if (!isSharingUnique) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Sharing detected. Sharing with the same lead criteria already exists.'));     
                break;
            }
        }   
        return isSharingUnique;
    }
    
    private static Boolean isCriteriaUnique(List<Territory_Sharing_Criterion__c>  sourceCriteria, List<Territory_Sharing_Criterion__c> targetCriteria) {
    
        Boolean criteriaTheSame = true;
        
        if (targetCriteria.size() != sourceCriteria.size()) {
            return true;
        }
        
        for (Territory_Sharing_Criterion__c targetCriterion : targetCriteria) {
           	
            if (criteriaTheSame) {
                criteriaTheSame = false;
            	
                for (Territory_Sharing_Criterion__c sourceCriterion : sourceCriteria) {
           			if (sourceCriterion.Field_API_Name__c.equals(targetCriterion.Field_API_Name__c)
                        && sourceCriterion.Operator__c.equals(targetCriterion.Operator__c)
                        && sourceCriterion.Field_Value__c.equals(targetCriterion.Field_Value__c)) {
                            criteriaTheSame = true;   
                            break;
                    } else {
                        criteriaTheSame = false;   
                    }
            	}
            } else {
                break;
            }
        }
        return !criteriaTheSame;
    }
}