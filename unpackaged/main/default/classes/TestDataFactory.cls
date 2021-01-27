@isTest 
public class TestDataFactory {

    public static void initApplicationSettings(){
        insert new ApplicationSettings__c(
            CalloutIntervalWait__c = 120,
            LarryAPIToken__c = '9876tghjis872d6gbnj9qdasd',
            LarryEndpoint__c = 'https://dev-apply.verteva.com.au',
            Objects__c = 'Account,Applicant__c,ApplicantAddress__c,ApplicantEmployment__c,Application__c,ApplicationBankAccount__c,ApplicationProperty__c,Asset__c,ExceptionLog__c,Expense__c,HEM__c,Income__c,Liability__c,Property__c,Valuation__c',
            SurplusBalance__c = 300
        );
    }

    public static Account createPersonAccount(String firstName, String lastName, String email, String mobile){
        
        Account pa = new Account(
            firstName = firstName,
            lastName = lastName,
            PersonEmail = email,
            PersonMobilePhone = mobile
        );
        insert pa;
        return pa;

    }
    
        //added by suraj   05/12/2020
   public static loan__Loan_Product__c createlendingproduct(){
        /*loan__Loan_Product__c lendingproduct = new loan__Loan_Product__c();
        lendingproduct.loan__Accrual_Entry_Frequency__c = 'Month-end';
        lendingproduct.loan__Accrual_Start_Basis__c =  'Disbursal Date';
        lendingproduct.Name =  'Nano Home Loan' ;
        lendingproduct.loan__Interest_Calculation_Method__c = 'Declining Balance';
        lendingproduct.loan__Time_Counting_Method__c = 'Actual Days (366)';
        lendingproduct.loan__Loan_Product_Type__c = 'Loan';
        lendingproduct.loan__Min_Interest_Rate__c = 0;
        lendingproduct.loan__Max_Interest_Rate__c = 10;
        lendingproduct.loan__Default_Interest_Rate__c = 2;
        lendingproduct.RecordTypeId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();
        lendingproduct.loan__Accrual_Based_Accounting__c = true;
        lendingproduct.loan__Actual_Interest_Only_Payments__c = true;
        lendingproduct.loan__Adjust_Deposit_Amount_In_Payoff__c = true;
        lendingproduct.loan__Min_Loan_Amount__c = 1000;
        lendingproduct.loan__Max_Loan_Amount__c = 2000000;
		lendingproduct.loan__Business_Hours__c = [SELECT Id FROM BusinessHours WHERE IsDefault=true].Id;
		lendingproduct.loan__Can_Waive_Interest_on_Prepaid_loan__c = true;
		lendingproduct.loan__Create_Summaries__c = true;
		lendingproduct.loan__Days_In_A_Year__c = 365;
		lendingproduct.loan__Default_Minimum_Amount_Due__c = 100;
		lendingproduct.loan__Default_Number_of_Installments__c = 350;
		lendingproduct.loan__Delinquency_Basis__c = 'Schedule Balance';
        insert lendingproduct;
        return lendingproduct;*/
       loan.TestHelper.createSeedDataForTesting();
       //Create a Fee Set
       loan__Currency__c curr = loan.TestHelper.createCurrency();
       
       //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
       
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount);
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
       //create dummy loan product
       loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                          dummyAccount,
                                                                          curr,
                                                                          dummyFeeSet);
       dummyLP.Name = 'Nano Home Loan';
        loan__Payment_Mode__c pMode = [select id from loan__Payment_Mode__c where Name = 'ACH'];
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        Id loanAccountRecordTypeId = Schema.SObjectType.loan__Loan_Account__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
       upsert dummyLP;
       return dummyLP;
    }
 
    public static Application__c createApplication(String accountId){
        loan__Loan_Product__c lp = createlendingproduct();
        createconversionmapping();
        Application__c application = new Application__c();
        application.Account__c = accountId;
        application.LendingProduct__c = lp.Id;
        insert application;
        return application;
    }

    public static Applicant__c addApplicant(String applicationId){
        Account coborrower = createPersonAccount('Kate', 'Nano', 'knanotesting@nanotesting.com.au', '456789789');
        Applicant__c newApplicant = new Applicant__c(
            Account__c = coborrower.id,
            Application__c = applicationId,
            Type__c = 'Co-Borrower'
        );
        insert newApplicant;
        return newApplicant;
    }

    public static ExceptionLog__c createApplicationException(String applicationId, String description, String code){
        ExceptionLog__c e = new ExceptionLog__c(
            Application__c = applicationId,
            Description__c = description,
            ExceptionCode__c = code
        );
        insert e;
        return e;
    }

    public static ApplicationChecklistConfiguration__c createChecklistConfig(String code){
        ApplicationChecklistConfiguration__c acc = new ApplicationChecklistConfiguration__c(
            ExceptionCode__c = code,
            ExceptionDescription__c = ' testing exc config'
        );
        insert acc;

        insert new TaskTemplate__c(
            ApplicationChecklistConfiguration__c = acc.id,
            Description__c = 'Task 1',
            DueIn__c = 2,
            Subject__c = 'Task 1 Subject'
        );

        return acc;
    }


    public static Application__c createCompleteApplication(String accountId){
        loan__Loan_Product__c lp = createlendingproduct();
        createconversionmapping();
        Application__c application = new Application__c(
            Account__c = accountId, LendingProduct__c = lp.Id
        );
        insert application;

        Property__c prop = new Property__c(
            Application__c = application.id
        );
        insert prop;

        ApplicationProperty__c applicationProperty = new ApplicationProperty__c(
            Application__c = application.Id,
            Property__c = prop.id
        );
        insert applicationProperty;

        Applicant__c applicant = new Applicant__c(
            Application__c = application.id,
            Account__c = accountId
        );
        insert applicant;

        ApplicantAddress__c applicantAddress = new ApplicantAddress__c(
            Applicant__c = applicant.id
        );
        insert applicantAddress;

        ApplicantEmployment__c applicantEmployment = new ApplicantEmployment__c(
            Applicant__c = applicant.id
        );
        insert applicantEmployment;

        ExceptionLog__c e = new ExceptionLog__c(
            Application__c = application.id
        );
        insert e;

        createFinancials(application.id);
        return application;

    }

    public static void createFinancials(String applicationId){

        Asset__c newAsset = new Asset__c(
            Application__c = applicationId,
            AssessedValue__c = 3240000,
            AssessedNotes__c = 'Some notes',
            BasiqValue__c = 2450000,
            Value__c = 3000000
        );
        insert newAsset;

        insert new Liability__c(
            Application__c = applicationId,
            AssessedBalance__c = 2000000,
            AssessedRepayment__c = 5000,
            AssessedNotes__c = 'mortgage balance'
        );
        
        insert new Income__c(
            Application__c = applicationId,
            AssessedAmount__c = 3200,
            AssessedNotes__c = 'monthly rental income'
        );

        insert new Expense__c(
            Application__c = applicationId,
            AssessedAmount__c = 3200,
            AssessedNotes__c = 'monthly rental income'
        );

    }



    public static loan__Floating_Rate__c createNewRate(loan__Floating_Rate_Index__c index, Decimal ratePercent, Date effectiveFrom, Date effectiveTo){
        if(index == null){
            index = new loan__Floating_Rate_Index__c(
                loan__Active__c = true,
                Name = 'Variable Rate ' + system.now().formatLong()
            );
            insert index;
        }
        loan__Floating_Rate__c rate = new loan__Floating_Rate__c(
            loan__Floating_Rate_Index__c = index.id,
            loan__Active__c = true,
            loan__Rate_Effective_From__c = effectiveFrom,
            loan__Rate_Effective_To__c = effectiveTo,
            loan__Rate_Percentage__c = ratePercent
        );
        insert rate;
        return rate;
    }

    public static clcommon__Rate_Schedule__c createRateSchedule(Date effectiveDate, Decimal interestRate, Decimal marginRate, Integer sequenceNumber, Integer terms, String unit, loan__Floating_Rate_Index__c index){
        clcommon__Rate_Schedule__c rateSchedule = new clcommon__Rate_Schedule__c(
            clcommon__Effective_Date__c = effectiveDate,
            clcommon__Interest_Rate__c = interestRate,
            clcommon__Margin_Rate__c = marginRate,
            clcommon__Sequence_Number__c = sequenceNumber,
            clcommon__Terms__c = terms,
            clcommon__Unit__c = unit,
            loan__Floating_Rate_Index__c = index.id
        );
        insert rateSchedule;
        return rateSchedule;
    }

    public static User createUser(String alias, String emailAddress, String userName){
        // Create a user
        Profile p = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User(alias=alias, email=emailAddress, 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username=userName);
        insert testUser;
        System.assertEquals(testUser.Id != null, true);
        return testUser;
    }
    
    public static NEILON__Folder__c createFoldersForBucket(String name){
        NEILON__Folder__c bucket = new NEILON__Folder__c(Name = name);
        bucket.NEILON__Parent__c = null;
        bucket.NEILON__Active__c = true;
        bucket.NEILON__Default__c = true;
        insert bucket;
        return bucket;
    }
    
    public static List<NEILON__File__c> createFiles(NEILON__Folder__c folder){
        
        // Create files
        List<NEILON__File__c> files = new List<NEILON__File__c>();
        NEILON__File__c file1 = new NEILON__File__c(Name= 'File1.png');
        file1.NEILON__Folder__c = folder.Id;
        file1.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file1.NEILON__Extension__c = '.png';
        file1.NEILON__Size__c = 5000;
        file1.NEILON__Content_Type__c = 'image/png';
        file1.NEILON__Track_Download_History__c = true;
        files.add(file1);
        
        NEILON__File__c file2 = new NEILON__File__c(Name= 'File2.png');
        file2.NEILON__Folder__c = folder.Id;
        file2.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file2.NEILON__Extension__c = '.jpg';
        file2.NEILON__Size__c = 5001;
        file2.NEILON__Content_Type__c = 'image/jpg';
        files.add(file2);
        
        NEILON__File__c file3 = new NEILON__File__c(Name= 'File3.png');
        file3.NEILON__Folder__c = folder.Id;
        file3.NEILON__Bucket_Name__c = 'Test_Bucket1';
        file3.NEILON__Extension__c = '.pdf';
        file3.NEILON__Size__c = 5000;
        file3.NEILON__Content_Type__c = 'image/pdf';
        files.add(file3);
        
        insert files;
        return files;
    }  
    
    public static List<NEILON__Folder__c> createSubfolders(NEILON__Folder__c parentFolder){
		List<NEILON__Folder__c> subFolders = new List<NEILON__Folder__c>();
		NEILON__Folder__c sub1 = new NEILON__Folder__c(Name= parentFolder.Name+'_Sub_Folder1');
		sub1.NEILON__Bucket_Name__c = parentFolder.NEILON__Bucket_Name__c;
		sub1.NEILON__Parent__c = parentFolder.Id;
		subFolders.add(sub1);
		
		NEILON__Folder__c sub2 = new NEILON__Folder__c(Name= parentFolder.Name+'_Sub_Folder2');
		sub2.NEILON__Bucket_Name__c = parentFolder.NEILON__Bucket_Name__c;
		sub2.NEILON__Parent__c = parentFolder.Id;
		subFolders.add(sub2);
		
		insert subFolders;
		return subFolders;
	} 
    //added by Suraj. To take into account conversion mapping for Lending product
    public static List<Conversion_Mapping__c> createconversionmapping(){
        List<Conversion_Mapping__c> cnlist = new List<Conversion_Mapping__c>();
        Conversion_Mapping__c cm = new Conversion_Mapping__c(Target_Object__c = 'loan__Coborrower__c',Target_Field__c = 'loan__Account__c',Source_Field__c ='Account__c',Source_Object__c='Applicant__c',Parent_Object__c='loan__Loan__c',Mandatory__c=true,Filter_Criteria__c='Application__c');
        cnlist.add(cm);
        Conversion_Mapping__c cm1 = new Conversion_Mapping__c(Target_Object__c = 'loan__Loan_Account__c',Target_Field__c = 'loan__Loan_Product_Name__c',Source_Field__c ='LendingProduct__c',Source_Object__c='Application__c');
        cnlist.add(cm1);
        insert cnlist;
        return cnlist;
    }
    //added by Suraj
    public static loan__Loan_Account__c createloanaccount(){
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
        return loanAccount;

    }
}