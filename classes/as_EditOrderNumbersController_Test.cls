@isTest
public with sharing class as_EditOrderNumbersController_Test {

	public static testMethod void test_as_EditOrderNumbers() {
        // Set page in context
        PageReference pageRef = Page.asEditOrderNumbers;
        Test.setCurrentPage(pageRef);
     
     	// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Insert order
		ptt_cm_Order__c cmo1 = as_TestHelper.createCmOrder(FALSE);
		cmo1.ptt_Sales_Channel__c = sc.Id;
		cmo1.ptt_Order_numbers__c = '123;345;';
		insert cmo1;
		
		ApexPages.currentPage().getParameters().put('orderId', cmo1.Id); 
    	
    	// Set Controller in context  
		as_EditOrderNumbersController controller = new as_EditOrderNumbersController();
	
		/* Start testing */

		// Back button
		System.assertEquals('/apex/aseditorder?Id=' + cmo1.id, controller.onBack().getUrl() );
		
		// Delete order number
		controller.orderNumbersValues.add('aaa');
		controller.orderNumbersValues.add('bbb');
		controller.selectedOnValues.add('aaa');
		System.assertEquals(null, controller.doDeleteON() );
		
		// Add order number
		controller.addONValue = '123';
		System.assertEquals(null, controller.doAddON() );
		
		// Add order number
		controller.addONValue = '12;3';
		System.assertEquals(null, controller.doAddON() );
		
		// Save button
		System.assertEquals('/apex/aseditorder?Id=' + cmo1.id, controller.onSave().getUrl() );
		
		
		
		// getter getOrderNumbersOptions()
		System.assert(controller.getOrderNumbersOptions().size() != null );
	}
}