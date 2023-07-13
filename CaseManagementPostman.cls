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
    System.debug('inside caseInsert');
    System.debug('req.requestBody.tostring()'+req.requestBody.tostring());
    Map<String, Object> requestPayLoadMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.tostring());
    System.debug('result++++'+requestPayLoadMap+String.valueOf(requestPayLoadMap.get('tlsurl')));
    System.debug('result'+requestPayLoadMap.get('caseid')+requestPayLoadMap.get('accountnumber'));

    Map<String,String> matchingFields = GeneralCaseManagement.fieldValidation;
   // Map<String,String> validateOnlineSource = GeneralCaseManagement.ONLINEFIELD ;
    System.debug('matchingFields'+matchingFields);
    String query = 'SELECT Id ,IsClosed,CaseNumber, TLS_Documentationlink__c, TLS_OnlineSource__c, TLS_URL__c, UI_ContactReason__c, RecordType.Name';
    query += ', ' + String.join(matchingFields.values(), ',');
    query += ' FROM Case WHERE (RecordType.Name = \'Order Remediation\' OR (RecordType.Name = \'General\' AND UI_ContactReason__c = \'Query or Manage my order\')) AND CaseNumber = \'' + (String)requestPayLoadMap.get('caseid') + '\'';
    System.debug('query::' + query);

    System.debug('line35'+ String.join(matchingFields.values(), ','));          
    
    List<Case> caseRecordList  = (List<Case>)Database.query(query);
    System.debug('caseRecordList: ' + caseRecordList);
    //  String cacNumber = caseRecordList[0].Account.CAC_Number__c;
    
    if(payLoadValidation(requestPayLoadMap,responceHere))
    {
        if(!caseRecordList.isEmpty())
        {
            if(validateField(requestPayLoadMap,caseRecordList[0],matchingFields)) //if Cac Number not match
                { 
                        String openCase = string.format(GeneralCaseManagement.CommentForOpenCloseCase, new List<String>{String.valueOf(requestPayLoadMap.get('tlsurl'))}) + GeneralCaseManagement.COMMENTBODYForOpenCase;
                        String closedCase = string.format(GeneralCaseManagement.CommentForOpenCloseCase, new List<String>{String.valueOf(requestPayLoadMap.get('tlsurl'))}) + GeneralCaseManagement.COMMENTBODYForCloseCase; 
                        comments = caseRecordList[0].IsClosed ? closedCase : openCase ; 

                    if(!caseRecordList[0].IsClosed)
                    {
                    System.debug('line43++'+String.valueOf(requestPayLoadMap.get('tlsdocumentationlink')));
                        caseRecordList[0].TLS_Documentationlink__c = String.valueOf(requestPayLoadMap.get('tlsdocumentationlink'));
                        caseRecordList[0].TLS_OnlineSource__c = String.valueOf(requestPayLoadMap.get('tlsonlinesource'));
                        caseRecordList[0].TLS_URL__c = String.valueOf(requestPayLoadMap.get('tlsurl'));
                        System.debug('caseCommentObject++++'+caseRecordList[0].Id+caseRecordList[0].TLS_URL__c);
                        
                        update caseRecordList[0];
                        System.debug('line45++'+ GeneralCaseManagement.MandatoryField[0]);
                        
                        System.debug('comments'+comments);
                        caseCommentObject(caseRecordList[0].Id,comments);
                        
                        updateData.put('Id',caseRecordList[0].Id);
                        updateData.put('CaseNumber',caseRecordList[0].CaseNumber);
                        
                        responseMethod(updateData,responceHere);
                        
                        //  System.debug('caseToUpdateList'+caseList.Account.CAC_Number__c)
                    }
                
                else {
                   System.debug('open case++++');
                    caseCommentObject(caseRecordList[0].Id,comments);
                    System.debug('inside else line 77++');
                    updateData.put('Id',caseRecordList[0].Id);
                    updateData.put('CaseNumber',caseRecordList[0].CaseNumber);
                    
                    responseMethod(updateData,responceHere);
                    } 
                }
            else
            {
                isCreateCase = true;
            } 
        }else{
            isCreateCase = true;
        }
        if(isCreateCase)
        {
            
            if (requestPayLoadMap.get('tlsonlinesource') == 'Proof of Occupancy') {
                String commentsToAdd = 'Proof of Occupancy documentation has been received. Please use the link provided to access and review the documentation';
                generalMethodToCreateCase(requestPayLoadMap, commentsToAdd);
                caseCommentObject(caseRecordList[0].Id, commentsToAdd);
            }
            else{
                System.debug('inside else+++'+missingList);
               String invalidData = 'Fields ['+missingList+'] invalid or no data';
                System.JSONGenerator FormatedJson = JSONGenerator.generateJSONErrorResponse(invalidData);
            }
            
            
        }
       
        
    }
    
}

