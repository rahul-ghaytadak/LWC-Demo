/*
* @Purpose: This Apex class is the test Class for Customer_Account_MassDelete.
* @Author: Aress Software
* @CreatedDate: 22-06-2020 
* @LastModifiedDate: 22-06-2020 
* @LastModifiedBy: Aress Software
*/
@IsTest
public class Customer_Account_MassDelete_Test {
static testMethod void testDeleteRecords() {

        List<Account> Accounts = new List<Account>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Accounts);
        Customer_Account_MassDelete extension = new Customer_Account_MassDelete(sc);

        System.assertNotEquals(null, extension.deleteRecords());
    }

    static testMethod void testSelectedSize() {
        List<Account> Accounts = new List<Account>();
        Accounts.add(new Account(Description ='Test'));
        Accounts.add(new Account(Description ='Decima'));
        Accounts.add(new Account(Description ='Test1'));
        Accounts.add(new Account(Description ='Solution'));
        Accounts.add(new Account(Description ='Tester'));
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Accounts);
        sc.setSelected(Accounts);
        Customer_Account_MassDelete extension = new Customer_Account_MassDelete(sc);
		System.assertEquals('5', extension.getMySelectedSize());
    }
       static testMethod void testclosePopup() {
        List<Account> Accounts = new List<Account>();
        Accounts.add(new Account(Description ='Test'));
        Accounts.add(new Account(Description ='Decima'));
        Accounts.add(new Account(Description ='Test1'));
        Accounts.add(new Account(Description ='Solution'));
        Accounts.add(new Account(Description ='Tester'));
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Accounts);
        sc.setSelected(Accounts);
        Customer_Account_MassDelete extension = new Customer_Account_MassDelete(sc);
        extension.closePopup();
        extension.showPopup();
		System.assertEquals('5', extension.getMySelectedSize());
    }
}