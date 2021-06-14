/**
* ===================================================================
* (c) PTT Technology 2013, Poland, All rights reserved
* ptt_Case_Trigger
* @author.....: Pawel Wozniak    
* @email......: pawel.wozniak@pruftechnik.com.pl
* @version....: V1.0
* @date.......: 2013-01-17 @update 2013-01-17
* Description.: --
* Objects.....: sf42_Project__c
* =================================================================
*/
trigger sf42_Project_Trigger on sf42_Project__c (after insert, after update) {
	
	if (Trigger.isAfter && Trigger.isUpdate ){ 
		updateCasesSharing();
    }
	
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/
    	
    public static void updateCasesSharing() { 	
   		List<CaseShare> newCaseShare = new List<CaseShare>();
    	List<ID> shareUsersIdsToDelete = new List<ID>();
		Set<Id> relatedCasesId = new Set<Id>();
		Set<Id> allProjectsId = new Set<Id>();
		
		// Colect all project ID in batch
    	allProjectsId = Trigger.newMap.keySet();
    	
    	// Get shares for all projects in batch
    	List<sf42_Project__Share> projectShares = new List<sf42_Project__Share>();
    	projectShares = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
					      FROM sf42_Project__Share 
						  WHERE ParentId IN :allProjectsId]; 	
    	
    	// Find all related cases
    	List<Case> allRealtedCases = new List<Case>();
		allRealtedCases.addAll([SELECT Id, ptt_Project__c FROM Case WHERE ptt_Project__c IN :allProjectsId]);
		
		// Copy shares from project to Case
		for (sf42_Project__c oneProject : Trigger.new) { 
    		for (Case currentCase : allRealtedCases) {
    			if (currentCase.ptt_Project__c == oneProject.Id) {
    				for (sf42_Project__Share ps : projectShares) {
	    				if(ps.ParentId == oneProject.Id) {	    				
							CaseShare cs = new CaseShare();
							cs.CaseId = currentCase.Id;
							cs.UserOrGroupId = ps.UserOrGroupId;
							cs.CaseAccessLevel = ps.AccessLevel.replace('All', 'Edit');
							newCaseShare.add(cs);
	    				}
    				}
    			}
    		}
    	}  	
	
		// Delete and insers shares
	    try {
	    	System.debug('@@ insert section');
	    	// Delete old Shares
	    	if (!shareUsersIdsToDelete.isEmpty()) {
				delete [SELECT id FROM CaseShare WHERE UserOrGroupId IN :shareUsersIdsToDelete and RowCause = 'Manual'];
	    	}
	    	// Add new Shares
	    	if (!newCaseShare.isEmpty()) {
				insert newCaseShare;
				System.debug('@@ after insert');
	    	}
	    } catch (exception e) {	
	    	system.debug ('@@ Case Share insert to DB failed: ' + e);
	    }
	}
    
}