public class as_AddCustomPackageController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    String orderId = '';
    List<CM_Custom_Package__c> avaliablePackages = new List<CM_Custom_Package__c>();
    List<CM_Selected_Package__c> orderExistingPackages = new List<CM_Selected_Package__c>();
    
    // Variables with default get set methods
    public ptt_cm_Order__c cmOrderObj { get; set; }
    
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_AddCustomPackageController() {
        orderId = ApexPages.currentPage().getParameters().get('orderId'); // Extract Order Id from URL parameter
        
        // Get information about order
        cmOrderObj = [SELECT id, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Activation_counter__c
                      FROM ptt_cm_Order__c 
                      WHERE id = :orderId];
                      
        avaliablePackages = generateAvaliablePackagesList(cmOrderObj);
                 
    }
    
    /*************** Getters ****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
   
    /* Avaliable packages Table content */
    public List<CM_Custom_Package__c> getCustomPackagesTableContent() {        
        return this.avaliablePackages;
    }
    
    /*************** Buttons ****************/
    /*** Actions invoked by custom buttons **/
    /****************************************/    
    
    /* Back */
    public PageReference BackToOrder() {
        PageReference pr = Page.asEditOrder;
        pr.getParameters().put('Id', orderId);
        return pr;
    }

    /* Save */
    public PageReference SaveSelectedPackages() {
        List <CM_Selected_Package__c> addToSelectedPackages = new List <CM_Selected_Package__c>(); // List of new packages to be added
        integer q = 0; // Counter for Quantity
        Integer quantity = 0;
        Integer index = 0;
        
        for (CM_Custom_Package__c singleCustPackage : avaliablePackages) {
            // If there is one or more selected
            if (singleCustPackage.ptt_Quantity__c > 0) {
                // Check for not multiorder packages which have more than 1 in Quantity
                if (singleCustPackage.ptt_isMultiorder__c == FALSE && singleCustPackage.ptt_Quantity__c > 1 ) { 
                    singleCustPackage.ptt_Quantity__c.addError('Maximum 1 package is allowed');  
                    return null;                
                } 
                // Add packages to linking object CM_Selected_Package__c
                quantity = (integer) singleCustPackage.ptt_Quantity__c; 
                if (singleCustPackage.ptt_index__c == null) {index = 0;} 
                else {index = (integer) singleCustPackage.ptt_index__c;}
                for (q = 0; q < quantity; q++) {  
                    CM_Selected_Package__c tempSelPackage = new CM_Selected_Package__c();   
                    
                    index++;          
                    tempSelPackage.ptt_CM_Custom_Package__c = singleCustPackage.Id;
                    tempSelPackage.ptt_CM_Order__c = orderId;
                    tempSelPackage.ptt_isActive__c = FALSE;
                    tempSelPackage.ptt_index__c = index;
                    addToSelectedPackages.add(tempSelPackage);
                }            
            } else {
                if (singleCustPackage.ptt_Quantity__c < 0) {
                    singleCustPackage.ptt_Quantity__c.addError('Value not allowed.');
                    return null;
                }
            }
        }

        insert addToSelectedPackages;
        // TODO: Reset activation counter, save that event to log?

        // Redirect to EditOrder screen
        PageReference pr = Page.asEditOrder;
        pr.getParameters().put('Id', orderId);
        return pr;    
    }
    
    /****************************************/
    /*** Class specific helper functions ****/
    /****************************************/
    
    /**
    *  This class prepare a list of avaliable packages excluding not multiorder packages which are already selected.
    *  Additionally it search for highest index of last smae type package and add it to index field.
    * 
    *  @param cmOrder Order object with ID, ptt_system__c, ptt_variant__c
    *  @return list for dataTable component with all avalible packages that can added to order.
    */
    List<CM_Custom_Package__c> generateAvaliablePackagesList (ptt_cm_Order__c cmOrder ){     
        List<CM_Selected_Package__c> orderExistingPackages = new List<CM_Selected_Package__c>();
        List<CM_Custom_Package__c> avaliablePackages = new List<CM_Custom_Package__c>();
        
        // Get all avaliable packages
        Map<Id, CM_Custom_Package__c> allPackagesMap = new Map<Id, CM_Custom_Package__c>([
            SELECT Id, name, ptt_IdCode__c, ptt_System__c, ptt_variant__c, ptt_isMultiorder__c, ptt_Quantity__c, ptt_Index__c
            FROM CM_Custom_Package__c
            WHERE ptt_system__c = :cmOrder.ptt_system__c
            AND ptt_variant__c INCLUDES (:cmOrder.ptt_variant__c)
            ORDER BY ptt_IdCode__c ASC]);
                        
        // Get a list of packages already assigned for this order                
        orderExistingPackages = [SELECT id, Name, ptt_Index__c, ptt_CM_Custom_Package__c
                                 FROM CM_Selected_Package__c
                                 WHERE ptt_CM_Order__c = :cmOrder.Id];   
                                 
        // Go througth ExistingPackages and remove already existing not Multiorder ones
        for (CM_Selected_Package__c existingPackage : orderExistingPackages ) {
            if (allPackagesMap.get(existingPackage.ptt_CM_Custom_Package__c).ptt_isMultiorder__c == FALSE){
                allPackagesMap.remove(existingPackage.ptt_CM_Custom_Package__c); //remove not multiorder package from Map of all Avaliable pkgs  
            }
        }
        
        // Find max value of Indexes for all selected packages;
        List <AggregateResult> highestIndexes = [SELECT ptt_CM_Custom_Package__c, MAX(ptt_Index__c)
                                             FROM CM_Selected_Package__c
                                             WHERE ptt_CM_Order__c = :orderId
                                             GROUP BY ptt_CM_Custom_Package__c];                                      
                                             
        // Fill the packagesIndexes map with results 
        for (AggregateResult singleIndex : highestIndexes) {
            // Search for all already selected packages in the map of All avaliable packages and update Index value
            if (allPackagesMap.containsKey((Id)singleIndex.get('ptt_CM_Custom_Package__c'))) { //To avoid errors check if this entry exists.
                CM_Custom_Package__c tmpPackage = allPackagesMap.get((Id)singleIndex.get('ptt_CM_Custom_Package__c')); // Read record
                tmpPackage.ptt_Index__c = (Decimal)singleIndex.get('expr0'); // insert Index value
                allPackagesMap.put(tmpPackage.Id, tmpPackage); // update record in Map
            }
        }
                               
        // Convert Map to List and sort values
        avaliablePackages = allPackagesMap.values();
        avaliablePackages.sort();
    
        return avaliablePackages;
    }
}