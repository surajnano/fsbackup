import { LightningElement, api, track } from 'lwc';
import getServiceabilityCalc from '@salesforce/apex/FinancialsController.getServiceabilityCalc';

export default class FinancialsHighlightsPanel extends LightningElement {

    @api application;
    @track serviceability;

    connectedCallback(){
        this.getServiceabilityCalc();
    }

    @api
    getServiceabilityCalc(){

        getServiceabilityCalc( { applicationId : this.application.Id })
        .then(result => { 
            console.log('FHP', JSON.stringify(result, null, 4));
            if(result)
                this.serviceability = result;

        })
        .catch(error => {
            if(error)
                console.log('FHP', JSON.stringify(error));

        })
    }

    @api get basiqClass(){ return this.serviceability.basiq < this.serviceability.surplusBalance ? 'red' : 'green'; }
    @api get applicantClass(){ return this.serviceability.applicant < this.serviceability.surplusBalance ? 'red' : 'green'; }
    @api get assessedClass(){ return this.serviceability.assessed < this.serviceability.surplusBalance ? 'red' : 'green'; }
    @api get lastModifiedByUrl(){ return this.application.FinancialLastModifiedBy__c ? '/'+this.application.FinancialLastModifiedBy__c : '';}

}