public with sharing class TerritorySharingRecalculation {

	public List<TerritorySharingWrapper> territorySharings { get; set;}
    
    private ISharingRecalculation recalculationService;
    private String criteriaToProcess;
    private String objectName;
	private String operation;

    public TerritorySharingRecalculation(List<TerritorySharingWrapper> sharings, String criteriaToProcess, String operation) {
        this.objectName = SharingConstants.OBJECT_BY_CRITERIA_TYPE.get(criteriaToProcess);
        this.criteriaToProcess = criteriaToProcess;
        this.operation = operation;
        this.territorySharings = sharings;

        Type t = Type.forName(SharingConstants.SHARING_RECALCULATION_CLASS_BY_OBJECT.get(this.objectName));
        this.recalculationService = (ISharingRecalculation)t.newInstance();
    }
    
    public String getObjectsQuery() {
        return QueryBuilder.getObjectsThatMeetTerritoryCriteriaQuery(this.objectName, this.territorySharings);
    }

    public void recalculateSharings(List<sObject> objects) {
        
        Map<Id, List<SharingWrapper>> sharings = ObjectAndSharingRuleMapper.getSharingRulesForObjects(this.territorySharings, objects);
            
		if (this.operation == SharingConstants.DELETE_OPERATION) { 
        	this.recalculationService.removeSharings(sharings);
		}

        if (this.operation == SharingConstants.ADD_OPERATION) {
            this.recalculationService.addSharings(sharings);
		}
    }
}