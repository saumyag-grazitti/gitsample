@isTest
public with sharing class as_CreateLicenseController_Test {
	 	 
	public static testMethod void test_as_CreateLicenseController() {
 
     	// Create Sales Channel
		ptt_cm_Sales_Channel__c sc = as_TestHelper.createCmSalesChannel(TRUE);
		
		// Crete end user data
		ptt_cm_End_User__c eud = as_TestHelper.createCmEndUserData(TRUE);
		
		// Insert CD Serial number
		CM_CD_Serial_Number__c csn = as_TestHelper.createCmCDSerialNumber(TRUE);
		
		// Insert order
		ptt_cm_Order__c cmo1 = as_TestHelper.createCmOrder(FALSE);
		cmo1.ptt_Sales_Channel__c = sc.Id;
		cmo1.ptt_End_User__c = eud.Id;
		cmo1.ptt_CD_Serial_Number__c = csn.Id;
		cmo1.ptt_ProductID__c = '123456789';
		cmo1.ptt_Is_Active__c = TRUE;
		cmo1.ptt_Activation_Counter__c = 0;
		insert cmo1;
		
		// Create custom package
		CM_Custom_Package__c cp = as_TestHelper.createCmCustomPackage(TRUE);
		
		// Link Package against Order
		CM_Selected_Package__c selpkg = new CM_Selected_Package__c();
		selpkg.ptt_CM_Custom_Package__c = cp.Id;
		selpkg.ptt_CM_Order__c = cmo1.Id;
		selpkg.ptt_IsActive__c = TRUE;
		selpkg.ptt_Index__c = 1;
		insert selpkg;
		
		// Create Feature item
		CM_Feature_Item__c fi = as_TestHelper.createCmFeatureItem(TRUE);
		
		CM_Selected_Feature__c sf = new CM_Selected_Feature__c();
		sf.ptt_CM_Custom_Package__c = cp.Id;
		sf.ptt_CM_Feature_Item__c = fi.id;
		sf.ptt_Quantity__c = 2;
		insert sf;
		       
		PageReference pageRef = Page.asCreateLicense;
        Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('orderId', cmo1.Id); 
    	
		as_CreateLicenseController controller = new as_CreateLicenseController();
	
        
	    Test.setMock(HttpCalloutMock.class, new as_CreateLicenseControllerMock());

	    Test.startTest();

		// Create license button
		controller.CommentText = 'Test license create';
		System.assertEquals(null, controller.CreateLic());

		Test.stopTest();

		// Back button
		System.assertEquals('/apex/aseditorder?Id=' + cmo1.Id, controller.Back().getUrl() );
		
		// Check if Order is not active
		cmo1.ptt_Is_Active__c = FALSE;
		controller.CommentText = 'Test license create';
		controller.CreateLic();
	}
}