@isTest
public class RingCentralSMSServiceTest {
    
    @isTest
    static void testSendSMSSuccess() {
        Test.setMock(HttpCalloutMock.class, new RingCentralSMSMockSuccess());
        
        RingCentralSMSService.SMSResponse response = 
            RingCentralSMSService.sendSMS('+12025551234', 'Test message');
        
        System.assertEquals(true, response.success);
        System.assertEquals('SMS-123456', response.messageId);
        System.assertEquals('Queued', response.status);
    }
    
    @isTest
    static void testSendSMSInvalidPhone() {
        RingCentralSMSService.SMSResponse response = 
            RingCentralSMSService.sendSMS('', 'Test message');
        
        System.assertEquals(false, response.success);
        System.assert(response.error.contains('Phone number and message are required'));
    }
    
    @isTest
    static void testSendSMSInvalidMessage() {
        RingCentralSMSService.SMSResponse response = 
            RingCentralSMSService.sendSMS('+12025551234', '');
        
        System.assertEquals(false, response.success);
        System.assert(response.error.contains('Phone number and message are required'));
    }
    
    @isTest
    static void testSendSMSExceedsCharLimit() {
        String longMessage = 'a'.repeat(161);
        RingCentralSMSService.SMSResponse response = 
            RingCentralSMSService.sendSMS('+12025551234', longMessage);
        
        System.assertEquals(false, response.success);
        System.assert(response.error.contains('exceeds'));
    }
    
    @isTest
    static void testSendSMSHttpError() {
        Test.setMock(HttpCalloutMock.class, new RingCentralSMSMockError());
        
        RingCentralSMSService.SMSResponse response = 
            RingCentralSMSService.sendSMS('+12025551234', 'Test message');
        
        System.assertEquals(false, response.success);
        System.assertEquals(400, response.httpStatusCode);
    }
    
    @isTest
    static void testFormatPhoneNumber() {
        String formatted1 = RingCentralSMSService.formatPhoneNumber('2025551234');
        System.assertEquals('+12025551234', formatted1);
        
        String formatted2 = RingCentralSMSService.formatPhoneNumber('12025551234');
        System.assertEquals('+12025551234', formatted2);
        
        String formatted3 = RingCentralSMSService.formatPhoneNumber('(202) 555-1234');
        System.assertEquals('+12025551234', formatted3);
    }
    
    @isTest
    static void testSendBulkSMS() {
        Test.setMock(HttpCalloutMock.class, new RingCentralSMSMockSuccess());
        
        List<String> phones = new List<String>{'+12025551234', '+12025555678'};
        List<RingCentralSMSService.SMSResponse> responses = 
            RingCentralSMSService.sendBulkSMS(phones, 'Bulk message');
        
        System.assertEquals(2, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(true, responses[1].success);
    }
    
    private class RingCentralSMSMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"SMS-123456","messageStatus":"Queued"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RingCentralSMSMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"Invalid phone number"}');
            res.setStatusCode(400);
            return res;
        }
    }
}