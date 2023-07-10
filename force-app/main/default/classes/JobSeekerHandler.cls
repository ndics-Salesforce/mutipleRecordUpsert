public with sharing class JobSeekerHandler {
	public JobSeekerHandler() {
	}

	public void createSeekerList() {
		List<SObject> seekerList = [SELECT Id, Name FROM JobSeeker__c WHERE Gender__c = '男性'];
		callQueueJobSeeker(seekerList);
		System.debug('seekerList: ' + seekerList);
	}

	public void callQueueJobSeeker(List<SObject> seekerList) {
		Axas02_2Queueable que = new Axas02_2Queueable(seekerList);
		if (seekerList.size() > 0) {
			Id jobId = System.enqueueJob(que);
		}
	}
}
