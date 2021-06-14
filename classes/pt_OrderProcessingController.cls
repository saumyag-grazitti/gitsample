public with sharing class pt_OrderProcessingController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    // Constants

    // Variables
    private Order_Processing__c OrderProcObj; //Object for standard controller
    ApexPages.StandardController stdController; // Standard controller
    String oppid = '';
    Opportunity oppObj = new Opportunity();
    
    // Variables with default get set methods
    public Account accountObj { get; set; } 
    public boolean addressRead { get; set; } 
    public boolean showAllSections { get; set; }
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/

    public pt_OrderProcessingController(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.OrderProcObj = (Order_Processing__c)stdController.getRecord();
        oppid = ApexPages.currentPage().getParameters().get('oppid');
        addressRead = FALSE;
        
        if (oppid != null) {
            oppObj = [SELECT Id, AccountId, sf42_gl_Contact__c, CurrencyIsoCode, Amount  FROM Opportunity WHERE id = :oppid];
            OrderProcObj.Opportunity__c = oppObj.Id;
            OrderProcObj.Account__c = oppObj.AccountId;
            OrderProcObj.Contact__c = oppObj.sf42_gl_Contact__c;
            OrderProcObj.CurrencyIsoCode = oppObj.CurrencyIsoCode;
            OrderProcObj.sf42_JP_Order_Amount__c = oppObj.Amount;
            doReadAccountAddresses();
        }
        
        if ([SELECT sf42_Business_Unit__c FROM User Where Id = :Userinfo.getUserId()].sf42_Business_Unit__c == 'Spain') {
             showAllSections = TRUE;
        } 
    }
    
    /********** Immediate actions ***********/
    /***** Actions executed on page load ****/
    /****************************************/
       
    
    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
    
    
    /************* Setters *****************/
    /***** Reading values from field *******/
    /***************************************/

    
    
    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    public PageReference doReadAccountAddresses() {
        String AccountId = OrderProcObj.Account__c;
        // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, AccountId));
        if (AccountId != null) {
            accountObj = [SELECT Id, ptt_tax_number__c, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode, ShippingCity, ShippingCountry, ShippingState, ShippingStreet, ShippingPostalCode
                          FROM Account 
                          WHERE Id = :AccountId];
            addressRead = TRUE;
            OrderProcObj.ptt_Tax_number__c = accountObj.ptt_tax_number__c;
        }
        return null;
    }
    
    public PageReference opSave() {
        /*if(addressRead == TRUE) {
                accountObj.dupcheck__dc3DisableDuplicateCheck__c = TRUE;
            update accountObj;
        }*/
        upsert OrderProcObj;
        PageReference pr = new PageReference('/' + OrderProcObj.Id );
        pr.setRedirect(true);
        return pr;
        
    }
    
    
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/
    


}