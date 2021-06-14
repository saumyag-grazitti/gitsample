public with sharing class as_NewCustomPackage_Controller {
    
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/

    private CM_Custom_Package__c custPackageObj; //Object for standard controller
    ApexPages.StandardController stdController; // Standard controller
    
    // Variables with default get set methods
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_NewCustomPackage_Controller(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.custPackageObj = (CM_Custom_Package__c)stdController.getRecord();
    }

    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/

    public PageReference doSavePackage() {
        if (isMaterialItemNumerValid() == TRUE) {       
            try{
                insert custPackageObj;
            }
            catch (DmlException e) {
            	if ( e.getMessage().contains('DUPLICATE_VALUE') ) {
            		custPackageObj.ptt_IdCode__c.addError('Number is already used in another package.');
            		return null;
            	} else {
                	ApexPages.addMessages(e);
                	return null;
            	}
            }
            // catch duplicate value error and display it under filed
            
            PageReference pr = Page.asEditCustomPackage;
            pr.getParameters().put('Id', custPackageObj.Id);
            pr.setRedirect(true);
            return pr;         
        } else {
            return null;
        }       
    }
    
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/ 
    
    boolean isMaterialItemNumerValid() {
        // It is now implemented as Validation rule on "CM Custom Package" object.
        return TRUE;
    }
    
}