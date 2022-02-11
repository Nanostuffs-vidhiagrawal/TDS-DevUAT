import { LightningElement, api } from 'lwc';

import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import clientResource from '@salesforce/resourceUrl/AzureBlobClient';

/**
 * Show an item
 */
export default class fileUploadPOC extends LightningElement {
    @api
    label = 'label';

    loadedCallback() {
      Promise.all([
        loadScript(this, clientResource + '/azure-storage-blob.min.js')
      ])
      .then(() => console.log('fuck you'));
    }
}