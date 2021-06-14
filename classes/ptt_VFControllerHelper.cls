/**
* ===================================================================
* (c) PTT Technology 2012, Poland, All rights reserved
* ptt_VFControllerHelper
* @author.....: Pawel Wozniak    
* @email......: pawel.wozniak@pruftechnik.com.pl
* @version....: V1.0
* @date.......: 2012-07-04
* Description.: Helper clas for VisualForce Controllers.
* =================================================================
*/

global class ptt_VFControllerHelper {
	
	/**
	* Extract value from HTML tag with given id.
	* @param String res - string with html
	* @param String id - id of a tag which hold value
	* @return String with value inside HTML tag
	*/
	public static String extractValueFromId (String res, String id) {
		String value = '';
		if (res.length() > 0 && res.indexOf(id) >= 0) {
			System.debug('start');
			// Find tag with given id
			value = res.substring(res.indexOf(id)+id.length());
			System.debug(value);
			// Find end of tag opening
			value = value.substring(value.indexOf('>')+1);
			System.debug(value);
			// Find tag close, trim spaces
			value = value.substring(0, value.indexOf('</')).trim();
			System.debug(value);
		} 
		return value;
	}
		
}