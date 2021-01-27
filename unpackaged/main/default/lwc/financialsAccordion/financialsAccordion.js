import { LightningElement, track, api } from 'lwc';

export default class FinancialsAccordion extends LightningElement {

    @track expanded = true;
    @api sectionTitle;
    @api iconSize;
    @api buttonClass;
    @api buttonLabel;

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
    }
    collapse(){
        this.expanded = false;
    }

    handleClick(event){ 
        event.preventDefault();
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent('buttonclick')); 
    }


}