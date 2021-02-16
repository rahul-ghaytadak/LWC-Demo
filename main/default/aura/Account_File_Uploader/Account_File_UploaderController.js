/***************************************************************************************************************************
* Name:        Account_File_UploaderController
* Description: Controller for Account_File_Uploader Component 
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-10-14       Aress Dev               	Selects the file and check whether it is csv file or not. 
****************************************************************************************************************************/

({
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var ext;
        component.set('v.showSpinner', true);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            ext = fileName.substring(fileName.length-3,fileName.length);
        }
        component.set("v.fileName", fileName);
        if(ext=='csv'){
            var fileInput = component.find("file").get("v.files");
            var file = fileInput[0];
            if (file) {
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    var csv = evt.target.result;
                    window.setTimeout($A.getCallback(function(){
                        helper.FetchData(component,csv);
                    }), 10);
                }
                reader.onerror = function (evt) {
                }
            }
        }
        else {
            component.set("v.errorMessage",'Kindly select a CSV file.');
            component.set('v.showSpinner', false);
        }
    },
    
})