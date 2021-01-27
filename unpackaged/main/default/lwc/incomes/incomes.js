import {LightningElement, api, track} from 'lwc';
import getRecords from '@salesforce/apex/FinancialsController.getIncomes';
import saveRecords from '@salesforce/apex/FinancialsController.saveFinanceRecords';
import deleteIncome from '@salesforce/apex/FinancialsController.deleteRecord';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
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
export default class Incomes extends LightningElement {

    @api application;
    @track records;
    @track totals = {};
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
            ObjectName: 'Income__c',
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
        // this.showLoading = true;
        getRecords({applicationId: this.application.Id})
            .then(result => {
                this.records = JSON.parse(result);
                this.setRecordClass();
                this.totals = calcTotals(this.records);
                // this.showLoading = false;
            })
            .catch(error => {
                console.log(error);
                console.log(JSON.stringify(error, null, 4));
                // this.showLoading = false;
            });
    }

    setRecordClass() {
        this.records.forEach(element => {
            element.class = 'exclude-' + element.detail.Exclude__c;
        });
    }

    editRecord(event) {
        this.editRecordId = event.target.dataset.id;
        this.showModal = true;
    }

    @api get foundRecords() {
        return this.records && this.records.length;
    }

    @api get modalHeader() {
        return this.editRecordId ? 'Edit Income' : 'New Income';
    }

    @track showFooter = false;

    openModal() {
        this.editRecordId = undefined;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleLoad() {
        this.showFooter = true;
    }

    handleIncomeSuccess() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'New income created.',
            variant: 'success',
            mode: 'pester'
        }));
        this.getFieldsetFields();
        this.getRecords();
        this.closeModal();
    }

    @api
    saveRecords() {
        const allValid = checkValidity([...this.template.querySelectorAll('lightning-input[data-finance-records]')]);
        if (allValid) {
            this.showLoading = true;
            saveRecords({payload: JSON.stringify(this.records)})
                .then(result => {
                    console.log(result);
                    this.getRecords();
                    this.dispatchEvent(new CustomEvent('success', {detail: 'incomes'}));
                })
                .catch(error => {
                    console.log(error);
                    this.showLoading = false;
                    this.dispatchEvent(new CustomEvent('error', {detail: 'incomes'}));
                });
        } else {
            this.dispatchEvent(new CustomEvent('error', {detail: 'incomes'}));
        }


    }

    handleInputChange(event) {
        this.records = handleChange(this.records, event);
        this.totals = calcTotals(this.records);
        this.setRecordClass();
    }

    handleRowActions(event) {
        let actionName = event.detail.action.name;

        window.console.log('actionName ====> ' + actionName);

        let row = event.detail.row.Id;

        window.console.log('row ====> ' + row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'delete':
                this.deleteCons(row);
                break;
        }
    }

    editCurrentRecord(currentRow) {
        this.editRecordId = currentRow;
        this.showModal = true;
    }

    deleteCons(currentRow) {
        deleteIncome({recordId: currentRow , sObjectName:'Income__c'})
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Income record successfully deleted.',
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