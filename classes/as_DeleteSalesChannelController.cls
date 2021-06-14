public with sharing class as_DeleteSalesChannelController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/

    private ptt_cm_Sales_Channel__c SalesChannelObj;  //Object
    ApexPages.StandardController stdController;
    String errorMsg = '';
    boolean hasOrders = null;
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/

    public as_DeleteSalesChannelController(ApexPages.StandardController stdController) {
        this.SalesChannelObj = (ptt_cm_Sales_Channel__c)stdController.getRecord();
        this.stdController = stdController;
        
        hasOrders = checkIfHasOrders (SalesChannelObj.Id);
        if (hasOrders == true) {
            errorMsg = 'This Sales Channel has orders assigned, you cannot delete it.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
        }      
    }
    
    /*************** Getters ****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
       
    // Disable delete button when has SC Orders
    public String getdelDisabled () {
        if (checkIfHasOrders(SalesChannelObj.Id) == true) {
           return 'true';
        }
        return 'false';
    }
    
    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/

    /* Back */
    public PageReference doCancel() {
        // Redirecting back to page SalesChannelOverview
        PageReference pr = Page.asSalesChannelOverview;
        pr.setRedirect(true);
        return pr;
    }
    
    /* Yes, I want to delete it */
    public PageReference deleteRecord() {
        // If there is 0 related orders allow to delete.           
        if (checkIfHasOrders(SalesChannelObj.Id) == false) {
            delete SalesChannelObj;
            // Redirecting back to page SalesChannelOverview
            PageReference pr = Page.asSalesChannelOverview;
            pr.setRedirect(true);
            return pr;
        } 
        return null; 
    }
    
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/   
    
    // Check if Sales Channel has any orders
    public boolean checkIfHasOrders (String scId) {
        Integer scOrdersCount = [SELECT count() FROM ptt_cm_Order__c WHERE  ptt_cm_Order__c.ptt_Sales_Channel__c = :scId];
        if (scOrdersCount > 0) { return true; }
        return false;
    }
}