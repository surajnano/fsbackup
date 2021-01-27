import { LightningElement, api } from 'lwc';
import getLatestRecord from '@salesforce/apex/CalloutWrapper.getLatestRecord';

export default class ValuationPanel extends LightningElement {

    @api currentRecord;
    @api error;
    @api recordId;
    serviceName = 'CoreLogicValuation';
    objectName = 'Valuation__c';
    fields = 'Id, Name, LastModifiedDate, Property__r.ExternalId__c';
    filter;

    connectedCallback(){    
        
        this.filter = 'Property__c = \'' + this.recordId + '\'';

        getLatestRecord( { objectName: this.objectName, fields : this.fields, filter: this.filter } )
        .then(result => {
            console.log(result);
            this.currentRecord = result;
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });
    }

    callout(){
        this.template.querySelector("c-callout-section-wrapper").callout(this.objectName, this.fields, this.filter, this.serviceName);
    }

    handleRecordUpdate(event){
        this.currentRecord = event.detail;
    }

}