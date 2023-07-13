/* Description : CaseManagementPostman handles Case Creation, updates fields based on the request payload,
                 performs validation, generates comments, and provides error,along with success responses.
* @Author : R Amthur Rafia
*/

@RestResource(urlMapping='/CodedetailData/*')

global with sharing class CaseManagementPostman 
{
    public static  List<String> missingList = new List<String>();
    public static  Map<String, String> updateData = new Map<String, String>();
    public static Map<String, String> statusresponseMap = new Map<String, String>();
    public static Map<String, String> statusresponseMapForError = new Map<String, String>();
    public static RestResponse responceHere = RestContext.response;
    public static String comments = '';
    public static Boolean isCreateCase = false;
    
    @httpPost
    global static void caseDataGet()
    {
        RestRequest req = RestContext.request;
        
        try{
            // Deserialize request body in a map
            Map<String, Object> requestPayLoadMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.tostring());
            
            // Defining matching fields
            Map<String,String> matchingFields = GeneralCaseManagement.fieldValidation;
            
              // Build the SOQL query to retrieve Case object records
            String query = 'SELECT Id ,IsClosed,CaseNumber, TLS_Documentationlink__c, TLS_OnlineSource__c, TLS_URL__c, UI_ContactReason__c, RecordType.Name';
            query += ', ' + String.join(matchingFields.values(), ',');
            query += ' FROM Case WHERE (RecordType.Name = \'Order Remediation\' OR (RecordType.Name = \'General\' AND UI_ContactReason__c = \'Query or Manage my order\')) AND CaseNumber = \'' + (String)requestPayLoadMap.get('caseid') + '\'';
                   
            //Storing Query result into a list
            List<Case> caseRecordList  = (List<Case>)Database.query(query);
           String CaseNumber;
            // Validating Payload data
            if(payLoadValidation(requestPayLoadMap,responceHere))
            {
                if(!caseRecordList.isEmpty())
                {
                    // Checking matching fields with request payload data
                    if(validateField(requestPayLoadMap,caseRecordList[0],matchingFields)) //if Cac Number not match
                    { 
                          // Determine the comment body based on whether the case is closed or open
                        String openCase = string.format(GeneralCaseManagement.CommentForOpenCloseCase, new List<String>{String.valueOf(requestPayLoadMap.get('tlsurl'))}) + GeneralCaseManagement.COMMENTBODYForOpenCase;
                        String closedCase = string.format(GeneralCaseManagement.CommentForOpenCloseCase, new List<String>{String.valueOf(requestPayLoadMap.get('tlsurl'))}) + GeneralCaseManagement.COMMENTBODYForCloseCase; 
                        comments = caseRecordList[0].IsClosed ? closedCase : openCase ; 
                        
                        if(!caseRecordList[0].IsClosed)
                        {
                           // Update fields in Case object
                            caseRecordList[0].TLS_Documentationlink__c = String.valueOf(requestPayLoadMap.get('tlsdocumentationlink'));
                            caseRecordList[0].TLS_OnlineSource__c = String.valueOf(requestPayLoadMap.get('tlsonlinesource'));
                            caseRecordList[0].TLS_URL__c = String.valueOf(requestPayLoadMap.get('tlsurl'));
                         
                            update caseRecordList[0];
                            
                            // Call the caseCommentObject method, passing the Case ID and commentBody
                            caseCommentObject(caseRecordList[0].Id,comments);
                            
                            updateData.put('Id',caseRecordList[0].Id);
                            updateData.put('CaseNumber',caseRecordList[0].CaseNumber);
                           
                            //calling responseMethod to show correct response
                           responseMethod(updateData,responceHere);  
                     

                        }
                        else {
                           // Call the caseCommentObject method, passing the Case ID and commentBody
                            caseCommentObject(caseRecordList[0].Id,comments);
                         
                            updateData.put('Id',caseRecordList[0].Id);
                            updateData.put('CaseNumber',caseRecordList[0].CaseNumber);
                             //calling responseMethod to show correct response
                            responseMethod(updateData,responceHere);
                        } 
                    }
                    else
                    {
                        isCreateCase = true;
                    } 
                }
                else
                {
                    isCreateCase = true;
                }
                if(isCreateCase)
                {
                    if (requestPayLoadMap.get('tlsonlinesource') == GeneralCaseManagement.ONLINESOURCE) {
                        String commentsToAdd = GeneralCaseManagement.COMMENTS;
                        //call generalMethodToCreateCase to create new case 
                        generalMethodToCreateCase(requestPayLoadMap, commentsToAdd,CaseNumber);
                          // Call the caseCommentObject method, passing the Case ID and commentBody
                        caseCommentObject(caseRecordList[0].Id, commentsToAdd);
                    }
                    else{
                        // Generate an error response with the error message
                        String invalidData = 'Fields ['+missingList+'] invalid or no data';
                        System.JSONGenerator FormatedJson = JSONGenerator.generateJSONErrorResponse(invalidData);
                        String jsonString = FormatedJson.getAsString(); 
                        responceHere.responseBody = Blob.valueOf(jsonString);
                        responceHere.statusCode = 400;
                    }
                }
            }
        }
        
        catch(Exception e)
        {
            System.debug('Exception occurred: ' + e.getMessage());
            String invalidData = 'Exception occurred:'+e.getMessage();
            System.JSONGenerator FormatedJson = JSONGenerator.generateJSONErrorResponse(invalidData);
            String jsonString = FormatedJson.getAsString(); 
            responceHere.responseBody = Blob.valueOf(jsonString);
            responceHere.statusCode = 400;
        }
    }
    
    //creating new Case 
    public static void generalMethodToCreateCase(Map<String, Object>  caseData,String commentsForCase,String CaseNumber)
    {
        Case newCase = new Case();
        newCase.Status = GeneralCaseManagement.CASESTATUS;
        newCase.Priority = GeneralCaseManagement.CASEPPRIORITY;
        newCase.Origin = GeneralCaseManagement.CASESORIGIN;
        newcase.UI_ContactReason__c = GeneralCaseManagement.CASECONTACTREASON;
        newCase.TLS_Documentationlink__c = (String) caseData.get('tlsdocumentationlink');
        newCase.TLS_URL__c = (String) caseData.get('tlsurl');
        newCase.TLS_OnlineSource__c = (String) caseData.get('tlsonlinesource');
        newCase.RecordTypeId = GeneralCaseManagement.GENERALRECORDTYPEID ;  
        // Set the Description field for the new case with the case number and additional comments
        newCase.Description = String.format(GeneralCaseManagement.CASEDESCRIPTION, new List<String>{CaseNumber}) + string.format(GeneralCaseManagement.CommentForOpenCloseCase, new List<String>{String.valueOf(caseData.get('tlsdocumentationlink'))}) + GeneralCaseManagement.COMMENTBODYForOpenCase;
        
        insert newCase;
     
        Case newCaseQuery = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id];
      
        updateData.put('Id',newCase.Id);
        updateData.put('CaseNumber',newCaseQuery.CaseNumber);
        responseMethod(updateData,responceHere);
    }
    
    //passing comments to case comment object
    public static void  caseCommentObject(Id caseIdValue,String comment)
    {
        CaseComment newCaseCommentObject = new CaseComment();
        if(String.isNotBlank(comment))
        {
            newCaseCommentObject.CommentBody = comment;
        }        
        newCaseCommentObject.ParentId = caseIdValue;
        newCaseCommentObject.IsPublished = true;
        insert newCaseCommentObject;
    }
    
    //sending respose
   public static void responseMethod(Map<String, String> responseInMap, RestResponse response) {
    if (response != null) {
        System.JSONGenerator formatedJsonData = JSONGenerator.generateJsonContentResponse(responseInMap);
        String jsonString = formatedJsonData.getAsString();
        // Set the status code and response body
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(jsonString);
    } else 
    { 
          System.debug('Response object cannot be null');
    }
}
   // Validating Payload data
    public static Boolean payLoadValidation(Map<String, Object> queryData, RestResponse responseData) 
{
    Boolean fieldCondition = true; 
     
    List<String> missingList = new List<String>();
       // Iterate over each mandatory field defined in GeneralCaseManagement Class
    for (String thisField : GeneralCaseManagement.MandatoryField) {
         // Check if the request body contains the mandatory field, and if its value is blank or "null"
        if (!queryData.containsKey(thisField) || String.isBlank((String)queryData.get(thisField)) || String.valueOf(queryData.get(thisField)).equalsIgnoreCase('null')) {
            missingList.add(thisField);
        }
    }
          // If there are no missing mandatory fields, set the mandatoryFieldCondition to false and send error message
    if (!missingList.isEmpty()) {
        fieldCondition = false;
        String errorMsg = 'Fields [' + String.join(missingList, ',') + '] invalid or no data';
        System.JSONGenerator FormatedJson = JSONGenerator.generateJSONErrorResponse(errorMsg);
        String jsonString = FormatedJson.getAsString();
        System.debug(jsonString);
        responseData.responseBody = Blob.valueOf(jsonString);
        System.debug('response'+responseData.responseBody);
        responseData.statusCode = 400;
    }
    
    return fieldCondition;
}
// Checking matching fields with request payload data
  public static Boolean validateField(Map<String, Object> requestPayLoadMap, Case caseObj, Map<String, String> matchingFields) {
    Boolean checkAndValidate = false;

    for (String cacValidate : matchingFields.keySet()) {
        String requestFieldValue = (String) requestPayLoadMap.get(cacValidate);
        String objectFieldValue = String.valueOf(caseObj.get(matchingFields.get(cacValidate)));
        if (requestFieldValue != null && objectFieldValue != null && requestFieldValue.equalsIgnoreCase(objectFieldValue)) {
            checkAndValidate = true;
        }
    }
    return checkAndValidate;
}    
}
