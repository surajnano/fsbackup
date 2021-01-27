import { LightningElement, api } from 'lwc';
import getLatestRecord from '@salesforce/apex/CalloutWrapper.getLatestRecord';
import getCalloutInterval from '@salesforce/apex/CalloutWrapper.getCalloutIntervalWait';
import makeCallout from '@salesforce/apex/CalloutWrapper.makeCallout';

export default class CalloutSectionWrapper extends LightningElement {

    @api currentRecord; 
    @api showSpinner;
    @api error;
    counter;
    intervalWait;

    connectedCallback(){
        getCalloutInterval()
        .then(result => {
            this.intervalWait = result;
            console.log( this.intervalWait );
        })
        .catch(error => {
            this.intervalWait = 120;
        });
    }

    @api
    callout(objectName, fields, filter, serviceName){

        this.showSpinner = true;
        makeCallout({ serviceName : serviceName , guid : this.currentRecord.Property__r.ExternalId__c })
        .then(result => {

            this.counter = 0;
            var _this = this;
            var interval = setInterval( function(){
                _this.counter += 1;
                if(_this.counter === _this.intervalWait){
                    clearInterval(interval);
                    _this.showSpinner = false;
                }

                getLatestRecord({ objectName: objectName, fields : fields, filter : filter })
                .then(result => {
                    var latestRecord = result;
                    console.log(JSON.stringify(latestRecord));
                    if( (_this.currentRecord == undefined && latestRecord) || 
                        (latestRecord && _this.currentRecord && latestRecord.Id !== _this.currentRecord.Id) ){
                        clearInterval(interval);
                        _this.showSpinner = false;
                        _this.currentRecord = latestRecord;

                        _this.dispatchEvent(
                            new CustomEvent("recordupdate", {
                                detail: _this.currentRecord
                            })
                        );
                    }

                })
                .catch(error => {
                    _this.error = error;
                    console.log(error);
                    clearInterval(interval);
                });


            } , 1000);

        })
        .catch(error => {
            console.log(JSON.stringify(error.body));
            this.showSpinner = false;
        });
    }

}