public with sharing class PD_A2_Handler {
    private static final String OPS_TEAM_EMAIL = 'ops@paydiverse.com';
    private static final String PREVET_TEAM_EMAIL = 'prevet@paydiverse.com';
    private static final Boolean REASSIGN_TO_OPS = false;
    
    public static void onAfterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        Id merchantTemplateId, opsTemplateId, preVetTemplateId;
        try { 
            merchantTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PD_3B1_ApprovalDocRequest' LIMIT 1].Id;
        } catch (Exception e) { merchantTemplateId = null; }
        
        try {
            opsTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PD_3B2_HandoffNoticeOps' LIMIT 1].Id;
        } catch (Exception e) { opsTemplateId = null; }
        
        try {
            preVetTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PD_3B3_HandoffConfirmPreVet' LIMIT 1].Id;
        } catch (Exception e) { preVetTemplateId = null; }

        Id opsQueueId = null;
        if (REASSIGN_TO_OPS) {
            try {
                opsQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Operations_Team' LIMIT 1].Id;
            } catch (Exception e) { opsQueueId = null; }
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Task> tasks = new List<Task>();
        List<Application__c> appsToReassign = new List<Application__c>();

        for (Application__c app : newList) {
            Application__c oldRec = oldMap.get(app.Id);
            if (oldRec == null) continue;
            
            Boolean becameApprovedForNext = (oldRec.Status__c != 'Approved for Next Steps' && app.Status__c == 'Approved for Next Steps');
            if (!becameApprovedForNext) continue;

            // 1) Merchant email
            if (merchantTemplateId != null && String.isNotBlank(app.Primary_Contact_Email__c)) {
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setTemplateId(merchantTemplateId);
                m.setWhatId(app.Id);
                m.setToAddresses(new String[] { app.Primary_Contact_Email__c });
                m.setSaveAsActivity(true);
                emails.add(m);
            }

            // 2) Ops internal email
            if (opsTemplateId != null && String.isNotBlank(OPS_TEAM_EMAIL)) {
                Messaging.SingleEmailMessage opsMsg = new Messaging.SingleEmailMessage();
                opsMsg.setTemplateId(opsTemplateId);
                opsMsg.setWhatId(app.Id);
                opsMsg.setToAddresses(new String[] { OPS_TEAM_EMAIL });
                opsMsg.setSaveAsActivity(false);
                emails.add(opsMsg);
            }

            // 3) Pre-vet internal email
            if (preVetTemplateId != null && String.isNotBlank(PREVET_TEAM_EMAIL)) {
                Messaging.SingleEmailMessage preVetMsg = new Messaging.SingleEmailMessage();
                preVetMsg.setTemplateId(preVetTemplateId);
                preVetMsg.setWhatId(app.Id);
                preVetMsg.setToAddresses(new String[] { PREVET_TEAM_EMAIL });
                preVetMsg.setSaveAsActivity(false);
                emails.add(preVetMsg);
            }

            // 4) Ops task with portal URL
            String portalUrl = '';
            try {
                Object pu = app.get('Portal_URL__c');
                if (pu != null) portalUrl = String.valueOf(pu);
            } catch (Exception e) { }

            Task t = new Task();
            t.Subject = 'Ops Handoff - Documents and Short Form';
            t.OwnerId = app.OwnerId;
            t.WhatId = app.Id;
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.ActivityDate = Date.today().addDays(1);
            
            String details = 'Application approved for next steps.' + '\n' +
                'Business: ' + app.Business_Name__c + '\n' +
                'Contact: ' + app.Primary_Contact_Name__c + ' / ' + 
                app.Primary_Contact_Phone__c + ' / ' + app.Primary_Contact_Email__c;
            if (portalUrl != '') details += '\nPortal: ' + portalUrl;
            
            t.Description = details;
            tasks.add(t);

            // 5) Optional owner reassignment
            if (REASSIGN_TO_OPS && opsQueueId != null) {
                Application__c appUpdate = new Application__c(Id = app.Id, OwnerId = opsQueueId);
                appsToReassign.add(appUpdate);
            }
        }

        // Execute DML
        if (!emails.isEmpty()) {
            try { Messaging.sendEmail(emails, false); }
            catch (Exception e) { System.debug('A2 Email Error: ' + e.getMessage()); }
        }
        if (!tasks.isEmpty()) {
            try { insert tasks; }
            catch (DmlException e) { System.debug('A2 Task Error: ' + e.getMessage()); }
        }
        if (!appsToReassign.isEmpty()) {
            try { update appsToReassign; }
            catch (DmlException e) { System.debug('A2 Reassign Error: ' + e.getMessage()); }
        }
    }
}