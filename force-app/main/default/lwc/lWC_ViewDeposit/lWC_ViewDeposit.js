import { LightningElement, wire, api, track } from 'lwc';  
import getDepositsList from '@salesforce/apex/LWC_ViewDepositCls.getDepositsList';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

const COLS = [
    { label: 'First Name', fieldName: 'FirstName', editable: true },
    { label: 'Last Name', fieldName: 'LastName', editable: true },
    { label: 'Title', fieldName: 'Title' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' }
];

export default class LWC_ViewDeposit extends LightningElement {

    @api recordId;
    isloading;
    renderTable = false;
    @track depList;

    connectedCallback() {
        var xyz;
        this.isLoading = true;
        getDepositsList()
            .then(result => {
                this.depList = result;
                if (this.depList.length === 0) {
                    this.renderTable = false;
                }
                else {
                    this.renderTable = true;
                }
            })
            this.isLoading = false;
            console.log('Line 35 -> ',depList);
    }


}