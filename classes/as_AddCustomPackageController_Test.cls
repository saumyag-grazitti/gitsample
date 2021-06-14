@isTest
public with sharing class as_AddCustomPackageController_Test {
	
	public static testMethod void test_AddCustomPackageController() {
        /* Configure enviroment */
        
        // Prepare database structure 
        ptt_cm_Order__c cmOrder = as_TestHelper.createCmOrder(TRUE);
        CM_Custom_Package__c pkgOne = as_TestHelper.createCmCustomPackage(TRUE);
        CM_Custom_Package__c pkgTwo = as_TestHelper.createCmCustomPackage(TRUE);
        // Connect package with Order
        CM_Selected_Package__c orderPkgLink = new CM_Selected_Package__c();
        orderPkgLink.ptt_CM_Custom_Package__c = pkgOne.Id;
        orderPkgLink.ptt_CM_Order__c = cmOrder.Id;
        orderPkgLink.ptt_Index__c = 1;
        orderPkgLink.ptt_IsActive__c = TRUE;
        insert orderPkgLink;
               
        // Set page in context
        PageReference pageRef = Page.asAddCustomPackage;
        Test.setCurrentPage(pageRef);
        
		// Set url parameters
		ApexPages.currentPage().getParameters().put('OrderId', cmOrder.Id); 
    
    	// Set Controller in context  
		as_AddCustomPackageController controller = new as_AddCustomPackageController ();
	
		/* Start testing */
		
		// Back button
		System.assertEquals('/apex/aseditorder?Id=' + cmOrder.Id, controller.BackToOrder().getUrl() );
		
		// Save button		
		System.assertEquals('/apex/aseditorder?Id=' + cmOrder.Id, controller.SaveSelectedPackages().getUrl() );
		
		
		
	}

}