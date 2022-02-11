import {LightningElement, api, track} from 'lwc';
import FcLabelsService from 'c/fc_labelsService';

export default class FcClaimItem extends LightningElement {

    @api claimItem = {};
    @api allowEdit;
    @track landLordDocumentsColumns = {Filename__c:'Document Name',Location__c:'Download Link'};
    @track allowDeleteLandLordDocuments = false;
    @track tenantDocumentsColumns = {Filename__c:'Document Name',Location__c:'Download Link'};
    @track activeSections = ['A','B', 'C'];
    isInternal = false;

    get landLordAttachments(){
        return this.claimItem.attachments.filter(attachment => {
            return  (attachment.User_Type__c === 'Agent' || attachment.User_Type__c === 'Landlord')
        });
    };

    get tenantAttachments(){
        return this.claimItem.attachments.filter(attachment => {
            return  attachment.User_Type__c === 'Tenant'
        });
    };

    @track labels = new FcLabelsService().getLabels();

    connectedCallback(){
        this.labels.tenant_section_statement = this.labels.tenant_section_statement.replace('%s', this.claimItem.disputeItemType.toLowerCase());
        this.labels.edit_response_modal_tenant_statement_label = this.labels.edit_response_modal_tenant_statement_label.replace('%s', this.claimItem.disputeItemType.toLowerCase());
    };


    editTenantResponse = () => {
        const modals = this.template.querySelectorAll('c-fc_modal');
        let modal = [...modals].find(modal => {
            return modal.name === 'edit-tenant-response-modal'
        });
        modal.show();
    };

    uploadAttachments = () => {
        const modals = this.template.querySelectorAll('c-fc_modal');
        let modal = [...modals].find(modal => {
            return modal.name === 'upload-evidence-modal'
        });
        modal.show();
    };

    handleEvndenceModalClosed = (event) => {
        const modals = this.template.querySelectorAll('c-fc_modal');
        let modal = [...modals].find(modal => {
            return modal.name === 'upload-evidence-modal'
        });
        modal.hide();
    };


    tenantResponseModified = () => {
        let tenantResponse = this.template.querySelector('lightning-textarea');
        const event = new CustomEvent('tenant_response_modified', {
            detail: {
                claimItemId: this.claimItem.id,
                tenantResponse: tenantResponse.value
            }
        });
        this.dispatchEvent(event);
        const modals = this.template.querySelectorAll('c-fc_modal');
        let modal = [...modals].find(modal => {
            return modal.name === 'edit-tenant-response-modal'
        });
        modal.hide();
    };

    handleEvidenceAttachmentDeleted = (event) => {
        const nEvent = new CustomEvent('evidence_attachment_deleted', {
            detail: {
                claimItemId: this.claimItem.id,
                attachmentId : event.detail.Id
            }
        });
        this.dispatchEvent(nEvent);
    }
}