# Apex Http
Library simplifying handling of http related stuff in Salesforce Apex. 

Latest version: 0.1.0

## Features
- single, standalone class
- one-liner methods for making callouts
- conditional callout mocks
- HttpResponse and HttpRequest builders

## Available methods
##### Making callouts
Fast and convenient method to make simple callout to external services which returns HttpResponse object.
```
HttpResponse response = ApexHttp.makeRequest('http://api.service.com'); // makes GET request

// All variants:
ApexHttp.makeRequest(new HttpRequest());
ApexHttp.makeRequest('http://api.service.com', ApexHttp.METHOD_DELETE);
ApexHttp.makeRequest('http://api.service.com', ApexHttp.METHOD_DELETE, HEADERS_MAP);
ApexHttp.makeRequest('http://api.service.com', ApexHttp.METHOD_POST, 'test body');
ApexHttp.makeRequest('http://api.service.com', ApexHttp.METHOD_POST, 'test body', HEADERS_MAP);
```

If you don't care about other response properties you can directly deserialize JSON to object.
Method returns null if response was not successful (status code was not 2XX)
```
SomeObject object = (SomeObject)ApexHttp.makeRequestAs(HttpRequest, SomeObject.class);
```

##### HttpRequest Builder
Allows to build HttpRequest object with given properties.
```
HttpRequest request = ApexHttp.request()
    .url('http://api.service.com')
    .method(ApexHttp.METHOD_GET)
    .build();

// All methods:
ApexHttp.request()
    .url('http://api.service.com')
    .method(ApexHttp.METHOD_GET)
    .contentType(ApexHttp.CONTENT_TYPE_JSON)
    .parameter('page', '1')
    .parameters(new Map<String, String> { 'page' => '1' })
    .header('Authorization', 'Bearer 123456')
    .headers(new Map<String, String> { 'Authorization' => 'Bearer 123456' })
    .body('Test')
    .bodyAsJson(new Object())
    .bodyAsJson(new Object(), true) // ignores nulls
    .bodyAsPrettyJson(new Object())
    .bodyAsPrettyJson(new Object(), true) // ignore nulls
    .bodyAsBlob('Test')
    .timeout(300)
    .certificate('RootCA')
    .oAuth()            // sets oAuth header to UserInfo.getSessionId()
    .oAuth('123456')    // sets oAuth header
    .compressed()
    .build();
```

##### Testing callouts
Library allows to easily mock http requests in tests.\
You need to create HttpMock or ConditionalHttpMock, then just set the mock in test.\
Both implements HttpCalloutMock and can be easily used in existing tests.
```
ApexHttp.HttpMock mock = ApexHttp.mock(200); // creates HttpResponse with statusCode 200 and empty body

// Test.startTest();
ApexHttp.setMock(mock); // equivalent to calling Test.setMock(HttpCalloutMock.class, mock);
// or
ApexHttp.setMock(new HttpResponse());
// Test.stopTest();

// All variants:
ApexHttp.mock(200, 'Mock response');
ApexHttp.mock(200, 'Mock response', HEADERS_MAP);
ApexHttp.mock('staticResourceResponse', 200);
```

##### HttpConditionalMock Builder
Allows to create ConditionalMock which returns different response for each request, based on given condition.\
Currently supported conditions are: request URL and request method.
```
ApexHttp.ConditionalHttpMock conditionalMock = ApexHttp.conditionalMock() // equivalent to: new ApexHttp.ConditionalHttpMockBuilder()
    // match by URL
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse(200, 'foo was ok!')
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo/bar').thenResponse(302, 'foo/bar was found!')
    // match by method
    .whenRequest(ApexHttp.METHOD, 'GET').thenResponse(200, 'You made GET request')
    .whenRequest(ApexHttp.METHOD, 'POST').thenResponse(200, 'You made POST request')
    // fallback
    .elseResponse(400, 'Bad request') // fallback response when none condition was met
    .build();


ApexHttp.setMock(mock); // equivalent to calling Test.setMock(HttpCalloutMock.class, mock);

// All methods:
ApexHttp.ConditionalHttpMock conditionalMock = ApexHttp.conditionalMock() // equivalent to: new ApexHttp.ConditionalHttpMockBuilder()
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse(200, 'OK response')
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse(200, 'OK response with headers', HEADERS_MAP)
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse('staticResourceResponse', 200)
    .whenRequest(ApexHttp.URL, 'http://test.service.com/foo').thenResponse(new HttpResponse())
    
    .elseResponse(400, 'Bad request') // fallback response when condition is not met
    .elseResponse(400, 'Bad request', HEADERS_MAP)
    .elseResponse('fallbackStaticResourceResponse', 400)
    .elseResponse(new HttpResponse())
    .build();
```

##### HttpResponse Builder
Allows to build HttpResponse object with given properties.
```
HttpResponse response = ApexHttp.response() // equivalent to: new ApexHttp.HttpRequestBuilder()
    .statusCode(200)
    .body('Test')
    .build();

ApexHttp.setMock(response); // mock in test

// All methods:
HttpResponse response = ApexHttp.response() // equivalent to: new ApexHttp.HttpRequestBuilder()
    .statusCode(200)
    .status('OK')
    .header('Authorization', 'Bearer 123456')
    .headers(new Map<String, String> { 'Authorization' => 'Bearer 123456' })
    .body('Test')
    .build();
```

## License

This project is licensed under the MIT License - see the LICENSE.md file for details