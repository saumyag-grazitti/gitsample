public with sharing class Variable implements Expression {
     
    private sObject objectToCheckSharing;
    private Territory_Sharing_Criterion__c criterium;
    private String classToProcessOperation; 
        
    public Variable(Territory_Sharing_Criterion__c criterium){ 
        this.criterium = criterium; 
        this.classToProcessOperation = SharingConstants.OPERATION_CLASS_BY_OBJECT.get(this.criterium.Operator__c);
    }

    public Expression add(Expression expr){ 
        return this; 
    }
    
    public Expression set(SObject objectToCheckSharing){ 
        this.objectToCheckSharing = objectToCheckSharing;
		return this; 
    }
    
	public Boolean evaluate() { 
        
        if (String.isNotBlank(this.classToProcessOperation) && this.objectToCheckSharing != null)  {
            Type t = Type.forName(this.classToProcessOperation);
        	IOperator operator = (IOperator)t.newInstance();
        	return operator.isMatchCriterion(this.objectToCheckSharing, this.criterium);    
        }
        return false;
    }
}