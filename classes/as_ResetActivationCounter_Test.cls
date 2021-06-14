@isTest
public with sharing class as_ResetActivationCounter_Test {
	
	public static testMethod void test_as_NewSalesChannelController() {
        // Set page in context
        PageReference pageRef = Page.asDeleteSalesChannel;
        Test.setCurrentPage(pageRef);
     
     	// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Insert order
		ptt_cm_Order__c cmo1 = as_TestHelper.createCmOrder(FALSE);
		cmo1.ptt_Sales_Channel__c = sc.Id;
		cmo1.ptt_Activation_Counter__c = 2;
		insert cmo1;
		
		//Put URL parameters
		ApexPages.currentPage().getParameters().put('orderid', cmo1.Id); 
    	
    	// Set Controller in context  
		as_ResetActivationCounter controller = new as_ResetActivationCounter();
	
		/* Start testing */
		
		// Back button
		System.assertEquals('/apex/aseditorder?Id=' + cmo1.Id, controller.Back().getUrl() );
		
		// Reset without comment
		//controller.doReset();
		// System.assert(ApexPages.hasMessages() == TRUE  );
		
		// Reset with comment
		controller.CommentText = 'This is a reset comment';
		System.assertEquals('/apex/aseditorder?Id=' + cmo1.Id, controller.doReset().getUrl() );
	}
	

}