/**
* ===================================================================
* (c) PTT Technology 2011, Poland, All rights reserved
* ptt_Device_Trigger
* @author.....: Pawel Wozniak    
* @email......: pawel.wozniak@pruftechnik.com.pl
* @version....: V1.1
* @date.......: 2011-10-18 @update 2013-04-22
* Description.: --
* Objects.....: Device 
* =================================================================
*/
trigger ptt_Device_Trigger on sf42_Devices__c (before insert, before update, after insert, after update, after delete) {

 	 DevicesServicesDemosTriggerHandler sharingHandler = new DevicesServicesDemosTriggerHandler();

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ptt_DeviceManager.setUserFieldOnChild(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert){ 
        ptt_DeviceManager.createReference(Trigger.New);
        sharingHandler.onAfterInsert(Trigger.New);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate){ 
        ptt_DeviceManager.changeOwnerOfSubdevice(Trigger.newMap, trigger.oldMap);
        ptt_DeviceManager.updateReference(Trigger.newMap);
        sharingHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isDelete){ 
        ptt_DeviceManager.deleteReference(Trigger.oldMap.keySet());
    }
}