public with sharing class as_CustomPackageManagement_Controller {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    private CM_Custom_Package__c custPackageObj; //Object for standard controller
    ApexPages.StandardController stdController;
   
    // Automatic get set
    public String packageIdToDelete {get; set;}
    public String packageItemNoToDelete {get; set;}
   
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/

    public as_CustomPackageManagement_Controller(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.custPackageObj = (CM_Custom_Package__c)stdController.getRecord();
    }
    
    
    /*************** Getters ****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
        
    public List<CM_Custom_Package__c> getPackagesTableContent() {
        List<CM_Custom_Package__c> packagesList;
        if (custPackageObj.ptt_system__c == null) {
            packagesList = [SELECT Id, name, ptt_IdCode__c, ptt_System__c, ptt_variant__c, ptt_isMultiorder__c 
                            FROM CM_Custom_Package__c
                            ORDER BY ptt_IdCode__c ASC];
                            
        // Removed because it should                             
        /* } else if (custPackageObj.ptt_system__c != null && custPackageObj.ptt_variant__c == null) {
             packagesList = [SELECT Id, name, ptt_IdCode__c, ptt_System__c, ptt_variant__c, ptt_isMultiorder__c 
                             FROM CM_Custom_Package__c
                             WHERE ptt_system__c = :custPackageObj.ptt_system__c
                             ORDER BY ptt_IdCode__c ASC];*/
        } else if (custPackageObj.ptt_system__c != null ) { //&& custPackageObj.ptt_variant__c != null ) {
              packagesList = [SELECT Id, name, ptt_IdCode__c, ptt_System__c, ptt_variant__c, ptt_isMultiorder__c 
                             FROM CM_Custom_Package__c
                             WHERE ptt_system__c = :custPackageObj.ptt_system__c
                             AND ptt_variant__c = :custPackageObj.ptt_variant__c
                             ORDER BY ptt_IdCode__c ASC];
        
        }
        return packagesList;
    }
    
    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/
    
    /* Filter */
    public PageReference doFilterPackages() {
        return null;
    }

    
    /*********** Command links **************/
    /*** Actions invoked by comand links ****/
    /****************************************/
    
    public PageReference doDeletePackage() {
        // Check if used in any order
        try {Database.delete(packageIdToDelete);}
        catch (System.DmlException e) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Package ' + packageItemNoToDelete + ' can\'t be deleted because is selected in order(s). Remove it from orders(s) first.'));
        }
        return null;
    }

}