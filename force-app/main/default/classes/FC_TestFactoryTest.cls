/**
 * @who   Tiago Lopes <tiago.lopes@weare4c.com>
 * @what  Test class for TestFactory framework
 * @when  24/10/2019
 */
@isTest
private class FC_TestFactoryTest {

  @isTest
  static void when_objectIsCreated_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account testAccount = (Account) FC_TestFactory.createSObject(new Account());
    Test.stopTest();
    //then
    System.assertEquals('Test Account', testAccount.Name, 'Expecting Default field value is set to specific value');
  }

  @isTest
  static void when_objectIsInserted_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account testAccount = (Account) FC_TestFactory.createSObject(new Account(),true);
    Test.stopTest();
    //then
    testAccount = [SELECT Name FROM Account WHERE Id = :testAccount.Id];
    System.assertEquals('Test Account', testAccount.Name, 'Expecting Default field value is set to specific value');
  }

  @isTest
  static void when_objectIsCreatedWithSpecificDefaultsSet_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account testAccount = (Account) FC_TestFactory.createSObject(new Account(), 'FC_TestFactoryDefaults.MyAccountDefaults');
    Test.stopTest();
    //then
    System.assertEquals('My Test Account', testAccount.Name, 'Expecting Default field value is set to specific value');
  }

  @isTest
  static void when_objectIsInsertedWithSpecificDefaultsSet_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account testAccount = (Account) FC_TestFactory.createSObject(new Account(), 'FC_TestFactoryDefaults.MyAccountDefaults', true);
    Test.stopTest();
    //then
    System.assertEquals('My Test Account', testAccount.Name, 'Expecting Default field value is set to specific value');
  }

  @isTest
  static void when_ListOfObjectsIsCreated_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account[] testAccounts = (Account[]) FC_TestFactory.createSObjectList(new Account(), 200);
    Test.stopTest();
    //then
    System.assertEquals(200, testAccounts.size());
    System.assertEquals('Test Account 0', testAccounts[0].Name);
    System.assertEquals('Test Account 199', testAccounts[199].Name);
    for(Account testAccount : testAccounts){
      System.assert(testAccount.Name.startsWith('Test Account'), 'Expecting Default field value is set to specific value');
    }
  }

  @isTest
  static void when_ListOfObjectIsInserted_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account[] testAccounts = (Account[]) FC_TestFactory.createSObjectList(new Account(), 200, true);
    Test.stopTest();
    //then
    testAccounts = [SELECT Name FROM Account WHERE Id IN :testAccounts ORDER BY Name];
    System.assertEquals(200, testAccounts.size());
    System.assertEquals('Test Account 0', testAccounts[0].Name);
    for(Account testAccount : testAccounts){
      System.assert(testAccount.Name.startsWith('Test Account'), 'Expecting Default field value is set to specific value');
    }
  }

  @isTest
  static void when_ListOfObjectsIsCreatedWithSpecificDefaultsSet_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account[] testAccounts = (Account[]) FC_TestFactory.createSObjectList(new Account(), 200, 'FC_TestFactoryDefaults.MyAccountDefaults');
    Test.stopTest();
    //then
    System.assertEquals(200, testAccounts.size());
    System.assertEquals('My Test Account 0', testAccounts[0].Name);
    System.assertEquals('My Test Account 199', testAccounts[199].Name);
    for(Account testAccount : testAccounts){
      System.assert(testAccount.Name.startsWith('My Test Account'), 'Expecting Default field value is set to specific value');
    }
  }

  @isTest
  static void when_ListOfObjectsIsInsertedWithSpecificDefaultsSet_expect_defaultFieldsArePopulated(){
    //when
    Test.startTest();
      Account[] testAccounts = (Account[]) FC_TestFactory.createSObjectList(new Account(), 200, 'FC_TestFactoryDefaults.MyAccountDefaults', true);
    Test.stopTest();
    //then
    testAccounts = [SELECT Name FROM Account WHERE Id IN :testAccounts ORDER BY Name];
    System.assertEquals(200, testAccounts.size());
    System.assertEquals('My Test Account 0', testAccounts[0].Name);
    for(Account testAccount : testAccounts){
      System.assert(testAccount.Name.startsWith('My Test Account'), 'Expecting Default field value is set to specific value');
    }
  }
}