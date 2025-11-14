@RestResource(urlMapping='/sdocs/templates/*')
global class SDocsTemplateCreator {
    
    @HttpPost
    global static String createTemplates() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<String> created = new List<String>();
        
        try {
            // Define 5 core templates
            List<Map<String, String>> templates = new List<Map<String, String>>{
                new Map<String, String>{
                    'name' => 'PayDiverse_MPA_Template',
                    'displayName' => 'Merchant Processing Application',
                    'object' => 'Application__c'
                },
                new Map<String, String>{
                    'name' => 'PayDiverse_Bank_Submission',
                    'displayName' => 'Bank Submission Packet',
                    'object' => 'Bank_Submission__c'
                },
                new Map<String, String>{
                    'name' => 'PayDiverse_Merchant_Agreement',
                    'displayName' => 'Merchant Processing Agreement',
                    'object' => 'Opportunity'
                },
                new Map<String, String>{
                    'name' => 'PayDiverse_Pricing_Proposal',
                    'displayName' => 'Custom Pricing Proposal',
                    'object' => 'Opportunity'
                },
                new Map<String, String>{
                    'name' => 'PayDiverse_Residual_Report',
                    'displayName' => 'Monthly Residual Report',
                    'object' => 'Residual_Report_Data__c'
                }
            };
            
            for (Map<String, String> tpl : templates) {
                created.add('STAGED: ' + tpl.get('name') + ' [' + tpl.get('object') + ']');
            }
            
            res.statusCode = 200;
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'templatesStaged' => created.size(),
                'templates' => created,
                'note' => 'Templates staged. Create via S-Docs UI or configure merge fields as needed.'
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