public with sharing class as_editOrderController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    // Constants
    Static final Integer ACTIVATION_COUNTER_LIMIT = 3;
    
    // Variables
    ApexPages.StandardController stdController; // Standard controller
    private ptt_cm_Order__c cmOrderObj = new ptt_cm_Order__c(); //cm Order Object
    List<CM_Selected_Package__c> packagesTableContent = new List<CM_Selected_Package__c>();
    
    private Id endUserId ;
    
    // Automatic get set
    public ptt_cm_End_User__c cmEndUserObj {get; set;} 
    public CM_Selected_Package__c cmPackage {get; set;}
    public Boolean isEdit {get; set;}
    public String selectedPackageId {get; set;}
    public String isCreateLicenseDisabled {get; set;}
    public Integer activePackages {get; set;}

    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    
    public as_editOrderController(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.cmOrderObj = (ptt_cm_Order__c)stdController.getRecord();     
        this.endUserId = cmOrderObj.ptt_End_User__c;
        
        readData();
    }   
    
    /* 
    * Reads data from database. 
    * Made as separate function because after save constructor is not called.
    */ 
    void readData() {
        // Read data from CM End User if user is already specified
        if (endUserId != null) {
        cmEndUserObj = [SELECT Id, Name, ptt_Company_Name__c, ptt_Street__c, ptt_Email__c, ptt_Zip_Postal_Code__c, ptt_Industry__c, ptt_City__c, ptt_Industry_subcategory__c, ptt_State__c, ptt_Country2__c, ptt_CountryISO2__c
                        FROM ptt_cm_End_User__c 
                        WHERE id = :cmOrderObj.ptt_End_User__c];            
        } else {
        	cmEndUserObj = new ptt_cm_End_User__c();
        }           
        
        // Get a list of packages assigned for this order                
        packagesTableContent = [SELECT id, Name, ptt_IsActive__c, ptt_Index__c, ptt_CM_Custom_Package__c, ptt_CM_Custom_Package__r.Name, ptt_CM_Custom_Package__r.ptt_IdCode__c
                        FROM CM_Selected_Package__c
                        WHERE ptt_CM_Order__c = :cmOrderObj.Id
                        ORDER BY Name];                
       
        activePackages = [SELECT COUNT()
                         FROM CM_Selected_Package__c
                         WHERE ptt_CM_Order__c = :cmOrderObj.Id AND ptt_IsActive__c = TRUE ];
        
    }
    
    
    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/

    public List<CM_Selected_Package__c> getPackagesTableContent() {                                      
        return this.packagesTableContent;
    }

    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/

    /* Save */
    public PageReference orderSave() {
        update packagesTableContent;
        updateCmOrder(cmOrderObj);  

        // If user fill in one of reqired fields validate if all has values.
        final String validationError = 'Please fill in all reqired fields.';
        Boolean err = FALSE;
        if ( cmEndUserObj.ptt_Company_Name__c != null || cmEndUserObj.ptt_Street__c != null || cmEndUserObj.ptt_Email__c != null || 
        	 cmEndUserObj.ptt_Zip_Postal_Code__c != null || cmEndUserObj.ptt_City__c != null || cmEndUserObj.ptt_Country2__c != null) {
        	    if (cmEndUserObj.ptt_Company_Name__c == null) {cmEndUserObj.ptt_Company_Name__c.addError(validationError); err = TRUE;}
        		if (cmEndUserObj.ptt_Street__c == null ) {cmEndUserObj.ptt_Street__c.addError(validationError); err = TRUE;}
        		if (cmEndUserObj.ptt_Email__c == null) {cmEndUserObj.ptt_Email__c.addError(validationError); err = TRUE;}
        		if (cmEndUserObj.ptt_Zip_Postal_Code__c == null) {cmEndUserObj.ptt_Zip_Postal_Code__c.addError(validationError); err = TRUE;}
        		if (cmEndUserObj.ptt_City__c == null ) {cmEndUserObj.ptt_City__c.addError(validationError); err = TRUE;}
        		if (cmEndUserObj.ptt_Country2__c == null) {cmEndUserObj.ptt_Country2__c.addError(validationError); err = TRUE;}
        	if (err == TRUE) {return null;}			
        }        
        
        // Insert user data if there is no associated EndUser object yet
        if (endUserId == null) {
            cmEndUserObj.Name = cmOrderObj.Name;
            cmEndUserObj.ptt_CM_Order__c = cmOrderObj.Id;
			cmEndUserObj.ptt_CountryISO2__c = findISO2(cmEndUserObj.ptt_Country2__c);
            insert cmEndUserObj;
            
            cmOrderObj.ptt_End_User__c = cmEndUserObj.Id;
            endUserId = cmEndUserObj.Id;
            updateCmOrder(cmOrderObj);         
  
        }
        // Otherwise update already existing record (record is read in cosntructor to display values on page)
        else if (endUserId != null ) { 
            cmEndUserObj.ptt_CountryISO2__c = findISO2(cmEndUserObj.ptt_Country2__c);    
            update cmEndUserObj;
            updateCmOrder(cmOrderObj);     
        }
        
        readData();      
        this.cmOrderObj.ptt_Activation_Code__c = [SELECT ptt_Activation_Code__c FROM ptt_cm_Order__c WHERE Id = :cmOrderObj.Id].ptt_Activation_Code__c;        
        return null;
    }
    
    /* Back */
    public PageReference orderEditBack() {
        PageReference pr = Page.asSalesChannelDetails;
        pr.getParameters().put('Id', cmOrderObj.ptt_Sales_Channel__c);
        return pr;
    }
    
    /* Create License */
    public PageReference doCreateLicense() {
        // Check if order is active
        if (cmOrderObj.ptt_Is_Active__c == TRUE) {
                // Check if 
                if (cmOrderObj.ptt_Activation_Counter__c > (ACTIVATION_COUNTER_LIMIT-1) ) {     
                String errorMsg = 'Activation limit reached, you can not create more licenses';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
             }
        } else {
            String errorMsg = 'Order is inactive you can not create license';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
        }   
        PageReference pr = Page.asCreateLicense;
        pr.getParameters().put('orderId', cmOrderObj.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    /* Reset */
    public PageReference doResetCounter() {
        PageReference pr = Page.asResetCounter;
        pr.getParameters().put('orderId', cmOrderObj.Id);
        pr.setRedirect(false);
        return pr;
    }
    
    /* Details */
    public PageReference doEditOrderNumbers() {
		orderSave();
		if (ApexPages.hasMessages() == TRUE) {return null;}
        PageReference pr = Page.asEditOrderNumbers;
        pr.getParameters().put('orderId', cmOrderObj.Id);
        return pr;
     }
    
    /* Add */
    public PageReference doAddPackage() {
    	orderSave();
		if (ApexPages.hasMessages() == TRUE) {return null;}
        PageReference pr = Page.asAddCustomPackage;
        pr.getParameters().put('orderId', cmOrderObj.Id);
        return pr;
    }
    
    /*********** Command links **************/
    /*** Actions invoked by comand links ****/
    /****************************************/

    /* Del */
    public PageReference doDeletePackage() {
        Database.Delete(selectedPackageId);
        readData();
        return null;
    }
   
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/
    
    /**
    * Updates Cm Order in case of duplicated SerialNo display error 
    * @since 1.1
    * @param cmOrderObj reference to cmOrder object
    */
    void updateCmOrder(ptt_cm_Order__c cmOrderObj){
        try {
            update cmOrderObj;          
        } catch (exception e) {
            cmOrderObj.ptt_CD_Serial_Number__c.addError('This CD Serial Number is already used, plese check it again.');
        } 
    } 
    
    /**
    * Search for ISO2 code by selected country.
    * @since 1.1
    * @param countryName string with selected country name.
    * @return two letters country ISO code  
    */
    String findISO2(String countryName) {
	    String ISO2 = '';
	    try {
	    	ISO2 = [SELECT pw_cc__IsoCode_2__c FROM pw_cc__CountryObject__c WHERE Name = :countryName].pw_cc__IsoCode_2__c;
	    } catch (exception e) {}  
	    return ISO2;
    }
}