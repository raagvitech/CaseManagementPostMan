public with sharing class GeneralCaseManagement {
    
        public static final List<String> MandatoryField = new List<String>{'accountnumber','tlsdocumentationlink','tlsonlinesource'};
        public static final Map<String, String> fieldValidation = new Map<String, String>{'origin' => 'Origin','accountnumber' => 'CAC__c'};
        public static final Id GENERALRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
        public static final String PAYLOADERROR;
        public static final String PAYLOADSUCESS;
        public static final String ONLINESOURCE = 'Proof of Occupancy';
        public static final Map<String,String> ERRORANDSUCCESSMAP = new Map<String,String>();
        public static final Map<String,String> ERRORMAP = new Map<String,String>();
        public static final String CommentForOpenCloseCase = 'Proof of Occupancy documentation has been received{0}';
        public static final String COMMENTBODYForOpenCase = 'Please use the link provided to access and review the documentation';
        public static final String COMMENTBODYForCloseCase = 'Case was already Closed,so Documentation link has not been updated.Refer to the share point folder to find and review the documentation';
        public static final String GENERALRECORDTYPE = 'General';
        public static final String ORDERREMEDIATION = 'Order Remediation';
        public static final String CASESTATUS = 'Open';
        public static final String CASESORIGIN = 'Online';
        public static final String CASEPPRIORITY = 'Medium';
        public static final String CASECONTACTREASON = 'Query or Manage My Order';
        public static final String CASEDESCRRIPTION = 'Case created automatically as Account does not match original Case[original case number passed in form the webform].Proof of Occupancy documentation received:,PLease use the link provided to access and review the documentation';

}