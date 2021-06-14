/**
 * Created by yanagerasimchuk on 5/31/18.
 */

public with sharing class ObjectAndSharingRuleMapper {

    public static Map<Id, List<SharingWrapper>> getSharingRulesForObjects(List<TerritorySharingWrapper> sharings, List<sObject> objects) {

        Map<Id, List<SharingWrapper>> objectSharingRules = new Map<Id, List<SharingWrapper>>();

        if (!objects.isEmpty()) {

            for (sObject obj : objects) {
                List<SharingWrapper> sharingWrappers = getTerritorySharingRules(sharings, obj);
                objectSharingRules.put(obj.Id, sharingWrappers);
            }
        }
        return objectSharingRules;
    }

    private static List<SharingWrapper> getTerritorySharingRules(List<TerritorySharingWrapper> sharings, sObject obj) {

        List<SharingWrapper> sharingWrappers = new  List<SharingWrapper>();

        String objectName = obj.getSObjectType().getDescribe().getName();
        String businessUnitField = SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(objectName);
        Object businessUnitValue = obj.get(businessUnitField);

        for (TerritorySharingWrapper sharingWrapper : sharings) {

            if (businessUnitValue != null && (String) businessUnitValue == sharingWrapper.sharing.Business_Unit__c) {

                Expression expr = new AndComposite();
                List<Territory_Sharing_Criterion__c> criteria = sharingWrapper.getCriteriaByObjectName(objectName);

                if (criteria.isEmpty()) {
                    sharingWrappers.add(new SharingWrapper(sharingWrapper.sharing));
                    continue;
                }

                for (Territory_Sharing_Criterion__c criterion : criteria) {
                    expr.add(new Variable(criterion));
                }

                expr.set(obj);

                if (expr.evaluate()) {
                    sharingWrappers.add(new SharingWrapper(sharingWrapper.sharing));
                }
            }
        }
        return sharingWrappers;
    }

    public static SharingWrapper getSharingRuleByObject(List<TerritorySharingWrapper> sharings, sObject obj) {

        if (obj != null) {
            
            String objectName = obj.getSObjectType().getDescribe().getName();
            String businessUnitField = SharingConstants.BUSINESS_UNIT_FIELD_BY_OBJECT.get(objectName);
            Object businessUnitValue = obj.get(businessUnitField);

            for (TerritorySharingWrapper sharingWrapper : sharings) {

                if (businessUnitValue != null && (String)businessUnitValue == sharingWrapper.sharing.Business_Unit__c) {

                    Expression expr = new AndComposite();
                    List<Territory_Sharing_Criterion__c> criteria = sharingWrapper.getCriteriaByObjectName(objectName);

                    if (criteria.isEmpty()) {
                        return new SharingWrapper(sharingWrapper.sharing);
                    }

                    for (Territory_Sharing_Criterion__c criterion : criteria) {
                        expr.add(new Variable(criterion));
                    }

                    expr.set(obj);

                    if (expr.evaluate()) {
                        return new SharingWrapper(sharingWrapper.sharing);
                    }
                }
            }
        }
        return null;
    }
}