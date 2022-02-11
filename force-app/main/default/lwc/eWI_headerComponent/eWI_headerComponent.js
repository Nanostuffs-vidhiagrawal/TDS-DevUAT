import { LightningElement,api,wire,track} from 'lwc';

import TDSTheme from '@salesforce/resourceUrl/TDSTheme';
import Notification_icon from '@salesforce/resourceUrl/Notification_icon';
import sdsheaderfooter from '@salesforce/resourceUrl/sdsheaderfooter';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EWI_headerComponent extends LightningElement {
 LogoFiles = TDSTheme + '/assets/img/Logo_FIles.png';
SearchBgIcon = TDSTheme + '/assets/img/Search_Bg_icon.png'; 
NotificationIcon = Notification_icon + '/assets/img/notify-icon.png';
UserIcon = sdsheaderfooter + '/assets/img/User_Icon.png';
customCss = TDSTheme  + '/assets/css/custom.css';

renderedCallback() {

Promise.all([
    loadScript(this, TDSTheme+'/assets/js/plugin.min.js'),
    loadScript(this, TDSTheme+'/assets/js/jquery.dataTables.min.js'),
    loadScript(this, TDSTheme+'/assets/js/dataTables.responsive.js'),
    loadScript(this, TDSTheme+'/assets/js/datepicker.js'),
    loadScript(this, TDSTheme+'/assets/js/custom.js'),
    loadStyle(this, TDSTheme  + '/assets/css/custom.css'),
])
    .then(() => {
        alert('Files loaded.');
    })
    .catch(error => {
        alert(error.body.message);
    });
}

}