public with sharing class as_EditCustomPackage_Controller {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    private CM_Custom_Package__c custPackageObj;
    ApexPages.StandardController stdController;
    List<CM_Feature_Item__c> featuresList = new List<CM_Feature_Item__c>();
    Map<Id, CM_Selected_Feature__c> packageExistingFeatures = new  Map<Id, CM_Selected_Feature__c>();
    Integer countOfNotMultiorder = 0;
      
    // Variables with default get set methods

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    
    public as_EditCustomPackage_Controller(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.custPackageObj = (CM_Custom_Package__c)stdController.getRecord();
        packageExistingFeatures.putAll([SELECT Id, ptt_Quantity__c, ptt_CM_Feature_Item__c, ptt_CM_Custom_Package__c
                                   FROM CM_Selected_Feature__c
                                   WHERE ptt_CM_Custom_Package__c = :custPackageObj.Id]);
        
        featuresList = generateFeaturesList(custPackageObj);
    }

    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/

    public List<CM_Feature_Item__c> getAvaliableFeatures () {      
        return this.featuresList;
    }
    
    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/
    
     public PageReference doSaveCustomPackage () {      
        // Save state of selected features
        // String errorMsg = 'List content: <br/>' +  String.valueOf(featuresList).replace('{', '{<br/>').replace('},', '}<p/>').replace(',', '<br/>');
        // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg));
       
        List<CM_Selected_Feature__c> updateList = new List<CM_Selected_Feature__c>();
        List<CM_Selected_Feature__c> insertList = new List<CM_Selected_Feature__c>();
        
        // Iterate throught data returned by table
        for (CM_Feature_Item__c featureItem : featuresList) {
            
            // Check if there is more than 1 not multiorder selected
            if (featureItem.ptt_Quantity__c > 1 && featureItem.ptt_is_Multiorder__c == FALSE){
                featureItem.ptt_Quantity__c.addError('You can\'t select more than 1 not multiorder feature.');
                return null;
            } else 
            if (featureItem.ptt_Quantity__c < 0) {
                featureItem.ptt_Quantity__c.addError('Value not allowed');
                return null;
            } else {            
                if( featureItem.ptt_Quantity__c > 0 || featureItem.ptt_Package_Existing_Feature_ID__c != null ) {
                    // prepare insert
                    if (featureItem.ptt_Package_Existing_Feature_ID__c == null) {
                        CM_Selected_Feature__c tmpInsert = new CM_Selected_Feature__c();
                        tmpInsert.ptt_CM_Custom_Package__c = custPackageObj.Id;
                        tmpInsert.ptt_CM_Feature_Item__c = featureItem.Id;
                        tmpInsert.ptt_Quantity__c = featureItem.ptt_Quantity__c;
                        insertList.add(tmpInsert);
                    } 
                    else {
                    // prepare update
                        if ( packageExistingFeatures.containsKey(featureItem.ptt_Package_Existing_Feature_ID__c)){
                            CM_Selected_Feature__c tmpUpdate = packageExistingFeatures.get(featureItem.ptt_Package_Existing_Feature_ID__c);
                            if (featureItem.ptt_Quantity__c == null) {featureItem.ptt_Quantity__c = 0;}
                            tmpUpdate.ptt_Quantity__c = featureItem.ptt_Quantity__c;
                            packageExistingFeatures.put(tmpUpdate.Id, tmpUpdate);
                        }           
                    }
                }
                // Count how many not multiorder packages are seleceted.
                if( featureItem.ptt_Quantity__c > 0 && featureItem.ptt_is_Multiorder__c == FALSE ) {
                    countOfNotMultiorder++;
                }
            }
        }
        updateList = packageExistingFeatures.values();
 /*       
        String errorMsg1 = 'Update List content: <br/>' +  String.valueOf(updateList).replace('{', '{<br/>').replace('},', '}<p/>').replace(',', '<br/>');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg1));
        
        String errorMsg2 = 'Insert List content: <br/>' +  String.valueOf(insertList).replace('{', '{<br/>').replace('},', '}<p/>').replace(',', '<br/>');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg2));
  */     
      
        if (updateList.size() > 0) {update updateList;}
        if (insertList.size() > 0) {insert insertList;}      
        
        // Update status of CustomPackgae isMultiorder field depending of counted not multiored features.
        if (countOfNotMultiorder > 0) {custPackageObj.ptt_isMultiorder__c = FALSE;}
        else {custPackageObj.ptt_isMultiorder__c = TRUE;}
        
        // Update Cutom Pacgae object 
        update custPackageObj;
    
        // Redirect to Package management
        PageReference pr = Page.asCustomPackageManagement;
        pr.setRedirect(true);
        return pr;
        // return null;
    }
        
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/
    
    /**
    *  This class generate Avalaible Features list with proper Quantity values counting already selected ones.
    *  @param cmOrder Order object with ID, ptt_system__c, ptt_variant__c
    *  @return list for dataTable component with all avalible features and their quantity.
    */
    
    List<CM_Feature_Item__c> generateFeaturesList (CM_Custom_Package__c customPackage) {
        List<CM_Selected_Feature__c> packageExistingFeatures = new List<CM_Selected_Feature__c>();
        List<CM_Feature_Item__c> avaliableFeatures = new List<CM_Feature_Item__c>();
        List<CM_Feature_Item__c> allFeaturesList = new List<CM_Feature_Item__c> ();
        Map<Id, CM_Feature_Item__c> allFeaturesMap = new Map<Id, CM_Feature_Item__c> ();
        
        // Get all possible features for this CustomPackage system and variant
        allFeaturesList = [SELECT id, Name, ptt_Key__c, ptt_Code__c, ptt_Is_Multiorder__c, ptt_Quantity__c, ptt_System__c, ptt_Variant__c
            FROM CM_Feature_Item__c 
            WHERE ptt_System__c = :custPackageObj.ptt_System__c 
            AND ptt_Variant__c INCLUDES (:custPackageObj.ptt_Variant__c)
            ORDER BY Name ASC];
            
        // Set zero quanttity for all of the,
        for (CM_Feature_Item__c featureItem : allFeaturesList) {
            featureItem.ptt_quantity__c = 0;
            allFeaturesMap.put(featureItem.Id, featureItem); 
        }

        // Get all already selected Features for this Custom Package
        packageExistingFeatures = [SELECT Id, ptt_Quantity__c, ptt_CM_Feature_Item__c, ptt_CM_Custom_Package__c
                                   FROM CM_Selected_Feature__c
                                   WHERE ptt_CM_Custom_Package__c = :customPackage.Id];                                      
       
        // Set Quantity for already selected features.
        for (CM_Selected_Feature__c existingFeature : packageExistingFeatures ) {  
           if(allFeaturesMap.containsKey(existingFeature.ptt_CM_Feature_Item__c)) {
               CM_Feature_Item__c tmpFeature = allFeaturesMap.get(existingFeature.ptt_CM_Feature_Item__c);
               tmpFeature.ptt_Quantity__c = existingFeature.ptt_Quantity__c;
               tmpFeature.ptt_Package_Existing_Feature_ID__c = existingFeature.Id; // add Id if feature was selected before.
               allFeaturesMap.put(tmpFeature.Id, tmpFeature);
           }   
        }

        // Convert Map to List and sort values
        avaliableFeatures = allFeaturesMap.values();
        avaliableFeatures.sort();
       
        return avaliableFeatures;  
    }
    
    
    
    
}