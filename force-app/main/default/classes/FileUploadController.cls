// FileUploadController.cls
public with sharing class FileUploadController {
    @AuraEnabled
    public static String sendFileToExternalService(String fileName, String base64Data) {
        try {
            // Decode base64 data
              Blob fileBlob = EncodingUtil.base64Decode(base64Data);

            // Create a ContentVersion record to store the file in Salesforce (optional)
         
            // Prepare the request to the external service
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://vlz4xyy1d2.execute-api.us-east-2.amazonaws.com/stg/analyze');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'multipart/form-data; boundary=boundary123');
            request.setHeader('Accept', 'application/json');
            // request.setHeader('Authorization', 'Bearer YOUR_ACCESS_TOKEN'); // Replace with your actual access token if needed
    
            String boundary = 'boundary123';
            String header = '--' + boundary + '\r\nContent-Disposition: form-data; name="file"; filename="' + fileName + '"\r\nContent-Type:multipart/form-data\r\n\r\n';
            String footer = '\r\n--' + boundary + '--\r\n';

            request.setBodyAsBlob(Blob.valueOf(header + EncodingUtil.base64Encode(fileBlob)+ footer) );

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);

            // Check the response and handle accordingly
            if (response.getStatusCode() == 200) {
                String body = response.getBody();
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(body);
                Contact newContact = new Contact();
        
                // Set the fields for the new contact
                newContact.FirstName = (String)jsonMap.get('name');
    
                newContact.Email = (String)jsonMap.get('emailId');
                newContact.Phone = (String)jsonMap.get('phone');
                insert newContact;
                return body;
            } else {
                return 'Error sending file to external service. Status Code: ' + response.getBody();
            }
        } catch (Exception e) {
            // Handle exceptions and return an error message
            return 'Error processing file: ' + e.getMessage();
        }
      
    }
}