catch(Exception e)
{
    System.debug('Exception occurred: ' + e.getMessage());
}

//  return null;

}

public static void generalMethodToCreateCase(Map<String, Object>  caseData,String commentsForCase)
{
System.debug('caseData++++'+caseData.get('tlsonlinesource')+GeneralCaseManagement.ONLINESOURCE);

    SYSTEM.debug('line90+++');
    Case newCase = new Case();

        newCase.Status = GeneralCaseManagement.CASESTATUS;
        newCase.Priority = GeneralCaseManagement.CASEPPRIORITY;
        newCase.Origin = GeneralCaseManagement.CASESORIGIN;
        newcase.UI_ContactReason__c = GeneralCaseManagement.CASECONTACTREASON;
        newCase.Description = GeneralCaseManagement.CASEDESCRRIPTION;
        newCase.TLS_Documentationlink__c = (String) caseData.get('tlsdocumentationlink');
        newCase.TLS_URL__c = (String) caseData.get('tlsurl');
        newCase.TLS_OnlineSource__c = (String) caseData.get('tlsonlinesource');
        newCase.RecordTypeId = GeneralCaseManagement.GENERALRECORDTYPEID ;  
    
            
    insert newCase;
    System.debug('line105++'+newCase.Id+newCase.CaseNumber);
    
    Case newCaseQuery = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id];
    System.debug('line105++'+newCase.Id+newCaseQuery.CaseNumber);
    updateData.put('Id',newCase.Id);
    updateData.put('CaseNumber',newCaseQuery.CaseNumber);
    System.debug('updateData108+++'+updateData+newCase.Id+newCase.CaseNumber);
    
      responseMethod(updateData,responceHere);
  

}

public static void  caseCommentObject(Id caseIdValue,String comment)
{
System.debug('inside caseCommentObject'+caseIdValue+comment);
CaseComment newCaseCommentObject = new CaseComment();
if(String.isNotBlank(comment))
{
    newCaseCommentObject.CommentBody = comment;
}

newCaseCommentObject.ParentId = caseIdValue;
newCaseCommentObject.IsPublished = true;

insert newCaseCommentObject;
}

public static void responseMethod(Map<String, String> responseInMap,RestResponse response) {
    System.debug('responseInMap: ' + responseInMap);

    // Generate the JSON content
   System.JSONGenerator formatedJsonData = JSONGenerator.generateJsonContentResponse(responseInMap);
    String jsonString= formatedJsonData.getAsString();
    // Set the status code and response body
    Integer statusCode = 200;
    response.responseBody = Blob.valueOf(jsonString);

    // Perform further actions with the status code and response body
    // ...
}



public static Boolean payLoadValidation(Map<String, Object> queryData,RestResponse responseData)
{
System.debug('inside queryData+++'+queryData+responseData);
Boolean fieldCondition = false ;


for(String thisField:GeneralCaseManagement.MandatoryField)
{
    System.debug('line204+++'+thisField); 
    String errorMsg = 'Fields [';

    if(!queryData.containskey(thisField) || String.isBlank((String)queryData.get(thisField)) || String.valueOf(queryData.get(thisField)).equalsIgnoreCase('null'))
    {
        missingList.add(thisField);
    }
    System.debug('missingList'+missingList);
    if(missingList.isEmpty())
{
    fieldCondition = true ;
}
else{
    fieldCondition = false;
    errorMsg = errorMsg+String.join(missingList,',')+'] invalid or no data';
    System.JSONGenerator FormatedJson = JSONGenerator.generateJSONErrorResponse(errorMsg);
    String jsonString = FormatedJson.getAsString();
    responseData.responseBody = blob.valueOf(jsonString);

}
}

return fieldCondition;
}

  public static Boolean validateField(Map<String,Object> requestPayLoadMap,Case caseObj,Map<String,String> matchingFields)
{
  Boolean checkAndValidate = false ;

//  String cacValidate = GeneralCaseManagement.fieldValidation;
for(String cacValidate : matchingFields.keySet())
    {
    String requestFieldValue = (String)requestPayLoadMap.get(cacValidate);
    String objectFieldValue = String.valueOf(caseObj.get((matchingFields.get(cacValidate))));
    if(requestFieldValue.equalsIgnoreCase(objectFieldValue)){
    checkAndValidate = true;
    }
 }
return checkAndValidate;
}

// public static boolean validateOnlineSourceField(Map<String,Object> requestResponse, Map<String,String> validateFieldOnlineSource)
// {
//         Boolean returnValidateField =  false ;
//        for(String val : validateFieldOnlineSource.keySet())
//        {
//        if(requestResponse.containskey(val))
//        {
//         System.debug('val+++++++'+requestResponse);
//         returnValidateField = true;
//        }
//        }
  
        
  
//      return returnValidateField ;
// }

}