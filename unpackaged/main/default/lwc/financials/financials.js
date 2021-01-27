import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplication from '@salesforce/apex/FinancialsController.getApplication';


export default class Financials extends LightningElement {

    @api recordId;
    @track application;
    @track lastUpdatedOn;
    @track saved = { assets : false, liabilities : false, incomes : false, expenses : false };
    @api isDialogVisible;


    connectedCallback(){ 
        this.getApplication(); 
        //window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
    }


    beforeUnloadHandler(event){
        event.preventDefault();
        event.stopPropagation();
    }

    @api
    getApplication(){
        getApplication({applicationId : this.recordId })
        .then(result => {
            this.application = result;
        })
        .catch(error => {
            console.log(error);
        })

    }

    handleSave(e){
        this.template.querySelector('c-incomes').saveRecords();
        this.template.querySelector('c-expenses').saveRecords();
        this.template.querySelector('c-liabilities').saveRecords();
        this.template.querySelector('c-assets').saveRecords();
    }

    handleCancel(){
        this.refreshFinancials();
    }

    refreshFinancials(){
        this.getApplication();
        this.template.querySelector('c-incomes').getRecords();
        this.template.querySelector('c-expenses').getRecords();
        this.template.querySelector('c-liabilities').getRecords();
        this.template.querySelector('c-assets').getRecords();
        //this.template.querySelector('c-financials-highlights-panel').getServiceabilityCalc();
    }

    
    handleSuccess(event){
        
        if( this.saved.hasOwnProperty(event.detail) )
            this.saved[ event.detail ] = true;

        if(Object.values(this.saved).every(Boolean)){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Financial data saved successfully',
                variant : 'success',
                mode: 'pester'
            }));  
            this.getApplication();
            //this.template.querySelector('c-financials-highlights-panel').getServiceabilityCalc();
        }
    }

    handleError(event){

        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: `There was a problem saving ${event.detail}. Please review your changes and try again.`,
            variant : 'error',
            mode: 'pester'
        }));  
        
    }


}