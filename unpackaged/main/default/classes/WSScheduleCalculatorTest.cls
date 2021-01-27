@isTest(SeeAllData = false)
global class WSScheduleCalculatorTest{
    @isTest(SeeAllData = false)
    static void testWithCorrectParams() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-03-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":500000,"paymentFrequency":"Monthly","RateScheduleList":[{"startDate":"2020-03-21","sequence":1,"interestRate":2.6},{"startDate":"2020-10-21","sequence":2,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    @isTest(SeeAllData = false)
    static void testWithInCorrectLoanAmount() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-03-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":0,"paymentFrequency":"Monthly","RateScheduleList":[{"startDate":"2020-03-21","sequence":1,"interestRate":2.6},{"startDate":"2020-10-21","sequence":2,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    @isTest(SeeAllData = false)
    static void testWithInCorrectTerm() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-03-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":500000,"paymentFrequency":"Monthly","RateScheduleList":[{"startDate":"2020-03-21","sequence":1,"interestRate":2.6},{"startDate":"2020-10-21","sequence":2,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":-360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    @isTest(SeeAllData = false)
    static void testWithInCorrectDisbursalDate() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-05-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":500000,"paymentFrequency":"Monthly","RateScheduleList":[{"startDate":"2020-03-21","sequence":1,"interestRate":2.6},{"startDate":"2020-10-21","sequence":2,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    @isTest(SeeAllData = false)
    static void testWithInCorrectFrequency() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-03-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":500000,"paymentFrequency":"Montly","RateScheduleList":[{"startDate":"2020-03-21","sequence":1,"interestRate":2.6},{"startDate":"2020-10-21","sequence":2,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    @isTest(SeeAllData = false)
    static void testWithInCorrectRateSchedule() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String rw;
        req.requestURI = '/getPaymentInformation/';
        String requestParams = '{"expectedDisbursalDate":"2020-03-21","firstPaymentDate":"2020-04-21","interestOnlyPayments":60,"loanAmount":500000,"paymentFrequency":"Monthly","RateScheduleList":[{"startDate":"2020-03-21","sequence":2,"interestRate":2.6},{"startDate":"2020-10-21","sequence":1,"interestRate":2.7},{"startDate":"2025-03-21","sequence":3,"interestRate":3.6}],"terms":360}';
        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestParams);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        rw = WSScheduleCalculator.getPaymentAmountInfo();
        Test.stopTest();
        System.debug(LoggingLevel.ERROR, '--2---'+rw);
        //System.debug(LoggingLevel.ERROR, '--2---'+results.errorCode);
        //System.assertEquals(System.Label.INVESTMENT_ORDER_ID_NULL, results.errorMessage);
        //System.assertEquals(Constants.IO_SALE_IO_ID_NULL, results.errorNumber);
    }
    
}