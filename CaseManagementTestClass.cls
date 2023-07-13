public with sharing class JSONGenerator
{
    public static System.JSONGenerator generateJSONErrorResponse(String missingField) 
    {
        try{
            // Create the JSON generator
            System.JSONGenerator gen = JSON.createGenerator(true);
            
            // Start building the JSON structure
            gen.writeStartObject();
            gen.writeNumberField('statusCode', 400);
            gen.writeBooleanField('success', false);
            gen.writeStringField('time', String.valueOf(DateTime.now()));
            
            // Build the 'error' object
            gen.writeFieldName('error');
            gen.writeStartObject();
            gen.writeStringField('message',  missingField);
            gen.writeEndObject();
            
            // Get the JSON string
            String jsonString = gen.getAsString();
            
            // Display the generated JSON
            System.debug('Generated JSON: ' + jsonString);
            return gen;
            
        } 
        catch (Exception f)
        {
            System.JSONGenerator errorJSONgen = JSON.createGenerator(true);
            errorJSONgen.writeStartObject();
            errorJSONgen.writeStringField('message', 'An error occured while generating the Json response');
            errorJSONgen.writeStringField('exceptionMessage',f.getMessage());
            errorJSONgen.writeEndObject();
            String jsonErrorString = errorJSONgen.getAsString();
            return errorJSONgen;
            
        }
    }
    
    public static System.JSONGenerator generateJsonContentResponse(Map<String, String> responseInMap) { 
        try {
            // Create the JSON generator
            System.JSONGenerator gen = JSON.createGenerator(true);
            // Start building the JSON structure
            gen.writeStartObject();
            gen.writeNumberField('status', 201);
            gen.writeBooleanField('success', true);
            gen.writeStringField('time', String.valueOf(DateTime.now()));
            // Build the 'data' object
            gen.writeFieldName('data');
            gen.writeStartObject();
            gen.writeStringField('Id', responseInMap.get('Id'));
            gen.writeStringField('CaseNumber', responseInMap.get('CaseNumber'));
            gen.writeEndObject();
            gen.writeEndObject();
            
            // Get the JSON string
            String jsonString = gen.getAsString();
            
            // Display the generated JSON
            System.debug('Generated JSON: ' + jsonString);
            
            // Return the JSON string
            return gen;
        }
        catch (Exception e) 
        {
            System.JSONGenerator errorgen = JSON.createGenerator(true);
            errorgen.writeStartObject();
            errorgen.writeStringField('message', 'An error occured while generating the Json response');
            errorgen.writeStringField('exceptionMessage',e.getMessage());
            errorgen.writeEndObject();
            String jsonErrorString = errorgen.getAsString();
            return errorgen;
        }
    }
}
