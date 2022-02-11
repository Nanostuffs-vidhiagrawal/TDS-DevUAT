import { LightningElement, api } from 'lwc';
import FcLabelsService from 'c/fc_labelsService';

export default class FcEvidenceUploadModal extends LightningElement {
    labels = new FcLabelsService().getLabels();

    @api caseId
    @api disputeItemId
    @api userType
    @api buttonLabel
    @api isInternal = false
    
    renderedCallback() {
        if(this.isInternal) {
        this.showModal();
    }
    }
    
    get buttonLabelToShow() {
        return this.buttonLabel;
    }
    
    get addEvidenceLabel() {
        return this.labels.add_evidence;
    }
    
    get attachmentLabel() {
        return this.labels.attachment;
    }
    
    showModal() {
        const modal = this.template.querySelector('c-fc_modal');
        modal.show();
    }
    
    hideModal() {
        const modal = this.template.querySelector('c-fc_modal');
        modal.hide();
    }
        
}