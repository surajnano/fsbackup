import { LightningElement, api, track } from 'lwc';
//import getRecords from '@salesforce/apex/FinancialsController.getRecords';

export default class FinancialsTable extends LightningElement {
    
    @api sectionHeader;
    @api objectApiName
    @api fieldSetApiName;
    @api applicationId;
    
    @track showLoading;

    @track financialData;
    @track financialColumns;

    connectedCallback(){

        this.getFinancialData();

    }


    getFinancialData(){
        // this.showLoading = true;
        // getRecords( { objectApiName : this.objectApiName, fieldSetApiName : this.fieldSetApiName, applicationId : this.applicationId } )
        // .then(result => {
        //     //console.log('financialsTable.js ' + JSON.stringify(result, null, 4));
        //     if(result){
        //         this.financialData = result.lstDataTableData;
        //         this.financialColumns = result.lstDataTableColumns;

        //     }
        //     this.showLoading = false;
           
        // })
        // .catch(error => {
        //     console.log(JSON.stringify(error));
        //     this.showLoading = false;
        // });
    }


}