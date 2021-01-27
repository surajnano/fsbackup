import { LightningElement, api, track } from 'lwc';

const sldsClasses = ' slds-form-element__static slds-grow word-break-ie11 is-read-only ';

export default class CustomField extends LightningElement {

    @api title;
    @api isNumber;
    @api isDate;
    @api isUrl;
    @api styleClass;
    @api formatStyle;
    @api label;
    @api value;

    
    
    @api get fieldClass(){

        return this.styleClass ? this.styleClass + sldsClasses : sldsClasses; 
    }

}