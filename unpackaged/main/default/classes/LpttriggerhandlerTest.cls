@isTest
public class LpttriggerhandlerTest {
    @isTest()
    static void testLpttriggerhandler(){
        
        loan__Loan_Account__c lac = TestDataFactory.createloanaccount();
        system.debug('loan account found fronm test data factory');
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c(loan__Loan_Account__c = lac.Id, loan__Transaction_Amount__c = 200);
        try{
            insert lpt;  
        }
        catch(DmlException e){
            system.debug('following error occured, '+ e.getMessage());
        }
        /* 
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();         
        //Create a dummy MF_Account         
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');         
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');                  
        //Create a Fee Set
        
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);  
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();         
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);                  
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();                  
        //Create a dummy Loan Product 
        //static loan__Loan_Product__c createLoanProduct(loan__Office_Name__c dummyOffice, loan__MF_Account__c dummyAccount, loan__Currency__c curr, loan__Fee_Set__c dummyFeeSet)
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,dummyAccount,curr, dummyFeeSet);
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';                
        contact dummyClient = new contact();          
        dummyClient.LastName = 'Test Contact';         
        dummyClient.MobilePhone = '0412345678';          
        insert dummyClient;
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForContact(dummyLP, dummyClient, dummyFeeSet, dummyLoanPurpose, dummyOffice);
        loan__Loan_Payment_Transaction__c lptxn = new loan__Loan_Payment_Transaction__c();
        lptxn.loan__Loan_Account__c = loanAccount.Id; 
        lptxn.loan__Cleared__c = false;       
        lptxn.loan__rejected__c = false;          
        lptxn.loan__reversed__c = false;           
        lptxn.loan__Transaction_Amount__c = 1000;          
        lptxn.loan__Transaction_Date__c = system.Today();         
        insert lptxn; */
        
    }
}