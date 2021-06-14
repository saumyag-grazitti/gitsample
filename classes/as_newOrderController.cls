public with sharing class as_newOrderController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    private ptt_cm_Order__c cmOrderObj; //cm Order Object  
    private ptt_cm_End_User__c cmEndUser = new ptt_cm_End_User__c();
   // ApexPages.StandardController stdController; // Standard controller
    String scId = ApexPages.currentPage().getParameters().get('scId');
    List<ptt_cm_Order__c> allOrders = new List<ptt_cm_Order__c>();
    
    // Automatic get set
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_newOrderController(ApexPages.StandardController stdController) {
        if (scId == '' || scId == null) {
        	String errorMsg = 'No SalesChannel Id provided.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
        } else {
	     //   this.stdController = controller;
	        cmOrderObj = (ptt_cm_Order__c)stdController.getRecord(); 
	        cmOrderObj.ptt_Sales_Channel__c = scId;
	        cmOrderObj.ptt_Activation_Counter__c = 0;
    	}
    }
    
    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
    

    /************* Setters *****************/
    /***** Reading values from field *******/
    /***************************************/
    

    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    // Order section
    
    /* Save */
    public PageReference orderSave() {
        if (cmOrderObj.ptt_System__c == 'Calimaster' && cmOrderObj.ptt_Activation_Code__c == null) {
            cmOrderObj.ptt_Activation_Code__c.addError('Please enter Activation Code manually');
            return null;      
        } else
        if (cmOrderObj.ptt_Variant__c == null) {
            cmOrderObj.ptt_Variant__c.addError('Please select Variant');
            return null;
        } else {
            // Redirection
            PageReference pr = Page.asEditOrder;
            try {
                insert cmOrderObj;
                pr.getParameters().put('Id', cmOrderObj.Id);
                // Create enduser object connected to this order.
                cmEndUser.Name = [SELECT Name FROM ptt_cm_Order__c WHERE Id = :cmOrderObj.Id].Name;
                cmEndUser.ptt_CM_Order__c = cmOrderObj.Id;
                insert cmEndUser;
                cmOrderObj.ptt_End_User__c = cmEndUser.Id;
                update cmOrderObj; 
                return pr;       
            } catch (System.DmlException e) {
                if (e.getMessage().contains('DUPLICATE_VALUE')) {
                	cmOrderObj.ptt_CD_Serial_Number__c.addError('This CD Serial Number is already used, plese check it again.');
                }
                else {
                	cmOrderObj.ptt_CD_Serial_Number__c.addError(e);
                }
                return null;
            }
        }
    }
    
    /* Back */
    public PageReference orderBack() {
        PageReference pr = Page.asSalesChannelDetails;
        pr.getParameters().put('Id', scId);
        return pr;
    }  
    
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/

}