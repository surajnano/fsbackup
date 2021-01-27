import { LightningElement, api, track, wire } from 'lwc';
import getApplicants from '@salesforce/apex/ApplicantsController.getApplicants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Applicants extends LightningElement {

    @track activeTab;
    @api recordId;
    @track applicants;
    @api identityListSizeBool = false;

    //modal vars
    @track showModal;
    @track modalHeader;
    @track modalObjectApiName;
    @track isCallout = false;
    @track CCRAPPID;

    connectedCallback(){
        this.getApplicants();
    }

    getApplicants(){
        getApplicants({ applicationId : this.recordId })
        .then(data => {
            this.applicants = JSON.parse(JSON.stringify(data));
            if(this.applicants && this.applicants.length > 0)
                this.activeTab = this.applicants[0].Id;

            this.applicants.forEach(element => {
                if(element.ApplicantAddresses__r)
                    element.latestAddressId = element.ApplicantAddresses__r[0].Id;
                if(element.ApplicantEmployments__r)
                    element.latestEmploymentId = element.ApplicantEmployments__r[0].Id;
                if(element.Applicant_Identities__r)
                    element.identities = element.Applicant_Identities__r;
                if(element.Applicant_Identities__r && element.identities.length > 1)
                    this.identityListSizeBool = true;
            });
        })
        .catch(error => {
            console.log(error);
        });
    }

    //modal functions
    newAddress(){
        this.isCallout = false;
        this.modalHeader = 'New address';
        this.modalObjectApiName = 'ApplicantAddress__c';
        this.showModal = true;
    }

    newEmployment(){
        this.isCallout = false;
        this.modalHeader = 'New employment';
        this.modalObjectApiName = 'ApplicantEmployment__c';
        this.showModal = true;
    }
    newIdentity(){
        this.isCallout = false;
        this.modalHeader = 'New Identity';
        this.modalObjectApiName = 'ApplicantIdentity__c';
        this.showModal = true;
    }
    requestCCR(event){
        this.serviceName = 'ApplicantCreditCheck';
        this.modalHeader = 'Request Applicant Credit Check';
        this.displayMessage = 'Are you sure you want to request a Credit Check?';
        this.CCRAPPID = event.target.dataset.applicant;
        this.isCallout = true;
        this.showModal = true;
    }

    requestIDCheck(event){
        this.serviceName = 'ApplicantIdentityVerification';
        this.modalHeader = 'Request Applicant Identity Verification';
        this.displayMessage = 'Are you sure you want to request an Identity Verification?';
        this.CCRAPPID = event.target.dataset.applicant;
        this.isCallout = true;
        this.showModal = true;

    }

    confirmCCRSuccess(){
        this.isCallout = false;
        this.showModal = false;
        this.getApplicants();
    }

    closeModal(){
        this.showModal = false;
    }
    handleSuccess(){
        this.getApplicants();
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: this.modalHeader + ' created.',
            variant : 'success',
            mode: 'pester'
        }));
        
        this.closeModal();
    }

}