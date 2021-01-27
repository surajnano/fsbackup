global class ScheduleCalculator{

    public static final String TOTAL_PAYMENTS = 'totalPayments';
    public static final String TOTAL_INTEREST = 'totalInterest';

    
    //creating a wrapper for rate schedule
    global class RateSchedule implements Comparable {
        global Integer sequence     { global get; global set; }
        global Date    startDate    { global get; global set; }
        global Decimal interestRate { global get; global set; }

        /*
         * Method: compareTo
         *
         * Description: Implements compareTo which gets used by sort implicitly
         */
        public Integer compareTo(Object compareTo) {
            RateSchedule compareToRec = (RateSchedule)compareTo;
            if (startDate == compareToRec.startDate) return 0;
            if (startDate > compareToRec.startDate) return 1;
            return -1;
        }
    }
    //creating a wrapper for the request
    global class LoanParams{
        global Decimal loanAmount                    { global get; global set; }
        global Integer interestOnlyPayments          { global get; global set; }
        global Integer terms                         { global get; global set; }
        global Date    expectedDisbursalDate         { global get; global set; }
        global Date    firstPaymentDate              { global get; global set; }
        global String  paymentFrequency              { global get; global set; }
        global List<RateSchedule> RateScheduleList   { global get; global set; }       
    }
    LoanParams lp;
    List<clcommon.FinancialCalculator.RepaymentSchedule> emiListemiList3;
    global ScheduleCalculator(LoanParams lp){
        this.lp = lp;
        Decimal loanAmount = lp.loanAmount;
        Decimal paymentAmount = null;
        Integer term = lp.terms;
        Decimal rate = 0;
        Integer interestOnlyTerm = lp.interestOnlyPayments;
        Integer dueDay = null;
        Date contractDate = lp.expectedDisbursalDate;
        Date firstPaymentDate = lp.firstPaymentDate;
        Date lastPaymentDate = null;
        Date secondPaymentDate = null;
        Decimal balloon = 0;
        String paymentFrequency = lp.paymentFrequency;
        String timeCountingMethod = 'Actual Days';
        //String accrualBaseMethodCode = clcommon.CLConstants.'365/365';
        String billingMethodCode = 'Flexible Repayment';
        String repaymentProc = 'Flexible Repayment';
        String action = 'CALCULATE_ALL';
        
        Boolean moveAcrossMonth = false;
        String scheduleAdjustmentMethod = 'Before';
        //This businesshours is associated with a recurring holiday(1st day of every month).
        BusinessHours bankHours= null;

        Boolean orgRoundingOn = true;
        Integer orgDigitsAfterDecimals = 2;
        String  orgRoundMode = clcommon.CLConstants.ROUNDING_MODE_NEAREST;
        Boolean orgSkipHolidays = false;
        Boolean orgAdjustRoundingInLastPayment = true;
        Boolean orgFinalPaymentDifference = true;
        String orgInterestOnlyPeriodBehavior = 'Actual';
        Decimal orgCalculatorVersion = 3.1;
        Decimal orgRoundingFactor = 0.01;
        Boolean principalInterestRoundingOn = true;

        Map<String, Object> orgInputs = new Map<String, Object>();
        Map<String, Object> calcInputs = new Map<String, Object>();

        

        orgInputs.put('orgRoundingOn', orgRoundingOn);
        orgInputs.put('orgDigitsAfterDecimals', orgDigitsAfterDecimals);
        orgInputs.put('orgRoundMode', orgRoundMode);
        orgInputs.put('orgSkipHolidays', orgSkipHolidays);
        orgInputs.put('orgAdjustRoundingInLastPayment', orgAdjustRoundingInLastPayment);
        orgInputs.put('orgFinalPaymentDifference', orgFinalPaymentDifference);
        orgInputs.put('orgInterestOnlyPeriodBehavior', orgInterestOnlyPeriodBehavior);

        Boolean calc3Failed = false;

        calcInputs.put('Loan_Amt_c', loanAmount);
        calcInputs.put('Contract_Dt_c', contractDate);
        calcInputs.put('First_Payment_Dt_c', firstPaymentDate);
        calcInputs.put('Payment_Amt_c', 0);
        calcInputs.put('Payment_Amt_2_Start_dt_c', null);
        calcInputs.put('Payment_Amt_2_c', null);
        calcInputs.put('First_Payday_Date_c', firstPaymentDate);
        calcInputs.put('Second_Payday_Date_c', secondPaymentDate);
        calcInputs.put('Rate_c', rate);
        calcInputs.put('Term_c', term);
        calcInputs.put('Amortization_Term_c', null);
        calcInputs.put('Interest_Only_Period_c', interestOnlyTerm);
        calcInputs.put('InterestOnly_Payment_Amt_c', 0);
        calcInputs.put('Payment_Amt_c', paymentAmount);
        calcInputs.put('Balloon_Payment_Amt_c', balloon);
        calcInputs.put('Payment_Frequency_Cd_c', paymentFrequency);
        calcInputs.put('Payment_Frequency_Multiplier_c', 1);
        calcInputs.put('Time_Counting_Method_Cd_c', timeCountingMethod);
        calcInputs.put('Accrual_Base_Method_Cd_c', '365/365');
        calcInputs.put('Billing_Method_Cd_c', billingMethodCode);
        calcInputs.put('Due_Day_c', dueDay);
        calcInputs.put('Repayment_Procedure_c', repaymentProc);
        calcInputs.put('Action_c', action);
        calcInputs.put('Additional_Interest_Amt_c', 0.0);
        calcInputs.put('Financed_Fees_c', 0.0);
        calcInputs.put('Prepaid_Fees_c', 0.0);
        calcInputs.put('Recurring_Fee_Frequency_c', null);
        calcInputs.put('Principal_Interest_Rounding_On_c', principalInterestRoundingOn);
        calcInputs.put('Bank_Hours_c', bankHours);
        calcInputs.put('Schedule_Adjustment_Method_c', scheduleAdjustmentMethod);
        calcInputs.put('Move_Across_Month_c', moveAcrossMonth);

        List<clcommon.FinancialCalculator.RateSchedule> rs = new List<clcommon.FinancialCalculator.RateSchedule>();
        
        for(RateSchedule rsInstance :lp.RateScheduleList){
            clcommon.FinancialCalculator.RateSchedule managedRateSchedule = new clcommon.FinancialCalculator.RateSchedule();
            managedRateSchedule.sequence        = rsInstance.sequence;
            managedRateSchedule.startDate       = rsInstance.startDate;
            managedRateSchedule.interestRate    = rsInstance.interestRate;
            rs.add(managedRateSchedule);
        }
        System.debug(rs.size());
        List<clcommon.FinancialCalculator.ProposedRepaymentSchedule> ps = new List<clcommon.FinancialCalculator.ProposedRepaymentSchedule>();
        List<clcommon.FinancialCalculator.HolidaySchedule> hs = new List<clcommon.FinancialCalculator.HolidaySchedule>();
        String msgPrefix = '';

        try {
            clcommon.LoanCalculator_v3.LoanCalculatorInput lI = new clcommon.LoanCalculator_v3.LoanCalculatorInput(calcInputs);
            clcommon.LoanCalculator_v3 fc3 = new clcommon.LoanCalculator_v3(orgInputs);
            emiListemiList3 = new List<clcommon.FinancialCalculator.RepaymentSchedule>();
            emiListemiList3 = fc3.calculateEMI(lI, rs, ps);
            system.debug(lI.rate_c);
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, msgPrefix + '[Calc3] ' + e.getMessage()  + 'ST: ' + e.getStackTraceString());
            calc3Failed = true;
        }
    
        
    }
    
    global Decimal getPaymentAmountIO(){

        if(emiListemiList3 != null && emiListemiList3.size() > 0){
            if(lp.interestOnlyPayments > 0)
                return emiListemiList3[0].amount.setScale(2);
            
        }
        return 0;
    }
    
    global Decimal getPaymentAmountPnI(){
        if(emiListemiList3 != null && emiListemiList3.size() > 0){
            if(lp.interestOnlyPayments > 0)
            return emiListemiList3[lp.interestOnlyPayments].amount.setScale(2);
        }
        return 0;
    }
    
    global List<WSScheduleCalculator.Schedules> getRepaymentSchedule(){
        List<WSScheduleCalculator.Schedules> ScheduleList = new List<WSScheduleCalculator.Schedules>();
        for (clcommon.FinancialCalculator.RepaymentSchedule e : emiListemiList3) {
                WSScheduleCalculator.Schedules scheduleInstance = new WSScheduleCalculator.Schedules();
                scheduleInstance.serialNumber  = e.paymentNo;
                scheduleInstance.paymentAmount = e.amount.setScale(2);
                scheduleInstance.interest      = e.interest.setScale(2);
                scheduleInstance.principal     = e.principal.setScale(2);
                scheduleInstance.duedate       = e.dueDate;
                ScheduleList.add(scheduleInstance);

                
            }
        return ScheduleList;
    }

    global Map<String, Decimal> getTotals(){
        Decimal totalPayments = 0;
        Decimal totalInterest = 0;
        for (clcommon.FinancialCalculator.RepaymentSchedule e : emiListemiList3){
            totalPayments += e.amount.setScale(2);
            totalInterest += e.interest.setScale(2);
        }

        return new Map<String, Decimal>{
            TOTAL_PAYMENTS => totalPayments,
            TOTAL_INTEREST => totalInterest
        };
    }

}