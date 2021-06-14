public class as_Exceptions {

	/* License Generator Exceptions */
	public virtual class licGenException extends Exception {
		/* Global variables */
		String details = '';
		  
    	/* Constructor */
    	public licGenException(String message, String errorDetails) {
	        // Pass 'message' to the base class
	        this.setMessage(message);
	        this.details = errorDetails;
    	}
    	
    	/* Getters */
    	public String getDetails() {
    		return this.details;
    	}
    	
	}
	
		// Sub exceptions
	//	public class manyNotMultiorderFeaturesSelectedException extends licGenException {}
	//	public class activationCodeNotFoundException extends licGenException {}
	
}