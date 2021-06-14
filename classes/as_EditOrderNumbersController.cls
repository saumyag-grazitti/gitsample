public with sharing class as_EditOrderNumbersController {

    /****************************************/
    /***** Controller global variables ******/
    /****************************************/

    // Variables
    String orderId = ApexPages.currentPage().getParameters().get('orderId');  // Read OrderID parameter
    ptt_cm_Order__c orderObject = [SELECT Id, ptt_Order_numbers__c FROM ptt_cm_Order__c WHERE Id = :orderId]; // Get order object
    public Set<string> orderNumbersValues = new Set<string>(); // Hold the values of all order numbers 
    
    // Variables with default get set methods
    public List<string> selectedOnValues { get; set; } // represents what is selected (highlited) on apex:selectList
    public String addONValue { get; set; } // represents inputfield id="inputOrderNumber"
   
    /****************************************/
    /**** Custom controller constructor *****/
    /****************************************/
    public as_EditOrderNumbersController () {
        if (orderObject.ptt_Order_numbers__c !=null) {
            orderNumbersValues.addAll(orderObject.ptt_Order_numbers__c.split(';'));  // Add Order Numbers values from object field
        }
        selectedOnValues = new  List<string>();        
    }
    
    /************** Getters *****************/
    /*** Passing values to VS Page fields ***/
    /****************************************/
   
    public List<SelectOption> getOrderNumbersOptions(){
        List<SelectOption> options = new List<SelectOption>();
        
        // Iterate througth whole list and generate SelectOptions
        for(string s : sortSetOfString(orderNumbersValues)) {
            options.add( new SelectOption(s,s) );
        }
        return options;
    } 
    
    /************* Setters *****************/
    /***** Reading values from field *******/
    /***************************************/
    
    
    /************** Buttons *****************/
    /** Actions invoked by custom buttons ***/
    /****************************************/
    
    /* Save */
    public PageReference onSave() {
        String csvOrderNumbers ='';
        
        // Convert set to sorted list and iterate throught
        for (String s : sortSetOfString(orderNumbersValues)) {
            csvOrderNumbers = csvOrderNumbers + s + ';'; // Create semicolon separated string which can be stored in object field.
        }
        
        // Assign csv string to object field and update it
        orderObject.ptt_Order_numbers__c = csvOrderNumbers;
        update orderObject;
        
        // Redirect to Edit order page
        PageReference pr = Page.aseditorder;
        pr.getParameters().put('Id', orderId);
        return pr;       
    }
    
    /* Back */
    public PageReference onBack() {
        PageReference pr = Page.aseditorder;
        pr.getParameters().put('Id', orderId);
        return pr;
    }
    
    /* Delete */
    public PageReference doDeleteON() {
        // Go throught all selected values and remove them
        for(String s : selectedOnValues){
             orderNumbersValues.remove(s);
        }
        return null;
    }
    
    /* Add */
    public PageReference doAddON() {
        if (addONValue.contains(';')) {
            String errorMsg = 'Semicolon ; is not allowed in add field. Please correct value.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorMsg));
        } else {
            if (addONValue.length() > 0) {
                orderNumbersValues.add(addONValue);
                addONValue = '';
            }
        }
        return null;
    }
    
    /****************************************/
    /**** Class specific helper functions ***/
    /****************************************/
    
    /**
    * Sort Set of strings and return sorted list
    * @param setValues set of strings
    * @return sorted list
    */ 
    List<String> sortSetOfString (Set<String> setValues ) {
        List<string> tempList = new List<String>();
        tempList.addAll(setValues);
        tempList.sort();
        return tempList;
    }

}