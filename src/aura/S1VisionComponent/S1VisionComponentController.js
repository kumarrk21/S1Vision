({
    doInit:function(cmp,evt,helper){
      cmp.set('v.predictions',[])
      if (window.addEventListener) {
          window.addEventListener("message", function(result){
            helper.getImagePredictionsFromVF(cmp,evt,result);
          }, false);
      } else {
          window.attachEvent("onmessage", function(result){
            helper.getImagePredictionsFromVF(cmp,evt,result);
          });
      }
      
    },


    predictImage: function(cmp, evt, helper) {
        var uploadImageContainer = cmp.find('uploadImage').getElement();
        uploadImageContainer.click();
    },

    uploadImage: function(cmp, evt, helper) {
        //$A.util.removeClass(cmp.find('_spinner'),"slds-hide");
        cmp.set('v.predictions',[])
        cmp.set('v.showSpinner', true);
        var file = evt.target.files[0];
        var reader = new FileReader();
        var blob = file.slice(0, file.size);
        reader.readAsBinaryString(blob);

        reader.onloadend = function(e) {
            if (e.target.readyState == FileReader.DONE) {
                var imageContent = btoa(e.target.result);
                var fileContent = 'data:' + file.type + ';base64,' + imageContent;
                var image = cmp.find('_image').getElement();
                image.src = fileContent;
                $A.util.removeClass(cmp.find('_imageContainer'), "slds-hide");
                helper.sendImagePredictionsToVF(cmp,evt,imageContent)
                //helper.getImagePredictions(cmp,evt,imageContent)
            }
        }
    }
})