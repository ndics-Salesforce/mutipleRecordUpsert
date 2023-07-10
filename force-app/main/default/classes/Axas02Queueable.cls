public class Axas02Queueable implements Queueable, Database.AllowsCallouts {
	private JobSeeker__c js;
	private Http h;
	private HttpRequest req;

	@TestVisible
	private HttpResponse res;

	private String calloutBaseUrl = 'callout:Axas02JWTBearer/';
	private String customJobSeekerUrl = calloutBaseUrl + '/services/apexrest/axas02/restctrl';
	private static String HTTP_METHOD_POST = 'POST';
	private static String HEADER_CONTENT_TYPE = 'Content-Type';
	private static String APPLICATION_JSON_CHARSET_UTF8 = 'application/json;charset=UTF-8';
	private String msg;
	private List<JobSeeker__c> seekerList;
	private Map<Id, SObject> seekerMap;

	/**
	 * コンストラクタ
	 */
	public Axas02Queueable() {
		this.seekerList = new List<JobSeeker__c>();
	}

	public Axas02Queueable(List<JobSeeker__c> seekerList) {
		this.seekerList = seekerList;
	}

	public void execute(QueueableContext context) {
		postSeeker();
	}

	@TestVisible
	private HttpResponse postSeeker() {
		/**
		 * seekerListからId項目を削除し、必要な項目のみでListを作る。
		 * Id,NameをString変数に格納。それをInnerListに追加。
		 * InnnerListをOuterListにaddする。
		 */
		List<List<String>> outerList = new List<List<String>>();
		for (JobSeeker__c j : this.seekerList) {
			String jId = j.Id;
			String jName = j.Name;
			List<String> innerList = new List<String>();
			innerList.add(jId);
			innerList.add(jName);
			outerList.add(innerList);
			System.debug('innerList : ' + innerList);
		}
		System.debug('outerList : ' + outerList);

		String body = (String) JSON.serialize(outerList);
		System.debug('body' + body);
		this.h = new Http();
		this.req = new HttpRequest();
		this.req.setEndpoint(customJobSeekerUrl);
		this.req.setMethod(HTTP_METHOD_POST);
		this.req.setHeader(HEADER_CONTENT_TYPE, APPLICATION_JSON_CHARSET_UTF8);
		this.req.setBody(body);
		try {
			this.res = this.h.send(req);
			if (this.res.getStatusCode() == 200) {
				this.msg = 'HttpStatusCode : ' + this.res.getStatusCode() + '\n';
				this.msg += this.res.getBody();
				System.debug(msg);
			}
			if (System.Test.isRunningTest() && this.res.getStatusCode() != 200) {
				throw new AxasException('error msg');
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}

		this.req = null;
		return this.res;
	}
}
