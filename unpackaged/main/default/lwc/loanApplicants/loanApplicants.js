import { LightningElement, api, track, wire } from 'lwc';
import getApplicants from '@salesforce/apex/ApplicantsController.getApplicants';

export default class LoanApplicants extends LightningElement {

    @track currentApplicant;
    @api recordId;
    @api applicants;

    @wire(getApplicants, { applicationId : '$recordId' })
    wiredApplicants({ error, data }) {
        if(data){
            console.log(JSON.stringify(data, null, 4));
            this.applicants = data;
            if(this.applicants && this.applicants.length > 0)
                this.currentApplicant = this.applicants[0].Id;
        } else if(error){
            console.log(error);
        }
    }

    handleSelect(event) {
        this.currentApplicant = event.detail.name;
    }


}