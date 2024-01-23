public with sharing class FileUploaderClass {
    /*
   * @method uploadFile() 
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
   *   upload was successful, otherwise returns null
   */
   @AuraEnabled
  public static String uploadFile(String base64, String filename) {
     try {
          // Decode base64 data
            Blob fileBlob = EncodingUtil.base64Decode(base64);

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
          System.debug('Sending request...');
          HttpResponse response = http.send(request);
          System.debug('Response from Server in Salesforce: '+response);
          // Check the response and handle accordingly
          if (response.getStatusCode() == 200) {
              String body = response.getBody();
              Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(body);
              Contact newContact = new Contact();
      
              // Set the fields for the new contact
              newContact.FirstName = (String)jsonMap.get('firstName');
              newContact.LastName = (String)jsonMap.get('lastName');
  
              newContact.Email = (String)jsonMap.get('emailId');
              newContact.Phone = (String)jsonMap.get('phone');
              insert newContact;
              return body;
          } else {
            System.debug('Error Response: ' + response.getBody());
              return  'Error code' + response.getStatusCode() + response.getBody();
          }
      } catch (Exception e) {
          // Handle exceptions and return an error message
          return 'Error processing file: ' + e.getMessage();
      }
    
  }
  
}