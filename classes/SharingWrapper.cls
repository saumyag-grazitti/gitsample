/**
 * Created by yanagerasimchuk on 5/25/18.
 */

public with sharing class SharingWrapper {
	
    public Id customSharingRuleId { get; private set;}
    public Set<Id> usersOrGroupId { get; private set;}
    public String accountAccessLevel { get; private set;}
    public String leadAccessLevel { get; private set;}
    public String contactAccessLevel { get; private set;}
    public String opportunityAccessLevel { get; private set;}
    public String caseAccessLevel { get; private set;}
    public String deviceAccessLevel { get; private set;}
    public String servicesDemosAccessLevel { get; private set;}
    public String activityAccessLevel { get; private set;}
    
    public SharingWrapper(Territory_Sharing__c sharing) {
        this.customSharingRuleId = sharing.Id;
        this.usersOrGroupId = new Set<Id>();
        this.usersOrGroupId.add(sharing.Group_Id_To_Share_Record_With__c);
        this.accountAccessLevel = sharing.Account_Access_Level__c;
        this.leadAccessLevel = sharing.Lead_Access_Level__c;
        this.contactAccessLevel = sharing.Contact_Access_Level__c;
        this.opportunityAccessLevel = sharing.Opportunity_Access_Level__c;
        this.caseAccessLevel = sharing.Case_Access_Level__c;
        this.deviceAccessLevel = sharing.Device_Access_Level__c;
        this.servicesDemosAccessLevel = sharing.Services_Demos_Access_Level__c;
        this.activityAccessLevel = sharing.Activity_Access_Level__c;
    }

    public SharingWrapper(Account_Owner_Sharing__c sharing, Set<Id> userIds) {
        this.customSharingRuleId = sharing.Id;
        this.usersOrGroupId = new Set<Id>();
        this.usersOrGroupId.addAll(userIds);
        this.deviceAccessLevel = sharing.Device_Access_Level__c;
        this.servicesDemosAccessLevel = sharing.Services_Demos_Access_Level__c;
        this.activityAccessLevel = sharing.Activity_Access_Level__c;
        this.accountAccessLevel = SharingConstants.DEFAULT_LEVEL_ACCESS;
        this.leadAccessLevel = SharingConstants.DEFAULT_LEVEL_ACCESS;
    }
}