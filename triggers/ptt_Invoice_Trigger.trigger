/**
* ===================================================================
* (c) PT Technology 2011, Poland, All rights reserved
* ptt_Case_Trigger
* @author.....: Pawel Wozniak    
* @email......: pawel.wozniak@pruftechnik.com.pl
* @version....: V0.1 this code is quick written and dirty need to be changed
* @date.......: 2011-10-24
* Description.: Search for last invoice nuber from current BU and add 1
* Objects.....: Invoice 
* =================================================================
*/

trigger ptt_Invoice_Trigger on sf42_Invoice__c (before insert) {
    for (sf42_Invoice__c invoiceNew : Trigger.New) {
        
        // Get Creator ID
        Id creatorID = UserInfo.getUserId();
        User Owner = [Select User.sf42_Business_Unit__c From User where User.Id = :creatorId];
        
        // Create country prefix based on BU Name
        String butxt = Owner.sf42_Business_Unit__c ;
        String invCountryID = '';
        String separator = '';
        if (butxt.startsWith('Belgium')) {
            invCountryID = 'BE';
            separator = '-';
        } else
        if (butxt.startsWith('Brasil')) {
            invCountryID = 'BR';
            separator = '-';
        } else
        if (butxt.startsWith('Canada')) {
            invCountryID = 'CA';
            separator = '-';
        } else
        if (butxt.startsWith('China')) {
            invCountryID = 'CN';
            separator = '-';
        } else
        if (butxt.startsWith('France')) {
            invCountryID = 'FR';
            separator = '-';
        } else
        if (butxt.startsWith('Germany')) {
            invCountryID = 'GE';
            separator = '-';
        } else
        if (butxt.startsWith('Italy')) {
            invCountryID = 'IT';
            separator = '-';
        } else
        if (butxt.startsWith('Japan')) {
            invCountryID = '';
            separator = '';
        } else
        if (butxt.startsWith('Poland')) {
            invCountryID = 'PL';
            separator = '-';
        } else
        if (butxt.startsWith('Russia')) {
            invCountryID = 'RU';
            separator = '-';
        } else
        if (butxt.startsWith('Singapore')) {
            invCountryID = 'SG';
            separator = '-';
        } else
        if (butxt.startsWith('Spain')) {
            invCountryID = 'ES';
            separator = '-';
        } else
        if (butxt.startsWith('UK')) {
            invCountryID = 'UK';
            separator = '-';
        } else
        if (butxt.startsWith('USA')) {
            invCountryID = 'US';
            separator = '-';
        } 
        
        // Current year  
        Integer invYear = Date.today().year();
        
        
        // Number Prefix
        String prefix = invCountryID + separator + invYear + separator;
        Integer prefixLen = prefix.length();
        
        // Find last invoice number for that country
        String lastInvNoString = '';
        try {
        sf42_Invoice__c lastInv = [Select s.ptt_gl_invoice_number__c, s.Name, s.CreatedDate, s.CreatedBy.sf42_Business_Unit__c, s.CreatedById From sf42_Invoice__c s WHERE s.CreatedBy.sf42_Business_Unit__c = :butxt ORDER BY s.CreatedDate DESC Limit 1];
        lastInvNoString = lastInv.ptt_gl_invoice_number__c;
        }
        catch (Exception e){
            // Exception is caused when country has no Invoices at all. Then query results is null
            lastInvNoString = prefix + '00001';
        }
        
        try {
        lastInvNoString = lastInvNoString.substring(prefixLen);
        }
        catch (Exception e){
            // The same like previous exception
            lastInvNoString = '00001';
        }
        // system.debug('Last inv number: ' + lastInvNoString);
        
        Integer lastInvNumber = Integer.valueOf(lastInvNoString);
                
        // Increment
        integer newInvNumber = lastInvNumber + 1;
        
        String newInvNoStr = '';
        newInvNoStr = newInvNoStr + newInvNumber;
        Integer newInvNoStrLen = newInvNoStr.length();
        
        String zeros = '';
        Integer i = 0;
        Integer stop = 5 - newInvNoStrLen;
        for (i=0 ; i<stop ; i++){
            zeros = zeros + '0';
        }
            
        // OUTPUT Save value to field ptt_gl_invoice_number
        invoiceNew.ptt_gl_invoice_number__c = prefix + zeros + newInvNumber ;
            
    }
}