({
  CreateRecord: function (component, event, helper) {
    // alert("create records");
    var fileInput = component.find("file").getElement();
    var file = fileInput.files[0];
    //alert(file);
    if (file){
        component.set("v.showResult", true);
        //console.log("File");
        var reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = function (evt) {
            
            var csv = evt.target.result;
            console.log(' file.name => ' +  file.name);
            var filename =  file.name;
            helper.CSV2JSON(component, csv, filename);
            
        }
        reader.onerror = function (evt) {
            //console.log("error reading file");
        }
        component.set("v.showcard", true);
    }
  },

  handleShowErrorDetails : function(component, event, helper){
      component.set("v.showErrorDetails", true);
  },

})