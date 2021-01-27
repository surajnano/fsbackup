import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getRecords from '@salesforce/apex/FinancialsController.getAssets';
import saveRecords from '@salesforce/apex/FinancialsController.saveFinanceRecords';
import saveNewAsset from '@salesforce/apex/FinancialsController.saveNewAsset';
import OBJ_ASSET from '@salesforce/schema/Asset__c';
import deleteAsset from '@salesforce/apex/FinancialsController.deleteRecord';
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
export default class Assets extends LightningElement {

    @api application;
    @track records;
    @track showLoading;
    @track newRecord;
    @track showModal;
    
    @track totals = { basiq : 0, user : 0, assessed : 0};
    //Variables for ountry-State dependent picklists
    @track controllingValues = [];
    @track dependentValues = [];
    @track isEmpty = false;
    controlValues;
    totalDependentValues = [];

    anyExistingLoans = [{label:'Yes', value: 'true'}, {label: 'No', value: 'false'}];
    incomeFrequency = [{label: 'Weekly', value: 'Weekly', toMonthlyCalc : 52}, {label:'Fortnightly', value: 'Fortnightly', toMonthlyCalc : 26}, {label: 'Monthly', value: 'Monthly', toMonthlyCalc : 52}];
    
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
            ObjectName: 'Asset__c',
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
    getRecords(){
        // this.showLoading = true;
        getRecords( { applicationId : this.application.Id } )
        .then(result => {
            this.records = JSON.parse(result); 
            this.totals = calcTotals(this.records);
            this.setRecordClass();
            // this.showLoading = false;
        })
        .catch(error => {
            console.log( error );
            console.log( JSON.stringify( error, null, 4 ) );
            // this.showLoading = false;
        });
    }

    @api get foundRecords(){ return this.records && this.records.length; }
    setRecordClass(){
        this.records.forEach(element => { element.class = 'exclude-'+element.detail.Exclude__c; });
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
                this.dispatchEvent( new CustomEvent('success', { detail: 'assets' }) );
            })
            .catch(error => {
                console.log(error);
                this.showLoading = false;
                this.dispatchEvent( new CustomEvent('error', { detail: 'assets' }) );
            });
        } else {
            this.dispatchEvent( new CustomEvent('error', { detail: 'assets' }) );
        }
            
    }

    handleInputChange(event){
        this.records = handleChange(this.records, event);
        this.totals = calcTotals(this.records);
        this.setRecordClass();
    }





    //MODAL functions

    handleChange(event){

        Object.defineProperty(this.newRecord, event.target.name, {value : event.detail.value, configurable : true, writable : true});

    }

    openModal() { 
        this.isEmpty = false;
        this.editRecordId = undefined;
        this.newRecord = {
            applicationId : this.application.Id,
            applicantId:'',
            unitNumber : '',
            streetNumber : '',
            streetName : '',
            streetType : '',
            suburb : '',
            postalCode : '',
            city : '',
            state : '',
            country : 'Australia',
            propertyValue : undefined,
            notes : '',
            hasLoan : 'true',
            loanBalance : undefined,
            loanMonthlyRepayments : undefined,
            loanNotes : '',
            hasRentalIncome : 'true',
            rentalIncome : undefined,
            incomeFrequency : undefined,
            incomeNotes : ''

        };
        this.showModal = true;
    }
    closeModal() { this.showModal = false; }

    saveNewRecord(){
        console.log( JSON.stringify(this.newRecord, null, 4 ));
        const allValid = checkValidity([...this.template.querySelectorAll('lightning-input[data-new-record], lightning-combobox')]);
        if (allValid) {
            this.convertToMonthlyIncome();
            console.log( JSON.stringify(this.newRecord, null, 4 ));
            saveNewAsset( {payload : JSON.stringify(this.newRecord) })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'New asset created.',
                    variant : 'success',
                    mode: 'pester'
                }));
                this.getRecords( false );
                this.showModal = false;
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error, null, 4 ),
                    variant : 'error',
                    mode: 'pester'
                }));
            });
        }

    }

    checkCustomValidity(){
        if(this.newRecord.hasRentalIncome && this.template.querySelectorAll('lightning-input[name=rentalIncome]').name === '' && inputCmp.value == undefined)
            inputCmp.setCustomValidity('Please complete this field.');
        inputCmp.reportValidity();
    }

    convertToMonthlyIncome(){
        if(this.newRecord.hasRentalIncome && this.newRecord.rentalIncome)
            this.incomeFrequency.forEach(freq => {
                if(freq.value === this.newRecord.incomeFrequency)
                    this.newRecord.monthlyRentalIncome = (this.newRecord.rentalIncome * freq.toMonthlyCalc)/12;
            });
    }

     // Picklist values based on record type
     @wire(getPicklistValuesByRecordType, { objectApiName: OBJ_ASSET, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
     countryPicklistValues({error, data}) {
         if(data) {
             this.error = null;
 
             let countyOptions = [{label:'--None--', value:'--None--'}];
 
             // Account Country Control Field Picklist values
             data.picklistFieldValues.Country__c.values.forEach(key => {
                 countyOptions.push({
                     label : key.label,
                     value: key.value
                 })
             });
 
             this.controllingValues = countyOptions;
 
             let stateOptions = [{label:'--None--', value:'--None--'}];
 
             this.controlValues = data.picklistFieldValues.State__c.controllerValues;
             this.totalDependentValues = data.picklistFieldValues.State__c.values;
 
             this.totalDependentValues.forEach(key => {
                 stateOptions.push({
                     label : key.label,
                     value: key.value
                 })
             });
 
             this.dependentValues = stateOptions;
         }
         else if(error) {
             this.error = JSON.stringify(error);
         }
     }
 
     handleCountryChange(event) {
         // Selected Country Value
         this.newRecord.country = event.target.value;
         this.isEmpty = false;
         let dependValues = [];
 
         if(this.newRecord.country) {
             // if Selected country is none returns nothing
             if(this.newRecord.country === '--None--') {
                 this.isEmpty = true;
                 dependValues = [{label:'--None--', value:'--None--'}];
                 this.newRecord.country = null;
                 this.newRecord.state = null;
                 return;
             }
 
             // filter the total dependent values based on selected country value 
             this.totalDependentValues.forEach(conValues => {
                 if(conValues.validFor[0] === this.controlValues[this.newRecord.country]) {
                     dependValues.push({
                         label: conValues.label,
                         value: conValues.value
                     })
                 }
             })
 
             this.dependentValues = dependValues;
         }
     }
 
     handleStateChange(event) {
         this.newRecord.state = event.target.value;
     }

     editRecord(event){
        this.editRecordId = event.target.dataset.id;
        this.showModal = true;
    }

    handleSuccess(){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Asset updated.',
            variant : 'success',
            mode: 'pester'
        }));
        this.getRecords(  );
        this.getFieldsetFields();

        this.closeModal();
    }

    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row.Id;
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
            case 'delete':
                this.deleteSelectedAsset(row);
                break;
        }
    }

    editCurrentRecord(currentRow) {
        this.editRecordId = currentRow;
        this.showModal = true;
    }

    deleteSelectedAsset(currentRow) {
        deleteAsset({recordId: currentRow, sObjectName: 'Asset__c'})
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Asset record successfully deleted.',
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