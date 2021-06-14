@isTest
public with sharing class as_newOrderController_Test {
 	
 	public static testMethod void test_as_NewCmOrder_noScId() {
 		/************ Configure enviroment ************/
 		
 		/**** Prepare database structure ****/		
		ptt_cm_Order__c cmo = new ptt_cm_Order__c();
 		
        /**** Set page in context ****/
        PageReference pageRef = Page.asNewOrder;
        Test.setCurrentPage(pageRef);
        
 		/**** Set url parameters ****/
 		// ApexPages.currentPage().getParameters().put('scId', sc.Id);     
    	
    	/**** Set Controller in context ****/  
		as_newOrderController controllerExt = new as_newOrderController (new ApexPages.StandardController(cmo) );
		
		
		/************** Start testing *************/
 		// Read error messages from page and check if there is one which should be displayed
 		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean hasMessage = false;
		for(Apexpages.Message msg : msgs){
		    if (msg.getDetail().contains('No SalesChannel Id provided.')) hasMessage = true;
		}
		system.assert(TRUE, hasMessage);
 	}
 		
 	public static testMethod void test_as_NewCmOrder() {
 		/************ Configure enviroment ************/
 		
 		/**** Prepare database structure ****/
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		ptt_cm_Order__c cmo = new ptt_cm_Order__c();
		
        /**** Set page in context ****/
        PageReference pageRef = Page.asNewOrder;
        Test.setCurrentPage(pageRef);
        
 		/**** Set url parameters ****/
 		ApexPages.currentPage().getParameters().put('scId', sc.Id);     
    	
    	/**** Set Controller in context ****/  
		as_newOrderController controllerExt = new as_newOrderController (new ApexPages.StandardController(cmo) );
		
		
		/************** Start testing *************/
		
		/* Save button without variant */
		cmo.ptt_System__c = 'Calimater';
		controllerExt.orderSave();
		
 		// Read error messages from page and check if there is one which should be displayed
 		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean hasMessage = false;
		for(Apexpages.Message msg : msgs){
		    if (msg.getDetail().contains('Please select Variant')) hasMessage = true;
		}
		system.assert(TRUE, hasMessage);
		
		/* Save button with variant */
		cmo.ptt_System__c = 'VIBGUARD Viewer';
		cmo.ptt_Variant__c = 'Server';
		controllerExt.orderSave();
		
		// Checking if saved properly
		ptt_cm_Order__c cmo2 = new ptt_cm_Order__c();
		cmo2 = [SELECT ptt_System__c, ptt_Variant__c FROM ptt_cm_Order__c WHERE Id = :cmo.Id];
		System.assertEquals(cmo.ptt_System__c, cmo2.ptt_System__c);
		System.assertEquals(cmo.ptt_Variant__c, cmo2.ptt_Variant__c);
		
		
		/* Back button */
		System.assertEquals('/apex/assaleschanneldetails?Id=' + sc.Id, controllerExt.orderBack().getUrl() );		

 	}

}