@isTest 
public class as_NewSalesChannelController_Test {

    public static testMethod void test_as_NewSalesChannelController() {
        // Set page in context
        PageReference pageRef = Page.asNewSalesChannel;
        Test.setCurrentPage(pageRef);
     
    	// Set Controller in context  
		as_NewSalesChannelController controller = new as_NewSalesChannelController(new ApexPages.StandardController(new ptt_cm_Sales_Channel__c()));
	
		// Start testing
		
		// Save with unique account Id
        Account a1 = as_TestHelper.createTestAccount(TRUE);
        controller.SalesChannelObj.Account_Name__c = a1.Id;
 		System.assertEquals('/apex/assaleschanneloverview', controller.doSave().getUrl() );       
        
        // Save with duplicated account ID
        // Create duplicated sales channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(FALSE);
		sc.Account_Name__c = a1.Id;
		insert sc;
		
		controller.SalesChannelObj.Account_Name__c = a1.Id;
		controller.doSave();
	
		// Check if getting Save error
		System.assert(TRUE,  ApexPages.hasMessages() );
		
		// Check Cancel redirection
		System.assertEquals('/apex/assaleschanneloverview', controller.doCancel().getUrl() );
		
	}
}