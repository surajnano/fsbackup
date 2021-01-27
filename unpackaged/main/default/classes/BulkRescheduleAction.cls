public class BulkRescheduleAction {
    public static loan__Loan_Account__c LAtobeUpdated;
    public static String RescheduleLoanAction(string loanAccountId, Boolean MaintainDelinquencyFlag, Decimal marginRate, Date EffecitveDate, Integer dueDay) {
        Date paymentDate;
        Id loanId = loanAccountId;
        loan.GlobalLoanUtilFacade util = new loan.GlobalLoanUtilFacade();
        Date systemDate = util.getCurrentSystemDate();
        Date transactionDate = systemDate;
        Savepoint sp = Database.setSavepoint();
        try {
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            if (ec.getObject('LoanObject') != null) {
                ec.deleteObject('LoanObject');
            }
            mfiflexUtil.ObjectCache loanOC = ec.createObject('LoanObject',
                'Loan_Account__c',
                loan.CustomSettingsUtil.getOrgParameters().loan__Namespace_Prefix__c);
            loanOC.addFields(loan.ObjectCacheQueryUtil.getLoanSnapshotFields());

            loanOC.addNamedParameter('lAccId', loanAccountId);
            loanOC.setWhereClause('ID = :lAccId');
            loanOC.setLimitClause('1');

            String query = loanOC.buildQuery().getQuery();
            system.debug('quer:' + query);
            LAtobeUpdated = (loan__Loan_Account__c) Database.query(query);

            Map < String, Object > rescheduleParametersmap = new Map < String, Object > ();
            rescheduleParametersmap.put('Reschedule_Balance__c', loan.LoanConstants.RESCHEDULE_BALANCE_PRINCIPAL_REMAINING);
            //Add Interest Only Payments on loan accounts. 
            mfiflexUtil.ExecutionContext ec1 = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache schedOC = ec1.getObject('RepaymentSchedules');
            if (schedOC != null) {
                ec1.deleteObject('RepaymentSchedules');
            }

            schedOC = ec1.createObject('RepaymentSchedules', 'Repayment_Schedule__c',
                loan.CustomSettingsUtil.getOrgParameters().loan__Namespace_Prefix__c);
            schedOC.addFields(loan.ObjectCacheQueryUtil.getScheduleFields());
            schedOC.addNamedParameter('lAccId', loanAccountId);
            schedOC.addNamedParameter('txnDate', transactionDate);
            schedOC.setWhereClause('Is_Archived__c = false AND Loan_Account__c = :lAccId AND Due_Date__c>:txnDate');
            schedOC.setOrderClause('Due_Date__c ASC');
            schedOC.buildQuery();
            List < loan__Repayment_Schedule__c > loanRepaymentSchedules = (List < loan__Repayment_Schedule__c > ) Database.query(schedOC.getQuery());
            Integer interestOnlyPeriod = 0;
            for (loan__Repayment_Schedule__c rs: loanRepaymentSchedules) {
                //In rate change with reschedule, for Delinquent loans we will take only Principal of remaining schedules
                if (rs.loan__Due_Principal__c <= 0) {
                    interestOnlyPeriod = interestOnlyPeriod + 1;
                } else {
                    break;
                }
            }


            //mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext(); 
            if (ec.getObject('LoanObject') != null) {
                ec.deleteObject('LoanObject');
            }
            loan.LoanRescheduleParameters rescheduleParams = new loan.LoanRescheduleParameters(loanID, transactionDate, LAtobeUpdated.loan__Next_Installment_Date__c, null, LAtobeUpdated.loan__Maturity_Date_Current__c, null, interestOnlyPeriod, null, LAtobeUpdated.loan__Frequency_of_Loan_Payment__c, MaintainDelinquencyFlag, null, null, dueDay, null, null, false, rescheduleParametersmap);
            List < loan.LoanRescheduleParameters.RateSchedule > rateScheduleList1 = getRateSchedule(loanID);

            loan__Multi_Step_Loan_Setup__c rateRecord1 = new loan__Multi_Step_Loan_Setup__c(loan__Sequence__c = rateScheduleList1.get(rateScheduleList1.size() - 1).rateSchedule.loan__Sequence__c + 1,
                loan__Start_Date__c = EffecitveDate,
                loan__Margin_Rate__c = marginRate,
                loan__Interest_Rate__c = getRatePercentage(rateScheduleList1.get(rateScheduleList1.size() - 1).rateSchedule.loan__Floating_Rate_Index__c) + marginRate,
                loan__Floating_Rate_Index__c = rateScheduleList1.get(rateScheduleList1.size() - 1).rateSchedule.loan__Floating_Rate_Index__c);
            loan.LoanRescheduleParameters.RateSchedule rateSchedule1 = new loan.LoanRescheduleParameters.RateSchedule(rateRecord1, true, false, False);
            rateScheduleList1.add(rateSchedule1);
            rescheduleParams.setRateSchedule(rateScheduleList1);
            system.debug('rescheduleParams:' + rescheduleParams);
            loan.LoanActionFactory factory = new loan.LoanActionFactory();
            loan.LoanAction8 loanAction = factory.getLoanAction8API();
            loanAction.rescheduleALoan(rescheduleParams);
            return 'Reschedule completed !!';
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(logginglevel.error, 'line number' + e.getLineNumber());
            System.debug(logginglevel.error, 'error stackTrace' + e.getStackTraceString() + e);
            return 'Error:' + e.getStackTraceString();
        }
    }
    public static Decimal getRatePercentage(id indexRate) {

        //assumed there is 1 floating rate till date.
        List < loan__Floating_Rate__c > floatingRates = [select id, loan__Rate_Percentage__c from loan__Floating_Rate__c where loan__Floating_Rate_Index__c =: indexRate and loan__Rate_Effective_To__c = null];
        for (loan__Floating_Rate__c frRec: floatingRates) {
            return frRec.loan__Rate_Percentage__c;
        }
        return 0;
    }

    public static List < loan.LoanRescheduleParameters.RateSchedule > getRateSchedule(Id loanID) {
        List < loan__Multi_Step_Loan_Setup__c > currentRateSchedule = [SELECT ID,
            Name,
            loan__Sequence__c,
            loan__Start_Date__c,
            loan__Interest_Rate__c,
            loan__Floating_Rate_Index__c,
            loan__Margin_Rate__c,
            loan__Loan_Account__c,
            loan__Parent_Multi_Step_Loan_Setup__c
            FROM loan__Multi_Step_Loan_Setup__c
            WHERE loan__Loan_Account__c =: loanID
            ORDER BY loan__Sequence__c, loan__Start_Date__c ASC
        ];
        List < loan.LoanRescheduleParameters.RateSchedule > rateScheduleList = new List < loan.LoanRescheduleParameters.RateSchedule > ();
        if (currentRateSchedule == null || currentRateSchedule.size() == 0) {
            return rateScheduleList;
        }
        for (loan__Multi_Step_Loan_Setup__c rateRecord: currentRateSchedule) {
            loan.LoanRescheduleParameters.RateSchedule rate = new loan.LoanRescheduleParameters.RateSchedule(rateRecord, null, null, null);
            rateScheduleList.add(rate);
        }
        return rateScheduleList;
    }
}