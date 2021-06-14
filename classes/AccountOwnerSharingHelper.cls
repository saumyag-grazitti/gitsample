/**
 * Created by yanagerasimchuk on 6/11/18.
 */

public with sharing class AccountOwnerSharingHelper {
    
    public static Boolean isDuplicate(Account_Owner_Sharing__c sharing) {
        Boolean isDuplicate = false;
        Map<Id, Account_Owner_Sharing__c> duplicateSharings = AccountOwnerSharingSelector.getSharingMapByPartnerAccountId(sharing.Partner_Account__c);
		System.debug(duplicateSharings);
        if (sharing.Id != null) {
            duplicateSharings.remove(sharing.Id);
        }
        if (!duplicateSharings.isEmpty()) {
            isDuplicate = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Sharing is duplicate.'));
        }
        return isDuplicate;
    }

    public static Boolean ruleNameIsBlank(String ruleName) {
        Boolean isBlank = false;
        if (String.isBlank(ruleName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rule Name is blank.'));
            isBlank = true;
        }
        return isBlank;
    }
}