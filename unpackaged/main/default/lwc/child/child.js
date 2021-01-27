import { LightningElement, api } from 'lwc';
import getLatestRecord from '@salesforce/apex/ChildController.getLatestRecord';

export default class Child extends LightningElement {

    @api currentRecord; 
    @api showSpinner;
    @api error;
    counter;

    @api
    callout(objectName, fields, filter){
        this.showSpinner = true;
        this.counter = 0;
        var _this = this;
        var interval = setInterval( function(){
            _this.counter += 1;
            if(_this.counter === 120){
                clearInterval(interval);
                _this.showSpinner = false;
            }

            //LOGIC

            getLatestRecord({ objectName: objectName, fields : fields, filter : filter })
            .then(result => {
                var latestRecord = result;
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
            });


        } , 1000);

    }
    

}