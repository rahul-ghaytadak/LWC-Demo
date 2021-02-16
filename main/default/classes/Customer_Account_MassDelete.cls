/*
* @Purpose: This Apex class is the extension to delete the selected field of list view.
* @Author: Aress Software
* @CreatedDate: 
* @Test Class: 
* @LastModifiedDate: 22-06-2020 
* @LastModifiedBy: Aress Software
*/

public with sharing class Customer_Account_MassDelete {

    ApexPages.StandardSetController setCon;
    public String error { get; set; }
    public PageReference originalUrl { get; set; }
    public boolean displayPopup {get; set;}     
    public boolean disableButton { get; set;}
    public boolean ShowGoBack { get; set;}
    public String ConfirmDelete_Msg { get; set; }
    public List<sObject> AccLstToDelete { get; set; }
    public Set<Id> SelectedAccIds { get; set; }
    public List<PermissionSetAssignment> PSA { get; set; }

    public Customer_Account_MassDelete (ApexPages.StandardSetController controller) {
        setCon = controller;
        PSA = [SELECT Id,PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Delete_Customer_Account' AND AssigneeId =: UserInfo.getUserId()];
        
        AccLstToDelete = new List<sObject>(setCon.getSelected());
        SelectedAccIds = new Set<Id>();
        for(sObject sobj : AccLstToDelete)
        {
            SelectedAccIds.add(sobj.Id); 
        }
        
        List<Opportunity> ClosedWonOppLst = [SELECT Id FROM Opportunity where StageName = 'Closed Won' AND AccountId IN:SelectedAccIds ];
        
        if(PSA.size()>0){
            if(ClosedWonOppLst.size() > 0){
                ConfirmDelete_Msg = 'Selected Account(s) have a \'Closed Won\' Opportunity and Cannot be deleted.';
                disableButton = false; 
                ShowGoBack = true;       
            }
            else{
            ConfirmDelete_Msg = 'Are you sure you want to permenantly delete ' + setCon.getSelected().size()+' Account Records and all its related Utility Accounts ?';
            ShowGoBack = false;
            disableButton = true; 
            }
        }
        else{
        ConfirmDelete_Msg = 'Sorry, You Do Not Have Permission to Delete these Records';
        disableButton = false; 
        ShowGoBack = true;
        }
    }

    public String getMySelectedSize() {
        return setCon.getSelected().size() + '';
      
    }
    
    public PageReference deleteRecords(){
        originalUrl = setCon.cancel();
        
        List<Utility_Account__c> UtilityAccToDelete = new List<Utility_Account__c>([Select Id,Name,Account__c from Utility_Account__c  where Account__c IN:SelectedAccIds]);
        
        

        if(PSA[0].AssigneeId == UserInfo.getUserId()){
        delete UtilityAccToDelete;
        delete AccLstToDelete;
        }
        return originalUrl;
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
}