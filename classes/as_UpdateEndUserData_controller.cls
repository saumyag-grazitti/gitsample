public class as_UpdateEndUserData_controller {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    
    // Variables
    String user, pwd, license, actcode, enduser;
    String company, street, zip, city, state, country, email, industry; 
    static ptt_cm_Order__c orderDetails = new ptt_cm_Order__c();
    static Map<String,String> enduserData = new Map<String,String>{};

    
    // Variables with default get set methods   
    public String redirectionURL { get; set; }

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/

    public as_UpdateEndUserData_controller(ApexPages.StandardController controller) {
        // Read all parameters.
        user = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('user'));
        pwd = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('pwd'));      
        
        license = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('license'));
        actcode = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('actcode'));
        enduser = as_licenseGenerator.ptUrlDecode(ApexPages.currentPage().getParameters().get('enduser'));

        enduserData = extractEndUserData(enduser);    
    }
    
    /****************************************/
    /********** Immediate actions ***********/
    /****************************************/
    
    public Pagereference doUpdateEndUserData() {   
      // Create Log entry
        CM_Activation_Log__c alog = new CM_Activation_Log__c();
        alog.ptt_Comment__c = 'Incoming request call from vibguard';                                     
        alog.ptt_End_User_Data__c = 'RAW: ' + ApexPages.currentPage().getParameters().get('enduser') + '\nDecoded: ' + enduser ;
        insert alog;
      
        try {
	        if (as_vibguardInterface_controller.verifyVibLogin(user, pwd) == TRUE) {
	            if(reqiredParametersSent() == TRUE) {
                	orderDetails = readOrderDetails(actcode);
                	as_licenseGenerator.generatePackagesParameterValue(orderDetails.Id);         
	                if (orderDetails.ptt_Activation_Counter__c > 2) { 
	                	throw new as_Exceptions.licGenException('ACTIVATION_LIMIT_REACHED.', 'Please contact PRUFTECHNIK to reset activation counter.' );     
	                } else if (orderDetails.ptt_is_Active__c == FALSE) {
            			throw new as_Exceptions.licGenException ('ORDER_IS_NOT_ACTIVE', 'Please contact PRUFTECHNIK to activate an order.' ); 	               
                    } else {
                        updateEndUserData(orderDetails);                       
                        redirectionURL = '/apex/asvibguardInterface?user=' +  user + '&pwd=' + pwd + '&license=' + license + '&actcode=' + actcode + '&tid=' + as_licenseGenerator.getTransactionTan().Id;                        
                        return null;
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
    /*** Class specific helper functions ****/
    /****************************************/
    
    ptt_cm_Order__c readOrderDetails(String actcode){
        // Find Order details for given Activation Code.
        try {
            orderDetails = [SELECT Id, ptt_End_User__c, ptt_Sales_Channel__r.ptt_remote_access__c, ptt_Sales_Channel__c, ptt_Activation_Code__c, ptt_Activation_Counter__c, ptt_is_Active__c
                            FROM ptt_cm_Order__c  
                            WHERE ptt_Activation_Code__c = :actcode LIMIT 1];
            return orderDetails;
        }
        catch (exception e) {
            throw new as_Exceptions.licGenException ('ACTIVATION_CODE_NOT_FOUND', 'Order with given Activation code not found');
        } 
    }
    
    /**
    *  Check if license, actcode parameters are not empty
    *  @return FALSE when any of them empty, TRUE when all contains data
    */
    boolean reqiredParametersSent () {
        if( (license == null || license == '' || actcode == null || actcode == '' || enduser == null || enduser == '' || !enduserData.containsKey('company') || !enduserData.containsKey('email') || !enduserData.containsKey('street') || !enduserData.containsKey('zip') || !enduserData.containsKey('city') || !enduserData.containsKey('country'))) {
            throw new as_Exceptions.licGenException ('MISSING_PARAMETERS', 'Missing required parameters.');
            return FALSE;
        }
        return TRUE;
    }   
    
    /**
    *  Update enduser data based on given order object.
    *  @param cmOrderObject - order object
    *
    */
    void updateEndUserData(ptt_cm_Order__c cmOrderObject) {
        ptt_cm_End_User__c endUser = new ptt_cm_End_User__c();
        
        // check if there is connected endUserData record then update it
        if (cmOrderObject.ptt_End_User__c != null) {
            endUser = [SELECT Id, Name, ptt_Company_Name__c, ptt_City__c, ptt_CM_Order__c, ptt_Country2__c, ptt_Email__c, ptt_Industry__c, ptt_Industry_subcategory__c, ptt_State__c, ptt_Street__c, ptt_Zip_Postal_Code__c 
                       FROM ptt_cm_End_User__c 
                       WHERE Id = :cmOrderObject.ptt_End_User__c];  
        }   
        // If any enduser data are filled in no update
        if (EndUser.ptt_Company_Name__c != null || EndUser.ptt_Street__c != null || EndUser.ptt_Email__c != null || 
        	 EndUser.ptt_Zip_Postal_Code__c != null || EndUser.ptt_City__c != null || EndUser.ptt_Country2__c != null ||
        	 endUser.ptt_State__c != null || endUser.ptt_Industry__c != null) {
        	 // Do not update enduser data but update Product Id
        	 cmOrderObject.ptt_ProductID__c =  license;
             update (cmOrderObject);        	 
        	 
        } else {
            // Requred parameters
            if (enduserData.containsKey('company')) {endUser.ptt_Company_Name__c = enduserData.get('company');}
            if (enduserData.containsKey('email')) {endUser.ptt_Email__c = enduserData.get('email');}
            if (enduserData.containsKey('street')) {endUser.ptt_Street__c = enduserData.get('street');}
            if (enduserData.containsKey('zip')) {endUser.ptt_Zip_Postal_Code__c = enduserData.get('zip');}
            if (enduserData.containsKey('city')) {endUser.ptt_City__c = enduserData.get('city');}       
            if (enduserData.containsKey('country')) {endUser.ptt_CountryISO2__c = enduserData.get('country');}   
            if (enduserData.containsKey('country')) {endUser.ptt_Country2__c = getCountryNameFromISO2(enduserData.get('country'));}
            
            // Optional Parameters
            if (enduserData.containsKey('state')) {endUser.ptt_State__c = enduserData.get('state');} else {endUser.ptt_State__c = null;}
            if (enduserData.containsKey('industry')) {endUser.ptt_Industry__c = enduserData.get('industry');} else {endUser.ptt_Industry__c = null;}
            if (enduserData.containsKey('subindustry')) endUser.ptt_Industry_subcategory__c = enduserData.get('subindustry');           
            
            // Order Id
            endUser.ptt_CM_Order__c = cmOrderObject.Id;
            upsert(endUser);
            
            cmOrderObject.ptt_End_User__c = endUser.id;
            cmOrderObject.ptt_ProductID__c =  license;
            update (cmOrderObject);
       	}
    }
    
    String getCountryNameFromISO2 (String iso2Code) {
        String countryname = '';
        try {
            countryName = [SELECT Name FROM pw_cc__CountryObject__c WHERE pw_cc__IsoCode_2__c = :iso2Code Limit 1].Name;
        }
        catch (exception e) {
            countryName = iso2Code;
        }   
        return countryName;
    }
    
    /**
    *  Extract data from endueser paremter and splits them by category name.
    *  @allParams string with enduser data parameter
    *  @return Map of parameters like name=>John, city=>Wroclaw
    */
    Map<String, String> extractEndUserData (String allParams) {
        Map<String, String> paramMap = new Map<String,String>{};
        if(allParams != null && allParams != '' && allParams.contains('|')){        
            // Remove three pipes ||| and parameter name if parameter is empty
            allParams = allParams.replaceAll('(\\w)*\\|\\|\\|','');
            // Split by sub parameters of enduser
            List<String> tmp = allParams.split('\\|\\|');
            for ( String t : tmp ) {
                String key = t.substring(0,t.indexOf('|')).toLowerCase();
                String value = t.substring(t.indexOf('|')+1,t.length());
                paramMap.put(key, value);         
            } 
        }      
        return paramMap;
    }   
    
}