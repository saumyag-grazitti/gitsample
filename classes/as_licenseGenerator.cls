public class as_licenseGenerator {
	
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    
    // Constants
    static final String BASE_URL = 'https://smtp.pruftechnik-cm.com:8443/com.pruftechnik.rcm.server.keygenerator';
    //static final String BASE_URL = 'https://smtp.pruftechnik-cm.com:8444/com.pruftechnik.rcm.server.keygenerator';
    
    static final String AUTH_PATH = '/authenticate';
    static final String LICENSE_PATH = '/license-generator';
    
    static final String AUTH_SUCCESS_MESSAGE = 'message_key_values'; // span ID name which contains message
    static final String AUTH_SUCCESS_MESSAGE_VALUE = 'get a licens'; // string which indicate that we can continue to licese download
    
    /* For key gen login access data go to getLicenseUrl */
    
    	static final String USER_NAME = 'activation-server-production';
		static final String PWD = 'xt8zxfhecit1r4pyyvrygov3';
	   
	    //static final String USER_NAME = 'activation-server';
	    //static final String PWD = 'aqkg1cho68vp5lrzgkensahw';
	    
	    //public static final String USER_NAME = 'activation-server-ptsandbox';
	    //public static final String PWD = 'GYGMzQaytvHcSq9Q5pZ7YpRr';    

	// Variables
	static String packagesParam = '';
	static String enduserParam = '';
	
	static cm_tan_List__c cmTanList = new cm_tan_List__c();
	static Map<String,String> transactionTan;
        
    /****************************************/
    /** Main class which generates license **/
    /****************************************/ 
               
    /**
    *  This function based on given OrderId is asking KeyGenrator for license file, 
    *  creates log file, save liense file as attachemnt and returns Id of Attachment.
    *  @param cmOrderObjectId Id of order for which license should be generated
    *  @return Id of license file stored in Log as attachemnt.
    */
    public static Attachment createLicense (String cmOrderObjectId, String tanid, String licComment) {
        /* Variables */
        Attachment licFile = new Attachment();
        ptt_cm_Order__c orderObj = new ptt_cm_Order__c();
        Http httpConn = new Http(); // Http connection.
        transactionTan = getTransactionTanFromId(tanId);
        // Get Order details
        try {
        	orderObj = [SELECT Id, Name, ptt_Is_Active__c, ptt_Activation_Code__c, ptt_End_User__c, ptt_Activation_Counter__c, ptt_Sales_Channel__c, ptt_Sales_Channel__r.Account_Name__c, ptt_ProductID__c  
                    FROM ptt_cm_Order__c 
                    WHERE Id = :cmOrderObjectId];
        } catch (exception e) {
        	// TODO: add error handling there there is no results.
        }
        
        if (orderObj.ptt_Activation_Counter__c < 3) {      
	        // Authenticate to KG Server
	        httpConn = authenticateToKGServer();
	        
	        // Generate license file and get its Id
	        licFile = askForLicense (httpConn, orderObj, licComment);
	        return licFile;
        } else {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Maximum activation limit reached.'));
        	return null;
        }      
    }

    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/ 
    
    /**
    *   whole URL which should be sent to KG in order to retrive license file.
    *  @param orderObj order object with complete data set
    *  @return prepared map which contains url and params for obtaining license
    */
    public static Map<String,String> getLicenseUrl (ptt_cm_Order__c orderObj, Id transTanId) { 
    	
    	//String USER_NAME1 = 'activation-server-ptsandbox';
	    //String PWD1 = 'GYGMzQaytvHcSq9Q5pZ7YpRr';  
       
        packagesParam =  generatePackagesParameterValue(orderObj.Id);
        enduserParam = enduserUrlParamValue(orderObj.ptt_End_User__c);  
        Map<String,String> trTan = getTransactionTanFromId (transTanId);
                  
        Map<String,String> licURL = new Map<String,String>();

        licURL.put('url', BASE_URL + LICENSE_PATH);
        licURL.put('params',
            'user=' + as_licenseGenerator.USER_NAME + 
            '&pwd=' + as_licenseGenerator.PWD + 
            '&tanindex=' + trTan.get('index') +
            '&tan=' + trTan.get('value') +
            '&licensee=' + orderObj.ptt_ProductID__c +
            '&packages=' + packagesParam +
            '&enduser=' + enduserParam );
            
        if (licURL.get('url').length() + licURL.get('params').length() > 65530) {
        	throw new as_Exceptions.licGenException ('KEY_GENERATOR_CALL_TOO_LONG','Invalid KeyGenerator call length (maximum 65535 characters). Please contact your system administrator.');
    		return null;
    	} 
           
        return licURL;
    } 
    
    /**
    *  Get last not used TAN code and mark it as used.
    *  @return Map with TAN value and index
    */ 
    private static Map<String,String> getTransactionTanFromId(String tanid) {
        
        Map<String,String> tanValue = new Map<String,String>{};
        try {
            cmTanList = [SELECT Id, Name, Tan_Index__c, isUsed__c FROM cm_tan_List__c WHERE Id = :tanid LIMIT 1];   
            tanValue.put('index',String.valueOf(cmTanList.Tan_Index__c.intValue()));
            tanValue.put('value',cmTanList.Name); 
        } catch (exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Problem with TAN list. Contact administrator.'));    
        }     
        return tanValue;
    }
    
    /**
    *  Update Activation counter
    */
    private static void addOneToActivationCounter (Id cmOrderId) {
        ptt_cm_Order__c cmo = new ptt_cm_Order__c();
        cmo = [SELECT ptt_Activation_Counter__c FROM ptt_cm_Order__c WHERE Id = :cmOrderId];
        if (cmo.ptt_Activation_Counter__c > 2) {throw new as_Exceptions.licGenException ('ACTIVATION_LIMIT_REACHED', 'Maximum activation limit reached.'); }
        cmo.ptt_Activation_Counter__c = cmo.ptt_Activation_Counter__c +1;                          
        update cmo;
    }

    /**
    *  This class is calling Key Genrator and sending all reqired parameters.
    *  @httpConnection connection returned after authentication
    *  @orderObj record data
    *  @return Id of attachemnt where license file is saved 
    */
    public static Attachment askForLicense (Http httpConnection, ptt_cm_Order__c orderObj, String licenseComment) {
         HTTPRequest request = new HttpRequest();
         HttpResponse response = new HttpResponse();
         Integer statusCode = 0;
         String statusName = ''; 
         String contentType = '';  
         
System.debug('@@ entering askFor Lciense: ');
          
         	try { // Try to obain license file          
                request.setTimeout(120000);
                request.setMethod('POST');
                request.setBody('LicenseRequest');
                Map<String,String> licenseURL = getLicenseUrl(orderObj, cmTanList.Id);
  
                request.setEndpoint(licenseURL.get('url') + '?' + licenseURL.get('params')); 
System.debug('@@ Endpoint: ' + licenseURL.get('url') + '?' + licenseURL.get('params'));

                response = httpConnection.send(request);                                        
                statusCode = response.getStatusCode();
                statusName = response.getStatus();
                contentType = response.getHeader('Content-Type'); 
                    if (StatusCode == 200 && !response.getBody().contains('message_description')) {           
                        // Check if recivied content is an application (blob)
                        if (contentType.indexOf('application') >= 0) {                   
                            // Incrase activation counter                             
                            addOneToActivationCounter (orderObj.Id);
                           
                            // Create Log entry
                            CM_Activation_Log__c alog = new CM_Activation_Log__c();
                            alog.ptt_Account__c =  orderObj.ptt_Sales_Channel__r.Account_Name__c;
                            alog.ptt_do_Reset__c = FALSE;
                            alog.ptt_Activation__c = orderObj.ptt_Activation_Counter__c;
                            alog.ptt_cm_Order__c = orderObj.Id;
                            alog.ptt_Comment__c = licenseComment;     
	System.debug('@@ Lic comment: ' + licenseComment);                                
                            alog.ptt_Selected_Packages__c = ptUrlDecode(packagesParam.replace('||', '\n').replace('|', ': ').left(30000) );
                            // alog.ptt_End_User_Data__c = ptUrlDecode(enduserParam.replace('||', '\n').replace('|', ': ') );
                            alog.ptt_End_User_Data__c = enduserParam;
                            insert alog;
                            
                            Attachment att = saveLicFile(response, alog.Id);
                            return att;
                           
                        }
                        else {                                                            
                       		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, response.getBody()));
                       		throw new as_Exceptions.licGenException ('KEY_GENERATOR_RESPONSE_ERROR', 'Remote Server error' + response.getBody());      
                        }
                   } else {
                       String errorMSG = 'Remote Server error.<br/> Status code: ' + statusCode + ' <br/>Status name: ' + statusName + '<br/>Please contact adminstrator.' + '<br/>Body: ' + response.getbody(); // Server error
                       //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMSG));
                       System.debug('@@Server error: ' + response.getbody());    
                       throw new as_Exceptions.licGenException ('KEY_GENERATOR_SERVER_ERROR', errorMSG);               
                   }

            } catch (System.CalloutException e) {
                System.debug('@@Callout ERROR: '+ e);
                throw new as_Exceptions.licGenException ('KEY_GENERATOR_CALLOUT_ERROR', 'KG server error: ' + e); 
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'KG server error: ' + e));
            }
                
        return null;
    }
    /**
    *  Save attachment for CM Activation Log entry
    *  @response HTTP response from KG server which contains license file data
    *  @parentId Id of CM Activation Log entry where attachment should be stored
    *  @return Attachment Id as string, for usage in download link
    */
    private static Attachment saveLicFile (HttpResponse response, String parentId) {
        Attachment att2 = new Attachment();
        String fileName = '';
        // Extract file name from header
        fileName = response.getHeader('Content-Disposition');
        fileName = fileName.substring(fileName.indexOf('filename')+9);                         
        
        // Save attachement
        att2.Body = response.getBodyAsBlob(); // Read file content   
        att2.Name = fileName;
        att2.ParentId = parentId;
        
		if (fileName == null) {	 
		    String errorMsg = 'Error: file not recivied from Key Generator';
		    throw new as_Exceptions.licGenException ('FILE_NOT_RECIVIED_FROM_KG', errorMsg);
		}
        insert att2; 
        System.debug('@@ lic file after saveLic: ' + att2);
        return att2;
    }
    
    /**
    *  Authentication to KG server
    *  @return http connection used to retrive license.
    */
    public static Http authenticateToKGServer () {
        String authenticateURL = BASE_URL + AUTH_PATH;
        String authenticateParams = 'user=' + USER_NAME + '&pwd=' + PWD;
        
        Http httpProtocol = new Http(); // Http connection.
        HTTPRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Integer statusCode = 0;
        String statusName = ''; 
        
        //Try to authenticate
        request.setEndpoint(authenticateURL); 
        request.setMethod('POST'); 
        request.setBody(authenticateParams);
        try {
            // Send the HTTP request and get the response.
            response = httpProtocol.send(request);               
            statusCode = response.getStatusCode(); // Read the status code
            statusName = response.getStatus(); // Read the status name
            // 200 means ok, we can continue, else error
            if (StatusCode == 200) {
                if(Test.isRunningTest()) {
                	return new HTTP();   
                }
                String responseBody = response.getBody();
                // Check if we got response which contains 'AUTH_SUCCESS_MESSAGE_VALUE' string in message_actions then continue, elese error
                String message_actions = ptt_VFControllerHelper.extractValueFromId (responseBody, AUTH_SUCCESS_MESSAGE);
                System.debug('message_actions ' + message_actions);
                if (message_actions.indexOf(AUTH_SUCCESS_MESSAGE_VALUE) >= 0) {
                    System.debug('@@: Auth ok.');
                    return httpProtocol;
                }
            } else {
            	 // in case that authentication failed
                String errorMsg = 'Server error: Code: ' + statusCode + '. Name: ' + statusName ;
                throw new as_Exceptions.licGenException('AUTHENTIFICATION_TO_KG_FAILED', errorMsg);
            }
        }
        catch (System.CalloutException e) {
               System.debug('Callout ERROR: '+ e);
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'KG server error: ' + e));
        }
        return null;
                           
    }
    

    

        
  /**
    *  Generate output string for packages based on selected packages and their features
    *  @param list of all selected and active packages
    *  @return string encoded in utf-8 which contains all selected features.
    */ 
    public static String generatePackagesParameterValue (String orderId) {

        String paramValue = '';  
        
        List<CM_Selected_Package__c > activeSelectedPackagesList = new List<CM_Selected_Package__c >();
        List<CM_Selected_Feature__c> selectedFeatures = new List<CM_Selected_Feature__c>();
        
        Map<Id, Integer> quantityOfSelectedPackages = new Map<Id,Integer>(); // Id of selected customPackage, Quantity - how many times chosen
        Map<Id, CM_Feature_Item__c> allFeatureItems = new Map<Id, CM_Feature_Item__c>();
         
        // Get All Active packages for this order
        activeSelectedPackagesList = [SELECT Id, ptt_Index__c, ptt_IsActive__c, ptt_CM_Custom_Package__c 
                                      FROM CM_Selected_Package__c 
                                      WHERE ptt_CM_Order__c = :orderId AND ptt_IsActive__c = TRUE];
        if (activeSelectedPackagesList.size() == 0) {
        	throw new as_Exceptions.licGenException ('ORDER_HAS_NO_ACTIVE_PACKEGES', 'Oder do not have any active packages.');
        }
        // Iterate throught all selected packages and count duplicates. Store in quantityOfSelectedPackages
        for (CM_Selected_Package__c oneSelectedPackage : activeSelectedPackagesList) {
            // Incrase quantity if CustomPackage already in the Map
            if (quantityOfSelectedPackages.containsKey(oneSelectedPackage.ptt_CM_Custom_Package__c)) {
                Integer quantity = quantityOfSelectedPackages.get(oneSelectedPackage.ptt_CM_Custom_Package__c);
                quantity++;
                quantityOfSelectedPackages.put(oneSelectedPackage.ptt_CM_Custom_Package__c, quantity);
            } else {
            // Set quantity to 1 and add to Map.
                quantityOfSelectedPackages.put(oneSelectedPackage.ptt_CM_Custom_Package__c, 1);
            }              
        }    
      
        // Create Set with all Ids of selected packages. 
        Set<Id> selectedPackgagesId = quantityOfSelectedPackages.keySet();      
        
        // Find selected features for this packages, limit results to Ids from Set selectedPackgagesId
        selectedFeatures = [SELECT Id, ptt_CM_Custom_Package__c, ptt_CM_Feature_Item__c, ptt_Quantity__c
                            FROM CM_Selected_Feature__c
                            WHERE ptt_Quantity__c > 0
                            AND ptt_CM_Custom_Package__c IN :selectedPackgagesId];

        // Create Set with all Ids of selected Feature Items. Fill it with data from List selectedFeatures
        set<Id> selectedFeaturesItemsId = new set<Id>();  
        for (CM_Selected_Feature__c oneSelectedFeature : selectedFeatures) {
            selectedFeaturesItemsId.add(oneSelectedFeature.ptt_CM_Feature_Item__c);
        }
        
        // Fill in Map with properties of Feature Items, limit results to FeatureItems that are assigned to selected Packages
        allFeatureItems.putAll([SELECT id, Name, ptt_is_Multiorder__c, ptt_Code__c, ptt_Key__c, ptt_System__c, ptt_Variant__c, ptt_Quantity__c
                                FROM CM_Feature_Item__c
                                WHERE Id IN :selectedFeaturesItemsId]);
    
        Map<String, CM_Feature_Item__c> paramQuantityMap = new Map<String, CM_Feature_Item__c>();
        
        for (Id pkgId : selectedPackgagesId) { // Loop throught all uniques ID of selected Packages
            for (Integer pq = 0; pq < quantityOfSelectedPackages.get(pkgId); pq++) { // Loop throught quantity of that package
                // generate features Key|index depended on quantity
                for (CM_Selected_Feature__c oneSelectedFeature : selectedFeatures) {
                    if (oneSelectedFeature.ptt_CM_Custom_Package__c == pkgId) { // restrict to packages only for selectedPackage
                        String featureKey = allFeatureItems.get(oneSelectedFeature.ptt_CM_Feature_Item__c).ptt_Key__c;
                        Boolean isMultiorder = allFeatureItems.get(oneSelectedFeature.ptt_CM_Feature_Item__c).ptt_is_Multiorder__c;
                        Integer quantity = (Integer)oneSelectedFeature.ptt_Quantity__c;
                        
                        // Use CM_Feature_Item__c object to store data in Map
                        CM_Feature_Item__c tmpFItem = new CM_Feature_Item__c();
                        tmpFItem.ptt_is_Multiorder__c = isMultiorder;
                        tmpFItem.ptt_Quantity__c = quantity;
                        
                        // Check if Map contains featureKey
                        if (paramQuantityMap.containsKey(featureKey)) {
                            Integer quant = (Integer) paramQuantityMap.get(featureKey).ptt_Quantity__c;
                            quantity = quantity + quant;
                            tmpFItem.ptt_Quantity__c = quantity;
                            paramQuantityMap.put(featureKey, tmpFItem);
                        } else {
                              paramQuantityMap.put(featureKey, tmpFItem);                       
                        }                   
                  	}
                }
            }
        } 
    
        
        Set<String> quantityKeySet = paramQuantityMap.keySet();
        for (String qks : quantityKeySet) {
        
            // Check if there is notMultiorder Feature selected more than one time
            if (paramQuantityMap.get(qks).ptt_is_Multiorder__c == FALSE && paramQuantityMap.get(qks).ptt_Quantity__c > 1) {
               throw new as_Exceptions.licGenException('MULTIPLE_NOT_MULTIORDER_LICENSES_SELECTED','Order contains multiple licenses for not Multiorder item: ' + qks);
               return null; 
            } else {            
                //  final paramValue string
                for (Integer q = 1; q <= paramQuantityMap.get(qks).ptt_Quantity__c ; q++) {
                    paramValue = paramValue + qks + '|' + q + '||';
                } 
            }
        }

    return paramValue;
    }
    
    /**
    * Create value for enduser URL parameter
    * @param endUserId Id of End User
    * @return string prepared url parameter
    */
    public static String enduserUrlParamValue (String endUserId) {
        ptt_cm_End_User__c endUserObj = new ptt_cm_End_User__c();
        String endUserUrl = '';
        
        try {
        endUserObj = [SELECT Id, ptt_Company_Name__c, ptt_City__c, ptt_CM_Order__c, ptt_Country2__c, ptt_CountryISO2__c, ptt_Email__c, ptt_Industry__c, ptt_Industry_subcategory__c, ptt_State__c, ptt_Street__c, ptt_Zip_Postal_Code__c 
                      FROM ptt_cm_End_User__c 
                      WHERE Id = :endUserId LIMIT 1];  
        }
        catch (exception ex) {
        	throw new as_Exceptions.licGenException ('MISSING_ENDUSER_OBJECT', 'Missing enduser object');
        }
      
        // Create enduser parameter value
        if (endUserObj.ptt_Company_Name__c != null) {endUserUrl = endUserUrl + 'company|' + ptUrlEncode(endUserObj.ptt_Company_Name__c) + '||';}
        if (endUserObj.ptt_Street__c != null) {endUserUrl = endUserUrl + 'street|' + ptUrlEncode(endUserObj.ptt_Street__c) + '||';}
        if (endUserObj.ptt_Zip_Postal_Code__c != null) {endUserUrl = endUserUrl + 'zip|' + ptUrlEncode(endUserObj.ptt_Zip_Postal_Code__c) + '||';}
        if (endUserObj.ptt_City__c != null) {endUserUrl = endUserUrl + 'city|' + ptUrlEncode(endUserObj.ptt_City__c) + '||';}
        if (endUserObj.ptt_State__c != null) {endUserUrl = endUserUrl + 'state|' + ptUrlEncode(endUserObj.ptt_State__c) + '||';}
        if (endUserObj.ptt_CountryISO2__c != null) {endUserUrl = endUserUrl + 'country|' + ptUrlEncode(endUserObj.ptt_CountryISO2__c) + '||';}
        if (endUserObj.ptt_Email__c != null) {endUserUrl = endUserUrl + 'email|' + ptUrlEncode(endUserObj.ptt_Email__c) + '||';}
        if (endUserObj.ptt_Industry__c != null) {endUserUrl = endUserUrl + 'industry|' + ptUrlEncode(endUserObj.ptt_Industry__c) + '||';}
        if (endUserObj.ptt_Industry_subcategory__c	 != null) {endUserUrl = endUserUrl + 'subindustry|' + ptUrlEncode(endUserObj.ptt_Industry_subcategory__c) + '||';}
  		
        return endUserUrl;
    } 
   
    /**
    *  Encode string to UTF-8 to be safe for URL 
    *  @param input raw string
    *  @return web safe encoded string with + changed to %20 (space)
    */
    public static String ptUrlEncode (String s) {
        s = EncodingUtil.urlEncode(s, 'UTF-8');
        s = s.replace('+','%20');
        return s;
    }   
    
    /**
    * Encode string to UTF-8 to be safe for URL 
    * @param input raw string
    * @return web safe encoded string
    */
    public static String ptUrlDecode (String s) {
       If (s == null || s == '') {return '';}
        else {
            return String.escapeSingleQuotes(EncodingUtil.urlDecode(s ,'UTF-8'));          
        }
    }
    
    /**
    *  Generate error message in html format readable by vibguard
    *  @param message_key Short error name in capital letters with underscores ERROR_EXAMPLE
    *  @param message_key_values Detailed error description
    */ 
    public static void asErrorMessage(String message_key, String message_key_values) {
        String errorMsg = '\n<div id="message">\n' +
                            '\t<span id="message_type">1</span>\n'+
                            '\t<span id="message_description">Activation Server error</span>\n'+
                            '\t<span id="message_key">' + message_key + '</span>\n' +
                            '\t<span id="message_key_values">'+ message_key_values + '</span>\n' + 
                            '</div>\n';
        //Debug request
        CM_Activation_Log__c alog = new CM_Activation_Log__c();
        alog.ptt_is_Error__c = TRUE;
        alog.ptt_Comment__c = 'Message_key: ' + message_key + '\nmessage_key_values: ' + message_key_values;
        insert alog;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));                        
    }
    
    /**
    *  Get last not used TAN code and mark it as used.
    *  @return Map with TAN value and index
    */ 
    public static cm_tan_List__c getTransactionTan() {
        cm_tan_List__c cmTan = new cm_tan_List__c();
		List<cm_tan_List__c> tanList = new List<cm_tan_List__c>();
        try { 
            // Get defined number of records
            Integer tanPool = 30; 
            tanList = [SELECT Id, Name, Tan_Index__c, isUsed__c FROM cm_tan_List__c WHERE isUsed__c = FALSE LIMIT :tanPool];	
			do {		
	            // Get random TAN from cmTanList
	            Double randomTan = math.random() * tanPool;
	            Integer tanNo = randomTan.intValue();
				cmTan = tanList.get(tanNo);
			} while (cmTan.isUsed__c == TRUE);			
			cmTan.isUsed__c = TRUE;
            update cmTan;     
             
        } catch (exception e) {
            throw new as_Exceptions.licGenException ('TAN_LIST_ERROR', 'Problem with TAN list. Contact administrator.');    
        }           
        return cmTan;
    }
}