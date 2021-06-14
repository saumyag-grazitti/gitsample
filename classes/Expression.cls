public interface Expression {
    Expression add(Expression expr);
    Expression set(sObject objectToCheckSharing);
    Boolean evaluate();
}