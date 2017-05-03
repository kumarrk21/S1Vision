global class S1VisionComponentController {

    transient global String fileData {get;set;}
    global String predictionsResult {get;set;}

    global S1VisionComponentController(){

    }

    global void getCallVisionBase64VF(){
         System.debug('filedata is ' + fileData);
         predictionsResult = getCallVisionBase64(fileData);
         System.debug('predictions result is ' +  predictionsResult);
         //return getCallVisionBase64(fileData);
    }

    private static String getJWTSub(){
        String sub = '';
        List < S1Vision__mdt > keys = [SELECT JWTSub__c FROM S1Vision__mdt WHERE DeveloperName = 'Default'];
        if(keys.size()>0){
            sub = keys[0].JWTSub__c;
        }
        return sub;
    }

    private static String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        //jwt.sub = 'kumarrk21@gmail.com';
        jwt.sub = getJWTSub();
        jwt.aud = 'https://api.metamind.io/v1/oauth2/token';
        jwt.exp = '3600';
        String access_token = S1VisionJWTBearerFlow.getAccessToken('https://api.metamind.io/v1/oauth2/token', jwt);
        return access_token;    
    }

    @RemoteAction
    global static String getCallVisionBase64(String base64String) {        
        System.debug('Base64 is ' + base64String);
        String access_token = getAccessToken();
        System.debug('Access token is ' +  access_token);
        List<S1Vision.Prediction> predictions = S1Vision.predictBase64(base64String,access_token,'GeneralImageClassifier');
        String predictionsString =  JSON.serialize(predictions);
        System.debug('Predictions is ' + predictionsString);
        //return predictions;
        return predictionsString;
    }


    @AuraEnabled
    //public static List<S1Vision.Prediction> getCallVisionBase64(String base64String) {
    global static String getCallVisionBase64LC(String base64String) {        
        return getCallVisionBase64(base64String);
    }

    /*
    @AuraEnabled
    global static List<S1Vision.Prediction> getCallVisionUrl() {
        // Get a new token
        String access_token = getAccessToken();
        // Make a prediction using URL to a file
        List<S1Vision.Prediction> predictions =  S1Vision.predictUrl('http://metamind.io/images/generalimage.jpg',access_token,'GeneralImageClassifier');
        return predictions;
    }

    @AuraEnabled
    global static List<S1Vision.Prediction> getCallVisionContent() {
        // Get a new token
        String access_token = getAccessToken();

        // Make a prediction for an image stored in Salesforce
        // by passing the file as blob which is then converted to base64 string
        ContentVersion content = [SELECT Title,VersionData FROM ContentVersion where Id = '06841000000LkfCAAS' LIMIT 1];
        return S1Vision.predictBlob(content.VersionData, access_token, 'GeneralImageClassifier');
    }
    */
}