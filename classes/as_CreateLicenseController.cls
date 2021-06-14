public class as_CreateLicenseController {
    
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    
    // Constants
    //static final String BASE_URL = 'https://smtp.pruftechnik-cm.com:8443/com.pruftechnik.rcm.server.keygenerator';
    static final String BASE_URL = 'https://smtp.pruftechnik-cm.com:8444/com.pruftechnik.rcm.server.keygenerator';
    
    static final String AUTH_PATH = '/authenticate';
    static final String LICENSE_PATH = '/license-generator';

    static final String AUTH_SUCCESS_MESSAGE = 'message_key_values'; // span ID name which contains message
    static final String AUTH_SUCCESS_MESSAGE_VALUE = 'get a licens'; // string which indicate that we can continue to licese download
    
    // Variables
    
    //static String username = 'activation-server-production';
    //static String password = 'xt8zxfhecit1r4pyyvrygov3';
     
    //static String username = 'activation-server';
    //static String password = 'aqkg1cho68vp5lrzgkensahw';
 
    static String username = 'activation-server-ptsandbox';
    static String password = 'GYGMzQaytvHcSq9Q5pZ7YpRr';   
    
    
    
    private ptt_cm_Order__c cmOrderObject;
    private ptt_cm_End_User__c endUserObject = new ptt_cm_End_User__c();
    private List<CM_Selected_Package__c > activePackagesList = new List<CM_Selected_Package__c >();
    private ptt_cm_Sales_Channel__c salesChannel = new ptt_cm_Sales_Channel__c();
    
    private String orderId = '';
    private String errorMsg = '';
 
    private String authenticateURL = BASE_URL + AUTH_PATH;
    private String authenticateParams = 'user=' + username + '&pwd=' + password; 
    private String licenseURL = '';
    private String licenseParams = '';
   
    private String tan = '', license = '', enduser = '', packages = '';
    private Integer tanindex = 0;
    
    private cm_tan_List__c cmTan2 = new cm_tan_List__c();
    //Map<String,String> cmTan2 = new Map<String,String>();
        
    // Variables with default get set methods
    public String CommentText { get; set; }
    public String orderName { get; set; }
    public boolean hasAnyStoppers { get; set; } 
    public Id attDlID { get; set; }
    public String attDlName { get; set; } 
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_CreateLicenseController() {
       
        // Extract id from parameter
        orderId = ApexPages.currentPage().getParameters().get('orderid');
        if (orderId != null && orderId != '') {
            hasAnyStoppers = FALSE;
            
            cmOrderObject = [SELECT Id, Name, ptt_Is_Active__c, ptt_Activation_Code__c, ptt_End_User__c, ptt_Activation_Counter__c, ptt_Sales_Channel__c, ptt_ProductID__c, ptt_Sales_Channel__r.Account_Name__c
                             FROM ptt_cm_Order__c 
                             WHERE Id = :orderId];
                             
            // Get Active packages for this object
            activePackagesList = [SELECT Id, ptt_Index__c, ptt_IsActive__c, ptt_CM_Custom_Package__c 
                                  FROM CM_Selected_Package__c 
                                  WHERE ptt_CM_Order__c = :orderId AND ptt_IsActive__c = TRUE ];
           
            // Pass order name to page.        
            orderName = cmOrderObject.name;
    
            // Check if order is active and did not reached maximum activation limit
            if (cmOrderObject.ptt_Is_Active__c == FALSE) {
                hasAnyStoppers = TRUE;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order is not active, you can not create license.'));
            }
            else if (cmOrderObject.ptt_Activation_Counter__c > 2) {
                hasAnyStoppers = TRUE;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order reached maximum activation limit'));
            }
            else if (cmOrderObject.ptt_Activation_Code__c == null || cmOrderObject.ptt_End_User__c == null) {
                hasAnyStoppers = TRUE;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order is missing important informations.'));
            } 
            else if (activePackagesList.size() < 1) {
                hasAnyStoppers = TRUE;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order do not have any active packagaes'));
            }
            else { // Load data which are needed to create license
                   
                // Get end user record which is connected to this order    
                endUserObject = [SELECT Id, Name, ptt_Company_Name__c, ptt_City__c, ptt_CM_Order__c, ptt_Country2__c, ptt_CountryISO2__c, ptt_Email__c, ptt_Industry__c, ptt_Industry_subcategory__c, ptt_State__c, ptt_Street__c, ptt_Zip_Postal_Code__c 
                                 FROM ptt_cm_End_User__c 
                                 WHERE Id = :cmOrderObject.ptt_End_User__c];   
                                 
                salesChannel = [SELECT id, Account_Name__c 
                                FROM ptt_cm_Sales_Channel__c 
                                WHERE Id =: cmOrderObject.ptt_Sales_Channel__c];        
            }
            
            // Create Packages parameter value
            try {
                String packages = as_licenseGenerator.generatePackagesParameterValue(orderId);
            } catch (as_Exceptions.licGenException ex) { 
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ex.getDetails()));
                hasAnyStoppers = TRUE;
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Missing OrderId Parameter'));
            hasAnyStoppers = TRUE;
        }
        
    } 
    
    /********** Immediate actions ***********/
    /***** Actions executed on page load ****/
    /****************************************/
    
    /* Get the valid TAN and select it as used */
    public void obtainTan() {
    	this.cmTan2 = as_licenseGenerator.getTransactionTan();
    }
    
    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    /* Create */
    public PageReference CreateLic() {
    //	try { 
	        if (CommentText == '') {
	            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Comment field cannot be empty'));
				return null;
	        } else {
	            Http httpConnection = new Http(); // Http connection.
	            String fileURL = ''; 
	            Attachment att = new Attachment(); 
	            Map<String,String> licenseURL = as_licenseGenerator.getLicenseUrl(cmOrderObject, cmTan2.Id); 

	            if (hasAnyStoppers == FALSE &&  packages != null) {
                    httpConnection = as_licenseGenerator.authenticateToKGServer();
System.debug('@@ Before KG error.');
                    att = as_licenseGenerator.askForLicense(httpConnection, cmOrderObject, CommentText );
System.debug('@@ After KG error.');
                    // Redirect to filedownload.
                    fileURL = '/servlet/servlet.FileDownload?file=' + att.Id;
                    attDlId = att.Id;
                    attDlName = att.Name;
                    hasAnyStoppers = TRUE;
		        }
           } 
/*   	  }
		catch (as_Exceptions.licGenException ex) {
	  	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, ex.GetMessage() + ' ' + ex.getDetails()));
	  // 	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, ex.getDetails()));
  		hasAnyStoppers = TRUE;
  		return null;
    	} 
	*/ 	
        return null;
    }
    
    /*Back */
    public PageReference Back() {
        PageReference pr = Page.asEditOrder;
        pr.getParameters().put('Id', orderId);
        pr.setRedirect(false);
        return pr;
    }
    
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/ 
    
    /**
    * Reads error message send by KeyGenerator in http response and
    * transform it to Salesforce apex:pageMessages format
    * @param response - http respnse after server call
    */
    void displayKeyGenError (HttpResponse response) {
        String errorMsg = '';
        String detail = '';
           
        String responseBody = response.getBody();
                                       
        String message_type = ptt_VFControllerHelper.extractValueFromId(responseBody, 'message_type');            
        String message_description = ptt_VFControllerHelper.extractValueFromId(responseBody, 'message_description'); 
        String message_key = ptt_VFControllerHelper.extractValueFromId(responseBody, 'message_key'); 
        String message_key_values = ptt_VFControllerHelper.extractValueFromId(responseBody, 'message_key_values'); 
       
        errorMsg = 'An error occurred: <b>' + message_key + '</b><br/>Message: <b>' + message_description +'</b>';
        // detail = '<br/>BODY: ' + response.getHeaderKeys() + 'Content-Disposition: ' + response.getHeader('Content-Disposition') + ' Content-Type: ' + response.getHeader('Content-Type');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg, detail));
    }
    
}