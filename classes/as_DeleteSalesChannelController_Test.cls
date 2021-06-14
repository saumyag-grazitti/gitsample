@isTest
public with sharing class as_DeleteSalesChannelController_Test {
	
	 public static testMethod void test_as_NewSalesChannelController() {
        // Set page in context
        PageReference pageRef = Page.asDeleteSalesChannel;
        Test.setCurrentPage(pageRef);
     
     	// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Insert order
		ptt_cm_Order__c cmo1 = as_TestHelper.createCmOrder(FALSE);
		cmo1.ptt_Sales_Channel__c = sc.Id;
		insert cmo1;
    	
    	// Set Controller in context  
		as_DeleteSalesChannelController controllerExt = new as_DeleteSalesChannelController(new ApexPages.StandardController(sc));
	
		/* Start testing */

		
		// Add parameters to page URL - page is expecting Id 
        ApexPages.currentPage().getParameters().put('Id', sc.Id);
        
        // Back button
		System.assertEquals('/apex/assaleschanneloverview', controllerExt.doCancel().getUrl() );		
		
		
		// Try to delete sales channel with orders
		System.assertEquals(null, controllerExt.deleteRecord() );
		
		// Check if delete is disabled
		System.assertEquals('true', controllerExt.getdelDisabled() );
		
		// Delete order
		delete cmo1;
		
		// Try to delete SalesChannel
		System.assertEquals('/apex/assaleschanneloverview', controllerExt.deleteRecord().getUrl() );	
	 }

}