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
/**
 * Library simplifying handling of Http related stuff in Salesforce Apex.
 *
 * @version 0.1.0
 */
public without sharing class ApexHttp {
	
	public static final String URL = 'URL';
	public static final String METHOD = 'METHOD';
	
	public static final String METHOD_GET = 'GET';
	public static final String METHOD_POST = 'POST';
	public static final String METHOD_PATCH = 'PATCH';
	public static final String METHOD_PUT = 'PUT';
	public static final String METHOD_DELETE = 'DELETE';
	public static final String METHOD_HEAD = 'HEAD';
	public static final String METHOD_TRACE = 'TRACE';
	public static final Set<String> METHODS = new Set<String> {
		METHOD_GET, METHOD_POST, METHOD_PATCH, METHOD_PUT, METHOD_DELETE, METHOD_HEAD, METHOD_TRACE };
	
	public static final String HEADER_AUTHORIZATION = 'Authorization';
	public static final String HEADER_AUTHORIZATION_OAUTH = 'OAuth ';
	
	public static final String HEADER_CONTENT_TYPE = 'Content-Type';
	public static final String HEADER_CONTENT_TYPE_JSON = 'application/json';
	public static final String HEADER_CONTENT_TYPE_STREAM = 'application/octet-stream';
	
	private static final String URL_QUERY_START = '?';
	private static final String URL_QUERY_PARAMETER_NEXT = '&';
	private static final String URL_QUERY_PARAMETER_NAME_VALUE_SEPARATOR = '=';
	
	private static final String EMPTY_STRING = '';
	private static final System.Http HTTP = new System.Http();
	private static final Map<String, String> EMPTY_MAP = new Map<String, String>();
	
	/**
	 * Makes synchronous HTTP Callout to given endpoint with GET method.
	 *
	 * @see makeRequest(String url, String method)
	 */
	public static HttpResponse makeRequest(String url) {
		return makeRequest(url, METHOD_GET);
	}
	
	/**
	 * Makes synchronous HTTP Callout to given endpoint with given method.
	 *
	 * @see makeRequest(String url, String method, String body)
	 */
	public static HttpResponse makeRequest(String url, String method) {
		return makeRequest(url, method, EMPTY_STRING);
	}
	
	/**
	 * Makes synchronous HTTP Callout to given endpoint with given method and body.
	 *
	 * @see makeRequest(String url, String method, String body, Map<String, String> headers)
	 */
	public static HttpResponse makeRequest(String url, String method, String body) {
		return makeRequest(url, method, body, EMPTY_MAP);
	}
	
	/**
	 * Makes synchronous HTTP Callout to given endpoint with given method and headers.
	 *
	 * @see makeRequest(String url, String method, String body, Map<String, String> headers)
	 */
	public static HttpResponse makeRequest(String url, String method, Map<String, String> headers) {
		return makeRequest(url, method, EMPTY_STRING, headers);
	}
	
	/**
	 * Makes synchronous HTTP Callout to given endpoint with given method, bod and headers.
	 *
	 * @see makeRequest(HttpRequest request)
	 */
	public static HttpResponse makeRequest(String url, String method, String body, Map<String, String> headers) {
		return makeRequest(
			new ApexHttp.HttpRequestBuilder()
				.url(url)
				.method(method)
				.body(body)
				.headers(headers)
				.build()
		);
	}
	
	/**
	 * Makes synchronous HTTP Callout with given HttpRequest.
	 *
	 * @return HttpResponse of the callout.
	 */
	public static HttpResponse makeRequest(HttpRequest request) {
		return HTTP.send(request);
	}
	
	/**
	 * Makes synchronous HTTP Callout with given HttpRequest and deserializes response as json into given type.
	 *
	 * @return deserialized object of given type, null if request was not successful.
	 */
	public static Object makeRequestAs(HttpRequest request, Type clazz) {
		HttpResponse response = HTTP.send(request);
		if (response != null && response.getStatusCode() >= 200 && response.getStatusCode() <= 299) {
			return JSON.deserialize(response.getBody(), clazz);
		} else {
			return null;
		}
	}
	
	/**
	 * Creates new ApexHttp.HttpRequestBuilder instance. Shorthand method for new ApexHttp.HttpRequestBuilder().
	 *
	 * @return new instance of ApexHttp.HttpRequestBuilder.
	 */
	public static ApexHttp.HttpRequestBuilderUrl request() {
		return new ApexHttp.HttpRequestBuilder();
	}
	
	/**
	 * Creates new ApexHttp.HttpResponseBuilder instance. Shorthand method for new ApexHttp.HttpResponseBuilder().
	 *
	 * @return new instance of ApexHttp.HttpResponseBuilder.
	 */
	public static ApexHttp.HttpResponseBuilder response() {
		return new ApexHttp.HttpResponseBuilder();
	}
	
	/**
	 * Creates new ApexHttp.HttpMock which returns HttpResponse with given status code.
	 *
	 * @see mock(Integer statusCode, String body)
	 */
	public static ApexHttp.HttpMock mock(Integer statusCode) {
		return mock(statusCode, EMPTY_STRING);
	}
	
	/**
	 * Creates new ApexHttp.HttpMock which returns HttpResponse with given status code and body.
	 *
	 * @see mock(Integer statusCode, String body, Map<String, String> headers)
	 */
	public static ApexHttp.HttpMock mock(Integer statusCode, String body) {
		return mock(statusCode, body, EMPTY_MAP);
	}
	
	/**
	 * Creates new ApexHttp.HttpMock which returns HttpResponse with given status code, body and headers.
	 *
	 * @return new instance of ApexHttp.HttpMock with created HttpResponse.
	 */
	public static ApexHttp.HttpMock mock(Integer statusCode, String body, Map<String, String> headers) {
		HttpResponse response = ApexHttp.response()
			.statusCode(statusCode)
			.body(body)
			.headers(headers)
			.build();
		return new ApexHttp.HttpMock(response);
	}
	
	/**
	 * Creates new ApexHttp.HttpMock which returns HttpResponse with given status code and static resource.
	 *
	 * @return new instance of ApexHttp.HttpMock with created HttpResponse.
	 */
	public static ApexHttp.HttpMock mock(String staticResource, Integer statusCode) {
		HttpResponse response = ApexHttp.response()
			.statusCode(statusCode)
			.staticResource(staticResource)
			.build();
		return new ApexHttp.HttpMock(response);
	}
	
	/**
	 * Creates new ApexHttp.ConditionalHttpMockBuilder instance. Shorthand method for new ApexHttp.ConditionalHttpMockBuilder().
	 *
	 * @return new instance of ApexHttp.ConditionalHttpMockBuilder.
	 */
	public static ApexHttp.ConditionalHttpMockBuilderWhen conditionalMock() {
		return new ApexHttp.ConditionalHttpMockBuilder();
	}
	
	/**
	 * Creates new ApexHttp.Query instance without parameters. Shorthand method for new ApexHttp.Query().
	 *
	 * @return new instance of ApexHttp.Query.
	 */
	public static ApexHttp.Query query() {
		return new ApexHttp.Query();
	}
	
	/**
	 * Creates new ApexHttp.Query instance with given parameters. Shorthand method for new ApexHttp.Query(Map<String, String> parameters).
	 *
	 * @return new instance of ApexHttp.Query
	 */
	public static ApexHttp.Query query(Map<String, String> parameters) {
		return new ApexHttp.Query(parameters);
	}
	
	/**
	 * Creates new ApexHttp.Query instance with parameters extracted from given string. Shorthand method for new ApexHttp.Query(String str).
	 *
	 * @return new instance of ApexHttp.Query
	 */
	public static ApexHttp.Query query(String str) {
		return new ApexHttp.Query(str);
	}
	
	/**
	 * Creates new ApexHttp.HttpMock with given HttpResponse and sets the mock.
	 *
	 * @see setMock(HttpCalloutMock mock)
	 */
	public static void setMock(HttpResponse response) {
		setMock(new ApexHttp.HttpMock(response));
	}
	
	/**
	 * Sets test mock with given HttpCalloutMock.
	 */
	public static void setMock(HttpCalloutMock mock) {
		Test.setMock(HttpCalloutMock.class, mock);
	}
	
	/**
	 * Class responsible for handling query part of the url.
	 */
	public virtual class Query {
		
		private final Map<String, String> parameters;
		
		/**
		 * Creates new Query instance without parameters.
		 */
		public Query() {
			this.parameters = new Map<String, String>();
		}
		
		/**
		 * Creates new Query instance with given parameters.
		 */
		public Query(Map<String, String> parameters) {
			this.parameters = new Map<String, String>(parameters);
		}
		
		/**
		 * Creates new Query instance with parameters extracted from given string.
		 */
		public Query(String str) {
			this.parameters = parseQueryParameters(str);
		}
		
		/**
		 * Returns actual parameters count associated with query.
		 *
		 * @return parameters count in query
		 */
		public virtual Integer getParametersCount() {
			return parameters.size();
		}
		
		/**
		 * Returns actual parameters count associated with query.
		 *
		 * @return true if query has no parameters, false otherwise
		 */
		public virtual Boolean isEmpty() {
			return parameters.isEmpty();
		}
		
		/**
		 * Sets parameter with given name and value in query. Does nothing if name or value must is blank (null or empty).
		 */
		public virtual void setParameter(String name, String value) {
			if (String.isNotBlank(name) && String.isNotBlank(value)) {
				parameters.put(name, value);
			}
		}
		
		/**
		 * Sets given parameters in query.
		 */
		public virtual void setParameters(Map<String, String> parameters) {
			if (parameters != null) {
				for (String parameter : parameters.keySet()) {
					setParameter(parameter, parameters.get(parameter));
				}
			}
		}
		
		/**
		 * Gets value of given parameter name from query.
		 *
		 * @return value associated with given parameter name
		 */
		public virtual String getParameter(String parameter) {
			return parameters.get(parameter);
		}
		
		/**
		 * Returns copy of query parameters.
		 *
		 * @return copy of query parameters
		 */
		public virtual Map<String, String> getParameters() {
			return new Map<String, String>(parameters);
		}
		
		/**
		 * Creates query string from the query.
		 *
		 * @return query string without leading '?'
		 */
		public virtual String getQuery() {
			if (parameters == null) {
				return EMPTY_STRING;
			}
			if (parameters.isEmpty()) {
				return EMPTY_STRING;
			}
			String query = '';
			for (String parameter : parameters.keySet()) {
				query += parameter + URL_QUERY_PARAMETER_NAME_VALUE_SEPARATOR +
					parameters.get(parameter) + URL_QUERY_PARAMETER_NEXT;
			}
			return query.removeEnd(URL_QUERY_PARAMETER_NEXT);
		}
		
		protected virtual Map<String, String> parseQueryParameters(String str) {
			if (str == null) {
				throw new IllegalUsageException('ApexHttp.Query: string must not be null!');
			}
			if (String.isBlank(str)) {
				return new Map<String, String>();
			}
			String strQuery = str.substringAfter(ApexHttp.URL_QUERY_START);
			str = 'http://url.com?' + (String.isNotBlank(strQuery) ? strQuery : str);
			PageReference ref = new PageReference(str);
			return ref.getParameters();
		}
	}
	
	public interface HttpRequestBuilderUrl {
		ApexHttp.HttpRequestBuilderMethod url(String url);
	}
	
	public interface HttpRequestBuilderMethod {
		ApexHttp.HttpRequestBuilderElse method(String method);
	}
	
	public interface HttpRequestBuilderElse {
		/**
		 * Sets request's Content-Type header with given value.
		 */
		ApexHttp.HttpRequestBuilderElse contentType(String contentType);
		
		/**
		 * Sets request's header with given value.
		 */
		ApexHttp.HttpRequestBuilderElse header(String name, String value);
		
		/**
		 * Sets request's headers with given values.
		 */
		ApexHttp.HttpRequestBuilderElse headers(Map<String, String> headers);
		
		/**
		 * Sets request's url query parameter with given value.
		 */
		ApexHttp.HttpRequestBuilderElse parameter(String key, String value);
		
		/**
		 * Sets request's url query parameters with given value.
		 */
		ApexHttp.HttpRequestBuilderElse parameters(Map<String, String> parameters);
		
		/**
		 * Sets request's body.
		 */
		ApexHttp.HttpRequestBuilderElse body(String body);
		
		/**
		 * Sets request's body as json string with preserved nulls.
		 * Automatically sets Content-Type to 'application/json'.
		 */
		ApexHttp.HttpRequestBuilderElse bodyAsJson(Object obj);
		
		/**
		 * Sets request's body as json string.
		 * Automatically sets Content-Type to 'application/json'.
		 */
		ApexHttp.HttpRequestBuilderElse bodyAsJson(Object obj, Boolean suppressNulls);
		
		/**
		 * Sets request's body as prettied json string with preserved nulls.
		 * Automatically sets Content-Type to 'application/json'.
		 */
		ApexHttp.HttpRequestBuilderElse bodyAsPrettyJson(Object obj);
		
		/**
		 * Sets request's body as prettied json string.
		 * Automatically sets Content-Type to 'application/json'.
		 */
		ApexHttp.HttpRequestBuilderElse bodyAsPrettyJson(Object obj, Boolean suppressNulls);
		
		/**
		 * Sets request's body as blob.
		 * Automatically sets Content-Type to 'application/octet-stream'.
		 */
		ApexHttp.HttpRequestBuilderElse bodyAsBlob(String body);
		
		/**
		 * Sets request's timeout.
		 */
		ApexHttp.HttpRequestBuilderElse timeout(Integer timeout);
		
		/**
		 * Sets request's oAuth header to current user session id.
		 * Equivalent of calling header('Authorization', 'OAuth ' + UserInfo.getSessionId());
		 */
		ApexHttp.HttpRequestBuilderElse oAuth();
		
		/**
		 * Sets request's oAuth header.
		 * Equivalent of calling header('Authorization', 'OAuth ' + name);
		 */
		ApexHttp.HttpRequestBuilderElse oAuth(String name);
		
		/**
		 * Sets request's certificate.
		 */
		ApexHttp.HttpRequestBuilderElse certificate(String name);
		
		/**
		 * Sets request's as compressed.
		 */
		ApexHttp.HttpRequestBuilderElse compressed();
		
		/**
		 * Builds new HttpRequest instance.
		 */
		System.HttpRequest build();
	}
	
	/**
	 * HttpRequest Builder class
	 */
	public virtual class HttpRequestBuilder
		implements ApexHttp.HttpRequestBuilderUrl, ApexHttp.HttpRequestBuilderMethod, ApexHttp.HttpRequestBuilderElse {
		
		private final System.HttpRequest request;
		private final ApexHttp.Query query;
		private String url;
		
		public HttpRequestBuilder() {
			this.request = new HttpRequest();
			this.query = new ApexHttp.Query();
		}
		
		public virtual ApexHttp.HttpRequestBuilderMethod url(String url) {
			if (String.isNotBlank(url) && (url.startsWith('callout:') || url.startsWith('http://') || url.startsWith('https://'))) {
				this.url = url;
			} else {
				throw new IllegalUsageException('ApexHttp.HttpRequestBuilder: request url must be valid HTTP Url or Named Credential!');
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse method(String method) {
			if (ApexHttp.METHODS.contains(method)) {
				request.setMethod(method);
			} else {
				throw new IllegalUsageException('ApexHttp.HttpRequestBuilder: request method must be valid HTTP method!');
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse contentType(String contentType) {
			request.setHeader(HEADER_CONTENT_TYPE, contentType);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse header(String name, String value) {
			if (String.isNotBlank(name) && String.isNotBlank(value)) {
				request.setHeader(name, value);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse headers(Map<String, String> headers) {
			if (headers != null) {
				for (String header : headers.keySet()) {
					header(header, headers.get(header));
				}
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse parameter(String key, String value) {
			query.setParameter(key, value);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse parameters(Map<String, String> parameters) {
			query.setParameters(parameters);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse body(String body) {
			if (body != null) {
				request.setBody(body);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse bodyAsJson(Object obj) {
			return bodyAsJson(obj, false);
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse bodyAsJson(Object obj, Boolean suppressNulls) {
			body(JSON.serialize(obj, suppressNulls));
			contentType(HEADER_CONTENT_TYPE_JSON);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse bodyAsPrettyJson(Object obj) {
			return bodyAsPrettyJson(obj, false);
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse bodyAsPrettyJson(Object obj, Boolean suppressNulls) {
			body(JSON.serializePretty(obj, suppressNulls));
			contentType(HEADER_CONTENT_TYPE_JSON);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse bodyAsBlob(String body) {
			request.setBodyAsBlob(Blob.valueOf(body));
			contentType(HEADER_CONTENT_TYPE_STREAM);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse timeout(Integer timeout) {
			timeout = Math.max(1, Math.min(120000, timeout));
			request.setTimeout(timeout);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse certificate(String name) {
			if (String.isNotBlank(name)) {
				request.setClientCertificateName(name);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse oAuth() {
			return oAuth(UserInfo.getSessionId());
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse oAuth(String name) {
			header(HEADER_AUTHORIZATION, HEADER_AUTHORIZATION_OAUTH + name);
			return this;
		}
		
		public virtual ApexHttp.HttpRequestBuilderElse compressed() {
			request.setCompressed(true);
			return this;
		}
		
		public virtual System.HttpRequest build() {
			request.setEndpoint(buildUrl(url, query));
			return request;
		}
		
		protected virtual String buildUrl(String url, ApexHttp.Query query) {
			Boolean urlHasParameters = url.contains(URL_QUERY_START);
			String separator = urlHasParameters ? URL_QUERY_PARAMETER_NEXT : URL_QUERY_START;
			return query.isEmpty() ? url : (url + separator + query.getQuery());
		}
	}
	
	/**
	 * HttpResponse Builder class
	 */
	public virtual class HttpResponseBuilder {
		
		private final HttpResponse response;
		
		public HttpResponseBuilder() {
			this.response = new HttpResponse();
		}
		
		public virtual ApexHttp.HttpResponseBuilder statusCode(Integer statusCode) {
			response.setStatusCode(statusCode);
			return this;
		}
		
		public virtual ApexHttp.HttpResponseBuilder status(String status) {
			response.setStatus(status);
			return this;
		}
		
		public virtual ApexHttp.HttpResponseBuilder body(String body) {
			if (body != null) {
				response.setBody(body);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpResponseBuilder staticResource(String resource) {
			try {
				StaticResource staticResource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :resource LIMIT 1];
				body(staticResource.Body.toString());
				header(ApexHttp.HEADER_CONTENT_TYPE, staticResource.ContentType);
			} catch (Exception e) {
				throw new IllegalUsageException('ApexHttp.HttpResponseBuilder: static resource not found ' + resource);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpResponseBuilder header(String name, String value) {
			if (String.isNotBlank(name) && String.isNotBlank(value)) {
				response.setHeader(name, value);
			}
			return this;
		}
		
		public virtual ApexHttp.HttpResponseBuilder headers(Map<String, String> headers) {
			if (headers != null) {
				for (String header : headers.keySet()) {
					header(header, headers.get(header));
				}
			}
			return this;
		}
		
		public virtual HttpResponse build() {
			return response;
		}
	}
	
	/**
	* Http Mock handling class
	*/
	public virtual class HttpMock implements HttpCalloutMock {
		
		private HttpResponse response;
		
		public HttpMock(HttpResponse httpResponse) {
			response = httpResponse;
		}
		
		public virtual HttpResponse getResponse() {
			return response;
		}
		
		public virtual HttpResponse respond(HttpRequest request) {
			return response;
		}
	}
	
	/**
	* Http ConditionalMock handling class
	*/
	public virtual class ConditionalHttpMock implements HttpCalloutMock {
		
		private final Map<Condition, HttpResponse> conditions;
		private final List<Condition> orderedConditions;
		private final HttpResponse defaultResponse;
		
		public ConditionalHttpMock(List<Condition> orderedConditions, Map<Condition, HttpResponse> conditions, HttpResponse defaultResponse) {
			this.conditions = conditions;
			this.orderedConditions = orderedConditions;
			this.defaultResponse = defaultResponse;
		}
		
		public virtual HttpResponse respond(HttpRequest request) {
			for (Condition condition : orderedConditions) {
				if (condition.test(request)) {
					return conditions.get(condition);
				}
			}
			return defaultResponse;
		}
	}
	
	public interface ConditionalHttpMockBuilderWhen {
		/**
		 * Sets mock's condition which will be matched against HttpRequest.
		 */
		ApexHttp.ConditionalHttpMockBuilderThen whenRequest(String property, Object value);
	}
	
	public interface ConditionalHttpMockBuilderThen {
		/**
		 * Sets mock's response for previously defined condition.
		 */
		ApexHttp.ConditionalHttpMockBuilderElse thenResponse(HttpResponse response);
		
		/**
		 * Sets mock's response statusCode and body for previously defined condition.
		 */
		ApexHttp.ConditionalHttpMockBuilderElse thenResponse(Integer statusCode, String body);
		
		/**
		 * Sets mock's response statusCode, body and headers for previously defined condition.
		 */
		ApexHttp.ConditionalHttpMockBuilderElse thenResponse(Integer statusCode, String body, Map<String, String> headers);
		
		/**
		 * Sets mock's response static resource and statusCode for previously defined condition.
		 */
		ApexHttp.ConditionalHttpMockBuilderElse thenResponse(String staticResource, Integer statusCode);
	}
	
	public interface ConditionalHttpMockBuilderElse {
		/**
		 * Sets mock's condition which will be matched against HttpRequest.
		 */
		ApexHttp.ConditionalHttpMockBuilderThen whenRequest(String property, Object value);
		
		/**
		 * Sets mock's fallback response when none condition of ConditionalHttpMock is met.
		 */
		ApexHttp.ConditionalMockBuilderBuild elseResponse(HttpResponse response);
		
		/**
		 * Sets mock's fallback response statusCode and body when none condition of ConditionalHttpMock is met.
		 */
		ApexHttp.ConditionalMockBuilderBuild elseResponse(Integer statusCode, String body);
		
		/**
		 * Sets mock's fallback response statusCode, body and headers when none condition of ConditionalHttpMock is met.
		 */
		ApexHttp.ConditionalMockBuilderBuild elseResponse(Integer statusCode, String body, Map<String, String> headers);
		
		/**
		 * Sets mock's fallback response static resource and statusCode when none condition of ConditionalHttpMock is met.
		 */
		ApexHttp.ConditionalMockBuilderBuild elseResponse(String staticResource, Integer statusCode);
	}
	
	public interface ConditionalMockBuilderBuild {
		/**
		 * Builds new ApexHttp.ConditionalHttpMock instance.
		 */
		ApexHttp.ConditionalHttpMock build();
	}
	
	/**
	 * Http ConditionalMock Builder class
	 */
	public virtual class ConditionalHttpMockBuilder implements ApexHttp.ConditionalHttpMockBuilderWhen,
		ApexHttp.ConditionalHttpMockBuilderThen, ApexHttp.ConditionalHttpMockBuilderElse, ApexHttp.ConditionalMockBuilderBuild {
		
		private final List<ApexHttp.Condition> orderedConditions;
		private final Map<ApexHttp.Condition, HttpResponse> conditions;
		private ApexHttp.Condition condition;
		private HttpResponse defaultResponse;
		
		public ConditionalHttpMockBuilder() {
			this.orderedConditions = new List<ApexHttp.Condition>();
			this.conditions = new Map<ApexHttp.Condition, HttpResponse>();
		}
		
		public virtual ApexHttp.ConditionalHttpMockBuilderThen whenRequest(String property, Object value) {
			condition = new MockCondition(property, value);
			return this;
		}
		
		public virtual ApexHttp.ConditionalHttpMockBuilderElse thenResponse(Integer statusCode, String body) {
			return thenResponse(statusCode, body, EMPTY_MAP);
		}
		
		public virtual ApexHttp.ConditionalHttpMockBuilderElse thenResponse(Integer statusCode, String body, Map<String, String> headers) {
			thenResponse(buildResponse(statusCode, body, headers));
			return this;
		}
		
		public virtual ApexHttp.ConditionalHttpMockBuilderElse thenResponse(HttpResponse response) {
			appendCondition(condition, response);
			return this;
		}
		
		public virtual ApexHttp.ConditionalHttpMockBuilderElse thenResponse(String staticResource, Integer statusCode) {
			appendCondition(condition, buildStaticResourceResponse(staticResource, statusCode));
			return this;
		}
		
		public virtual ApexHttp.ConditionalMockBuilderBuild elseResponse(Integer statusCode, String body) {
			return elseResponse(statusCode, body, EMPTY_MAP);
		}
		
		public virtual ApexHttp.ConditionalMockBuilderBuild elseResponse(Integer statusCode, String body, Map<String, String> headers) {
			return elseResponse(buildResponse(statusCode, body, headers));
		}
		
		public virtual ApexHttp.ConditionalMockBuilderBuild elseResponse(HttpResponse response) {
			defaultResponse = response;
			return this;
		}
		
		public virtual ApexHttp.ConditionalMockBuilderBuild elseResponse(String staticResource, Integer statusCode) {
			defaultResponse = buildStaticResourceResponse(staticResource, statusCode);
			return this;
		}
		
		public virtual ApexHttp.ConditionalHttpMock build() {
			return new ApexHttp.ConditionalHttpMock(orderedConditions, conditions, defaultResponse);
		}
		
		protected virtual void appendCondition(Condition condition, HttpResponse response) {
			orderedConditions.add(condition);
			conditions.put(condition, response);
		}
		
		protected virtual HttpResponse buildResponse(Integer statusCode, String body, Map<String, String> headers) {
			return ApexHttp.response()
				.statusCode(statusCode)
				.body(body)
				.headers(headers)
				.build();
		}
		
		protected virtual HttpResponse buildStaticResourceResponse(String staticResource, Integer statusCode) {
			return ApexHttp.response()
				.statusCode(statusCode)
				.staticResource(staticResource)
				.build();
		}
	}
	
	public interface Condition {
		Boolean test(HttpRequest request);
	}
	
	public class MockCondition implements Condition {
		
		private String property;
		private Object value;
		
		public MockCondition(String property, Object value) {
			this.property = property;
			this.value = value;
		}
		
		public Boolean test(HttpRequest request) {
			if (property == ApexHttp.URL) {
				String url = request.getEndpoint();
				return url != null && url == (String)value;
			}
			else if (property == ApexHttp.METHOD) {
				String method = request.getMethod();
				return method != null && method == (String)value;
			}
			throw new IllegalUsageException('ApexHttp.MockCondition: not supported property: ' + property);
		}
		
		public Boolean equals(Object obj) {
			if (obj == null || !(obj instanceof MockCondition)) {
				return false;
			}
			MockCondition other = (MockCondition)obj;
			return property.equals(other.property) &&
				value.equals(other.value);
		}
		
		public override Integer hashCode() {
			Integer result = 17;
			result = 31 * result + property.hashCode();
			result = 31 * result + value.hashCode();
			return result;
		}
	}
	
	public class IllegalUsageException extends Exception { }
}