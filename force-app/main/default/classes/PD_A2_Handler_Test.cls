@isTest
private class PD_A2_Handler_Test {
    
    @isTest
    static void testApprovedForNextSteps_SendsEmail() {
        // Setup: Create Application
        Application__c app = new Application__c(
            Business_Name__c = 'Test Business',
            Primary_Contact_Name__c = 'John Doe',
            Primary_Contact_Email__c = 'john@test.com',
            Primary_Contact_Phone__c = '555-1234',
            Status__c = 'Initial Review'
        );
        insert app;
        
        // Execute: Change status to Approved for Next Steps
        Test.startTest();
        app.Status__c = 'Approved for Next Steps';
        update app;
        Test.stopTest();
        
        // Verify: Task created
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(1, tasks.size(), 'Should create one Ops task');
        System.assert(tasks[0].Subject.contains('Ops Handoff'), 'Task subject should mention Ops');
    }
    
    @isTest
    static void testNonTriggeringStatusChange() {
        // Setup
        Application__c app = new Application__c(
            Business_Name__c = 'Test Business',
            Primary_Contact_Email__c = 'test@test.com',
            Status__c = 'Initial Review'
        );
        insert app;
        
        // Execute: Change to different status
        Test.startTest();
        app.Status__c = 'Document Collection';
        update app;
        Test.stopTest();
        
        // Verify: No tasks created
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(0, tasks.size(), 'Should not create task for non-trigger status');
    }
    
    @isTest
    static void testBulkProcessing() {
        // Setup: Create 200 Applications
        List<Application__c> apps = new List<Application__c>();
        for (Integer i = 0; i < 200; i++) {
            apps.add(new Application__c(
                Business_Name__c = 'Bulk Test ' + i,
                Primary_Contact_Name__c = 'Contact ' + i,
                Primary_Contact_Email__c = 'test' + i + '@test.com',
                Primary_Contact_Phone__c = '555-' + i,
                Status__c = 'Initial Review'
            ));
        }
        insert apps;
        
        // Execute: Bulk update to Approved
        Test.startTest();
        for (Application__c app : apps) {
            app.Status__c = 'Approved for Next Steps';
        }
        update apps;
        Test.stopTest();
        
        // Verify: All tasks created
        List<Task> tasks = [SELECT Id FROM Task WHERE Subject LIKE 'Ops Handoff%'];
        System.assertEquals(200, tasks.size(), 'Should create task for each application');
    }
}