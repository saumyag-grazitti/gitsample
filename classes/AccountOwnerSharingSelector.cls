/**
 * Created by yanagerasimchuk on 6/15/18.
 */

public with sharing class AccountOwnerSharingSelector {

    public static Map<Id, Account_Owner_Sharing__c> getSharingsByPartnerAccountIds(List<Id> accountIds) {

        Map<Id, Account_Owner_Sharing__c> ownerBasedSharings = new Map<Id, Account_Owner_Sharing__c>();

        for (Account_Owner_Sharing__c sharing: [
                SELECT Id, Partner_Account__c,
                Services_Demos_Access_Level__c, Activity_Access_Level__c, Device_Access_Level__c
                FROM Account_Owner_Sharing__c
                WHERE Partner_Account__c IN :accountIds
                LIMIT 100000
            ]) {
            ownerBasedSharings.put(sharing.Partner_Account__c, sharing);
        }
        return ownerBasedSharings;
    }

    public static List<Account_Owner_Sharing__c> getSharingByPartnerAccountId(Id accountId) {
        return [
                SELECT Activity_Access_Level__c
                FROM Account_Owner_Sharing__c
                WHERE Partner_Account__c = :accountId
                LIMIT 2
        ];
    }

    public static Map<Id, Account_Owner_Sharing__c> getSharingMapByPartnerAccountId(Id accountId) {
        return new Map<Id, Account_Owner_Sharing__c>([
                SELECT Activity_Access_Level__c
                FROM Account_Owner_Sharing__c
                WHERE Partner_Account__c = :accountId
                LIMIT 2
        ]);
    }
}