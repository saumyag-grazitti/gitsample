public with sharing class TerritorySharingSelector {
    
    public static List<TerritorySharingWrapper> getDuplicateSharings(Territory_Sharing__c sharing) {
        
        Map<Id, Territory_Sharing__c> duplicateSharings =  new Map<Id, Territory_Sharing__c>([
            SELECT Id, (
            		SELECT Id, RecordType.DeveloperName, Territory_Sharing__c, Field_API_Name__c, Operator__c, Field_Value__c
                    FROM Territory_Sharing_Criteria__r
                    ORDER BY CreatedDate ASC
                    LIMIT 20
            	)
            FROM Territory_Sharing__c
            WHERE (Business_Unit__c = :sharing.Business_Unit__c  AND
                   Group_Id_To_Share_Record_With__c = :sharing.Group_Id_To_Share_Record_With__c) 
            LIMIT 1000
        ]);
        
        if (sharing.Id != null) {
			duplicateSharings.remove(sharing.Id);
        }
        return wrapSharingRulesAndCriteria(duplicateSharings.values());
    }
    
    public static List<TerritorySharingWrapper> getTerritorySharingsWithCriteria(Map<Id, Territory_Sharing__c> sharings) {
        
        List<TerritorySharingWrapper> sharingWrappers = new List<TerritorySharingWrapper>();
       
        for (Territory_Sharing__c sharing : [
            SELECT ID, Name,
                (
                    SELECT Id, RecordType.DeveloperName, Territory_Sharing__c, Field_API_Name__c, Operator__c, Field_Value__c
                    FROM Territory_Sharing_Criteria__r
                    ORDER BY CreatedDate ASC
                    LIMIT 20
                )
            FROM Territory_Sharing__c
            WHERE ID IN :sharings.keySet()
            LIMIT 10000
        ]) { 
            sharingWrappers.add(new TerritorySharingWrapper(sharings.get(sharing.Id), sharing.Territory_Sharing_Criteria__r));
        }
        return sharingWrappers;
    }

    public static List<Territory_Sharing_Criterion__c> getTerritorySharingCriteria(Id sharingId, String criteriaName) {

        return [
            SELECT Id, RecordType.DeveloperName, Territory_Sharing__c, 
                Field_API_Name__c, Operator__c, Field_Value__c
            FROM Territory_Sharing_Criterion__c
            WHERE (RecordType.DeveloperName = :criteriaName
                AND  Territory_Sharing__c = :sharingId)
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
    }
    
    public static TerritorySharingWrapper getSharingById(Id sharingId) {
        
        Territory_Sharing__c sharing = [
            SELECT ID, Name,Business_Unit__c , Group_Id_To_Share_Record_With__c,
                    Account_Access_Level__c, Lead_Access_Level__c, Case_Access_Level__c, Contact_Access_Level__c,
                    Opportunity_Access_Level__c, Device_Access_Level__c, Services_Demos_Access_Level__c, Activity_Access_Level__c,
                (
                    SELECT Id, RecordType.DeveloperName, Territory_Sharing__c, Field_API_Name__c, Operator__c, Field_Value__c
                    FROM Territory_Sharing_Criteria__r
                    ORDER BY CreatedDate ASC
                    LIMIT 20
                )
            FROM Territory_Sharing__c
            WHERE ID = :sharingId
            LIMIT 1
        ];
        
        return new TerritorySharingWrapper(sharing, sharing.Territory_Sharing_Criteria__r);
    }
    
    public static List<TerritorySharingWrapper> getTerritorySharingsByBusinessUnitAndGroupId(String businessUnit, String groupId) {

        List<TerritorySharingWrapper> sharings = new List<TerritorySharingWrapper>();
        
        for(Territory_Sharing__c sharing : [
                SELECT Id, Name, Business_Unit__c , Group_Id_To_Share_Record_With__c, 
                    Account_Access_Level__c, Lead_Access_Level__c, Case_Access_Level__c, Contact_Access_Level__c,
                    Opportunity_Access_Level__c, Device_Access_Level__c, Services_Demos_Access_Level__c, Activity_Access_Level__c,
                (
                    SELECT Id, RecordType.DeveloperName, Territory_Sharing__c, Field_API_Name__c, Operator__c, Field_Value__c
                    FROM Territory_Sharing_Criteria__r 
                    ORDER BY CreatedDate ASC
                    LIMIT 20
                )
                FROM Territory_Sharing__c
                WHERE (Business_Unit__c = :businessUnit
                    AND Group_Id_To_Share_Record_With__c = :groupId)
                LIMIT 200
        ] ) {
            sharings.add(new TerritorySharingWrapper(sharing, sharing.Territory_Sharing_Criteria__r));
        }
        return sharings;
    }
    
    public static List<TerritorySharingWrapper> wrapSharingRulesAndCriteria(List<Territory_Sharing__c> sharings) {
        
        List<TerritorySharingWrapper> sharingWrappers = new List<TerritorySharingWrapper>();

		for (Territory_Sharing__c sharing : sharings) {
			sharingWrappers.add(new TerritorySharingWrapper(sharing, sharing.Territory_Sharing_Criteria__r));
		}
        return sharingWrappers;
    }
}