import {LightningElement, api, track} from 'lwc';
import getContext from '@salesforce/apex/FC_EvidenceUploadCommunityController.getContext';
import isLeadTenant from '@salesforce/apex/FC_EvidenceUploadCommunityController.isLeadTenant';
import logError from '@salesforce/apex/FC_EvidenceUploadCommunityController.logError';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import FcLabelsService from 'c/fc_labelsService';
import updateTenantData from '@salesforce/apex/FC_EvidenceUploadCommunityController.updateTenantData';
import getEvidenceUploadBannerTexts from '@salesforce/apex/FC_EvidenceUploadCommunityController.getEvidenceUploadBannerTexts';
import updateTenantClaimStatement from '@salesforce/apex/FC_EvidenceUploadCommunityController.updateTenantClaimStatement';
import getEvidenceUploadLabels from '@salesforce/apex/FC_EvidenceUploadCommunityController.getEvidenceUploadCommunityLabels'
import deleteEvidenceAttachment from '@salesforce/apex/FC_EvidenceUploadCommunityController.deleteEvidenceAttachment';

export default class FcEvidenceUploadCommunity extends LightningElement {
    @api isMobile;

    @track isAuthenticated;
    @track caseId = undefined;
    @track caseParticipantId = undefined;
    @track isLead = false;
    @track editAllowed = false;
    @track caseRecord;
    @track bannerText = '';
    @track configurableLabels;

    @track stepNumber = 0;

    @track allowDeleteKeyDocuments = false;
    @track keyDocumentsColumns = {Filename__c:'Document Name',Location__c:'Download Link'};

    labels = new FcLabelsService().getLabels();
    bannerTexts;

    connectedCallback(){
        getEvidenceUploadLabels().then(labelsMap => {
           this.configurableLabels = labelsMap;
        });
        getEvidenceUploadBannerTexts().then(texts => {
            this.bannerTexts = texts;
        });

        this.isMobile = this.handleIsMobile();

    }

    handleIsMobile = () => {
        return  (/android|webos|iphone|ipad|ipod|blackBerry|iemobile|opera mini/i.test(navigator.userAgent.toLowerCase()) );
    };

    handleLoginSuccessful = (event) => {
        this.isAuthenticated = true;
        this.caseId = event.detail.caseId;
        this.isLead = event.detail.isLead;
        this.editAllowed = event.detail.editAllowed;
        this.caseParticipantId = event.detail.caseParticipantId;
        this.stepNumber = 1;

        this.executeGetContext();
    };

    executeGetContext = () => {
        let parameterObject = {
            caseId: this.caseId,
        };


        getContext({dataWrapper: parameterObject})
            .then(result => {
                this.caseRecord = result;

                let isLeadTenantParameters = {
                    caseId: this.caseId,
                    caseParticipantId: this.caseParticipantId
                };

                if (!this.isLead) {
                    isLeadTenant({dataWrapper: isLeadTenantParameters}).then(result => {
                        this.isLead = result;
                        this.setBannerText();
                    }).catch(error => {
                        this.unexpectedError(error);
                    })
                }else{
                    this.setBannerText();
                }
            })
            .catch(error => {
                this.unexpectedError(error);
            });
    };

    get canEdit(){
        return this.isLead && this.editAllowed;
    }

    get isStepNumber1(){
        return this.stepNumber === 1;

    };

    get isStepNumber2(){
        return this.stepNumber === 2;
    };

    nextStep = () => {
        this.stepNumber = 2;
        this.setBannerText();
    };

    prevStep = () => {
        this.stepNumber = 1;
        this.setBannerText();
    };

