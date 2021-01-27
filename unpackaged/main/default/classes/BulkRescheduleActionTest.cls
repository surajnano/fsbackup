@isTest
public class BulkRescheduleActionTest{
    @testSetup
    public static void setupData() {
        loan.TestHelper.createSeedDataForTesting();
        
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                          dummyAccount,
                                                                          curr,
                                                                          dummyFeeSet);
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name = 'ACH'];
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        Id loanAccountRecordTypeId = Schema.SObjectType.loan__Loan_Account__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        
        
        
        Account a1 = new Account(name = 'Sample');
        
        //a1.RecordType = [select id from RecordType where DeveloperName = 'PersonAccount' LIMIT 1];
        //system.debug(a1.RecordType);
        insert a1;
        loan__Bank_Account__c ba1 = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123456789',
                                                              loan__Bank_Name__c = 'Some Bank',
                                                              loan__Routing_Number__c = '999999991',
                                                              loan__Account_Type__c = 'Checking',
                                                              loan__Account__c = a1.id,
                                                              Account_Holder_Name__c = 'Sample');
        insert ba1;
        
        loan__Bank_Account__c ba = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '123456789',
                                                             loan__Bank_Name__c = 'Some Bank',
                                                             loan__Routing_Number__c = '999999999',
                                                             loan__Account_Type__c = 'Checking',
                                                             loan__Account__c = a1.id,
                                                             Account_Holder_Name__c = 'Sample');
        insert ba;
        
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                                                           a1,
                                                                                           dummyFeeSet,
                                                                                           dummyLoanPurpose,
                                                                                           dummyOffice);
    }
    
    
    
    @isTest 
    static void updateMarginRate() {
        loan__Floating_Rate_Index__c rateIndex=  loan.TestHelper.createFloatingRateIndex();
        loan__Loan_Account__c laAcc = loan.TestHelper2.getLoanAccount(null);
        loan__Multi_Step_Loan_Setup__c rateRecord1 = new loan__Multi_Step_Loan_Setup__c(loan__Sequence__c = 1,
                                                                                        loan__Start_Date__c =date.today().addDays(-10),
                                                                                        loan__Margin_Rate__c = 2,
                                                                                        loan__Interest_Rate__c = 4,
                                                                                        loan__Floating_Rate_Index__c=rateIndex.id,
                                                                                        loan__Loan_Account__c =laAcc.id);
        insert rateRecord1;
        
        laAcc.loan__Loan_Status__c=loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        
        update laAcc;
        Decimal paymentAmt=laAcc.loan__Payment_Amount__c;
        String msg = BulkRescheduleAction.RescheduleLoanAction(laAcc.Id, True, 4, date.today(), (Integer)laAcc.loan__Due_Day__c);
        
    }
}