import logError from '@salesforce/apex/FC_ErrorLogger.error';
import logWarning from '@salesforce/apex/FC_ErrorLogger.warn';
import logInfo from '@salesforce/apex/FC_ErrorLogger.info';
import logDebug from '@salesforce/apex/FC_ErrorLogger.debug';

export default class FcErrorLoggerService {
    error(message) {
        if(!message || message == {}) message = console.trace();
        logError({obj : message});
    };

    warn(message) {
        if(!message || message == {}) message = console.trace();
        logWarning({obj : message});
    };

    info(message) {
        if(!message || message == {}) message = console.trace();
        logInfo({obj : message});
    };

    debug(message) {
        if(!message || message == {}) message = console.trace();
        logDebug({obj : message});
    };
    
    error(message, includeConsoleLog) {
        if(!message || message == {}) message = console.trace();
        if(includeConsoleLog)
            console.error(message);
        logError({obj : message});
    };

    warn(message, includeConsoleLog) {
        if(!message || message == {}) message = console.trace();
        if(includeConsoleLog) 
            console.warn(message);
        logWarning({obj : message});
    };

    info(message, includeConsoleLog) {
        if(!message || message == {}) message = console.trace();
        if(includeConsoleLog) 
            console.log(message);
        logInfo({obj : message});
    };

    debug(message, includeConsoleLog) {
        if(!message || message == {}) message = console.trace();
        if(includeConsoleLog) 
            console.debug(message);
        logDebug({obj : message});
    };    
}

export { FcErrorLoggerService }