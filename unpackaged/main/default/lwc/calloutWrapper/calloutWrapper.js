import { LightningElement, api } from 'lwc';
import makeCallout from '@salesforce/apex/CalloutWrapper.makeCallout';
import getLatestRecord from '@salesforce/apex/CalloutWrapper.getLatestRecord';
import getCalloutInterval from '@salesforce/apex/CalloutWrapper.getCalloutIntervalWait';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CalloutWrapper extends LightningElement {

    @api serviceName;
    @api recordId;
    @api modalTitle;
    @api showSpinner;
    @api displayMessage;
    @api queryObjectName;
    @api queryFilterField;
    @api queryFields;
    @api currentRecord;

    intervalWait;

    connectedCallback(){
        let filter =  this.queryFilterField + ' = \'' + this.recordId + '\'';
        getLatestRecord( { objectName: this.queryObjectName, fields : this.queryFields, filter: filter } )
        .then(result => {
            this.currentRecord = result;
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });

        getCalloutInterval()
        .then(result => {
            this.intervalWait = result;
            console.log( this.intervalWait );
        })
        .catch(error => {
            this.intervalWait = 120;
        });
    }

    confirmCallout(){
        this.showSpinner = true;
        makeCallout({ serviceName : this.serviceName , guid : this.currentRecord.ExternalId__c })
        .then(result => {

            let res = JSON.parse(result);

            //result 
            console.log(res);
            if(res.status === '200'){
                this.runIntervalCheck();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: res.status + ' - ' + res.message,
                        variant : 'error',
                        mode: 'pester'
                    })
                );
                this.showSpinner = false;    
            }
            
           
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body,
                    variant : 'error',
                    mode: 'pester'
                })
            );
            this.showSpinner = false;
        });


    } 

    cancel(){
        this.dispatchEvent( new CustomEvent( 'cancel' ) );
    }

    
    runIntervalCheck(){
        this.counter = 0;
        var _this = this;
        var interval = setInterval( function(){
            _this.counter += 1;
            if(_this.counter === _this.intervalWait){
                clearInterval(interval);
                _this.showSpinner = false;
            }
            getLatestRecord( { objectName: _this.queryObjectName, fields : _this.queryFields, filter: _this.filter } )
            .then(result => {
                var latestRecord = result;
                if( (_this.currentRecord == undefined && latestRecord) || 
                    (latestRecord && _this.currentRecord && latestRecord.LastModifiedDate !== _this.currentRecord.LastModifiedDate) ){
                    clearInterval(interval);
                    _this.showSpinner = false;
                    _this.currentRecord = latestRecord;

                    _this.dispatchEvent(
                        new CustomEvent("confirmsuccess", {
                            detail: _this.currentRecord
                        })
                    );

                }

            })
            .catch(error => {
                _this.error = error;
                console.log(error);
            });


        } , 1000);
    }

}