    setBannerText = () => {
        if(!this.editAllowed){
            this.bannerText = this.bannerTexts.status_no_evidence_gathering;
        }else if(this.stepNumber === 1){ //claim details
            if(this.isLead){
                if(this.caseRecord.evidenceGatheringTargetDate){
                    this.bannerText = this.bannerTexts.claim_details_lead_text_with_date.replace('%s', this.caseRecord.evidenceGatheringTargetDate);
                }else{
                    this.bannerText = this.bannerTexts.claim_details_lead_text_no_date;
                }
            }else{
                this.bannerText = this.bannerTexts.claim_details_non_lead_text;
            }

        }else if(this.stepNumber === 2){ //evidence upload
            if(this.isLead){
                this.bannerText = this.bannerTexts.evidence_upload_lead_text;
            }else{
                this.bannerText = this.bannerTexts.evidence_upload_non_lead_text;
            }
        }
    };

    handleTenantChanged = (event) => {

        let updateTenantDataParams = {
            name: event.detail.editedTenantRecord.name,
            email: event.detail.editedTenantRecord.email,
            phone: event.detail.editedTenantRecord.phone,
            id: event.detail.editedTenantRecord.id,
            contactId : event.detail.editedTenantRecord.contactId
        };


        updateTenantData({dataWrapper: updateTenantDataParams}).then((result) => {
            let toastDetails;
            if (result.isSuccess === true) {
                this.executeGetContext();
                toastDetails = {
                    title: this.labels.update_success,
                    message: this.labels.tenant_details_update_success,
                    variant: 'success',
                }
            } else {
                toastDetails = {
                    title: this.labels.update_error,
                    message: this.labels.tenant_details_update_error,
                    mode: 'sticky',
                    variant: 'error',
                }
            }
            const evt = new ShowToastEvent(toastDetails);
            this.dispatchEvent(evt);
        }).catch(error => {
            this.unexpectedError(error);
        });
    };

    tenantResponseModified = (event) => {
        let updateTenantClaimStatementParams = {
            id: event.detail.claimItemId,
            tenantStatement: event.detail.tenantResponse,
        };

        updateTenantClaimStatement({dataWrapper: updateTenantClaimStatementParams}).then((result) => {
            let toastDetails;
            if (result.isSuccess === true) {
                this.executeGetContext();
                toastDetails = {
                    title: this.labels.update_success,
                    message: this.labels.tenant_response_update_success,
                    variant: 'success',
                }
            } else {
                toastDetails = {
                    title: this.labels.update_error,
                    message: this.labels.tenant_response_update_error,
                    mode: 'sticky',
                    variant: 'error',
                }
            }
            const evt = new ShowToastEvent(toastDetails);
            this.dispatchEvent(evt);
        }).catch(error => {
            this.unexpectedError(error);
        });
    };

    unexpectedError = (error, stack) => {
        console.error(error);
        console.log(stack);
        logError({error: error});
        const evt = new ShowToastEvent({
            title: this.labels.unexpected_error_title,
            message: this.labels.unexpected_error,
            mode: 'sticky',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    };

    handleEvidenceCreated = (event) => {
        this.executeGetContext();
    };

    handleEvidenceAttachmentDeleted = (event) => {
        deleteEvidenceAttachment({attachmentId : event.detail.attachmentId}).then((result) => {
            let toastDetails;
            if (result.isSuccess === true) {
                this.executeGetContext();
                toastDetails = {
                    title: this.labels.success,
                    message: this.labels.attachment_deleted_success,
                    variant: 'success',
                }
            } else {
                toastDetails = {
                    title: this.labels.error,
                    message: this.labels.attachment_delete_error,
                    mode: 'sticky',
                    variant: 'error',
                }
            }
            const evt = new ShowToastEvent(toastDetails);
            this.dispatchEvent(evt);
        }).catch(error => {
            this.unexpectedError(error);
        });
    };

    finishEditingDispute = () => {
        const evt = new ShowToastEvent({
            title: this.labels.final_toast_title,
            message: this.configurableLabels.final_toast_text,
            mode: 'sticky',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    };

    errorCallback = (error, stack) => {
        this.unexpectedError(error, stack)
    };
}