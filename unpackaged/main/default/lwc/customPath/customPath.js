import { LightningElement, api, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/CustomPathController.getPicklistValues';

export default class CustomPath extends LightningElement {

    @api applicationStatusWrapper;

    @wire(getPicklistValues, { objectApiName : 'Application__c', fieldApiName : 'Status__c' })
    wiredStatus({ error, data }) {
        if (data) {
            this.applicationStatusWrapper = JSON.parse(data);
            this.applicationStatusWrapper.forEach(element => {
                element.className = '';
                if(element.isCompleted) element.className = ' completed ';
                if(element.hasException) element.className = ' warning ';
                if(element.isCurrentStep) element.className += ' currentStep ';
            }); 

            console.log( this.applicationStatusWrapper, null, 4 );
        } else if (error) {
            console.log(error);
        }
    }
    

}