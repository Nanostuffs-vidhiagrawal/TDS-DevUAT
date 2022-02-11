import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getReportFile from '@salesforce/apex/FC_GetSpringCMReportController.getReport';

//import labels
import downloadingFile from '@salesforce/label/c.Downloading_File';
import downloadingFileStartsShortly from '@salesforce/label/c.File_Download_Starts_Shortly';
import downloadingFileError from '@salesforce/label/c.Downloading_File_Error';

export default class fc_GetSpringCMReportLWC extends NavigationMixin(LightningElement) {
    @api recordId
    @track showError = false
    
    label = {
        downloadingFile,
        downloadingFileStartsShortly,
        downloadingFileError
    }; 
        
    connectedCallback() {
        getReportFile({
            recordId: this.recordId,
        })
        .then((documentResponse) => {      
            if(!documentResponse.fileName) {
                this.showError = true;
                return;
            }                  
            //convert base64encoded blob to blob
            const byteCharacters = atob(documentResponse.encodedDocumentBlob);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);
            
            var filename = documentResponse.fileName;
            var file = new File([byteArray], filename, {type: documentResponse.contentType});  

            if (window.navigator.msSaveOrOpenBlob) { // IE10+
                window.navigator.msSaveOrOpenBlob(file, filename);
            } else { // Others
                var a = document.createElement("a"),
                    url = URL.createObjectURL(file);
                a.href = url;
                a.download = filename;
                document.body.appendChild(a);
                a.click();
                setTimeout(function () {
                    document.body.removeChild(a);
                    window.URL.revokeObjectURL(url);
                }, 0);
            }
        })
        .catch((error) => {
            this.showError = true;
        });
    }
}