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
                    helper.parsePredictions(cmp,evt,response.returnValue);
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
        visionFrame.getElement().contentWindow.postMessage(imageContent, '*');
    },

    getImagePredictionsFromVF: function(cmp, evt, result) {
        cmp.set('v.showSpinner', false);
        this.parsePredictions(cmp,evt,result.data)
    },

    parsePredictions: function(cmp, evt, predictionsString) {
        var predictions = JSON.parse(predictionsString);
        if (predictions.length) {
            for (var i = 0; i < predictions.length; i++) {
                var prediction = predictions[i];
                prediction.probabilityPerc = (prediction.probability * 100).toFixed(2) + '%';
            }
        }
        cmp.set('v.predictions', predictions);
    }
})