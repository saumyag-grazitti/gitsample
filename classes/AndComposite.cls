public class AndComposite extends Composite {
   
    public override Boolean evaluate(){

        if (this.children.isEmpty()) {
            return false;
        }

        for(Expression expr : this.children) {
            
            if(!expr.evaluate()) {
                return false;
            }
        }

        return true;
    }
}