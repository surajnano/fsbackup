@isTest
private class VertevaUtilsTest {

    @IsTest
    static void setGUID(){
        Account acc = TestDataFactory.createPersonAccount('Testing', 'Test', 'testing@nano.com.au', '456456456');
        TestDataFactory.createCompleteApplication(acc.id);
        
        //assert guid here

        system.assertEquals( 
            String.isNotEmpty( [select ExternalId__c from Application__c limit 1].ExternalId__c ),
            true
        );

        system.assertEquals( 
            String.isNotEmpty( [select ExternalId__c from Property__c limit 1].ExternalId__c ),
            true
        );

        system.assertEquals( 
            String.isNotEmpty( [select ExternalId__c from Applicant__c limit 1].ExternalId__c ),
            true
        );

        system.assertEquals( 
            String.isNotEmpty( [select ExternalId__c from ApplicantAddress__c limit 1].ExternalId__c ),
            true
        );

        system.assertEquals( 
            String.isNotEmpty( [select ExternalId__c from ApplicantEmployment__c limit 1].ExternalId__c ),
            true
        );

    }   

    @istest
    private static void testMethodPositive(){
        String objectName = VertevaUtils.findObjectNameFromRecordIdPrefix('500');
        System.assertEquals(objectName,'Case');
    }
    @isTest
    private static void testMethodNegative(){
        String objectName = VertevaUtils.findObjectNameFromRecordIdPrefix('500');
        System.assertNotEquals(objectName,'Account');
    }
    @isTest
    private static void testMethodNull(){
        String objectName = VertevaUtils.findObjectNameFromRecordIdPrefix('101');
        System.assertEquals(objectName,'');
    }
    @isTest
    private static void testMethodException(){
        String objectName = VertevaUtils.findObjectNameFromRecordIdPrefix('10');
        System.assertEquals(objectName,'');
    }

    @isTest
    private static void testGetPicklistValues(){
        System.assertEquals(
            VertevaUtils.getPicklistValues('Account', 'AccountSource').size() != 0, 
            true
        );
        System.assertEquals(
            VertevaUtils.isEmpty( VertevaUtils.getSerializedPicklistValues('Account', 'AccountSource') ), 
            false
        );
    }


    
}