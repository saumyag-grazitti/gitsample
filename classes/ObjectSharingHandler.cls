/**
 * Created by yanagerasimchuk on 5/30/18.
 */

public with sharing class ObjectSharingHandler {

    private ISharingRecalculation recalculationService;
    private List<sObject> objects;
    private String objectName;
    private String operation;

    public ObjectSharingHandler(List<sObject> objects, String operation) {
        this.objectName = objects[0].getSObjectType().getDescribe().getName();
        this.objects = objects;
		this.operation = operation;
        
        Type t = Type.forName(SharingConstants.SHARING_RECALCULATION_CLASS_BY_OBJECT.get(this.objectName));
        this.recalculationService = (ISharingRecalculation)t.newInstance();
    }

    public void recalculateSharings() {

        List<TerritorySharingWrapper> sharings = getTerritorySharingsToProcess(this.objects);
		Map<Id, List<SharingWrapper>> sharingWrappers = ObjectAndSharingRuleMapper.getSharingRulesForObjects(sharings, this.objects);
   
        if (!sharingWrappers.isEmpty()) {
            if (this.operation == SharingConstants.DELETE_OPERATION) {
                this.recalculationService.removeSharings(sharingWrappers);    
            }
             
            if (this.operation == SharingConstants.ADD_OPERATION) {
                this.recalculationService.addSharings(sharingWrappers);    
            }
        }
    }

    public void recalculateSharings(List<TerritorySharingWrapper> sharings) {

        Map<Id, List<SharingWrapper>> sharingWrappers = ObjectAndSharingRuleMapper.getSharingRulesForObjects(sharings, this.objects);
        
        if (!sharingWrappers.isEmpty()) {
            if (this.operation == SharingConstants.DELETE_OPERATION) {
                this.recalculationService.removeSharings(sharingWrappers);    
            }
             
            if (this.operation == SharingConstants.ADD_OPERATION) {
                this.recalculationService.addSharings(sharingWrappers);    
            }
   		}
    }
   
    private List<TerritorySharingWrapper> getTerritorySharingsToProcess(List<sObject> objects) {
        String query = getTerritorySharingsByBusinessUnitsQuery(objects);
  		List<Territory_Sharing__c> sharings = Database.query(query);
		return TerritorySharingSelector.wrapSharingRulesAndCriteria(sharings);
    }
           
    public String getTerritorySharingsByBusinessUnitsQuery() {
        return getTerritorySharingsByBusinessUnitsQuery(this.objects);
    }
    
    private String getTerritorySharingsByBusinessUnitsQuery(List<sObject> objects) {
        String businessUnitField = SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(this.objectName);
        Set<String> businessUnits = FilterHepler.getBusinessUnits(objects);
        String query = QueryBuilder.getTerritorySharingsByBusinessUnitsQuery(businessUnits);
        return query;
    }
}