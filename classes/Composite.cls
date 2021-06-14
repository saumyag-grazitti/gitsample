public abstract with sharing class Composite implements Expression {
   
    public List<Expression> children { get; private set; } 
    public Boolean hasChildren { get { return !children.isEmpty();} }
    
    public Composite() { 
        this.children = new List<Expression>(); 
    }
    
    public Expression add(Expression expr){
        this.children.add(expr);
        return this;
    }
    
    public Expression set(sObject objectToCheckSharing){
        
        for(Expression expr : this.children) {
            expr.set(objectToCheckSharing);
        }
        return this;
    }
    
    public abstract Boolean evaluate();
}