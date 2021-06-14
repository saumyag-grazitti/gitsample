/**
 * Created by yanagerasimchuk on 5/28/18.
 */

public with sharing class RecordTypeSelector {

    public static Id getRecordTypeId(String objectName, String devName) {

        List<RecordType> recTypes = [
            SELECT Id, DeveloperName, sObjectType
            FROM RecordType
            WHERE (DeveloperName = :devName
                AND sObjectType = :objectName)
            LIMIT 2
        ];
        return recTypes.isEmpty() ? null : recTypes[0].Id;
    }
}