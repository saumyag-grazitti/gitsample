public class as_vibguardInterface_controller {   
  
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    // Constants
    static String VIB_USER_NAME = 'vibguardviewer';
    static String VIB_PASSWORD = '4kui5sd4fsd4fwe181';

    // Variables
    String user, pwd, license, actcode;
    String company, street, zip, city, state, country, email, industry, tanid; 
    static ptt_cm_Order__c orderDetails = new ptt_cm_Order__c();
   // Map<String,String> licFileDetails = new Map<String,String>();
    // static Map<String,String> tanValue = new Map<String,String>{};

    // Variables with default get set methods
    public String asErrorMessage { get; set; }
    public Boolean showFileLink { get; set; }
    public Attachment licFile { get; set; }

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
   
    public as_vibguardInterface_controller() {  
        asErrorMessage = '';
        // Read all parameters.
        user = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('user'));
        pwd = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('pwd'));      
        
        license = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('license'));
        actcode = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('actcode'));
        
        tanid = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('tid'));
    
        // Find Order details for given Activation Code.
        try {    
            orderDetails = [SELECT Id, ptt_End_User__c, ptt_Sales_Channel__r.ptt_remote_access__c, ptt_Sales_Channel__c, ptt_Activation_Code__c
                            FROM ptt_cm_Order__c  
                            WHERE ptt_Activation_Code__c = :actcode LIMIT 1];
        }
        catch (exception e) {
              as_licenseGenerator.asErrorMessage ('ACTIVATION_CODE_NOT_FOUND', 'Order with given Activation code not found.');  
        }
    }
    
    /********** Immediate actions ***********/
    /***** Actions executed on page load ****/
    /****************************************/  
    
    /**
    *  Main program
    */
    public PageReference doGenerateLicense() {
	    try {  
	        if (verifyVibLogin(user, pwd) == TRUE && asErrorMessage == '') {
	            if(reqiredParametersSent() == TRUE) {      
	                   licFile = as_licenseGenerator.createLicense(orderDetails.Id, tanid, 'License request from vibguard viewer.');
	                   System.debug('@@ lic file retrived: ' + licFile);
	                   if (licFile.Id != null ) { //&& licFile.Id  != '') {
	                       showFileLink = TRUE;      
	                       return null;
	                   } else {
	                       throw new as_Exceptions.licGenException ('DID_NOT_GET_LICENSE_FILE', 'License file not retrivied.');             
	                   }                                    
	            }
	        }
	        return null;
	    }
	    catch (as_Exceptions.licGenException ex) {
	        as_licenseGenerator.asErrorMessage (ex.getMessage(), ex.getDetails());
	        return null;
	    } 
    }
    

    
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/
          
    /**
    *  Check if license, actcode parameters are not empty
    *  @return FALSE when any of them empty, TRUE when all contains data
    */
    boolean reqiredParametersSent () {
        if( license == null || license == '' || actcode == null || actcode == '') {
            throw new as_Exceptions.licGenException ('MISSING_PARAMETERS', 'Required parameters not sent in http call.');
            return FALSE;
        }
        return TRUE;
    }   
    
    /**
    *  Check login and password sent by Vibguard with list of allowed logins and pass 
    *  @return TRUE if login ok, FALSE when data do not match
    */
    
    public static boolean verifyVibLogin (String user, String pwd) {
        if(user == VIB_USER_NAME && pwd == VIB_PASSWORD) { return TRUE; }
        else { 
            throw new as_Exceptions.licGenException ('LOGIN_FAILED', 'Please check login data.');
            return FALSE;   
        }
    }   
}