global class S1VisionHTTPMock  implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"access_token":"whatever"}');
        return response;
    }
}