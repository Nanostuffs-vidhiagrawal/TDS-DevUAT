/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Service module that uploads files via browser leveraging Azure Storage SDK in static resource
 * @when 31/1/2020
 */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import AzureBlobClient from '@salesforce/resourceUrl/AzureBlobClient';
import createAccessUrl from '@salesforce/apex/FC_AzureStorageService.createAccessUrl';

export default class FcAzureBlobBrowserFileUpload {

    // loads scripts - needs to be run from client component
    loadScripts(cmp){
        console.log('## module - loading scripts');
                    Promise.all([
                        loadScript(cmp, AzureBlobClient + '/azure-storage-blob.js')
                    ])
                    .then(() => {})
    }

    resourceUrl;

    // utility function that randomises a given name
    randomiseName(name) {
        let uuid = function() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }
        return uuid() + '_' + name;
    }

    // extract file type
    getFileType(fileName) {
            let splitFileName = fileName.split(".");
            return splitFileName.length > 1 ? splitFileName[splitFileName.length-1] : undefined;
    }

    // get Shared Access Signature from controller
    async getAccessUrl(scheme, isInternal, operation) {
        let url = createAccessUrl({schemeName: scheme, isInternal: isInternal, operation: operation });
        console.log(url);
        return url;
    };

    /**
    * Handles file upload via uploadBrowserDataToBlockBlob()
    * Returns uploadResult promise to be handled by client
    */
    async uploadFile(evidenceFile, scheme, isInternal) {
          // get SAS
          console.log('## module - fetching SAS token');
          // passing 'c' statically as create operation
          this.resourceUrl = await this.getAccessUrl(scheme, isInternal, 'c');
          const containerURL = new azblob.ContainerURL(
            this.resourceUrl,
            azblob.StorageURL.newPipeline(new azblob.AnonymousCredential)
          );
          const file = evidenceFile;
          let filename = file.input_name != null ? file.input_name + '.' + this.getFileType(file.name) : file.name;
          const blockBlobURL = azblob.BlockBlobURL.fromContainerURL(containerURL, this.randomiseName(filename));
          console.log('## module - uploading... ' + file.input_name);
          var uploadResult = azblob.uploadBrowserDataToBlockBlob(azblob.Aborter.none, file, blockBlobURL);
          return uploadResult;
    }
}

export { FcAzureBlobBrowserFileUpload }