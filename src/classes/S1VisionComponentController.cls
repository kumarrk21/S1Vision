global class S1VisionComponentController {

    transient global String imageDataJSON {get;set;}
    transient global string returnDataString {get;set;}

    global S1VisionComponentController(){
        returnData ret = new returnData();
        ret.success = true;
        ret.message = '';
        returnDataString = JSON.serialize(ret);       
    }

    global void getCallVisionBase64VF(){
        returnData ret = new returnData();
        ret.success = false;
        ret.message = 'Error in getting predictions, check debug log';
         try{   
            ret.success = true;
            ret.predictions = getCallVisionBase64(imageDataJSON);
            ret.message = '';
          }catch(Exception ex){
            ret.message = 'Error: ' + ex.getMessage() + '. Stack trace: ' + ex.getStackTraceString();
          }
         returnDataString = JSON.serialize(ret);
    }


    private static String getAccessToken(String jwtSub, String certFileId) {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        //ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        ContentVersion base64Content = [SELECT ContentDocumentId, VersionData FROM ContentVersion where ContentDocumentId=:certFileId LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        S1VisionJWT jwt = new S1VisionJWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = jwtSub;
        jwt.aud = 'https://api.metamind.io/v1/oauth2/token';
        jwt.exp = '3600';
        String access_token = S1VisionJWTBearerFlow.getAccessToken('https://api.metamind.io/v1/oauth2/token', jwt);
        return access_token;    
    }

    @RemoteAction
    global static List<S1Vision.Prediction> getCallVisionBase64(String imageDataJSONString) {        
        imageData imgData = (imageData) JSON.deserialize(imageDataJSONString, S1VisionComponentController.imageData.class);
        String access_token = getAccessToken(imgData.jwtSub,imgData.certFileId);
        return S1Vision.predictBase64(imgData.imageContent,access_token,'GeneralImageClassifier');
    }

    

    @AuraEnabled
    global static List<S1Vision.Prediction> getCallVisionBase64LC(String base64String) {
    //global static String getCallVisionBase64LC(String base64String) {        
        return getCallVisionBase64(base64String);
    }
    

    private class returnData{
        Boolean success {get;set;}
        String message {get;set;}
        List<S1Vision.Prediction> predictions {get;set;}

    }

    public class imageData{
        public String jwtSub {get;set;}
        public String certFileId {get;set;}
        public String imageContent {get;set;}
    }
    
}