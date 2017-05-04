@isTest(SeeAllData=true)
private class S1VisionTest {
	
	@isTest static void test_method_one() {
		S1VisionHTTPMock mock = new S1VisionHTTPMock();
		Test.setMock(HttpCalloutMock.class, mock);

		S1VisionComponentController.imageData imgData = new S1VisionComponentController.imageData();
		imgData.imageContent = '/9j/4AAQSkZJRgABAQEASABIAAD/2wCEAAUDBAQEAwUEBAQFBQUGBwwIBwcHBw8LC=';
		imgData.jwtSub = 'kumarrk21@gmail.com';
		imgData.certFileId = '0691a000001IgqTAAS';
		S1VisionComponentController s1v = new S1VisionComponentController();
		s1v.imageDataJSON = JSON.serialize(imgData);
		s1v.getCallVisionBase64VF();
		//S1VisionComponentController.getCallVisionBase64(fileData);
		//S1VisionComponentController.getCallVisionBase64LC(fileData);

	}
	
	
	
}