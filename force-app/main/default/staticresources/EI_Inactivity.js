var timeoutID;
 
        function setup() {
			window.addEventListener("mousemove", resetTimer, false);
            window.addEventListener("mousedown", resetTimer, false);
            window.addEventListener("keypress", resetTimer, false);
            window.addEventListener("DOMMouseScroll", resetTimer, false);
            window.addEventListener("mousewheel", resetTimer, false);
            window.addEventListener("touchmove", resetTimer, false);
            window.addEventListener("MSPointerMove", resetTimer, false);
         
            startTimer();
        }
        setup();
         
        function startTimer() {
            timeoutID = window.setTimeout(goInactive, 1200000);
        }
         
        function resetTimer(e) {
            window.clearTimeout(timeoutID);
         
            goActive();
        }
         
        function goInactive() {
            // do something
			var hostURL = window.location.href;
			if(hostURL.includes("agllhome")){
				
				window.location.href = "https://www.zerodeposit.com";
			}else{
				
				var redirectURL = window.location.origin+'/zd/login';
				window.location.href = redirectURL;
			}
            
            
        }
         
        function goActive() {
            // do something
            //alert('active')
            startTimer();
        }