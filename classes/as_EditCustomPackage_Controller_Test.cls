@isTest
public with sharing class as_EditCustomPackage_Controller_Test {
	
	public static testMethod void test_EditCustomPackageController() {
        // Set page in context
        PageReference pageRef = Page.asEditCustomPackage;
        Test.setCurrentPage(pageRef);
        
		// Crete custom package
		CM_Custom_Package__c ccp = as_TestHelper.createCmCustomPackage(TRUE);
		
		// pass order Id to parameters
		ApexPages.currentPage().getParameters().put('Id', ccp.Id); 
    
    	// Set Controller in context  
		as_EditCustomPackage_Controller controllerExt = new as_EditCustomPackage_Controller(new ApexPages.StandardController(ccp));
	
		// Save button
		System.assertEquals('/apex/ascustompackagemanagement', controllerExt.doSaveCustomPackage().getUrl() );
	
		// Get all avaliable features
		System.assert(controllerExt.getAvaliableFeatures().size() != null);
	}

}