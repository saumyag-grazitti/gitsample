public with sharing class as_NewSalesChannelController {
  
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/

    private ptt_cm_Sales_Channel__c SalesChannelObj;  //Object
    ApexPages.StandardController stdController;
    String errorMsg = '';

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    
    public as_NewSalesChannelController(ApexPages.StandardController stdController) {
        this.SalesChannelObj = (ptt_cm_Sales_Channel__c)stdController.getRecord();
        this.stdController = stdController;
    }  
    
    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    /* Save */
    public PageReference doSave() {
        // Check if there is no already existing sales channel for this Account
        String chosenAccId = this.SalesChannelObj.Account_Name__c;
        List<ptt_cm_Sales_Channel__c> salesChannels = [SELECT Id, Name, Account_Name__c FROM ptt_cm_Sales_Channel__c WHERE Account_Name__c = :chosenAccId LIMIT 1];
        if (salesChannels.size() > 0 ) {
            errorMsg = 'Sales channel for this Account already exists, please select another one.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg));
            return null;
        }
        else { 
            StdController.save(); // Standard save action
            // Redirection after save
            PageReference pr = Page.asSalesChannelOverview;
            pr.setRedirect(true);
            return pr;
        }
    }
    
    /* Cancel */
    public PageReference doCancel() {
        // Redirecting back to page SalesChannelOverview
        PageReference pr = Page.asSalesChannelOverview;
        pr.setRedirect(true);
        return pr;
    }   
}