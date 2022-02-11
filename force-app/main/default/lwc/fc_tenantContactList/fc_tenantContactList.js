import {LightningElement, api} from 'lwc';

export default class FcTenantContactList extends LightningElement {

    @api tenantList = [];
    @api editEnabled;

    handleEditTenant = (event) => {
        let eventTenantRecord = {
            name : event.detail.editedTenantRecord.name,
            email : event.detail.editedTenantRecord.email,
            phone : event.detail.editedTenantRecord.phone,
            id : event.detail.editedTenantRecord.id,
            contactId : event.detail.editedTenantRecord.contactId 
        };

        const evt = new CustomEvent('tenant_changed', {
            detail: {
                editedTenantRecord: eventTenantRecord,
            }
        });
        this.dispatchEvent(evt);
    }


}