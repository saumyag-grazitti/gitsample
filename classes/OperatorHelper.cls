public with sharing class OperatorHelper {

    public final static String COMMA = '"';
    
    public static List<String> getFieldValues(String fieldValuesStr) {
        
        List<String> fieldValues = new List<String>();
        String values = fieldValuesStr;
       
        if (values.contains(COMMA)) {
            
            while(values.contains(COMMA)) {
                Integer commaIndex = values.indexOf(COMMA);
                Integer commaNextIndex = values.indexOf(COMMA, commaIndex + 1);
                String valueWihComma = values.substring(commaIndex, commaNextIndex + 1);
                fieldValues.add(valueWihComma.remove(COMMA));
                values = values.remove(valueWihComma);
        	}
        }
        
        for (String value : values.replaceAll(';', ',').split(',')) {
            if (String.isNotBlank(value)) {
            	fieldValues.add(value.trim());    
            }
        }   
        return fieldValues;
    }
    
    public static List<String> getFieldValuesForQuery(String fieldValuesStr) {
        
        List<String> fieldValues = new List<String>();
        
        for (String fieldValue : getFieldValues(fieldValuesStr)) {
        	fieldValues.add(fieldValue.replace('\'', '\\\''));    
        }
        return fieldValues;
    }
    
    public static List<String> getFieldValuesIgnoreCase(String fieldValuesStr) {
        
        List<String> fieldValues = new List<String>();
        
        for (String fieldValue : getFieldValues(fieldValuesStr)) {
        	fieldValues.add(fieldValue.toLowerCase());    
        }
        return fieldValues;
    }
    
    public static String getValueWithoutComma(String fieldValuesStr) {
        return fieldValuesStr.remove(COMMA);
    }
}