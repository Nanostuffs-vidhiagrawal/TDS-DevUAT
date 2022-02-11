import {LightningElement, track, wire} from 'lwc';
import getCaseParticipant from '@salesforce/apex/FC_EvidenceUploadCommunityController.getCaseParticipant';
import logError from '@salesforce/apex/FC_EvidenceUploadCommunityController.logError';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import FcLabelsService from 'c/fc_labelsService';

export default class FcAuthentication extends LightningElement {

    @track email;
    @track accessCode;
    @track postCode;

    labels = new FcLabelsService().getLabels();


    handleSubmit = () => {
        let fieldValues = this.template.querySelectorAll('lightning-input');
        const allValid = [...fieldValues]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            fieldValues.forEach(input => {
                this[input.name] = input.value;
            });

            let parameterObject = {
                accessCode: this.accessCode,
                postCode: this.postCode,
                emailAddress: this.email
            };

            getCaseParticipant({dataWrapper: parameterObject})
                .then(result => {
                    if (result.isSuccess) {
                        const event = new CustomEvent('loginsuccesful', {
                            detail: {
                                caseId: result.caseId,
                                isLead: result.isLead,
                                editAllowed: result.editAllowed,
                                caseParticipantId: result.caseParticipantId,
                            }
                        });
                        this.dispatchEvent(event);
                    } else {
                        const evt = new ShowToastEvent({
                            title: this.labels.login_error_title,
                            message: this.labels.login_error,
                            mode: 'sticky',
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    logError({error: error});
                    const evt = new ShowToastEvent({
                        title: this.labels.unexpected_error_title,
                        message: this.labels.unexpected_error,
                        mode: 'sticky',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                });
        }
    }
}