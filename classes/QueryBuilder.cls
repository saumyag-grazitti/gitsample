public with sharing class QueryBuilder {
    
    public static String getTerritorySharingsByBusinessUnitsQuery(Set<String> businessUnits) {

        String subQueryPattern = 'SELECT RecordType.DeveloperName, {0} FROM Territory_Sharing_Criteria__r LIMIT 20';
        String queryPattern = 'SELECT {0}, ({1}) FROM Territory_Sharing__c WHERE Business_Unit__c IN (\'\'{2}\'\') LIMIT 100000';

        List<String> territorySharingFields = SharingSettingsHelper.getAllFieldsAPINamesByObjectName(SharingConstants.TERRITORY_SHARING_OBJECT_NAME);
        List<String> criteriaFields = SharingSettingsHelper.getAllFieldsAPINamesByObjectName(SharingConstants.SHARING_CRITERIA_OBJECT_NAME);
      	List<String> businessUnitsList = new List<String>();
        businessUnitsList.addAll(businessUnits);

        String subQuery = String.format(subQueryPattern, new List<String> {
                String.join(criteriaFields, ',')
        });

        return String.format(queryPattern, new List<String> {
                String.join(territorySharingFields, ','),
                subQuery,
                String.join(businessUnitsList, '\',\'')
        });
    }
    
    public static String getObjectsThatMeetTerritoryCriteriaQuery(String objectName, List<TerritorySharingWrapper> sharings) {
     
        String queryPattern = 'SELECT {0} FROM {1} WHERE {2} LIMIT 100000';
        String whereConditions = getWhereConditionsStr(objectName, sharings); 

        return String.format(queryPattern, new List<String> {
                String.join(SharingSettingsHelper.getFieldsToProcessByObjectName(objectName), ','),
                objectName,
                whereConditions
        });    
    }
    
    private static String getWhereConditionsStr(String objectName, List<TerritorySharingWrapper> sharings) {
        
        String equalsCondPattern = '{0} = \'\'{1}\'\'';
        String likeCondPattern = '{0} LIKE \'\'{1}%\'\'';
        String inCondPattern = '{0} IN (\'\'{1}\'\')';
        
        String businessUnitFieldAPIName = SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(objectName);
        List<String> whereConditions = new List<String>();
        
        for (TerritorySharingWrapper sharingWrapper : sharings) {
            
            List<String> conditions = new List<String>();           
            conditions.add(String.format(equalsCondPattern, new List<String>{businessUnitFieldAPIName, sharingWrapper.sharing.Business_Unit__c}));
         
            for (Territory_Sharing_Criterion__c criterion : sharingWrapper.getCriteriaByObjectName(objectName)) {
                
                if (String.isNotBlank(criterion.Field_Value__c)) {

                    String operator = SharingConstants.LOGICAL_OPERATOR_BY_OPERATION.get(criterion.Operator__c);
                    
                    if (operator == 'LIKE') {
                        
                        List<String> likeConditions = new List<String>();
                        
                        for (String fieldValue : OperatorHelper.getFieldValuesForQuery(criterion.Field_Value__c)) {
                        	likeConditions.add(String.format(likeCondPattern, new List<String>{criterion.Field_API_Name__c, fieldValue}));
                        }
                    	conditions.add('(' + String.join(likeConditions,' OR ') + ')');
                    }
                    
                    if (operator == 'IN') {
                        List<String> fieldValues = OperatorHelper.getFieldValuesForQuery(criterion.Field_Value__c);
                        conditions.add(String.format(inCondPattern, new List<String>{criterion.Field_API_Name__c, String.join(fieldValues, '\',\'')}));
                    }   
                }
            }
            whereConditions.add('(' + String.join(conditions,' AND ') + ')');
        }
        
        return !whereConditions.isEmpty() ? String.join(whereConditions, ' OR ') : ' ';
    }
    
    public static sObject getParentObjectDetailsById(String objectName, Id objectId) {
        
        Set<String> childObjects = SharingConstants.ACCOUNT_LOOKUP_FIELD_BY_CHILD_OBJECT.keySet();
        String pattern = 'SELECT Id, OwnerId, {0} FROM {1} WHERE Id = \'\'{2}\'\' LIMIT 1';
        String objName = objectname;
        String objId = objectId;
        
 		if (childObjects.contains(objectName)) { //if it's child record we get take account id lookup
       		objName = SharingConstants.ACCOUNT_OBJECT;
            objId = getAccountIdByChildObjectId(objectName, objectId);
		}
        
		String query = String.format(pattern, new List<String>{
        		String.join(SharingSettingsHelper.getFieldsToProcessByObjectName(objName), ','), 
                objName,
                objId
		});
        
        return Database.query(query);
    }
    
    private static Id getAccountIdByChildObjectId(String objectName, Id objectId) {
         
        String accountLookupField = SharingConstants.ACCOUNT_LOOKUP_FIELD_BY_CHILD_OBJECT.get(objectName);
        String pattern = 'SELECT Id, {0} FROM {1} WHERE Id = :objectId LIMIT 1';
        String query = String.format(pattern, new List<String>{
            accountLookupField, 
            objectName
        });
        
		sObject childObj = Database.query(query);
        System.debug(childObj);
        return (Id)childObj.get(accountLookupField);
    }
}