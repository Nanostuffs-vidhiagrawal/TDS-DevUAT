import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_CASENUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import EA_USERTYPE_FIELD from '@salesforce/schema/Evidence_Attachment__c.User_Type__c';
import NAME_FIELD from '@salesforce/schema/ContentDocument.Title';

import getDisputeItems from '@salesforce/apex/FC_EvidenceUploadController.getDisputeItems';
import getSchemeName from '@salesforce/apex/FC_EvidenceUploadController.getSchemeName';
import createEvidenceAttachments from '@salesforce/apex/FC_EvidenceUploadController.createEvidenceAttachments';
import getLimitsForScheme from '@salesforce/apex/FC_EvidenceUploadController.getLimitsForScheme';
import FcAzureBlobBrowserFileUpload from 'c/fc_AzureBlobBrowserFileUpload';
import FcErrorLoggerService from 'c/fc_ErrorLoggerService';
import FcLabelsService from 'c/fc_labelsService';

const casefields = [CASE_CASENUMBER_FIELD];
const columns = { file_name:'File Name', user_type:'User Type', file_type:'File Type' };
const logger = new FcErrorLoggerService();

export default class FlowFileUploadCmp extends LightningElement {
    labels = new FcLabelsService().getLabels();

    @api caseId
    @api disputeItemId
    @api isInternal = false
    @api set userType(value) {
        this.selectedUserType = value;
    }
    get userType() {
        return this.selectedUserType;
    }

    get columns() {
        if(this.isInternal) {
             columns.dispute_item = 'Dispute Item';
        }
        return columns;
    }
    @track selectedUserType
    @track fileName
    @track disputeItemLabel
    @track showLoadingSpinner
    @track currentFile
    @track files = []
    @track disputeItemsOptions
    @track userTypeOptions
    @track validationResult
    @track selectedRows = []
    @track allowedFileTypes = [".pdf",".doc",".docx",".txt",".rtf",".xps",".odt",".xls",
                                ".xlsx",".ods",".png",".jpeg",".jpg",".gif",".tiff",".tif",
                                ".bmp",".emf",".mpe",".mpg",".mov",".avi",".mp3",".mp4",
                                ".wmv",".wav",".csv",".eml",".msg"];
    
    @wire(getRecord, { recordId: '$caseId', fields: casefields })
    dispute;    
    
    @wire(getDisputeItems, { recordId: '$caseId'})
    disputeItems({ error, data }) {
        if (data) {
            this.disputeItemsOptions = []
            for(let i=0; i<data.length; i++)  {
                this.disputeItemsOptions = [ ...this.disputeItemsOptions, {value: data[i].Id , label: data[i].Type__c} ];                                  
            }                
        } else if (error) {
            logger.error(error);
        }
    }
    
