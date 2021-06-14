@isTest
public class as_SalesChannelOverviewController_Test {

    public static testMethod void test_as_SalesChannelOverviewController() {
    	/************ Configure enviroment ************/
 
        /**** Prepare database structure ****/
        
        // Create Order, with SC and Account
        ptt_cm_Order__c cmo = as_TestHelper.createCmOrder(TRUE);
        cmo.ptt_Activation_Code__c = [SELECT ptt_Activation_Code__c FROM ptt_cm_Order__c WHERE Id = :cmo.Id].ptt_Activation_Code__c ;   // There is a workflow rule which search for ACode by given CD Serial no, aftersave.
        ptt_cm_Sales_Channel__c sc = [SELECT Id, Name FROM ptt_cm_Sales_Channel__c WHERE Id = :cmo.ptt_Sales_Channel__c];             
        /**** Set page in context ****/
        PageReference pageRef = Page.asSalesChannelOverview;
        Test.setCurrentPage(pageRef);
    
        /**** Set Controller in context ****/
        as_SalesChannelOverviewController controller = new as_SalesChannelOverviewController(new ApexPages.StandardController(new ptt_cm_Sales_Channel__c()));
    
        /************** Start testing *************/
    	        
        /* Buttons */
        // Verify if proper URL returned when clicked on new Sales Channel button
        String NewSalesChannelURL = controller.doCreateNewSalesChannel().getUrl();
        System.assertEquals('/apex/asnewsaleschannel', NewSalesChannelURL);
        
        /* Searching for Name */
		// Search for random string, should return empty list
		controller.searchName = 'aazzee';
        controller.doFilter();
        System.assertEquals(0, controller.getScTableContent().size()); // No results shoulb be returned
        
        // Search for real SC name, should return 1 entry
 		controller.searchName = sc.Name;
        controller.doFilter();
        System.assertEquals(1, controller.getScTableContent().size()); // One SC should be found     
        System.assertEquals(sc.Name, controller.getScTableContent().get(0).Name); // Name should be equals
        
        // Show All names, reset filter
        controller.doShowAll(); 
        System.assertEquals('', controller.searchName);
        System.assertEquals('', controller.activationCode);
        
		/* Searching for Activation Code */       
		// Search for random ActCode, should return empty list
		controller.activationCode = 'mkasdfmkmk';
		controller.doFilterActCode();
		System.assertEquals(TRUE, controller.orderTableRendered);
		System.assertEquals(0, controller.getOrdersTableContent().size()); // No results shoulb be returned
		
		// Search for real ActCode, should be one returned
		controller.activationCode = cmo.ptt_Activation_Code__c;
		controller.doFilterActCode();  
		System.assertEquals(TRUE, controller.orderTableRendered);
		System.assertEquals(1, controller.getOrdersTableContent().size());
		System.assertEquals(cmo.ptt_Activation_Code__c, controller.getOrdersTableContent().get(0).ptt_Activation_Code__c);
		
		// Show all Activation Codes
		controller.doShowAllActCodes(); 
        System.assertEquals('', controller.searchName);
        System.assertEquals('', controller.activationCode);
		
    }
}