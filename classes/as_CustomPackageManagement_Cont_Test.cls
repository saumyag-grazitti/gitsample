@isTest
public with sharing class as_CustomPackageManagement_Cont_Test {
	public static testMethod void test_as_CustomPackageManagement() {
        // Set page in context
        PageReference pageRef = Page.asCustomPackageManagement;
        Test.setCurrentPage(pageRef);
     
     	CM_Custom_Package__c ccp = as_TestHelper.createCmCustomPackage(FALSE);
     	CM_Custom_Package__c ccp2 = as_TestHelper.createCmCustomPackage(TRUE);
    	
    	// Set Controller in context  
		as_CustomPackageManagement_Controller controllerExt = new as_CustomPackageManagement_Controller (new ApexPages.StandardController(ccp) );
	
		// Test autofilter
		System.assertEquals(null, controllerExt.doFilterPackages());
		
		// Test Delete link
		controllerExt.packageIdToDelete = ccp2.Id;	
		System.assertEquals(null, controllerExt.doDeletePackage());
		
		// Test getter for table ocntent
		System.debug('PAWEL: ' + controllerExt.getPackagesTableContent().size());
		System.assert( controllerExt.getPackagesTableContent().size() != null);


 	}


}