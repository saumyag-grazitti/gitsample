/**
 * Created by yanagerasimchuk on 4/16/18.
 */

global with sharing class as_CreateLicenseControllerMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HTTPResponse resp = new HTTPResponse();
        resp.setBody('get a license');
        resp.setStatus('SUCCESS');
        resp.setHeader('Content-Type', 'application/text');
        resp.setHeader('Content-Disposition', 'filename=test key file');
        resp.setStatusCode(200);
        return resp;
    }
}