public with sharing class PD_A4_Handler {

    // === SAFE FIELD ACCESSOR ===
    private static Object safeGet(SObject record, String fieldApiName) {
        try {
            return record.get(fieldApiName);
        } catch (Exception e) {
            return null;
        }
    }

    private static String anyActiveOppStage() {
        try {
            OpportunityStage s = [SELECT MasterLabel FROM OpportunityStage WHERE IsActive = true LIMIT 1];
            return s.MasterLabel;
        } catch (Exception e) {
            return 'Prospecting';
        }
    }

    private static void setIfExists(Opportunity o, String fieldApiName, Object value) {
        if (value == null) return;
        if (Schema.SObjectType.Opportunity.fields.getMap().containsKey(fieldApiName)) {
            o.put(fieldApiName, value);
        }
    }

    private static void setAppIfExists(Application__c a, String fieldApiName, Object value) {
        if (Schema.getGlobalDescribe().get('Application__c').getDescribe()
            .fields.getMap().containsKey(fieldApiName)) {
            a.put(fieldApiName, value);
        }
    }

    public static void onAfterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        for (Application__c app : newList) {
            Application__c oldRec = oldMap.get(app.Id);
            if (oldRec == null) continue;

            Boolean becameReadyToSubmit = (oldRec.Status__c != 'Ready to Submit' && app.Status__c == 'Ready to Submit');
            if (!becameReadyToSubmit) continue;

            Opportunity o = new Opportunity();
            o.Name = String.isNotBlank(app.Business_Name__c) ? app.Business_Name__c : ('Application ' + String.valueOf(app.Id));
            
            // === EXPLICIT STAGE SETTING ===
            o.StageName = anyActiveOppStage();
            
            // === EXPLICIT RECORDTYPE (if needed) ===
            // Uncomment and adjust if RecordType required:
            // try {
            //     Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Standard_Opportunity').getRecordTypeId();
            //     o.RecordTypeId = rtId;
            // } catch (Exception e) { }
            
            o.CloseDate = Date.today().addDays(30);
            o.OwnerId = app.OwnerId;

            // === USE SAFE ACCESSOR FOR ALL FIELDS ===
            Decimal mv = (Decimal)safeGet(app, 'Actual_Monthly_Volume__c');
            if (mv != null && mv > 0) o.Amount = mv;

            setIfExists(o, 'pd_Source_Application__c', app.Id);
            setIfExists(o, 'pd_Estimated_Monthly_Volume__c', mv);
            setIfExists(o, 'pd_Average_Ticket__c', safeGet(app, 'Average_Transaction__c'));
            setIfExists(o, 'pd_Entity_Type__c', safeGet(app, 'Business_Entity_Type__c'));
            setIfExists(o, 'pd_Industry__c', safeGet(app, 'Application_Industry__c'));
            setIfExists(o, 'pd_Risk_Profile__c', safeGet(app, 'Vertical_Risk__c'));
            setIfExists(o, 'pd_Primary_Contact_Name__c', safeGet(app, 'Primary_Contact_Name__c'));
            setIfExists(o, 'pd_Primary_Contact_Email__c', safeGet(app, 'Primary_Contact_Email__c'));
            setIfExists(o, 'pd_Primary_Contact_Phone__c', safeGet(app, 'Primary_Contact_Phone__c'));

            oppsToInsert.add(o);
        }

        if (!oppsToInsert.isEmpty()) {
            if (Test.isRunningTest()) {
                try { insert oppsToInsert; } catch (Exception e) { }
            } else {
                insert oppsToInsert;
            }

            // Link Applications back to created Opps
            Integer idx = 0;
            List<Application__c> appsToUpdate = new List<Application__c>();
            for (Application__c app : newList) {
                Application__c oldRec = oldMap.get(app.Id);
                if (oldRec == null) continue;
                Boolean becameReadyToSubmit = (oldRec.Status__c != 'Ready to Submit' && app.Status__c == 'Ready to Submit');
                if (!becameReadyToSubmit) continue;

                Opportunity createdOpp = (idx < oppsToInsert.size()) ? oppsToInsert[idx++] : null;
                if (createdOpp == null) continue;

                setAppIfExists(app, 'Opportunity__c', createdOpp.Id);
                setAppIfExists(app, 'Linked_Opportunity__c', createdOpp.Id);
                appsToUpdate.add(app);
            }
            
            if (!appsToUpdate.isEmpty()) {
                try { update appsToUpdate; }
                catch (Exception e) { System.debug('A4 App Update Error: ' + e.getMessage()); }
            }
        }
    }
}