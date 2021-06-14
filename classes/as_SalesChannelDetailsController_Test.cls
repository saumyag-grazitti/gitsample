@isTest
public class as_SalesChannelDetailsController_Test {

	 public static testMethod void test_as_NewSalesChannelController() {
        // Set page in context
        PageReference pageRef = Page.asSalesChannelDetails;
        Test.setCurrentPage(pageRef);
     
    	// Set Controller in context  
		as_SalesChannelDetailsController controllerExt = new as_SalesChannelDetailsController(new ApexPages.StandardController(new ptt_cm_Sales_Channel__c()));
	
		/* Start testing */
		
		// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Create Order
		ptt_cm_Order__c cmo1 = as_TestHelper.createCmOrder(FALSE);
		cmo1.ptt_Sales_Channel__c = sc.Id;
		insert cmo1;
		
		ptt_cm_Order__c cmo2 = as_TestHelper.createCmOrder(FALSE);
		cmo2.ptt_Sales_Channel__c = sc.Id;
		insert cmo2;
		
		// Add parameters to page URL - page is expecting Id 
        ApexPages.currentPage().getParameters().put('Id', sc.Id);				
		
		// Back button
		System.assertEquals('/apex/assaleschanneloverview?nooverride=1', controllerExt.scBack().getUrl() );
		
		// New Order button
		System.assertEquals('/apex/asneworder', controllerExt.doNewOrder().getUrl() );
		//System.assertEquals(sc.Id, controllerExt.doNewOrder().getParameters().get('scId') );	
		
		// Save button
		System.assertEquals('/apex/assaleschanneloverview', controllerExt.scSave().getUrl() );
		
		// Filter button
		controllerExt.systemSelecedOption = 'VIBGUARD Viewer';
		controllerExt.activationCode = '';
		System.assertEquals(null, controllerExt.doFilterOrders() );
		
		// All button
		controllerExt.systemSelecedOption = 'All';
		System.assertEquals(null, controllerExt.doShowAllOrders() );
		
		// Edit Order
		System.assertEquals('/apex/aseditorder', controllerExt.doOrderEdit().getUrl() );
		
		// Delete Order
		controllerExt.orderIdToDelete = cmo2.Id;
		System.assertEquals(null, controllerExt.doDeleteOrder());
		
		// system picklist
		System.assert(controllerExt.getSystemOptions().size()> 1);
		
		// initial order table state
		controllerExt.activationCode = '';
		controllerExt.systemSelecedOption = null;
		System.assert(controllerExt.getOrdersTableContent().size() != null);
	 }
	
}