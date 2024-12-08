public with sharing class OpportunityTriggerRecursionHandler {
    public void handleAfterUpdate(List<Opportunity> newOpportunities) {
        updateLastOpportunityClosedDateOnAccount(newOpportunities);
    }

    public void updateLastOpportunityClosedDateOnAccount (List<Opportunity> newOpportunities) {
        Map<String, Account> mapAccountsToUpdate = new Map<String, Account>();
        for (Opportunity opp : newOpportunities) {
            if (!mapAccountsToUpdate.containsKey(opp.AccountId)) {
                Account accToUpdate = new Account();
                accToUpdate.Id = opp.AccountId;
                accToUpdate.opportunityClosedDate__c = opp.CloseDate;
                mapAccountsToUpdate.put(accToUpdate.Id, accToUpdate);
            }
            else {
                if (opp.CloseDate > mapAccountsToUpdate.get(opp.AccountId).opportunityClosedDate__c) {
                    mapAccountsToUpdate.get(opp.AccountId).opportunityClosedDate__c = opp.CloseDate;
                }
            }
        }
        update mapAccountsToUpdate.values();
    }
}