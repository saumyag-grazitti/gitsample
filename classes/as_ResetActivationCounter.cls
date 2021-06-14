public with sharing class as_ResetActivationCounter {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    
    // Variables
    private String orderId = '';
    private ptt_cm_Order__c cmOrderObject;
    private Integer oldActivationValue = 0;
        
    // Variables with default get set methods
    public String CommentText { get; set; }
    public String orderName { get; set; }

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    
    public as_ResetActivationCounter() {
        orderId = ApexPages.currentPage().getParameters().get('orderid');
        cmOrderObject = [SELECT Name, ptt_Activation_Counter__c, ptt_Sales_Channel__r.Account_Name__c FROM ptt_cm_Order__c WHERE Id = :orderId];
        orderName = cmOrderObject.Name;
        oldActivationValue = Integer.ValueOf (cmOrderObject.ptt_Activation_Counter__c);
    }

    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
     
    /* Reset */
    public PageReference doReset() {
        if (CommentText == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Comment field cannot be empty'));
            return null;
        } else {
        
            // Set activation counter to 0
            cmOrderObject.ptt_Activation_Counter__c = 0;
            update cmOrderObject;
        
            // Create Log entry
            CM_Activation_Log__c alog = new CM_Activation_Log__c();
            alog.ptt_Account__c =  cmOrderObject.ptt_Sales_Channel__r.Account_Name__c;
            alog.ptt_do_Reset__c = TRUE;
            alog.ptt_Activation__c = oldActivationValue;
            alog.ptt_cm_Order__c = OrderId;
            alog.ptt_Comment__c = CommentText;                                         
            insert alog;
     
            PageReference pr = Page.asEditOrder;
            pr.getParameters().put('Id', orderId);
            pr.setRedirect(false);
            return pr;
        }
    }    

    /* Back */
    public PageReference Back() {
        PageReference pr = Page.asEditOrder;
        pr.getParameters().put('Id', orderId);
        pr.setRedirect(false);
        return pr;
    }
}