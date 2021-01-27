import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecords from '@salesforce/apex/FinancialsController.saveFinanceRecords';
import getRecords from '@salesforce/apex/FinancialsController.getLiabilities';
import deleteLiability from '@salesforce/apex/FinancialsController.deleteRecord';
import { handleChange, calcTotals, checkValidity } from 'c/financialUtils';
import getFieldSetFieldsByFieldSetName from '@salesforce/apex/CommonUtility.getExtraFields';
const actions = [
    {label: 'Edit', name: 'edit'},
    {label: 'Delete', name: 'delete'}
];
const a = {
    type: 'action',
    typeAttributes: {
        rowActions: actions,
        menuAlignment: 'right'
    }
};
export default class Liabilities extends LightningElement {

    @api application;
    @track records;
    @track totals = { basiq : 0, user : 0, assessed : 0, basiqBalance : 0, basiqRepayment : 0, balance : 0, repayment : 0, assessedBalance : 0, assessedRepayment : 0 };
    @track showModal = false;
    @track showLoading = false;
    @track editRecordId;

    @track data = [];
    @track columns = [];

    @api labels;
    connectedCallback() {
        this.getRecords();
        this.getFieldsetFields();
    }
    @api
    getFieldsetFields() {
        this.showLoading = true;
        getFieldSetFieldsByFieldSetName({
            fieldSetName: 'financials',
            ObjectName: 'Liability__c',
            duplicates: null,
            supportedFieldsOnly: false,
            objectId: this.application.Id
        })
            .then(result => {
                this.data = JSON.parse(result).lstOfSObjs;
                this.columns = JSON.parse(result).lstOfFieldLabels;
                this.columns.push(a);
                this.showLoading = false;
                this.labels = JSON.parse(result).lstOfFieldLabels;
            })
            .catch(error => {
                console.log(error);
                console.log(JSON.stringify(error, null, 4));
                this.showLoading = false;
            });
    }
    @api
    getRecords() {
        getRecords({applicationId: this.application.Id})
            .then(result => {
                this.records = JSON.parse(result);
                this.setRecordClass();
                this.totals = calcTotals(this.records);
            })
            .catch(error => {
                console.log(error);
                console.log(JSON.stringify(error, null, 4));
            });
    }


    @api get foundRecords(){ return this.records && this.records.length; }
    @api get modalHeader(){ return this.editRecordId ? 'Edit Liability' : 'New Liability'; }

    setRecordClass(){
        this.records.forEach(element => { element.class = 'exclude-'+element.detail.Exclude__c; });
    }
    editRecord(event){
        this.editRecordId = event.target.dataset.id;
        this.showModal = true;
    }

    @track showFooter = false;
    openModal(){ this.showModal = true; this.editRecordId = null;}
    closeModal(){ this.showModal = false; }
    handleLoad(){ this.showFooter = true; }
    
    handleLiabilitySuccess(){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'New liability created.',
            variant : 'success',
            mode: 'pester'
        }));
        this.getRecords( false );
        this.getFieldsetFields();
        this.closeModal();
    }

    @api
    saveRecords(){
        const allValid = checkValidity([...this.template.querySelectorAll('lightning-input[data-finance-records]')]);
        if (allValid) {
            this.showLoading = true;
            saveRecords( { payload : JSON.stringify(this.records) } )
            .then(result => {
                console.log(result);
                this.getRecords();
                this.dispatchEvent( new CustomEvent('success', { detail: 'liabilities' }) );
            })
            .catch(error => {
                console.log(error);
                this.showLoading = false;
                this.dispatchEvent( new CustomEvent('error', { detail: 'liabilities' }) );
            });
        } else {
            this.dispatchEvent( new CustomEvent('error', { detail: 'liabilities' }) );
        }
        

    }

    handleInputChange(event){
        this.records = handleChange(this.records, event);
        this.totals = calcTotals(this.records);
        this.setRecordClass();
    }
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row.Id;
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'delete':
                this.deleteSelectedLiability(row);
                break;
        }
    }

    editCurrentRecord(currentRow) {
        this.editRecordId = currentRow;
        this.showModal = true;
    }

    deleteSelectedLiability(currentRow) {
        deleteLiability({recordId: currentRow , sObjectName:'Liability__c'})
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Liability record successfully deleted.',
                    variant: 'success',
                    mode: 'pester'
                }));
                this.getFieldsetFields();
                this.getRecords();

            })
            .catch(error => {
                console.log(error);
                console.log(JSON.stringify(error, null, 4));
            });
    }

}