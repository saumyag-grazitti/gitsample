public with sharing class as_NewCustomPackage_Controller_Test {
	
	public static testMethod void test_as_NewCustomPackage_Controller() {
		/* Configure enviroment */

		// Prepare database structure
		CM_Custom_Package__c cmCustPkg = as_TestHelper.createCmCustomPackage(FALSE);
		
        // Set page in context
        PageReference pageRef = Page.asNewCustomPackage;
        Test.setCurrentPage(pageRef);
        
        // Set url parameters
     
    	// Set Controller in context  
		as_NewCustomPackage_Controller controllerExt = new as_NewCustomPackage_Controller (new ApexPages.StandardController(cmCustPkg) );
		
		/* Start testing */
		
		// Save button	
		System.assert(controllerExt.doSavePackage().getUrl().contains('/apex/aseditcustompackage') );
		
		// Try to save when missing one parameter
		cmCustPkg.ptt_Variant__c = '';
		System.assertEquals(null, controllerExt.doSavePackage());
		
 	}
}