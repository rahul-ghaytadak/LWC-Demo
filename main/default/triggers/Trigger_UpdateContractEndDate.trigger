/*
* @Purpose: Update Utility Accounts End Date when Contract is deleted.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: Trigger_UpdateContractEndDateHandler
* @Test Class: Update_contractEndDate_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
trigger Trigger_UpdateContractEndDate on Contract ( before delete) {
    List<Contract> Contract_Id = new List<Contract>();
    if (Trigger.isBefore) {
        if(trigger.isDelete){
            Trigger_UpdateContractEndDateHandler.updateContractEndDate(trigger.old);
        } 
    }
}