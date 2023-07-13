@isTest
global class CaseManagementTestClass
{
 @TestSetUp
    static void setUpMethod()
    {
        Account acc=new Account();
        acc.Name='Test';
        acc.CustomerId__c='88888';
        insert acc;
              
           // Set up the test data
        Case caseRecord = new Case(
            RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId(),
            UI_ContactReason__c = 'Query or Manage my order',
            Status = 'New',
            Origin = 'Online',
           	AccountId=acc.Id
        );
        insert caseRecord;  
    }
    
    @IsTest
    public static void testcaseDataGet() 
    {
        
    case caseQuery= [select Id,CAC__c,Origin,AccountId,UI_ContactReason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case WHERE Origin = 'Online' Limit 1];
        
       String str = '{\"tlsdocumentationlink\": \"Test7 closed case Sharepoint Document URL Test\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://login.salesforce.com/\" ,\"origin\" : \"Online\",\"accountnumber\" : \"'+caseQuery.CAC__c+'\", \"caseid\" : \"'+caseQuery.CaseNumber+'\"}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = 'services/apexrest/CodedetailData';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        CaseManagementPostman.caseDataGet();
        assert.areEqual([SELECT Id,Origin,TLS_DocumentationLink__c FROM Case WHERE Origin = 'Online' ].TLS_DocumentationLink__c, 'Test7 closed case Sharepoint Document URL Test');
        assert.areEqual(200,res.statusCode);
        Test.stopTest();
}

  
    
   @IsTest
 public static void testpayLoadValidation() {
    
    case caseQuery= [select Id,CAC__c,Origin,AccountId,UI_ContactReason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case WHERE Origin = 'Online' Limit 1];
    String str = '{\"tlsdocumentationlink\": \"Test7 closed case Sharepoint Document URL Test\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://login.salesforce.com/\" ,\"origin\" : \"Online\",\"accountnumber\" : \"999\", \"caseid\" : '+caseQuery.Id+'\"}';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse(); 
    req.requestURI = 'services/apexrest/CodedetailData';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(str);
    RestContext.request = req;
    RestContext.response = res;
     res.statusCode = 400;
   
    Map<String, Object> queryData1 = new Map<String, Object>{
        'accountnumber' => '898900',
        'origin' => 'Online',
       
        'caseid' => '123489'
    };
    RestResponse responseData1 = new RestResponse();

    Test.startTest();
    CaseManagementPostman.payLoadValidation(queryData1, responseData1);
     System.assertEquals(400, res.statusCode);
  

}

    
 @isTest
   public static void testgeneralMethodToCreateCase() {
  
    case caseQuery = [select Id,CAC__c,Origin,AccountId,UI_ContactReason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM case WHERE Origin = 'Online' Limit 1];
        
   String str = '{\"tlsdocumentationlink\": \"Test7 closed case Sharepoint Document URL Test\",\"tlsonlinesource\" :\"Proof Of Occupancy\",\"tlsurl\" : \"https://login.salesforce.com/\" ,\"origin\" : \"Online\",\"accountnumber\" : \"999\", \"caseid\" : \"090\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = 'services/apexrest/CodedetailData';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        CaseManagementPostman.caseDataGet();
        assert.areEqual(200,res.statusCode);
        Test.stopTest();

    
}
 
    @IsTest
    public static void caseDataOnlineSourceTest()
    {
        case caseQuery= [Select Id,CAC__c,Origin,AccountId,UI_ContactReason__c,TLS_DocumentationLink__c,TLS_OnlineSource__c,TLS_URL__c,CaseNumber FROM Case WHERE Origin = 'Online' Limit 1];
        String str = '{\"tlsdocumentationlink\": \"Test7 closed case Sharepoint Document URL Test\",\"tlsonlinesource\" :\"Occupancy\",\"tlsurl\" : \"https://login.salesforce.com/\" ,\"origin\" : \"Online\",\"accountnumber\" : \"999\", \"caseid\" : \"090\"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.requestURI = 'services/apexrest/CodedetailData';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        CaseManagementPostman.caseDataGet();
        assert.areEqual(400,res.statusCode);
        Test.stopTest();
    }
}