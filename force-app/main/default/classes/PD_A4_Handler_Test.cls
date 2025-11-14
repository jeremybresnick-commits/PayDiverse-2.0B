@isTest
private class PD_A4_Handler_Test {
    
    @isTest
    static void testReadyToSubmit_CreatesOpportunity() {
        // Setup: Create Application
        Application__c app = new Application__c(
            Business_Name__c = 'Test Business',
            Primary_Contact_Name__c = 'Jane Smith',
            Primary_Contact_Email__c = 'jane@test.com',
            Primary_Contact_Phone__c = '555-5678',
            Status__c = 'Document Collection'
        );
        
        // Add optional fields if they exist
        try {
            app.put('Actual_Monthly_Volume__c', 50000);
            app.put('Average_Transaction__c', 100);
            app.put('Business_Entity_Type__c', 'LLC');
        } catch (Exception e) { }
        
        insert app;
        
        // Execute: Change status to Ready to Submit
        Test.startTest();
        app.Status__c = 'Ready to Submit';
        update app;
        Test.stopTest();
        
        // Verify: Opportunity created
        List<Opportunity> opps = [SELECT Id, Name, StageName, Amount FROM Opportunity WHERE Name = 'Test Business'];
        System.assertEquals(1, opps.size(), 'Should create one Opportunity');
        System.assertNotEquals(null, opps[0].StageName, 'Stage should be set');
    }
    
    @isTest
    static void testNonTriggeringStatusChange() {
        // Setup
        Application__c app = new Application__c(
            Business_Name__c = 'Test Business',
            Status__c = 'Initial Review'
        );
        insert app;
        
        // Execute: Change to different status
        Test.startTest();
        app.Status__c = 'Document Collection';
        update app;
        Test.stopTest();
        
        // Verify: No Opportunity created
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        System.assertEquals(0, opps.size(), 'Should not create Opportunity for non-trigger status');
    }
    
    @isTest
    static void testSafeFieldAccess() {
        // Setup: Create minimal Application (fields might not exist)
        Application__c app = new Application__c(
            Business_Name__c = 'Minimal Test',
            Status__c = 'Document Collection'
        );
        insert app;
        
        // Execute: Trigger handler
        Test.startTest();
        app.Status__c = 'Ready to Submit';
        update app;
        Test.stopTest();
        
        // Verify: Opportunity created despite missing fields
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Name = 'Minimal Test'];
        System.assertEquals(1, opps.size(), 'Should create Opportunity even with minimal data');
    }
    
    @isTest
    static void testBulkProcessing() {
        // Setup: Create 200 Applications
        List<Application__c> apps = new List<Application__c>();
        for (Integer i = 0; i < 200; i++) {
            Application__c app = new Application__c(
                Business_Name__c = 'Bulk Test ' + i,
                Status__c = 'Document Collection'
            );
            try {
                app.put('Actual_Monthly_Volume__c', 10000 + (i * 100));
            } catch (Exception e) { }
            apps.add(app);
        }
        insert apps;
        
        // Execute: Bulk update to Ready to Submit
        Test.startTest();
        for (Application__c app : apps) {
            app.Status__c = 'Ready to Submit';
        }
        update apps;
        Test.stopTest();
        
        // Verify: All Opportunities created
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        System.assertEquals(200, opps.size(), 'Should create Opportunity for each application');
    }
}