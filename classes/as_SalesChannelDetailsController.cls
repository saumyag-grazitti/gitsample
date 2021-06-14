public class as_SalesChannelDetailsController {
    
    /****************************************/
    /***** Controller global variables ******/
    /****************************************/
    // Constants
    Static final Integer ACTIVATION_COUNTER_LIMIT = 3;
    
    // Variables
    private ptt_cm_Sales_Channel__c salesChannelObj; //Sales Channel Object
    ApexPages.StandardController stdController; // Standard controller
    String scId = ApexPages.currentPage().getParameters().get('Id');
    private String first_picklist_option = 'All'; //First item of System picklist    
    List<ptt_cm_Order__c> ordersList; // List of CM orders for table Orders List
    
    // Automatic get set
    public Id orderIdToDelete {get; set;}
    public String systemSelecedOption {get; set;} //picklist "System"
    public String orderNameToDelete {get; set;}
    public String isCreateLicenseDisabled {get; set;}
    public String activationCode {get; set;}

    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_SalesChannelDetailsController(ApexPages.StandardController controller) {
        this.stdController = controller;
        // Return the record that is currently in context, based on the id parameter in the Visualforce page URL.
        this.salesChannelObj = (ptt_cm_Sales_Channel__c)stdController.getRecord(); 
        activationCode = '';
    }   
    
    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
    
    // Generate System picklist options values
    public List<SelectOption> getSystemOptions() {   
        final sObject picklist_object = new ptt_cm_Order__c();
        return getPickValues(picklist_object, 'ptt_System__c', first_picklist_option);
    }

    // Generate initial values for Order List
    public List<ptt_cm_Order__c> getOrdersTableContent() {
        if (activationCode.length() == 0 && systemSelecedOption == null) {
            queryAllSCOrders(); // call the function which set up global variable value to all realted records
        }
        return this.ordersList;   
    }

    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/

    /* Save */
    public PageReference scSave() {
        stdController.save(); // Standard save action
        PageReference pr = Page.asSalesChannelOverview;
        pr.setRedirect(true);
        return pr;
    }

    /* Back */
    public PageReference scBack() {
        PageReference pr = Page.asSalesChannelOverview;
        pr.getParameters().put('nooverride','1');
        pr.setRedirect(true);
        return pr;
    }

    /* New Order */    
    public PageReference doNewOrder() {
        PageReference pr = page.asNewOrder;
        pr.getParameters().put('scId', SalesChannelObj.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    /* Filter */
    public PageReference doFilterOrders() {
        String queryText = '';
        if (activationCode.length() > 0) {
            queryText = String.escapeSingleQuotes(activationCode.replace('*','%'));
        }
        // When System is All and no Activation code entered
        if (systemSelecedOption.equals(first_picklist_option) && activationCode.length() == 0) {
            queryAllSCOrders();
        }
        // When System is All and Activation code is entered
        else if (systemSelecedOption.equals(first_picklist_option) && activationCode.length() > 0) {
        ordersList = [SELECT Id, name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Is_Active__c, ptt_Sales_Channel__c,
                     ptt_CD_Serial_Number__r.Name, ptt_Activation_Counter__c, ptt_ProductID__c, ptt_Active_CustomPackages__c, ptt_End_User__r.ptt_Company_Name__c
                    FROM ptt_cm_Order__c 
                    WHERE ptt_Sales_Channel__c = :scId 
                    AND ptt_Activation_Code__c LIKE :queryText
                    ORDER BY Name ASC ];
        } 
        // When System is not All and Activation code is entered
        else if (!systemSelecedOption.equals(first_picklist_option) && activationCode.length() > 0) {
        ordersList = [SELECT Id, name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Is_Active__c, ptt_Sales_Channel__c,
                     ptt_CD_Serial_Number__r.Name, ptt_Activation_Counter__c, ptt_ProductID__c, ptt_Active_CustomPackages__c, ptt_End_User__r.ptt_Company_Name__c
                    FROM ptt_cm_Order__c 
                    WHERE ptt_Sales_Channel__c = :scId 
                    AND ptt_System__c = :systemSelecedOption 
                    AND ptt_Activation_Code__c LIKE :queryText
                    ORDER BY Name ASC ];
        } 
        // When System is not All and no Activation code entered
        else if (!systemSelecedOption.equals(first_picklist_option) && activationCode.length() == 0) {
        ordersList = [SELECT Id, name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Is_Active__c, ptt_Sales_Channel__c,
                     ptt_CD_Serial_Number__r.Name, ptt_Activation_Counter__c, ptt_ProductID__c, ptt_Active_CustomPackages__c, ptt_End_User__r.ptt_Company_Name__c
                    FROM ptt_cm_Order__c 
                    WHERE ptt_Sales_Channel__c = :scId 
                    AND ptt_System__c = :systemSelecedOption 
                    ORDER BY Name ASC ];
        } 
        return null;
        
    }
    
    /* All */
    public PageReference doShowAllOrders() {
        activationCode = ''; // reset field to empty string
        systemSelecedOption = first_picklist_option; // Set picklist to first value
        queryAllSCOrders (); // display all SC related records
        return null;
    }
    
    /*********** Command links **************/
    /*** Actions invoked by comand links ****/
    /****************************************/
    
    /* Edit order */
    public PageReference doOrderEdit() {
        PageReference pr = Page.asEditOrder;
        pr.setRedirect(true);
        return pr;
    }
    
    /* Delete order */
    public PageReference doDeleteOrder() {
        // Check if order has packages
        Integer hasPackages = [SELECT Count() FROM CM_Selected_Package__c WHERE ptt_CM_Order__c = :orderIdToDelete];
        if (hasPackages > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Order ' + orderNameToDelete + ' cannot be removed because it contains packages.'));
        } else {
            Database.Delete (orderIdToDelete);
            queryAllSCOrders();
        }
        return null;
    }
    

    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/
     
    public void queryAllSCOrders () {
        ordersList = [SELECT Id, Name, ptt_System__c, ptt_Variant__c, ptt_Activation_Code__c, ptt_Is_Active__c, ptt_Sales_Channel__c,
                      ptt_CD_Serial_Number__r.Name, ptt_Activation_Counter__c, ptt_ProductID__c, ptt_Active_CustomPackages__c, ptt_End_User__r.ptt_Company_Name__c
                      FROM ptt_cm_Order__c 
                      WHERE ptt_Sales_Channel__c =:scId
                      ORDER BY Name ASC];
    }
      
    /**
    * Read picklist values from existig pciklist and return them as options for VS apex:selectOptions
    * @param object_name    object which contains picklist
    * @param field_name     API name of picklist field
    * @param first_val      String like "All" which is a first value
    * @return               Retunrs list of options for VS picklist
    * @see http://www.interactiveties.com/b_describe_picklist.php
    */
    public List<selectOption> getPickValues(sObject object_name, String field_name, String first_val) {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        if (first_val != null) { //if there is a first value being provided
            options.add(new selectOption(first_val, first_val)); //add the first option
        }
        Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed   
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
           options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
        }
        return options; //return the List
   }
   
  
    
}