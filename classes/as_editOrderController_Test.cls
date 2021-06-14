@isTest
public with sharing class as_editOrderController_Test {

 	public static testMethod void test_editOrderControllerController() {
        // Set page in context
        PageReference pageRef = Page.asCreateLicense;
        Test.setCurrentPage(pageRef);
     	
     	// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Crete end user data
		ptt_cm_End_User__c eud = as_TestHelper.createCmEndUserData(TRUE);
		
		// Insert CD Serial number
		CM_CD_Serial_Number__c csn = as_TestHelper.createCmCDSerialNumber(TRUE);
		
		// Insert order
		ptt_cm_Order__c cmo = as_TestHelper.createCmOrder(FALSE);
		cmo.ptt_Sales_Channel__c = sc.Id;
		cmo.ptt_End_User__c = eud.Id;
		cmo.ptt_CD_Serial_Number__c = csn.Id;
		cmo.ptt_ProductID__c = '123456789';
		cmo.ptt_Is_Active__c = TRUE;
		cmo.ptt_Activation_Counter__c = 0;
		insert cmo;
     	
     	// Add URL parameters
		ApexPages.currentPage().getParameters().put('Id', cmo.Id); 
    	
     
    	// Set Controller in context  
		as_editOrderController controllerExt = new as_editOrderController (new ApexPages.StandardController(cmo) );
	   
     	// Save button
     	System.assertEquals(null, controllerExt.orderSave() );
     	
     	// Back button
     	System.assertEquals('/apex/assaleschanneldetails?Id=' + sc.Id, controllerExt.orderEditBack().getUrl() );
     	
        // Create License button
        System.assertEquals('/apex/ascreatelicense?orderId=' + cmo.Id, controllerExt.doCreateLicense().getUrl() );
     	
        // Reset button
        System.assertEquals('/apex/asresetcounter?orderId=' + cmo.Id, controllerExt.doResetCounter().getUrl() );
     	
        // Details button
       // System.assertEquals('/apex/aseditordernumbers?orderId=' + cmo.Id, controllerExt.doEditOrderNumbers().getUrl() );
     	
     	// Add button
     //	System.assertEquals('/apex/asaddcustompackage?orderId=' + cmo.Id, controllerExt.doAddPackage().getUrl() );
     
        // Del link
        // Create custom package
		CM_Custom_Package__c cp = as_TestHelper.createCmCustomPackage(TRUE);
        controllerExt.selectedPackageId = cp.Id;
        System.assertEquals(null, controllerExt.doDeletePackage() );
     
        
 	}     
        
}