({
  doInit: function (component, event, helper) {},
  showClear: function (component, event, helper) {
    document.getElementById("EnterButton10").style.display = "none";
    // console.log("Test @@ show clear");
    let IsEditMode = component.get("v.IsEditMode");
    if (IsEditMode) {
      document.getElementById("EnterButton10").style.display = "none";
    } else {
      document.getElementById("EnterButton10").style.display = "block";
    }

    document.getElementById("clearButton10").style.display = "block";
  },
  clearSearch: function (component, event, helper) {
    // console.log("Clear");
    var input = document.getElementById("searchBox10");
    input.value = "";
    document.getElementById("clearButton10").style.display = "none";
  },

  showError: function (component, event, helper, message) {
    var error = document.getElementById("errorMessage10");
    error.innerText = message;
    error.style.display = "block";

    setTimeout(function () {
      error.style.display = "none";
    }, 10000);
  },
  enterManually: function (component, event, helper) {
    // console.log("@@enterManually ");
    //   Ashish commented below two lines and add two new line
    // document.getElementById("manualAddress").style.display = "block";
    // document.getElementById("output").style.display = "none";
    document.getElementById("EnterButton10").style.display = "none";
    document.getElementById("result10").style.display = "none";
  },
  enterSearch: function (component, event, helper) {
    // console.log("@@enter ");
    if (event.keyCode == 13) {
      // console.log("@@ enter13");
      helper.findAddress(component, event, helper);
    }
  },
  findAddress1: function (component, event, helper) {
    //  Below  two Line added by Ashish
    document.getElementById("result10").style.display = "block";
    let IsEditMode = component.get("v.IsEditMode");
    if (IsEditMode) {
      document.getElementById("EnterButton10").style.display = "none";
    } else {
      document.getElementById("EnterButton10").style.display = "block";
    }
    helper.findAddress(component, event, helper);
  }
});