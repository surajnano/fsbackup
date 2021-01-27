@RestResource(urlMapping='/getPaymentInformation/*')
global class WSScheduleCalculator{
    
    global class Schedules{
        public Integer serialNumber       { get; set; }
        public Decimal paymentAmount      { get; set; }
        public Decimal interest           { get; set; }
        public Decimal principal          { get; set; }
        public Date    dueDate            { get; set; }
    }
    global class ResponseWrapper{
        public Decimal totalInterest         { get; set; }
        public Decimal totalPayments         { get; set; }
        public Decimal interestOnlyAmount    { get; set; }
        public Decimal PnIAmount             { get; set; }
        public String status                 { get; set; }
        public String errorCode              { get; set; }
        public String errorMessage           { get; set; }
        public List<Schedules> SchedulesList { get; set; }
    }
    
    global static boolean validSchedule(ScheduleCalculator.LoanParams loanParamsToValidate){
        Boolean dateValidationPassed = false;
        Boolean sequenceValidationPassed = false;
        loanParamsToValidate.RateScheduleList.sort();
        if(loanParamsToValidate.RateScheduleList[0].startDate <= loanParamsToValidate.expectedDisbursalDate){
            dateValidationPassed = true;
        }
        Integer previousSeq = 0;
        for(ScheduleCalculator.RateSchedule rs: loanParamsToValidate.RateScheduleList){
            if(rs.interestRate < 0 || rs.sequence < 0){
                return false;
            }else if(rs.sequence < previousSeq){
                return false;
            }else{
                previousSeq = rs.sequence;
                sequenceValidationPassed = true;
            }
        }
        if(dateValidationPassed && sequenceValidationPassed){
            return true;
        }else return false;
    }
    
    @HttpPost
    global static String getPaymentAmountInfo(){
        
        String[] validFrequencies = new String[] {'Daily','Weekly','Bi-weekly','Semi-Monthly','Monthly','Bi-Monthly','Quarterly','Semi-Annual','Annual','Single-Payment'};
        //intialise request and response variables
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        
        //get request parameters
        String jsonRequest = req.requestBody.toString();

        system.debug(jsonRequest);
        
        ScheduleCalculator.LoanParams lp = new ScheduleCalculator.LoanParams();
        lp = (ScheduleCalculator.LoanParams)JSON.deserialize(jsonRequest, ScheduleCalculator.LoanParams.class);
        
  
        
        
        //call financial calculator to get the payment amount and schedule iformation
        ResponseWrapper rw       = new ResponseWrapper();
        if(lp.loanAmount <= 0 || lp.loanAmount == null){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'Invalid/null loan amount';
            return JSON.serialize(rw);
        }
        if(lp.interestOnlyPayments < 0 || lp.interestOnlyPayments == null || lp.Terms < 0 || lp.Terms == null || lp.Terms <= lp.interestOnlyPayments){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'Invalid Terms';
            return JSON.serialize(rw);
        }
        if(lp.expectedDisbursalDate > lp.firstPaymentDate || lp.expectedDisbursalDate == null){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'Expected disbursal date should be on or before the payment start date';
            return JSON.serialize(rw);
        }
        if(lp.firstPaymentDate == null){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'First payment date cannot be null';
            return JSON.serialize(rw);
        }
        if(lp.paymentFrequency == null || !validFrequencies.contains(lp.paymentFrequency)){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'Payment frequency cannot be null or other than: ' +
                                       'Daily,Weekly,Bi-weekly,Semi-Monthly,Monthly,Bi-Monthly,Quarterly,Semi-Annual,Annual,Single-Payment';
            return JSON.serialize(rw);
        }
        if(lp.RateScheduleList == null || !validSchedule(lp)){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 400;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'HTTP_BAD_REQUEST';
            rw.errorMessage          = 'Rate schedule either null or invalid';
            return JSON.serialize(rw);
        }
        
        try{
            ScheduleCalculator sc    = new ScheduleCalculator(lp);
            rw.interestOnlyAmount    = sc.getPaymentAmountIO();
            rw.PnIAmount             = sc.getPaymentAmountPnI();
            rw.SchedulesList         = sc.getRepaymentSchedule();
            res.statuscode           = 200;
            rw.status                = 'SUCCESS';
            rw.errorCode             = 'NO_ERROR';
            rw.errorMessage          = 'NO_ERROR';

            Map<String, Decimal> totals = sc.getTotals();
            rw.totalPayments = totals.get(ScheduleCalculator.TOTAL_PAYMENTS);
            rw.totalInterest = totals.get(ScheduleCalculator.TOTAL_INTEREST);

            system.debug(rw);

            return JSON.serialize(rw);
        }catch(Exception e){
            rw.interestOnlyAmount    = 0;
            rw.PnIAmount             = 0;
            rw.SchedulesList         = null;
            res.statuscode           = 500;
            rw.status                = 'FAILURE';
            rw.errorCode             = 'INTERNAL_SALESFORCE_ERROR';
            rw.errorMessage          = e.getMessage();
            return JSON.serialize(rw);
        }
        
    }    
}