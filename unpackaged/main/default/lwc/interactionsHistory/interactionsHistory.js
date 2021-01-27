/**
 * Created by Muhammad on 24/11/20.
 */

import { LightningElement, api,wire,track } from 'lwc';
import getRecords from '@salesforce/apex/InteractionsHistoryController.getAllCases';
export default class InteractionsHistory extends LightningElement {
    @api recordId;
    @api checkForCalls;
    @track cases;
    @track error;

    handleToggleSection(event) {
        getRecords({ accountId: this.recordId }).then(result => {
            this.cases = JSON.parse(result);
        })
            .catch(error => {
                window.console.log("error: " + JSON.stringify(error));
            });
    }
caseClicked(event){
window.open("/" + event.currentTarget.dataset.id,"_blank");
}

}