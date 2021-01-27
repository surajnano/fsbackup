import { LightningElement, api } from 'lwc';
import getLatestRecord from '@salesforce/apex/ChildController.getLatestRecord';

export default class Parent extends LightningElement {

    @api currentRecord;
    @api error;
    @api recordId;

    objectName = 'Valuation__c';
    fields = 'Id, Name, LastModifiedDate';
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
        this.template.querySelector("c-child").callout(this.objectName, this.fields, this.filter);
    }

    handleRecordUpdate(event){
        this.currentRecord = event.detail;
    }

}