    @wire(getSchemeName, { caseId: '$caseId' })
    schemeNameWired;
    
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: EA_USERTYPE_FIELD })
    wiredPicklistValues ({error, data}) {
        if (data) {
            this.userTypeOptions = data.values;
        } else if (error) {
            logger.error(error);
        }
    }
    
    get saveLabel() {
        return this.labels.save;
    }    
    
    get loadingLabel() {
        return this.labels.loading;
    }
    
    get fileSizeLabel() {
        return this.labels.max_file_size;
    }
    
    get securityLabel() {
        return this.labels.files_available_for_tds + ' ' + this.labels.files_security_info;
    }
    
    get supportedTypesLabel() {
        return this.labels.supported_file_types;
    }
        
    get disputeNumber() {
        return getFieldValue(this.dispute.data, CASE_CASENUMBER_FIELD);
    }    

    get schemeName() {
        return this.schemeNameWired.data;
    }

    @api get noFilesUploaded() {
        return this.files.length == 0
    }

    get isAddButtonDisabled() {        
        return !this.currentFile || !this.fileName || !this.selectedUserType
    }
    
    get fileAttachmentLabel() { 
        let fileName = this.currentFile ? this.currentFile.name : '';
        return 'Attachment ' + (fileName ? fileName : ''); 
    }

    handleUserTypeChange(event) {
        this.selectedUserType = event.target.value;
    }
    
    handleFileNameChange(event) {
        this.fileName = event.target.value;
    }
    
    handleDisputeItemChange(event) {
        this.disputeItemId = event.target.value;
        this.disputeItemLabel = this.disputeItemsOptions.filter(option => option.value == event.target.value)[0].label;        
    }

    handleUploadFinished(event) {
        if (event.target.files.length < 1) return
        //clear previous values    
        event.target.setCustomValidity("");
        this.currentFile = undefined;

        let currentFile = event.target.files[0];
        let filetype = this.getFileType(currentFile.name);
        
        if(currentFile.size > 20971520) {
            event.target.setCustomValidity(this.labels.file_size_limit_error);
        }
        else if(!this.allowedFileTypes.includes('.'+filetype)) {
            event.target.setCustomValidity('File type: ' + filetype + ' is not allowed.');
        }
        else {
            this.currentFile = currentFile;
        }
    }
    
    async addFile() {    
        await this.validateFileListSize(this.selectedUserType);
        if(!this.validationResult) {
            return;
        }
        
        this.currentFile.input_name = this.fileName;
           
        var fileItem = {
            file : this.currentFile,
            fileIndex : this.files.length + 1,
            file_name : this.fileName,
            user_type : this.selectedUserType,
            file_type : this.getFileType(this.currentFile.name),
            dispute_item : this.disputeItemLabel,
            dispute_id : this.caseId,
            file_size : this.currentFile.size,
            dispute_item_id : this.disputeItemId,
            source : 'Admin',
        };

        this.files = [...this.files, fileItem];  
        this.clearVariables();
    }
    
    getFileType(fileName) {
        let splitFileName = fileName.split(".");
        return splitFileName.length > 1 ? splitFileName[splitFileName.length-1] : undefined;
    }

    clearVariables() {
        this.fileName = undefined;
        if(this.isInternal) {
            this.selectedUserType = this.userType ? this.userType : undefined;
            this.disputeItemId = undefined;
            this.disputeItemLabel = undefined;
        }
        this.currentFile = undefined;
    }
       
    async validateFileListSize(userType) {
        let recId = this.disputeItemId ? this.disputeItemId : this.caseId;
        await getLimitsForScheme({schemeName : this.schemeName, recordId: recId})
        .then(result => {
            let typeFiles = this.files.filter(file => file.user_type == userType);
            if(this.disputeItemId) {
                typeFiles = typeFiles.filter(file => file.dispute_item_id == recId);
            }
            else {
                typeFiles = typeFiles.filter(file => file.dispute_id == recId);
            }
            let userTypeLimit = result[userType].userTypeLimit;
            let userTypeResult = result[userType].userTypeResult;

            if(typeFiles.length + userTypeResult >= userTypeLimit) {
                this.dispatchEvent(new ShowToastEvent({
                    title: this.labels.error,
                    message: this.labels.file_upload_limit_error,
                    messageData: [userTypeLimit + '', userType],
                    variant: "error",
                    mode: "sticky"
                }));          
                this.validationResult = false;               
            }
            else {
                this.validationResult = true;
            }
        })
        .catch(error => {                
            logger.error(error, true);
            this.validationResult = false;
        });
    }

    handleSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }
    
    deleteFiles() {
        for(let i=0; i< this.selectedRows.length; i++)  {
            this.files = this.files.filter(file => file.fileIndex != this.selectedRows[i].fileIndex);
        }
    }
    
    @api async handleSave(){
        this.showLoadingSpinner = true;
        // instantiate uploader module
        const blobUploader = new FcAzureBlobBrowserFileUpload();
        // load static resource scripts
        blobUploader.loadScripts(this);
        let errors = false;
        for(let i=0; i < this.files.length; i++){
            let file = this.files[i].file;
            // call upload function
            let res = await blobUploader.uploadFile(file, this.schemeName, this.isInternal)
            .then(result => {
                let url = result._response.request.url
                // bind url
                this.files[i].url = url;
            })
            .catch(error => {
                logger.error(error);
                this.showNotification(this.labels.error, this.labels.unexpected_error_common, "error");
                this.showLoadingSpinner = false;
                errors = true;
            });        
        }
        if(errors) {
            return;
        }
        createEvidenceAttachments({ files: this.files })
        .then(result => {
            this.showNotification(this.labels.success, this.labels.evidence_added_successfully, "success");
            this.sendCloseModalEvent();
            this.sendEvidenceCreatedEvent();
        })        
        .catch(error => {
            logger.error(error);
            this.showNotification(this.labels.error, this.labels.unexpected_error_common, "error");
        })
        .finally(() => this.showLoadingSpinner = false)
    }
    
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
    sendCloseModalEvent() {
        this.dispatchEvent(new CustomEvent('closemodal',{bubbles: this.isInternal, composed: true}));
    }
    
    sendEvidenceCreatedEvent() {
        this.dispatchEvent(new CustomEvent('evidencecreated',{
            bubbles: true, 
            composed: true,
            detail: {
                dispute_item_id: this.disputeItemId,
                dispute_id: this.caseId,
                user_type: this.selectedUserType,
            } 
        }));
    }
    
    handleDelete(event) {
        const row = event.detail;
        this.selectedRows = [row];
        this.deleteFiles();
    }
}