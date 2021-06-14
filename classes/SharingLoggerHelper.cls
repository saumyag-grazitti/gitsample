/**
 * Created by yanagerasimchuk on 5/28/18.
 */

public with sharing class SharingLoggerHelper {

    public static void logOperation(List<Account_Owner_Sharing__c> sharings, String status, String message) {

        if (sharings != null && !sharings.isEmpty()) {
			
            List<Sharing_logger__c> loggers = new List<Sharing_logger__c>();
            
            for (Account_Owner_Sharing__c sharing : sharings) {
				loggers.add(new Sharing_logger__c(
                        Account_Owner_Sharing__c = sharing.Id,
                        Status__c = status, 
                        Message__c = message
                ));
            }
            insert loggers;
        }
    }
    
    public static void logOperation(List<TerritorySharingWrapper> sharings, String status, String message) {

        if (sharings != null && !sharings.isEmpty()) {
			
            List<Sharing_logger__c> loggers = new List<Sharing_logger__c>();
            
            for (TerritorySharingWrapper sharingWrapper : sharings) {
				loggers.add(new Sharing_logger__c (
                        Territory_Sharing__c = sharingWrapper.sharing.Id,
                        Status__c = status, 
                        Message__c = message
                ));
            }
            insert loggers;
        }
    }
}