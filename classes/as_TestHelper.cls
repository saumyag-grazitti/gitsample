public class as_TestHelper {
    
    /* Account */
    public static Account createTestAccount(boolean makeinsert) {
        Account a = new Account();
        a.Name = 'testaccount ' + String.valueOf(Math.random()).substring(0,4);
        a.Phone = '+12-34-56789-0';
        a.sf42_gl_ALI__c = TRUE;
        a.CurrencyIsoCode = 'EUR';
        a.Industry = 'Chemicals';
        a.Industry_subcategory__c = 'Other';
        a.BillingCountry = 'Germany';
        a.BillingPostalCode = '51-180';
        
        if (makeinsert) insert a;
        return a;
    }
    
    /* CM Sales Channel */
    public static ptt_cm_Sales_Channel__c createCmSalesChannel (boolean makeinsert) {
        Account a = createTestAccount(TRUE);
        ptt_cm_Sales_Channel__c record = new ptt_cm_Sales_Channel__c();
        // Reqired fields
        record.Account_Name__c = a.Id; 
        // Optional fileds
        
        if (makeinsert) insert record;
        return record;
    }
    
    /*  CM Custom Package */
    public static CM_Custom_Package__c createCmCustomPackage (boolean makeinsert) {
        CM_Custom_Package__c record = new CM_Custom_Package__c();
        record.ptt_System__c = 'VIBGUARD Viewer';
        record.ptt_Variant__c = 'Server';
        record.ptt_IdCode__c = 'VIB 6.' + String.valueOf(Math.random()).substring(3,6);
        record.Name = 'My test Package';
            
        if (makeinsert) insert record;
        return record;
    }
    
    /* CM Feature Item */
    public static CM_Feature_Item__c createCmFeatureItem(boolean makeinsert) {
        CM_Feature_Item__c record = new CM_Feature_Item__c();
        record.ptt_Code__c = 'VIB 2.' + String.valueOf(Math.random()).substring(3,6);
        record.ptt_Is_Multiorder__c = TRUE;
        record.ptt_Key__c = 'VGDV_TEST';
        record.ptt_System__c = 'VIBGUARD Viewer';
        record.ptt_Variant__c = 'Server';
            
        if (makeinsert) insert record;
        return record;
    }
    
    /* CM CD Srial Number */
    public static CM_CD_Serial_Number__c createCmCDSerialNumber(boolean makeinsert) {
        CM_CD_Serial_Number__c record = new CM_CD_Serial_Number__c();
        record.Name = '00'+ String.valueOf(Math.random()).substring(3,6);
        record.ptt_Activation_Code__c = 'R842-Q8CA-47HO-C' +  + String.valueOf(Math.random()).substring(3,6);
            
        if (makeinsert) insert record;
        return record;
    }
    
    /* CM Order */
    public static ptt_cm_Order__c createCmOrder (boolean makeinsert) {
        ptt_cm_Sales_Channel__c sc = createCmSalesChannel(TRUE);
        ptt_cm_Order__c record = new ptt_cm_Order__c();
        // Reqired fields
        record.ptt_System__c = 'VIBGUARD Viewer';
        // Optional fields
        record.ptt_Sales_Channel__c = sc.Id;
        record.ptt_Variant__c = 'Server';
        record.ptt_CD_Serial_Number__c = createCDSerialNo(TRUE).Id;
        record.ptt_ProductID__c = '123456789';
            
        if (makeinsert) insert record;
        return record;
    }
    
    /* CD Serial No */
    public static CM_CD_Serial_Number__c createCDSerialNo (boolean makeinsert) {
    	CM_CD_Serial_Number__c record = new CM_CD_Serial_Number__c();
    	record.Name = '00' + String.valueOf(Math.random()).substring(3,6);
    	record.ptt_Activation_Code__c = 'Q81M-PZ30-XKI1-4' + String.valueOf(Math.random()).substring(3,6);
    	if (makeinsert) insert record;
        return record;
    }

    /* End User data */
    public static ptt_cm_End_User__c createCmEndUserData(boolean makeinsert) {
        ptt_cm_End_User__c record = new ptt_cm_End_User__c();
        record.Name = 'Pruftechnik';
        record.ptt_Street__c = 'Street';
        record.ptt_Email__c = 'p.wozniak@pruftechnik.com.pl';
        record.ptt_Zip_Postal_Code__c = '51-180';
        record.ptt_Industry__c = 'Automotive';
        record.ptt_City__c = 'Wroclaw';
        record.ptt_Industry_subcategory__c = 'Other';
        record.ptt_State__c = 'dolnoslaskie';
        record.ptt_Country2__c = 'Poland';   
        record.ptt_CM_Order__c = createCmOrder(TRUE).Id;
            
        if (makeinsert) insert record;
        return record;
    }
    
    /* End User data for given Order*/
    public static ptt_cm_End_User__c createCmEndUserDataForGivenOrder(Id orderId, boolean makeinsert) {
        ptt_cm_End_User__c record = createCmEndUserData(FALSE);
        record.ptt_CM_Order__c = orderId;
            
        if (makeinsert) insert record;
        return record;
    }
    
    /*** Macros ***/
    public static ptt_cm_Order__c  createOrderWithEndUser (boolean makeinsert){
        ptt_cm_Order__c o = createCmOrder(TRUE);
        ptt_cm_End_User__c eu = createCmEndUserDataForGivenOrder(o.Id, TRUE);
        return o;
    }
    
    public static ptt_cm_Order__c  createActiveOrderWithPackages (boolean makeinsert){
    	// Create custom package
    	createCmCustomPackage(TRUE);
    	
    	
    	ptt_cm_Order__c o = createCmOrder(TRUE);
    	return o;
    }
    
}