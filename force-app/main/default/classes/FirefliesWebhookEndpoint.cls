@RestResource(urlMapping='/fireflies/*')
global class FirefliesWebhookEndpoint {
    
    @HttpPost
    global static String handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Create Fireflies Meeting record
            Fireflies_Meeting__c meeting = new Fireflies_Meeting__c();
            meeting.Meeting_Title__c = (String) payload.get('title');
            meeting.Meeting_Date__c = DateTime.valueOf((String) payload.get('date'));
            meeting.Duration_Minutes__c = (Decimal) payload.get('duration');
            meeting.Fireflies_URL__c = (String) payload.get('fireflies_url');
            meeting.Transcript__c = (String) payload.get('transcript');
            meeting.Summary__c = (String) payload.get('summary');
            meeting.Action_Items__c = (String) payload.get('action_items');
            meeting.Recording_URL__c = (String) payload.get('recording_url');
            
            // Parse participants
            List<Object> participants = (List<Object>) payload.get('participants');
            meeting.Participants__c = String.join((List<String>) participants, '; ');
            
            insert meeting;
            
            res.statusCode = 200;
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'recordId' => meeting.Id
            });
            
        } catch (Exception e) {
            res.statusCode = 500;
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage()
            });
        }
    }
}