export default class FcLabelsService {

    getLabels = () => {
        return {
            login_error_title: 'Login Error',
            login_error: 'We don’t recognise your details. Please contact Zero Deposit.',
            unexpected_error_title: 'Unexpected Error',
            unexpected_error: 'There was an unexpected error. Please contact Zero Deposit',
            unexpected_error_common: 'Unexpected error occured. Please contact administrator.',
            email_validation: 'Please enter a valid email address',
            add_evidence: 'Add Evidence',
            save: 'Save',
            tenant_details_update_success: 'Tenant details updated.',
            tenant_details_update_error: 'There was an error while trying to update tenant details. Please contact Zero Deposit',
            update_error: 'Update Error',
            update_success: 'Update Success',
            loading: 'Loading...',
            evidence_added_successfully: 'Evidence added successfully.',
            success: 'Success',
            error: 'Error',
            confirm_delete: 'Confirm Delete',
            confirm_delete_text: 'Are you sure you want to delete this document?',
            delete: 'Delete',
            view: 'View',
            download_link: 'Download Link',
            landlord_section_title: 'Landlord\'s Evidence',
            landlord_section_claimed_by : 'Claimed by Landlord',
            landlord_section_statement: 'Landlord Statement',

            tenant_section_title: 'Your Response',
            tenant_section_edit_button: 'Edit',
            tenant_section_statement: 'Please respond to the landlord’s claim relating to %s, referring to specific evidence that supports your case. You can upload a maximum of 5 files.',

            evidence_section_title: 'Your Evidence',
            evidence_section_add_button: 'Upload',

            edit_response_modal_title : 'Edit Response',
            edit_response_modal_tenant_statement_label : 'Please respond to the landlord’s claim relating to %s, referring to specific evidence that supports your case.',

            tenant_response_update_success : 'Your response has been updated',
            tenant_response_update_error: 'There was an error while trying to update your response. Please contact Zero Deposit',
            max_file_size: 'There is a maximum file size of 20MB per file.',
            files_available_for_tds: 'Files are available for TDS to download.',
            files_security_info: 'We will not attempt to download files from links to other systems, as these can be altered '
                                    + ' after the event and the links may represent a security risk to TDS',
            supported_file_types: 'Supported file types:  Pdf, doc, docx, txt, rtf, xps, odt, xls, xlsx, ods, png, jpeg, '
                                    + 'jpg, gif, tiff, tif, bmp, emf, mpe, mpg, mov, avi, mp3, mp4, wmv, wav, csv, eml, msg',            
            file_upload_limit_error: 'There is a limit of {0} evidence files for {1} claim type. You can delete any file previously uploaded.',
            file_size_limit_error: 'You cannot upload files that exceed 20mb',
            attachment: 'Attachment',
            final_toast_title: 'Response Saved',
            attachment_deleted_success : 'Your attachment was successfully deleted.',
            attachment_delete_error : 'There was an error while trying to delete your attachment. Please contact Zero Deposit'

        }
    };

}