@RestResource(urlMapping='/fireflies/webhook')
global class FirefliesWebhookHandler {
    
    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String eventType = (String) payload.get('event_type');
            
            if (eventType == 'transcript_ready') {
                processTranscriptReady(payload);
            } else if (eventType == 'meeting_ended') {
                processMeetingEnded(payload);
            }
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"success": true}');
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
            System.debug('Fireflies Webhook Error: ' + e.getMessage());
        }
    }
    
    private static void processTranscriptReady(Map<String, Object> payload) {
        Map<String, Object> data = (Map<String, Object>) payload.get('data');
        
        String meetingId = (String) data.get('id');
        String title = (String) data.get('title');
        String transcript = (String) data.get('transcript_text');
        String summary = (String) data.get('summary');
        String audioUrl = (String) data.get('audio_url');
        String videoUrl = (String) data.get('video_url');
        DateTime meetingDate = DateTime.valueOf((String) data.get('date'));
        Integer duration = (Integer) data.get('duration');
        
        List<Object> participants = (List<Object>) data.get('participants');
        String participantNames = '';
        if (participants != null) {
            for (Object p : participants) {
                Map<String, Object> participant = (Map<String, Object>) p;
                participantNames += (String) participant.get('name') + '; ';
            }
        }
        
        Fireflies_Meeting__c meeting = new Fireflies_Meeting__c(
            External_Meeting_Id__c = meetingId,
            Meeting_Title__c = title,
            Meeting_Date__c = meetingDate,
            Duration_Minutes__c = duration,
            Transcript__c = transcript,
            Summary__c = summary,
            Audio_URL__c = audioUrl,
            Video_URL__c = videoUrl,
            Participants__c = participantNames.removeEnd('; ')
        );
        
        String relatedRecordId = findRelatedRecord(title, participantNames);
        if (relatedRecordId != null) {
            meeting.Related_Lead__c = relatedRecordId.startsWith('00Q') ? relatedRecordId : null;
            meeting.Related_Application__c = relatedRecordId.startsWith('a0') ? relatedRecordId : null;
            meeting.Related_Opportunity__c = relatedRecordId.startsWith('006') ? relatedRecordId : null;
        }
        
        upsert meeting External_Meeting_Id__c;
        
        createTaskFromMeeting(meeting);
    }
    
    private static void processMeetingEnded(Map<String, Object> payload) {
        processTranscriptReady(payload);
    }
    
    private static String findRelatedRecord(String title, String participants) {
        String searchTerm = '%' + title + '%';
        
        List<Lead> leads = [SELECT Id FROM Lead WHERE Name LIKE :searchTerm OR Email LIKE :searchTerm LIMIT 1];
        if (!leads.isEmpty()) return leads[0].Id;
        
        List<Application__c> apps = [SELECT Id FROM Application__c WHERE Name LIKE :searchTerm LIMIT 1];
        if (!apps.isEmpty()) return apps[0].Id;
        
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name LIKE :searchTerm LIMIT 1];
        if (!opps.isEmpty()) return opps[0].Id;
        
        return null;
    }
    
    private static void createTaskFromMeeting(Fireflies_Meeting__c meeting) {
        Task t = new Task(
            Subject = 'Meeting: ' + meeting.Meeting_Title__c,
            Description = meeting.Summary__c,
            ActivityDate = Date.today(),
            Status = 'Completed',
            Priority = 'Normal',
            Type = 'Call'
        );
        
        if (meeting.Related_Lead__c != null) {
            t.WhoId = meeting.Related_Lead__c;
        } else if (meeting.Related_Application__c != null) {
            t.WhatId = meeting.Related_Application__c;
        } else if (meeting.Related_Opportunity__c != null) {
            t.WhatId = meeting.Related_Opportunity__c;
        }
        
        insert t;
    }
}