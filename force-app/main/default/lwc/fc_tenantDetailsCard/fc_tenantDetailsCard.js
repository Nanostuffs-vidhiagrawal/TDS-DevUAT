import {LightningElement, api, track} from 'lwc';
import FcLabelsService from 'c/fc_labelsService';

export default class FcTenantDetailsCard extends LightningElement {

    @api tenantRecord = {};
    @api editEnabled;
    @track privateTenantRecord;

    connectedCallback(){
        this.privateTenantRecord = {};
        this.privateTenantRecord.email = this.tenantRecord.email;
        this.privateTenantRecord.phone = this.tenantRecord.phone;
    }

    labels = new FcLabelsService().getLabels();

    hideModal = () => {
        const modal = this.template.querySelector('c-fc_modal');
        modal.hide();
    }


    editTenant = () => {
        const modal = this.template.querySelector('c-fc_modal');
        modal.show();
    }

    saveRecord = () => {
        let fieldValues = this.template.querySelectorAll('lightning-input');
        const allValid = [...fieldValues]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            let eventTenantRecord = {};
            eventTenantRecord.id = this.tenantRecord.id;
            eventTenantRecord.name = this.tenantRecord.name;
            eventTenantRecord.contactId = this.tenantRecord.contactId;

            fieldValues.forEach(input => {
                eventTenantRecord[input.name] = input.value;
                this.privateTenantRecord[input.name] = input.value;
            });
            const event = new CustomEvent('tenant_changed', {
                detail: {
                    editedTenantRecord: eventTenantRecord,
                }
            });
            this.dispatchEvent(event);
            this.hideModal();
        }
    }


}