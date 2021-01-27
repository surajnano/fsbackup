function handleChange(records, event){
    records.forEach(record => {
        if(record.detail.Id === event.target.dataset.id){
            record.hasChanged = true;
            record.detail[event.target.name] = event.target.type == 'checkbox' ? event.detail.checked : event.detail.value;
        }
    });
    return records;
    
}

function calcTotals(records){
    let totals = { basiq : 0, user : 0, assessed : 0, basiqBalance : 0, basiqRepayment : 0, balance : 0, repayment : 0, assessedBalance : 0, assessedRepayment : 0 };
    records.forEach(element => {
        if(!element.detail.Exclude__c){
            totals.basiq += element.detail.BasiqAmount__c ? parseFloat(element.detail.BasiqAmount__c) : element.detail.BasiqValue__c ? parseFloat(element.detail.BasiqValue__c) : 0;
            totals.user += element.detail.Amount__c ? parseFloat(element.detail.Amount__c) : element.detail.Value__c ? parseFloat(element.detail.Value__c) : 0;
            totals.assessed += element.detail.AssessedAmount__c ? parseFloat(element.detail.AssessedAmount__c) : element.detail.AssessedValue__c ? parseFloat(element.detail.AssessedValue__c) : 0 ;
            totals.basiqBalance += element.detail.BasiqBalance__c ? parseFloat(element.detail.BasiqBalance__c) : 0;
            totals.basiqRepayment += element.detail.BasiqRepayment__c ? parseFloat(element.detail.BasiqRepayment__c) : 0;
            totals.balance += element.detail.Balance__c ? parseFloat(element.detail.Balance__c) : 0;
            totals.repayment += element.detail.Repayment__c ? parseFloat(element.detail.Repayment__c) : 0;
            totals.assessedBalance += element.detail.AssessedBalance__c ? parseFloat(element.detail.AssessedBalance__c) : 0;
            totals.assessedRepayment += element.detail.AssessedRepayment__c ? parseFloat(element.detail.AssessedRepayment__c) : 0;
        }
    });
    console.log('FUTILS', totals);
    return totals;
}

function checkValidity(fields){
    return fields.reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);
}

export { handleChange, calcTotals, checkValidity };