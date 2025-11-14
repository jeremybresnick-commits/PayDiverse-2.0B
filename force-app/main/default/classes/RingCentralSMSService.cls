public class RingCentralSMSService {
    
    private static final String NAMED_CREDENTIAL = 'ringcentral_api';
    private static final String SMS_ENDPOINT = '/restapi/v1.0/account/~/extension/~/sms';
    private static final Integer SMS_CHAR_LIMIT = 160;
    
    public class SMSRequest {
        public List<String> to;
        public String text;
    }
    
    public class SMSResponse {
        public Boolean success;
        public String messageId;
        public String status;
        public String error;
        public Integer httpStatusCode;
    }
    
    public static SMSResponse sendSMS(String phoneNumber, String message) {
        SMSResponse response = new SMSResponse();
        
        try {
            if (String.isBlank(phoneNumber) || String.isBlank(message)) {
                response.success = false;
                response.error = 'Phone number and message are required';
                return response;
            }
            
            if (message.length() > SMS_CHAR_LIMIT) {
                response.success = false;
                response.error = 'Message exceeds ' + SMS_CHAR_LIMIT + ' character limit';
                return response;
            }
            
            SMSRequest req = new SMSRequest();
            req.to = new List<String>{ phoneNumber };
            req.text = message;
            
            String requestBody = JSON.serialize(req);
            
            HttpRequest httpReq = new HttpRequest();
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Accept', 'application/json');
            httpReq.setEndpoint('callout:' + NAMED_CREDENTIAL + SMS_ENDPOINT);
            httpReq.setBody(requestBody);
            httpReq.setTimeout(30000);
            
            Http http = new Http();
            HttpResponse httpRes = http.send(httpReq);
            response.httpStatusCode = httpRes.getStatusCode();
            
            if (httpRes.getStatusCode() == 200) {
                Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                response.success = true;
                response.messageId = (String) resBody.get('id');
                response.status = (String) resBody.get('messageStatus');
            } else {
                response.success = false;
                response.status = httpRes.getStatus();
                response.error = 'HTTP ' + httpRes.getStatusCode() + ': ' + httpRes.getBody();
            }
            
        } catch (Exception e) {
            response.success = false;
            response.error = 'Exception: ' + e.getMessage();
        }
        
        return response;
    }
    
    public static List<SMSResponse> sendBulkSMS(List<String> phoneNumbers, String message) {
        List<SMSResponse> responses = new List<SMSResponse>();
        
        for (String phone : phoneNumbers) {
            responses.add(sendSMS(phone, message));
        }
        
        return responses;
    }
    
    public static String formatPhoneNumber(String phone) {
        if (String.isBlank(phone)) return null;
        String cleaned = phone.replaceAll('[^0-9]', '');
        if (cleaned.length() == 10) {
            return '+1' + cleaned;
        } else if (cleaned.length() == 11 && cleaned.startsWith('1')) {
            return '+' + cleaned;
        } else if (!cleaned.startsWith('+')) {
            return '+' + cleaned;
        }
        return phone;
    }
}