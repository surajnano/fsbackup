import { LightningElement, api, track } from 'lwc';
import getRecords from '@salesforce/apex/FinancialsController.getExpenses';
import saveRecords from '@salesforce/apex/FinancialsController.saveFinanceRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteExpense from '@salesforce/apex/FinancialsController.deleteRecord';
import {handleChange, calcTotals, checkValidity} from 'c/financialUtils';
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
export default class Expenses extends LightningElement {

    @api application;
    @track records;
    @track totals = { basiq : 0, user : 0, assessed : 0};
    @track showModal = false;
    @track showLoading = false;
    @api editRecordId;
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
            ObjectName: 'Expense__c',
            duplicates: null,
            supportedFieldsOnly: false,
            objectId: this.application.Id
        })
            .then(result => {
                this.data = JSON.parse(result).lstOfSObjs;
                this.columns = JSON.parse(result).lstOfFieldLabels;
                console.log(JSON.parse(result).lstOfSObjs);
                console.log(JSON.parse(result).lstOfFieldLabels);
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
    getRecords(showChildren){
        // this.showLoading = true;
        getRecords( { applicationId : this.application.Id } )
        .then(result => {
            this.handleResult(JSON.parse(result), showChildren);
            this.setRecordClass();
            console.log( JSON.stringify( this.records , null, 4 ) );
            // this.showLoading = false;
        })
        .catch(error => {
            console.log( error );
            console.log( JSON.stringify( error, null, 4 ) );
            // this.showLoading = false;
        });
    }

    setRecordClass(){
        this.records.forEach(element => { element.class = 'exclude-'+element.detail.Exclude__c; });
    }
    
    toggleChildRecords(event){
        this.records.filter(function(record) {
            if(record.detail.Id === event.target.name)
                record.diplayChildRecords = !record.diplayChildRecords;
        });        
    }

    handleResult(result, showChildren){
        this.records = result; 
        this.records.forEach(element => {
            element.diplayChildRecords = showChildren;
            element.hasChildren = element.childRecords && element.childRecords.length > 0;
        });
        this.totals = calcTotals(this.records);
    }

    editRecord(event){
        this.editRecordId = event.target.dataset.id;
        this.showModal = true;
    }

    @api get foundRecords(){ return this.records && this.records.length; }
    @api get modalHeader(){ return this.editRecordId ? 'Edit Expense' : 'New Expense'; }

    @track showFooter = false;
    openModal(){ this.showModal = true; this.editRecordId = null;}
    closeModal(){ this.showModal = false; }
    handleLoad(){ this.showFooter = true; }
    
    handleExpenseSuccess(){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'New expense created.',
            variant : 'success',
            mode: 'pester'
        }));
        this.getRecords(false);
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
                this.showLoading = false;
                this.dispatchEvent( new CustomEvent('success', { detail: 'expenses' }) );
            })
            .catch(error => {
                console.log(error);
                this.showLoading = false;
                this.dispatchEvent( new CustomEvent('error', { detail: 'expenses' }) );
            });
        } else {
            this.dispatchEvent( new CustomEvent('error', { detail: 'expenses' }) );
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
        deleteExpense({recordId: currentRow, sObjectName: 'Expense__c'})
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Expense record successfully deleted.',
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