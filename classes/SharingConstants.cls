public with sharing class SharingConstants {

    //Object name and fiedls
    public static final String LOGGER_OBJECT_NAME = 'Sharing_Logger__c';
    public static final String SHARING_CRITERIA_OBJECT_NAME = 'Territory_Sharing_Criterion__c';
    public static final String TERRITORY_SHARING_OBJECT_NAME = 'Territory_Sharing__c';
    public static final String DEVICES_OBJECT = 'sf42_Devices__c';
    public static final String SERVICE_DEMOS_OBJECT = 'Service_and_Demontration__c';
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String LEAD_OBJECT = 'Lead';
    public static final String IS_PARTNER_ACCOUNT_FIELD = 'isPartner';
    public static final String OWNER_ID_FIELD = 'OwnerId';

    //Record Typed
    public static final String LEAD_CRITERIA = 'Lead_Criteria';
    public static final String ACCOUNT_CRITERIA = 'Account_Criteria';
    public static final String TERRITORY_SHARING_RECORD_TYPE = 'Territory_Sharing';

    //BATCH OPERATIONS
    public static final String ADD_OPERATION = 'add';
    public static final String UPDATE_OPERATION = 'update';
    public static final String DELETE_OPERATION = 'delete';

    //ACCESS LEVELS
    public static final String DEFAULT_LEVEL_ACCESS = 'None';
    public static final String VIEW_LEVEL_ACCESS = 'Read';
    public static final String EDIT_LEVEL_ACCESS = 'Edit';

    public static final Map<String, Integer> ACCESS_LEVEL_PRIORITY = new Map<String, Integer>{
    	EDIT_LEVEL_ACCESS => 2,
        VIEW_LEVEL_ACCESS => 1,
        DEFAULT_LEVEL_ACCESS => 0    
    };
        
    //Group and Portal Roles Constants
    public static final String EXECUTIVE_PORTAL_ROLE = 'Executive';
    public static final String PARTNER_PORTAL_TYPE = 'Partner';
    public static final String ROLE_AND_SUBORDINATES_GROUP_TYPE = 'RoleAndSubordinates';

    public static final List<String> ACCOUNT_OWNER_FIELDS = new List<String> {
            'Name',
            'Partner_account__r.sf42_Business_Unit__c',
            'Partner_account__c',
            'Device_Access_Level__c',
            'Services_Demos_Access_Level__c',
            'Activity_Access_Level__c'
    };

    public static Map<String, String> BUSINESS_UNIT_FIELD_BY_OBJECT = new Map<String, String>{
            LEAD_OBJECT => 'ptt_Bussines_Unit_formula__c',
            ACCOUNT_OBJECT => 'sf42_Business_Unit__c'
    };

    public static Map<String, String> ACCOUNT_LOOKUP_FIELD_BY_CHILD_OBJECT = new Map<String, String>{
            'Opportunity' => 'AccountId',
            'Case' => 'AccountId',
            'Contact' => 'AccountId',
            'sf42_Devices__c' => 'sf42_Account__c',
            'Service_and_Demontration__c' => 'sf42_Account__c'
    };

    public static final Map<String, String> OBJECT_BY_CRITERIA_TYPE = new Map<String, String> {
            LEAD_CRITERIA => LEAD_OBJECT,
            ACCOUNT_CRITERIA => ACCOUNT_OBJECT
    };

    public static final Map<String, String> CRITERIA_TYPE_BY_OBJECT = new Map<String, String> {
            LEAD_OBJECT => LEAD_CRITERIA ,
            ACCOUNT_OBJECT => ACCOUNT_CRITERIA
    };
        
    //Includes and Equals operators have the same logic (by Przemyslaw's request)
    public static final Map<String,String> OPERATION_CLASS_BY_OBJECT = new Map<String,String> {
            'equals' => 'IncludesOperator',
            'includes' => 'IncludesOperator',
            'starts with' => 'StartsWithOperator'
    };

    public static final Map<String, String> LOGICAL_OPERATOR_BY_OPERATION = new Map<String, String>{
            'equals' => 'IN',
            'includes' => 'IN',
            'starts with' => 'LIKE'
    };

    public static final Map<String, String> SHARING_RECALCULATION_CLASS_BY_OBJECT = new Map<String, String> {
            ACCOUNT_OBJECT  => 'AccountSharingRecalculation',
            LEAD_OBJECT => 'LeadSharingRecalculation'
    };

    public static final Map<String, Map<String, String>> CRITERIA_TO_OPERATION_TO_LABEL = new Map<String, Map<String, String>> {
            ACCOUNT_CRITERIA => new Map<String, String> {
                    ADD_OPERATION => Label.Added_Accounts_Success,
                    UPDATE_OPERATION => Label.Updated_Accounts_Success,
                    DELETE_OPERATION => Label.Deleted_Accounts_Success
            },
            LEAD_CRITERIA => new Map<String, String> {
                    ADD_OPERATION => Label.Added_Leads_Success,
                    UPDATE_OPERATION => Label.Updated_Leads_Success,
                    DELETE_OPERATION => Label.Deleted_Leads_Success
            }
    };
 
    public static final Map<String, String> OWNER_BASED_SHARINGS_LABEL_BY_OPERATION = new Map<String, String> {
		ADD_OPERATION => Label.Added_Owner_Based_Rules ,
		UPDATE_OPERATION => Label.Updated_Owner_Based_Rules,
		DELETE_OPERATION => Label.Deleted_Owner_Based_Rules 
    };
}