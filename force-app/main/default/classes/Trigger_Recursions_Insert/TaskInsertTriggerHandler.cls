public with sharing class TaskInsertTriggerHandler {
    public void handleAfterInsert(List<Task> newTasks) {
        createCompetitorAccount(newTasks);
    }

    public void createCompetitorAccount(List<Task> newTasks) {

        List<Account> competitorAccounts = new List<Account>();

        for (Task ta : newTasks) {
            System.debug('task: ' + ta.Subject + ', ' + ta.Account_Competitor_Name__c);
            if (ta.Account_Competitor_Name__c != null) {
                Account compAcc = new Account();
                compAcc.Name = ta.Account_Competitor_Name__c;
                competitorAccounts.add(compAcc);
            }
        }

        if (competitorAccounts.size() > 0) {
            insert competitorAccounts;
        }
    }
}