import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import FcErrorLoggerService from 'c/fc_ErrorLoggerService';
import FcLabelsService from 'c/fc_labelsService';

export default class FcEvidenceAttachmentTable extends LightningElement {
    labels = new FcLabelsService().getLabels();
    logger = new FcErrorLoggerService();
    selectedRow = {};

    @api evidenceList
    @api fieldSet
    @api allowDelete  

    get confirmDeleteLabel() {
        return this.labels.confirm_delete;
    }    
    
    get deleteLabel() {
        return this.labels.delete;
    }    
    
    get confirmDeleteTextLabel() {
        return this.labels.confirm_delete_text;
    }    
    
    get columns() {
        let columns = [];
        let fieldSet = {...this.fieldSet};
        let allowDelete = this.allowDelete;
        let labels = this.labels;

        Object.keys(fieldSet).map(function(key) {
            if(key.toLowerCase() == 'location__c') {
                columns.push(
                    {   type: 'url',
                        fieldName: key,
                        label: labels.download_link,
                        typeAttributes: { label : labels.view }
                    }
                );
            }
            else {
                columns.push({'fieldName' : key, 'label' : fieldSet[key]});
            }
        });
        if(allowDelete) {
            columns.push(
                {   type: 'button-icon',
                    typeAttributes: { iconName : "utility:delete", name : "delete_action" }
                }
            );
        }
        return columns;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        this.selectedRow = event.detail.row;
        switch (actionName) {
            case 'delete_action':
                this.showModal();                
                break;
            default:
        }
    }
    
    showModal() {
        const modal = this.template.querySelector('c-fc_modal');
        modal.show();
    }
    
    handleDelete() {
        this.dispatchEvent(new CustomEvent('evidencerowdeleted', { detail: this.selectedRow }));
        const modal = this.template.querySelector('c-fc_modal');
        modal.hide();
    }
    
}