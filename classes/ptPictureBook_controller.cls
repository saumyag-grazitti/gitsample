public class ptPictureBook_controller {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    String bu = '';
    
    // Variables with default get set methods
    public User userObj {get; set;}
    public List<User> buUsers {get; set;}
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/

    public ptPictureBook_controller() {
        userObj = new User();
        buUsers = new List<User>();
        userObj = [SELECT sf42_Business_Unit__c FROM User WHERE Id = :UserInfo.getUserId()]; 
    }
    
    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/
    
    public PageReference doShowBUUsers() {
        bu = userObj.sf42_Business_Unit__c;
        buUsers = [SELECT Id, FullPhotoUrl, Name, AboutMe, Email, Title, Phone, MobilePhone
                   FROM User 
                   WHERE sf42_Business_Unit__c = :bu 
                   AND IsActive = TRUE 
                   ORDER BY Lastname ASC];          
        return null;
    }
}