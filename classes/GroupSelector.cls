/**
 * Created by yanagerasimchuk on 6/8/18.
 */

public with sharing class GroupSelector {

    public static List<Group> getPartnerExecutiveGroups() {
        return [
            SELECT Id, DeveloperName, Related.Name
            FROM Group
            WHERE (Type = :SharingConstants.ROLE_AND_SUBORDINATES_GROUP_TYPE
                AND DeveloperName LIKE '%PartnerExecutive%')
            ORDER BY DeveloperName
            LIMIT 10000
        ];
    }

    public static List<UserRole> getGroupRoles(Set<Id> roles) {
        return [
            SELECT Id, Name
            FROM UserRole
            WHERE Id IN :roles
            ORDER BY Name
            LIMIT 10000
        ];
    }

    public static List<UserRole> getExecutiveRoleByPartnerAccountID(Id accountId) {

        return [
            SELECT Id, Name, PortalAccountId, ParentRoleId, PortalRole, PortalType
            FROM UserRole
            WHERE PortalAccountId = :accountId
                AND PortalRole = :SharingConstants.EXECUTIVE_PORTAL_ROLE
                AND PortalType = :SharingConstants.PARTNER_PORTAL_TYPE
            LIMIT 1
        ];
    }
    
    public static Id getGroupIdByUserId(Id userId) {

        Id groupId;

        List<User> users = [
                Select Id, Name, UserRole.Name, AccountId
                FROM User
                WHERE Id = :userId
                LIMIT 1
        ];

        if (!users.isEmpty()) {

            List<UserRole> partnerExecutiveRole = getExecutiveRoleByPartnerAccountID(users[0].AccountId);

            if (!partnerExecutiveRole.isEmpty()) {

                List<Group> groups = [
                        SELECT Id, RelatedId, Type
                        FROM Group
                        WHERE (RelatedId = :partnerExecutiveRole[0].Id
                            AND Type = :SharingConstants.ROLE_AND_SUBORDINATES_GROUP_TYPE)
                        LIMIT 2
                ];

                if (!groups.isEmpty()) {
                    groupId = groups[0].Id;
                }
            }
        }
        return groupId;
    }
    
    public static Map<Id, Id> getPartnerUserAccounts(Set<Id> partnerAccountIds) {
        
        Map<Id, Id> partnerUsers = new  Map<Id, Id>();
        
        for (User userDetails : [
                SELECT Id, UserRole.PortalAccountId
                FROM User
                WHERE UserRole.PortalAccountId IN :partnerAccountIds
                LIMIT 10000
        ]) {
            partnerUsers.put(userDetails.Id, userDetails.UserRole.PortalAccountId);
        }
        return partnerUsers;
    }
    
    public static Id getPartnerAccountIdByUserId(Id userRoleId) {
        
       	List<User> userDetails = [
 			SELECT Id, UserRole.PortalAccountId
			FROM User
			WHERE Id = :userRoleId
            LIMIT 2
        ];
        
        return userDetails.isEmpty() ? null : userDetails[0].UserRole.PortalAccountId;
    }
}