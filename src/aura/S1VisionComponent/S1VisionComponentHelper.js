({
    getImagePredictions: function(cmp, evt, imageContent) {
        var helper = this;
        var apexMethod = cmp.get('c.getCallVisionBase64LC');
        apexMethod.setParams({
            base64String: imageContent
        });
        apexMethod.setCallback(this, function(response) {
            //$A.util.addClass(cmp.find('_spinner'), "slds-hide");
            cmp.set('v.showSpinner', false);
            try {
                var state = response.getState();
                if (state == 'SUCCESS') {
                    helper.parsePredictions(cmp, evt, response.returnValue);
                } else if (state == 'ERROR') {
                    console.log("Error in calling Apex method: ", response, response.getError());
                }
            } catch (e) {
                console.log("Error in calling Apex method: ", e);
            }

        });
        $A.enqueueAction(apexMethod);
    },

    sendImagePredictionsToVF: function(cmp, evt, imageContent) {
        var visionFrame = cmp.find('_visionFrame');
        var imageData = {};
        imageData.imageContent = imageContent;
        imageData.jwtSub = cmp.get('v.jwtSub');
        imageData.certFileId = cmp.get('v.certFileId');
        visionFrame.getElement().contentWindow.postMessage(JSON.stringify(imageData), '*');
    },

    getImagePredictionsFromVF: function(cmp, evt, result) {
        var returnData = {};
        try {
            returnData = JSON.parse(result.data);
            if (returnData.message != undefined) {
                if (returnData.success) {
                    this.parsePredictions(cmp, evt, returnData.predictions)
                } else {
                    cmp.set('v.showError', true);
                    cmp.set('v.errorMessage', returnData.message);
                }
            }
        } catch (e) {
            cmp.set('v.showError', true);
            cmp.set('v.errorMessage', e);
        }


        try {
            returnData = JSON.parse(result.data);
            cmp.set('v.showSpinner', false);
        } catch (e) {

        }


    },

    parsePredictions: function(cmp, evt, predictions) {
        //var predictions = JSON.parse(predictionsString);
        if (predictions.length) {
            for (var i = 0; i < predictions.length; i++) {
                var prediction = predictions[i];
                prediction.probabilityPerc = (prediction.probability * 100).toFixed(2) + '%';
            }
        }
        cmp.set('v.predictions', predictions);
    }
})
