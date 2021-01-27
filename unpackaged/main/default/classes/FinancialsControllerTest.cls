@isTest 
private class FinancialsControllerTest {
    
    @TestSetup
    static void createFinancials(){
        TestDataFactory.initApplicationSettings();
        Account individual = TestDataFactory.createPersonAccount('Seth', 'Testing', 'testing@verteva.com.au', '456456456');
        //loan__Loan_Product__c lendingproduct = TestDataFactory.createlendingproduct(); 
        Application__c application = TestDataFactory.createApplication(individual.Id);
        TestDataFactory.createFinancials(application.Id);
    }

    @isTest
    static void testRetrieveFinancials(){
        Application__c app = [select id, name from application__c limit 1];
        Application__c testApp = FinancialsController.getApplication(app.id);

        //assert application
        System.assertEquals(app.Name, testApp.Name);

        //assert assets
        System.assertEquals(String.isNotBlank(FinancialsController.getAssets(app.id)), true);

        //assert liabilities
        System.assertEquals(String.isNotBlank(FinancialsController.getLiabilities(app.id)), true);

        //assert expenses
        System.assertEquals(String.isNotBlank(FinancialsController.getExpenses(app.id)), true);

        //assert incomes
        System.assertEquals(String.isNotBlank(FinancialsController.getIncomes(app.id)), true);
    }

    @isTest
    static void testSaveFinancials(){
        Application__c app = [select id, name from application__c limit 1];

        String payload = FinancialsController.getAssets(app.id);
        system.debug(payload);
        List<FinancialsController.FinanceRecord> financeRecords  = (List<FinancialsController.FinanceRecord>) JSON.deserialize(payload, List<FinancialsController.FinanceRecord>.class);

        for(FinancialsController.FinanceRecord fr : financeRecords){
            fr.detail.put('AssessedNotes__c', 'APEXTESTING');
            fr.hasChanged = true;
        }
        FinancialsController.saveFinanceRecords( JSON.serialize( financeRecords ) );

        for(Asset__c updatedAsset : [SELECT AssessedNotes__c FROM Asset__c])
            system.assertEquals(updatedAsset.AssessedNotes__c, 'APEXTESTING');

    }


    @isTest
    static void testSaveNewAsset(){
        Application__c app = [select id, name, (select id from applicants__r) from application__c limit 1];
        Map<String, Object> payload = new Map<String, Object>{
            'applicationId' => app.id,
            'applicantId' => (app.Applicants__r.size() > 0 ? app.Applicants__r[0].id : null),//todo: remove checking applicant array
            'unitNumber' => '22',
            'streetNumber' => '100',
            'streetType' => 'Street',
            'streetName' => 'George',
            'suburb' => 'CBD',
            'postalCode' => '2000',
            'city' => 'Sydney',
            'state' => 'NSW',
            'country' => 'Australia',
            'propertyValue' => '2500009',
            'loanNotes' => 'assessed notes',

            'hasLoan' => 'true',

            'class' => VertevaUtils.getPicklistValues('Liability__c', 'Class__c')[0].getValue(),
            'loanMonthlyRepayments' => '5000',
            'loanBalance' => '500000',
            'loanNotes' => 'assessed notes',

            'hasRentalIncome' => 'true',

            'monthlyRentalIncome' => '2500',
            'incomeNotes' => 'rent notes'

        };

        FinancialsController.saveNewAsset(JSON.serialize(payload));



    }



    @isTest
    static void testServiceability(){
        
        Application__c app = [select id, name, (select id from applicants__r) from application__c limit 1];
        Map<String, Decimal> calc = FinancialsController.getServiceabilityCalc(app.id);

        system.assertEquals(calc !=  null, true);
        system.assertEquals(calc.get('surplusBalance') !=  null, true);
        system.assertEquals(calc.get('basiq') !=  null, true);
        system.assertEquals(calc.get('applicant') !=  null, true);
        system.assertEquals(calc.get('assessed') !=  null, true);
    }

}