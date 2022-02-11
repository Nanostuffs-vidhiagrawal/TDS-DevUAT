import {LightningElement, api, track} from 'lwc';

export default class FcClaimItemsDetails extends LightningElement {

    @api claimRecord;
    @api allowEdit;
    @api isMobile;

    tenantResponseModified = (event) => {
        console.log({...event});
        const nEvent = new CustomEvent('tenant_response_modified', {
            detail: {
                claimItemId: event.detail.claimItemId,
                tenantResponse: event.detail.tenantResponse
            }
        });
        this.dispatchEvent(nEvent);
    }

    handleEvidenceAttachmentDeleted = (event) => {
        console.log(event.detail);
        const nEvent = new CustomEvent('evidence_attachment_deleted', {
            detail: {
                claimItemId: event.detail.claimItemId,
                attachmentId : event.detail.attachmentId
            }
        });
        this.dispatchEvent(nEvent);
    }

    get getTabsetVariant(){
        return (this.isMobile ? 'scoped' : 'vertical');
    };
}