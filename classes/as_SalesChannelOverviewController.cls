public with sharing class as_SalesChannelOverviewController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/ 
    ApexPages.StandardController stdController;
    List<ptt_cm_Sales_Channel__c> filteredList;
    static List<ptt_cm_Order__c> filteredCmOrdersList = new List<ptt_cm_Order__c>();
    public Boolean orderTableRendered {get; set;}
    public Boolean sChannelTableRendered {get; set;}

    // Automatic get set
    public String searchName {get; set;}
    public String activationCode {get; set;}
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    
    public as_SalesChannelOverviewController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        searchName = '';
        activationCode = '';
        orderTableRendered = FALSE;
        SChannelTableRendered =  TRUE;
    }

    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/

    /* Sales Channell table */
    public List<ptt_cm_Sales_Channel__c> getScTableContent () {
        if (searchName.length() == 0 && activationCode.length() == 0) {
            filteredList = [SELECT id, Name, ptt_Business_Unit__c, ptt_remote_access__c, Account_Name__r.Name  
                            FROM ptt_cm_Sales_Channel__c 
                            ORDER BY Name ASC];
        }
        return filteredList;
    }
    /* Orders table */
    public List<ptt_cm_Order__c> getOrdersTableContent () {
 			return filteredCmOrdersList;
    }
    
    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    /* New Sales Channel */
    public PageReference doCreateNewSalesChannel() {       
        PageReference pr = Page.asNewSalesChannel;
        pr.setRedirect(true);
        return pr;
    }
     
    /* Filter SCName */   
    public PageReference doFilter() {
    	// Escape single quotes to prevent SQL Injection
    	activationCode = '';
        searchName = String.escapeSingleQuotes(searchName);
        activationCode = String.escapeSingleQuotes(activationCode);
        
        if (searchName != '' || searchName != null) {   
	        String queryText = searchName.replace('*','%');
	        filteredList = [SELECT id, Name, ptt_Business_Unit__c, ptt_remote_access__c, Account_Name__r.Name 
	                        FROM ptt_cm_Sales_Channel__c 
	                        WHERE Name LIKE :queryText ORDER BY Name ASC];
	    
	        orderTableRendered = FALSE;
	        SChannelTableRendered = TRUE;
        }
        return null;
    }
    
    /* All SCNames */
    public PageReference doShowAll() {
        searchName = '';
        activationCode = '';
        filteredList = [SELECT id, Name, ptt_Business_Unit__c, ptt_remote_access__c, Account_Name__r.Name 
                        FROM ptt_cm_Sales_Channel__c 
                        ORDER BY Name ASC];
       
        orderTableRendered = FALSE;
        SChannelTableRendered = TRUE;
        return null;
    }
    
    /* Filter Activation Codes */  
    public PageReference doFilterActCode() {
    	searchName = '';
    	// Escape single quotes to prevent SQL Injection
    	searchName = String.escapeSingleQuotes(searchName);
        activationCode = String.escapeSingleQuotes(activationCode);

        if (activationCode != '') {
        	String acodeQuery = activationCode.replace('*','%');

        	// Search for order with given Activation code
        	filteredCmOrdersList.addAll(
        		[SELECT Id, name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Sales_Channel__c, ptt_Sales_Channel__r.Name, ptt_CD_Serial_Number__r.Name, ptt_Is_Active__c
                 FROM ptt_cm_Order__c WHERE ptt_Activation_Code__c LIKE :acodeQuery]);

			orderTableRendered = TRUE;
			SChannelTableRendered = FALSE;
        } else {
			doShowAllActCodes();
        }
        return null;
    }
    
    /* All Activation Codes */
    public PageReference doShowAllActCodes() {
        searchName = '';
        activationCode = '';

        filteredCmOrdersList.addAll(
        		[SELECT Id, name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Sales_Channel__c, ptt_Sales_Channel__r.Name, ptt_CD_Serial_Number__r.Name, ptt_Is_Active__c
                 FROM ptt_cm_Order__c ]);
        	                     
        orderTableRendered = TRUE;
        SChannelTableRendered = FALSE;
        return null;
    }

}