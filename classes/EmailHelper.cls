public with sharing class EmailHelper {

    public static void sendFinishedJobStatus(Id jobId) {
        
        AsyncApexJob asyncJob = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :jobId
                LIMIT 1
        ];
        
		String textBody = String.format('<p>Custom sharing rules have beed recalculated with {0} failures.</p>', 
                                         new List<String>{ String.valueOf(asyncJob.NumberOfErrors)});

        if (String.isNotBlank(asyncJob.ExtendedStatus)) {
            textBody += '<br/><p>' +  asyncJob.ExtendedStatus + '</p>';
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        mail.setSubject('Custom Sharing Rules Recalculation Batch ' + asyncJob.Status);
        mail.setHTMLBody(textBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    public static void sendFinishedJobStatus(String jobStatus, String textBody) { 
    	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});    
        mail.setSubject('Custom Sharing Rules Recalculation Batch ' + jobStatus);
        mail.setHTMLBody(textBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}