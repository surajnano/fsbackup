import { LightningElement, track, api } from 'lwc';

export default class AccordionSection extends LightningElement {
    @track expanded = true;
    @track sectionClass = '';
    @api sectionTitle;
    @api iconSize;

    constructor(){
        super();
        if(this.expanded)
            this.expand();
    }
    toggle(event){
        if(this.expanded)
            this.collapse();
        else this.expand();
    }

    expand(){
        this.expanded = true;
        this.sectionClass = 'slds-section slds-is-open';
    }
    collapse(){
        this.expanded = false;
        this.sectionClass = 'slds-section';
    }

}