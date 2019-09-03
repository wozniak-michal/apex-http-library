/*
 * MIT License
 *
 * Copyright (c) 2019 Michał Woźniak @ purplishdev/apex-http-library
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
@IsTest
private class ApexHttpTest {
	
	private static final String EMPTY_STRING = '';
	private static final String TEST_URL = 'http://rest.test.com';
	private static final String TEST_QUERY = 'page=1&size=10&token=8fh36c1chd71';
	private static final String TEST_URL_WITH_QUERY = TEST_URL + '?' + TEST_QUERY;
	private static final Map<String, String> TEST_HEADERS = new Map<String, String> {
		'X-Auth-Token' => '123456',
		'X-Ref' => 'test',
		'X-Redirect' => 'true'
	};
	
	@IsTest
	static void testSetMock() {
		// given
		HttpResponse mockResponse = new HttpResponse();
		mockResponse.setStatusCode(200);
		mockResponse.setBody('TEST');
		
		// when
		Test.startTest();
		ApexHttp.setMock(mockResponse);
		HttpResponse response = ApexHttp.makeRequest(TEST_URL);
		Test.stopTest();
		
		// then
		System.assert(response.getStatusCode() == mockResponse.getStatusCode());
		System.assert(response.getBody() == mockResponse.getBody());
	}
	
	@IsTest
	static void testConditionalMockBuilder() {
		// given
		ApexHttp.ConditionalHttpMock mock = ApexHttp.conditionalMock()
			.whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse(200, 'OK request', TEST_HEADERS)
			.whenRequest(ApexHttp.URL, 'http://test.service.com/foo/bar').thenResponse(201, 'OK request 2', TEST_HEADERS)
			.whenRequest(ApexHttp.METHOD, ApexHttp.METHOD_POST).thenResponse(500, 'Internal server error')
			.elseResponse(400, 'Bad request')
			.build();
		
		// when
		Test.startTest();
		ApexHttp.setMock(mock);
		HttpResponse validResponse = ApexHttp.makeRequest('http://test.service.com/foo');
		HttpResponse validResponse2 = ApexHttp.makeRequest('http://test.service.com/foo/bar');
		HttpResponse validResponse3 = ApexHttp.makeRequest('http://test.service.com', ApexHttp.METHOD_POST);
		HttpResponse fallbackResponse = ApexHttp.makeRequest('http://test.service.com/test');
		Test.stopTest();
		
		// then
		System.assert(validResponse.getBody() == 'OK request');
		System.assert(validResponse.getStatusCode() == 200);
		
		System.assert(validResponse2.getBody() == 'OK request 2');
		System.assert(validResponse2.getStatusCode() == 201);
		
		System.assert(validResponse3.getBody() == 'Internal server error');
		System.assert(validResponse3.getStatusCode() == 500);
		
		System.assert(fallbackResponse.getBody() == 'Bad request');
		System.assert(fallbackResponse.getStatusCode() == 400);
	}
	
	@IsTest
	static void testMakeRequest() {
		// given
		ApexHttp.HttpMock mock = ApexHttp.mock(200);
		
		// when
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
		HttpResponse response = ApexHttp.makeRequest(TEST_URL, ApexHttp.METHOD_GET, TEST_HEADERS);
		Test.stopTest();
		
		// then
		HttpResponse mockResponse = mock.getResponse();
		System.assert(response.getStatusCode() == mockResponse.getStatusCode());
		System.assert(response.getBody() == mockResponse.getBody());
	}
	
	@IsTest
	static void testMakeRequestAs() {
		// given
		TestWrapper wrapper = new TestWrapper();
		String json = JSON.serialize(wrapper);
		ApexHttp.HttpMock successMock = ApexHttp.mock(200, json);
		ApexHttp.HttpMock errorMock = ApexHttp.mock(400, '');
		
		HttpRequest request = ApexHttp.request()
			.url(TEST_URL)
			.method(ApexHttp.METHOD_GET)
			.bodyAsJson(wrapper)
			.build();
		
		// when
		Test.startTest();
		ApexHttp.setMock(successMock);
		Object successResponse = ApexHttp.makeRequestAs(request, TestWrapper.class);
		
		ApexHttp.setMock(errorMock);
		Object errorResponse = ApexHttp.makeRequestAs(request, TestWrapper.class);
		Test.stopTest();
		
		// then
		System.assert(successResponse instanceof TestWrapper);
		TestWrapper responseWrapper = (TestWrapper) successResponse;
		System.assert(responseWrapper.testField == wrapper.testField);
		System.assert(responseWrapper.emptyField == wrapper.emptyField);
		
		System.assert(errorResponse == null);
	}
	
	@IsTest
	static void testRequestBuilder() {
		// given
		Map<String, String> queryParameters = new PageReference(TEST_URL_WITH_QUERY).getParameters();

		// when
		HttpRequest request = ApexHttp.request()
			.url(TEST_URL)
			.method(ApexHttp.METHOD_POST)
			.parameters(queryParameters)
			.headers(TEST_HEADERS)
			.body('TEST')
			.timeout(10)
			.compressed()
			.oAuth()
			.build();
		
		// then
		System.assert(request.getMethod() == ApexHttp.METHOD_POST);
		System.assert(request.getBody() == 'TEST');
		System.assert(request.getCompressed() == true);
		System.assert(request.getHeader(ApexHttp.HEADER_AUTHORIZATION) == ApexHttp.HEADER_AUTHORIZATION_OAUTH + UserInfo.getSessionId());
		for (String header : TEST_HEADERS.keySet()) {
			System.assert(request.getHeader(header) == TEST_HEADERS.get(header));
		}
	}
	
	@IsTest
	static void testRequestBuilderJson() {
		// given
		TestWrapper wrapper = new TestWrapper();
		String json = JSON.serialize(wrapper);
		
		// when
		HttpRequest request = ApexHttp.request()
			.url(TEST_URL)
			.method(ApexHttp.METHOD_GET)
			.bodyAsJson(wrapper)
			.build();
		
		// then
		System.assert(request.getBody().equals(json));
		System.assert(request.getHeader(ApexHttp.HEADER_CONTENT_TYPE) == ApexHttp.HEADER_CONTENT_TYPE_JSON);
	}
	
	@IsTest
	static void testRequestBuilderPrettyJson() {
		// given
		TestWrapper wrapper = new TestWrapper();
		String json = JSON.serializePretty(wrapper);
		
		// when
		HttpRequest request = ApexHttp.request()
			.url(TEST_URL)
			.method(ApexHttp.METHOD_GET)
			.bodyAsPrettyJson(wrapper)
			.build();
		
		// then
		System.assert(request.getBody().equals(json));
		System.assert(request.getHeader(ApexHttp.HEADER_CONTENT_TYPE) == ApexHttp.HEADER_CONTENT_TYPE_JSON);
	}
	
	@IsTest
	static void testRequestBuilderBlob() {
		// given
		String json = JSON.serialize(new TestWrapper());
		
		// when
		HttpRequest request = ApexHttp.request()
			.url(TEST_URL)
			.method(ApexHttp.METHOD_GET)
			.bodyAsBlob(json)
			.build();
		
		// then
		System.assert(request.getBody() == json);
		System.assert(request.getHeader(ApexHttp.HEADER_CONTENT_TYPE) == ApexHttp.HEADER_CONTENT_TYPE_STREAM);
	}
	
	@IsTest
	static void testResponseBuilder() {
		// when
		HttpResponse response = ApexHttp.response()
			.statusCode(200)
			.status('OK')
			.headers(TEST_HEADERS)
			.body('TEST')
			.build();
		
		// then
		System.assert(response.getStatusCode() == 200);
		System.assert(response.getStatus() == 'OK');
		System.assert(response.getBody() == 'TEST');
		for (String header : TEST_HEADERS.keySet()) {
			System.assert(response.getHeader(header) == TEST_HEADERS.get(header));
		}
	}
	
	@IsTest
	static void testQuery() {
		// given
		Map<String, String> queryParameters = new PageReference(TEST_URL_WITH_QUERY).getParameters();
		
		// when
		ApexHttp.Query emptyQuery = ApexHttp.query();
		ApexHttp.Query queryFromParameters = ApexHttp.query(queryParameters);
		ApexHttp.Query queryFromUrl = ApexHttp.query(TEST_URL_WITH_QUERY);
		ApexHttp.Query filledQuery = ApexHttp.query();
		filledQuery.setParameters(queryParameters);
		
		// then
		testSingleQuery(emptyQuery, new Map<String, String>(), EMPTY_STRING);
		testSingleQuery(queryFromParameters, queryParameters, TEST_QUERY);
		testSingleQuery(queryFromUrl, queryParameters, TEST_QUERY);
		testSingleQuery(filledQuery, queryParameters, TEST_QUERY);
	}
	
	static void testSingleQuery(ApexHttp.Query query, Map<String, String> parameters, String urlQuery) {
		System.assert(parameters.isEmpty() ? query.isEmpty() : !query.isEmpty());
		System.assert(query.getParameters() != null);
		System.assert(query.getParametersCount() == parameters.size());
		for (String param : parameters.keySet()) {
			System.assert(query.getParameter(param) == parameters.get(param));
		}
		System.assert(query.getQuery() == urlQuery);
	}
	
	@IsTest
	static void testGetQueryParameter() {
		// given
		String validUrl = 'http://some.service.com?page=1&size=50';
		String invalidUrl = 'service?page=1&size=50';
		String validQuery = 'page=1&size=50';
		String validQuery2 = '?page=1&size=50';
		
		// when
		String validUrlParam = ApexHttp.query(validUrl).getParameter('page');
		String validUrlInvalidParam = ApexHttp.query(validUrl).getParameter('offset');
		
		String invalidUrlParam = ApexHttp.query(invalidUrl).getParameter('page');
		String invalidUrlInvalidParam = ApexHttp.query(invalidUrl).getParameter('offset');
		
		String validQueryParam = ApexHttp.query(validQuery).getParameter('page');
		String validQueryInvalidParam = ApexHttp.query(validQuery).getParameter('offset');
		
		String validQuery2Param = ApexHttp.query(validQuery2).getParameter('page');
		String validQuery2InvalidParam = ApexHttp.query(validQuery2).getParameter('offset');
		
		// then
		System.assert(validUrlParam == '1');
		System.assert(validUrlInvalidParam == null);
		
		System.assert(invalidUrlParam == '1');
		System.assert(invalidUrlInvalidParam == null);
		
		System.assert(validQueryParam == '1');
		System.assert(validQueryInvalidParam == null);
		
		System.assert(validQuery2Param == '1');
		System.assert(validQuery2InvalidParam == null);
	}
	
	@IsTest
	static void shouldMockFail_WhenNonExistingStaticResource() {
		try {
			ApexHttp.mock('someStaticResourceWhichObviouslyDoesNotExists', 200);
		} catch (Exception e) {
			System.assert(true);
		}
	}
	
	@IsTest
	static void shouldRequestBuilderFail_WhenNonExistingCertificate() {
		try {
			ApexHttp.request()
				.url(TEST_URL)
				.method(ApexHttp.METHOD_GET)
				.parameter('foo', 'bar')
				.certificate('someCertificateWhichObviouslyDoesNotExists')
				.build();
		} catch (Exception e) {
			System.assert(true);
		}
	}
	
	@IsTest
	static void shouldRequestBuilderFail_WhenInvalidUrl() {
		try {
			ApexHttp.request()
				.url('invalid_url')
				.method(ApexHttp.METHOD_GET)
				.build();
		} catch (ApexHttp.IllegalUsageException e) {
			System.assert(true);
		}
	}
	
	@IsTest
	static void shouldRequestBuilderFail_WhenInvalidMethod() {
		try {
			ApexHttp.request()
				.url(TEST_URL)
				.method('NOPE')
				.build();
		} catch (ApexHttp.IllegalUsageException e) {
			System.assert(true);
		}
	}
	
	
	@IsTest
	static void shouldConditionalHttpMockBuilderFail_WhenNonExistingStaticResourceInThenCondition() {
		try {
			ApexHttp.conditionalMock()
				.whenRequest(ApexHttp.URL, 'http://test.service.com/foo')
				.thenResponse('someStaticResourceWhichObviouslyDoesNotExists', 200)
				.elseResponse('someStaticResourceWhichObviouslyDoesNotExists', 400)
				.build();
		} catch (Exception e) {
			System.assert(true);
		}
	}
	
	
	@IsTest
	static void shouldConditionalHttpMockBuilderFail_WhenNonExistingStaticResourceInElseCondition() {
		try {
			ApexHttp.conditionalMock()
				.whenRequest(ApexHttp.URL, 'http://test.service.com/foo')
				.thenResponse(200, 'OK')
				.elseResponse('someStaticResourceWhichObviouslyDoesNotExists', 400)
				.build();
		} catch (Exception e) {
			System.assert(true);
		}
	}
	
	public class TestWrapper {
		public String testField = 'testValue';
		public String emptyField = null;
	}
}