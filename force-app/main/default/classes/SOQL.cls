/**
 * The SOQL class serves as a primer into the Salesforce Object Query Language in Apex.
 * It covers fundamental aspects such as SELECT statements, WHERE clauses, Relationship queries, and LIMIT keyword.
 *
 * This class introduces developers to the concept of retrieving data from Salesforce using SOQL. It provides
 * a step-by-step guide on how to construct SOQL queries, filter results using WHERE clause, retrieve related
 * records, and manage data volume using the LIMIT keyword.
 *
 * Topics covered in this class include:
 * - Understanding the structure of a SOQL query.
 * - Crafting basic SELECT statements in SOQL.
 * - Applying filters using the WHERE clause in SOQL.
 * - Fetching related records using Relationship queries.
 * - Controlling the amount of data retrieved using the LIMIT keyword.
 *
 * Users of this class can expect to gain a solid understanding of SOQL in Apex and
 * be prepared to handle data retrieval tasks in Salesforce development.
 *
 * @author Mike Vermace
 */

public with sharing class SOQL {
	/* There are opportunities are to bulkify and, at least reduce the, DRY in this HW.
	 * 
	 * So, for example Q1 is essentially:
	 * 		
	 * 		SELECT Id, LastName, Company, Phone, Email FROM Lead 		// dropping 'WITH USER_MODE' for now.
	 * 	
	 * 	Similarly, Q2
	 * 
	 * 		SELECT Id (no others fields specified) FROM Contact WHERE Firstname =:fname
	 * 
	 *  and Q7
	 * 
	 * 	....decide to skip this extra work for now...
	 * 
	 * IDK when/if I added the PDM Extension but applied some of the Database.query() and Database.queryWithBinds() work in this assignment.
	 * 



	*/
	/**
	 * Question 1
	 * Update/Uncomment the template code to create a method
	 * Returns all leads from Salesforce Org
	 * @return List of all leads with Id, LastName, Company, Phone, Email
	 * Update the corresponding test class and testGetAllLeads method to cover this method
	 */
	public static List<Lead> getAllLeads() {
		List<Lead> leads = [SELECT Id, LastName, Company, Phone, Email FROM Lead WITH USER_MODE];
		return leads;
	}

	/**
	 * Question 2
	 * Update/Uncomment the template code to create a method
	 * Returns all contacts with first name of John.
	 * @return A list of Contact records.
	 * Update the corresponding test class and testGetContactsByFirstName method to cover this method
	 */
	
	public static List<Contact> getAllContacts() {
		String fname = 'John';
		List<Contact> contacts = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE FirstName =:fname WITH SYSTEM_MODE];
		return contacts;	
	}
	

	/**
	 * Question 3
	 * Update/Uncomment the template code to create a method
	 * Returns the Contact Id for all contacts with last name of Smith or Jones
	 * @return A list of Contact Ids.
	 * Update the corresponding test class and testGetContactIdsByLastName method to cover this method
	 */
	 //List<String> contLastNames = new List<String>{'Smith', 'Jones'};
	public static List<Id> getContactIds(List<String> contLastNames) {
		List<Contact> contIds = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE LastName IN :contLastNames WITH SYSTEM_MODE];
		return null; // contIds;
	}
		
	

	/**
	 * Question 4
	 * Update/Uncomment the template code to create a method
	 * Returns List of closed won opportunities for a specific Account.
	 * Example: yourMethodName('001XXXXXXXXXXXX') should return the list of closed won opportunities for the Account with the Id
	 * @param accountId The ID of the Account.
	 * @return A list of Opportunities with important opportunities fields
	 * Update the corresponding test class and testGetClosedWonOpportunityCountByAccount method to cover this method
	 */
	public static List<Opportunity> closedWonOppsByAccountId(Id accountId) {
		List<Opportunity> oppsForAccountId = [SELECT Id, Name, AccountId, StageName, Amount, CloseDate FROM Opportunity WHERE AccountId =:accountId AND StageName = 'Closed Won' WITH SYSTEM_MODE];
		return oppsForAccountId;
	}

	/**
	 * Question 5
	 * Update/Uncomment the template code to create a method
	 * Returns the total count of Account records.
	 * @return The Integer count of Account records.
	 * Update the corresponding test class and testGetAccountCount method to cover this method
	 */
	public static Integer accountCount() {
		Integer accountCount = [SELECT count() FROM Account WITH SYSTEM_MODE];
		return accountCount;
	}

	/**
	 * Question 6
	 * Update/Uncomment the template code to create a method
	 * Return Key Value pair of Task Id and Task records for any tasks due date within the next 7 days.
	 * @return A map of Task Ids to Task records.
	 * Update the corresponding test class and testGetTasksDueNextWeek method to cover this method
	 */
	public static Map<Id,Task> tasksDueSoon () {
		// Does not include overdue Tasks
		// Explored N in NEXT_N_DAYS:N -> NEXT_N_DAYS:<bind_variable>.  
		//   ex. Integer daysInFuture = 7; ---> ... FROM Task WHERE ActivityDate = LAST_N_DAYS:daysInFuture WITH SYSTEM_MODE
		//       but the ':' does not handle this...
		// TODO: Migrate [SELECT...] to DynamicSOQL using Database.QueryWithBinds()
		List<Task> tasksDueNextSevenDays = [SELECT Id, Subject, ActivityDate, OwnerId, Status FROM Task WHERE IsClosed = false AND ActivityDate = NEXT_N_DAYS:7 WITH SYSTEM_MODE];
		Map<Id,Task> tasksDueSoonMap = new Map<Id,Task>(tasksDueNextSevenDays);
		return tasksDueSoonMap;
	}

	/**
	 * Question 7
	 * Update/Uncomment the template code to create a method
	 * Retrieves all Contacts that have a example.com domain in their Email.
	 * @return A list of Contact records.
	 * Update the corresponding test class and testGetContactsByEmailDomain method to cover this method
	 */
	public static List<Contact> getAllContactsExampleDotCom() {
		List<Contact> contactsToReturn = [SELECT Id, Name, FirstName, LastName, Email FROM Contact WHERE Email LIKE '%example.com' WITH USER_MODE];
		return contactsToReturn;
	}

	/**
	 * Question 8
	 * Retrieves all Opportunities that have a specific keyword in their Name.
	 * Example: getOpportunitiesByNameKeyword('keyword') should return all Opportunities that have 'keyword' in their Name.
	 * @param keyword The keyword to search for in the Opportunity Name.
	 * @return A list of Opportunity records.
	 */
	public static List<Opportunity> getOpportunitiesByNameKeyword(String keyword) {
		//Ready 'keyword' for Like clause
		String likeStr = '%' + keyword + '%';
		System.debug('likeStr'+likeStr);
		//Build Map<String, Object> to place keyword in bind
		Map<String, Object> oppBinds = new Map<String, Object>{'oppName' => likeStr };
		
		//Build query
		String queryString = 'SELECT Id, Name, StageName, CloseDate, AccountId FROM Opportunity WHERE Name LIKE :oppName';
		
		//Build Opportunity List with Database.queryWithBinds()
		List<Opportunity> oppWithKeyword = Database.queryWithBinds(queryString, oppBinds, AccessLevel.SYSTEM_MODE);
		system.debug('oppWithKeyword'+JSON.serializePretty(oppWithKeyword));
		return oppWithKeyword; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 9
	 * Retrieves all Cases that Case Origin is not Web or Email or Blank
	 * @return A list of Case records.
	 */
	public static List<Case> getFilterCaseOrigins() {
		Map<String, Object> caseBinds = new Map<String, Object>{
			'webName' => 'Web',
			'emailName' => 'Email' 
		};
		
		String queryString = 'SELECT Id, Subject, Origin FROM Case WHERE Origin != :webName AND Origin != :emailName AND Origin != Null';
		
		List<Case> casesToReturn = Database.queryWithBinds(queryString, caseBinds, AccessLevel.SYSTEM_MODE);
		
		return casesToReturn; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 10
	 * Update/Uncomment the template code to create a method
	 * Retrieves all Leads that have a specific Lead Source or contain a specific keyword in their Title.
	 * Example: yourMethodName('Web', 'Engineer') should return all Leads that have 'Web' in their Lead Source or 'Engineer' in their Title.
	 * @param leadSource The Lead Source to search for.
	 * @param keyword The keyword to search for in the Lead Title.
	 * @return A list of Lead records.
	 * Update the corresponding test class and testGetLeadsBySourceOrTitle method to cover this method
	 */
	public static List<Lead> selectedLeads(String sourceString, String titleString) {
		String titleStr = '%' + titleString + '%';
		
		//Build Map<String, Object> to place keyword in bind
		Map<String, Object> leadBinds = new Map<String, Object>{
			'leadSource' => sourceString,
			'leadTitle' => titleStr
		};
		
		//Build query
		String queryString = 'SELECT Id, Name, FirstName, LastName, LeadSource, Company, Phone, Email, Title FROM Lead WHERE LeadSource = :leadSource OR Title LIKE :leadTitle'; 
		List<Lead> leadsToReturn = Database.queryWithBinds(queryString, leadBinds, AccessLevel.SYSTEM_MODE);

		return leadsToReturn;
	}

	/**
	 * Question 11
	 * Returns the names of all Contacts associated with an Account.
	 * Example: getContactNamesByAccount('001XXXXXXXXXXXX') should return the list of Contact LastNames for the Account with the Id
	 * @param accountId The ID of the Account.
	 * @return A list of Contact LastName.
	 */
	public static List<String> getContactNamesByAccount(Id accountId) {
		// Create a list to hold the Contact LastNames
		List<String> contactLastNames = new List<String>();
		// Query the Contacts
		List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE AccountId = :accountId WITH SYSTEM_MODE];
		// Loop through each Contact and add the LastName to the list
		for (Contact cont : contacts) {
			String lastName = cont.LastName;
			contactLastNames.add(lastName);
		}
		// Return the list of Contact LastNames
		return contactLastNames; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 12
	 * Returns the total revenue for all Opportunities in a specific Stage or if the amount is greater than 10000.
	 * Example: getTotalRevenueByStage('Closed Won') should return the total revenue for the found opportunities
	 * @param stage The Stage value to filter Opportunities.
	 * @return The total revenue.
	 */
	public static Decimal getTotalRevenueByStage(String stage) {
		// Use AggregateQuery to get the total revenue
		List<AggregateResult> resultList = [SELECT SUM(Amount) sumAmount FROM Opportunity WHERE StageName = :stage WITH SYSTEM_MODE]; 
		Decimal decSum = Decimal.valueOf(Integer.valueOf(resultList[0].get('sumAmount')));
		// Return the total revenue
		return decSum; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 13
	 * Retrieves the first 10 Accounts ordered by Name.
	 * @return A list of the first 10 Accounts ordered by Name.
	 */
	public static List<Account> getFirstTenAccounts() {
		List<Account> acctsToReturn = [SELECT Id, Name FROM Account ORDER BY Name LIMIT 10];
		return acctsToReturn; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 14
	 * Retrieves the Opportunities with an Amount greater than 100,000, ordered by CloseDate, and limited to 5 records.
	 * @return A list of Opportunities with an Amount greater than 100,000, ordered by CloseDate, and limited to 5 records.
	 */
	public static List<Opportunity> getHighValueOpportunities() {
		List<Opportunity> oppList = [SELECT Id, Name, AccountId, Amount, StageName, CloseDate FROM Opportunity WHERE Amount > 100000 ORDER BY CloseDate LIMIT 5];
		return oppList; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 15
	 * Retrieves the Contacts with the most recent Birthdate, ordered by Birthdate, and limited to 3 records.
	 * @return A list of Contacts
	 */
	public static List<Contact> getBirthdateContacts() {
		List<Contact> contactsToReturn = [SELECT Id, LastName, Birthdate FROM Contact ORDER BY Birthdate DESC LIMIT 3];
		return contactsToReturn; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 16
	 * Retrieves the Cases in the Open Status, ordered by CreatedDate, and limited to 10 records with an offset of 5.
	 * @return A list of Cases
	 */
	public static List<Case> getCasesWithStatus() {
		List<Case> casesToReturn = [SELECT Id, Subject, Status, CreatedDate FROM Case WHERE Status = 'Open' ORDER BY CreatedDate LIMIT 10 OFFSET 5];
		return casesToReturn; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 17
	 * Returns Set of Case Ids for a specific Account.
	 * Example: getCaseIdsByAccount('001XXXXXXXXXXXX') should return the set of Case Ids for the Account with the Id
	 * @param accountId The ID of the Account.
	 * @return A set of Case Ids.
	 */
	public static Set<Id> getCaseIdsByAccount(Id accountId) {
		// Create a set to hold the Case Ids
		Set<Id> caseIds = new Set<Id>();
		// Query the Cases
		List<Case> caseList = [SELECT Id, Subject, Status, CreatedDate FROM Case WHERE AccountId =:accountId WITH SYSTEM_MODE];
		//Loop through each Case and add the Id to the set
		for (Case singleCase : caseList) {
			caseIds.add(singleCase.Id);
		}
		return caseIds; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 18
	 * Return Map of Account Ids to Account Names Not in a specific Country.
	 * Example: getAccountIdsToNamesNotInCountry('United States') should return the map of Account Ids to Account Names for Accounts that are not in the United States.
	 * @param country The country to filter Accounts.
	 * @return A map of Account Ids to Account Names.
	 */
	public static Map<Id, String> getAccountIdsToNamesNotInCountry(String country) {
		// Create a map to hold the Account Ids to Account Names
		Map<Id, String> accountIdsToNames = new Map<Id, String>();

		// Query the Accounts
		List<Account> accountsToReturn = [SELECT Id, Name, BillingCountry FROM Account WHERE BillingCountry != :country WITH SYSTEM_MODE];
		// Loop through each Account and add the Id and Name to the map
		for (Account acc : accountsToReturn) {
			accountIdsToNames.put(acc.Id, acc.Name);
		}
		return accountIdsToNames; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 19
	 * Retrieves the Account Name for a given Contact.
	 * Example: getAccountNameForContact('003XXXXXXXXXXXX') should return the Account Name for the Contact with the Id
	 * @param contactId The Id of the Contact.
	 * @return The Account Name of the Contact.
	 */
	public static String getAccountNameForContact(String contactId) {
		List<Contact> contactWithAccountName = [SELECT Id, Lastname, AccountId, Account.Name FROM Contact WHERE Id =:contactId WITH SYSTEM_MODE];
		return contactWithAccountName[0].Account.Name; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 20
	 * Returns single Account that has related opportunities in the same query
	 * Example: getAccountAndOpportunitiesFromAccountId('001XXXXXXXXXXXX') should return the Account Name for the Account with the Id and all related Opportunities
	 * @param accountId The ID of the Account.
	 * @return An Account record with related Opportunities.
	 */
	public static Account getAccountAndOpportunitiesFromAccountId(Id accountId) {
		List<Account> acctToReturn = [SELECT Id, Name, (SELECT Id, AccountId, Name, StageName, CloseDate FROM Opportunities) FROM Account WHERE Id = :accountId WITH SYSTEM_MODE];
		return acctToReturn[0]; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 21
	 * Retrieves all contacts that have the Mailing State similar to the Account Billing State.
	 * Example: getAccountsWithContactsByState('001XXXXXXXXXXXX') should return a list of Contacts that have the same Mailing State as the Account with the Id
	 * @param Account Id
	 * @return List of contacts with the same Mailing State as the Account Billing State
	 */
	public static List<Contact> getAccountsWithContactsByState(Id accountId) {
		// Query the Account
		List<Account> acct = [SELECT Id, Name, BillingState FROM Account WHERE Id =:accountId WITH SYSTEM_MODE];
		// Store the Account's BillingState
		String billingState = acct[0].BillingState;
		// Query the Contacts
		List<Contact> contToReturn = [SELECT Id, FirstName, LastName, MailingState FROM Contact WHERE MailingState =:billingState WITH SYSTEM_MODE];
		return contToReturn; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 22
	 * Extracts email domains from them leads, then finds Accounts with matching website domains
	 * If Lead Email = test@test.com return account with website = www.test.com
	 * Example: findAccountsByLeadEmailDomains([set of lead ids]) should return a list of Accounts with matching email domains
	 * @param A set of Lead Ids.
	 * @return A list of Accounts with matching email domains.
	 */
	public static List<Account> findAccountsByLeadEmailDomains(Set<Id> leadIds) {
		// Query the Leads
		List<Lead> leadList = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Id IN :leadIds WITH SYSTEM_MODE];
		// Create a set of email domains from the Leads
		List<String> emailDoms = new List<String>();
		for (Lead leads : leadList) {
			if ( leads.Email != null ) {
				String domainStr = leads.Email.substringAfter('@');
				if ( domainStr.length() != 0 ) {
					emailDoms.add('www.' + domainStr);
				}
			}
		}
		List<Account> acct = [SELECT Id, Name, website FROM Account WHERE website IN :emailDoms WITH SYSTEM_MODE]; // Replace null with the variable you used to store the result
		return acct;
	}

	/**
	 * Question 23
	 * Clones and Inserts Opportunity Line Items from an original Opportunity to a list of cloned Opportunities.
	 * Adds a randomized number between 1 to 3 to the quantity of each line item.
	 * Example: cloneLineItems('001XXXXXXXXXXXX', [list of opportunity ids]) should clone the line items from the Opportunity with the Id to each Opportunity in the list
	 * @param Original Opportunity Id
	 * @param List of cloned Opportunity Ids
	 */
	public static void cloneLineItems(Id origOppId, List<Id> cloneOppIds) {
		
		// Query the original Opportunity Line Items
		List<OpportunityLineItem> origOppLineItems = [SELECT Name, Quantity, UnitPrice, PricebookEntryId, OpportunityId FROM OpportunityLineItem WHERE OpportunityId =:origOppId WITH SYSTEM_MODE];
		
		// Create a list to hold the new line items - adding all origOppLineItems to new clonedOppLineItems now.  Will update later
		List<OpportunityLineItem> clonedOppLineItems = new List<OpportunityLineItem>();
		
		// Generate a random number between 1 and 3 - semantics that one random number will be used for all cloned OpportunityLineItemsl could move inside loops below.
		Integer qty = (Integer) (( Math.random() * 3 ) + 1 );
		
		// Loop through each cloned Opportunity Id
		for ( Id cloneOppId : cloneOppIds ) {
		
			// Loop through each original line item
			for ( OpportunityLineItem origOppLineItem : origOppLineItems ) {
					
					OpportunityLineItem newOppLineItem = new OpportunityLineItem();
					
					newOppLineItem.Quantity = qty;
					newOppLineItem.UnitPrice = origOppLineItem.UnitPrice;
					newOppLineItem.PricebookEntryId = origOppLineItem.PricebookEntryId;
					newOppLineItem.OpportunityId = cloneOppId;
					
					clonedOppLineItems.add(newOppLineItem);
			}
		}
		insert clonedOppLineItems;
	}

	/**
	 * Question 24
	 * Retrieves the Opportunity Name, Account Name, and Owner Name for Opportunities that have a Stage of 'Closed Won'.
	 * @return A list of filtered Opportunity
	 */
	public static List<Opportunity> getOpportunityDetailsForClosedWon() {
		String stageNameFilter = 'Closed Won';  //Maybe safer to hard-code 'Closed Won'...
		List<Opportunity> oppList = [SELECT Id, Name, Account.Name, Owner.Name, Primary_Contact__c FROM Opportunity WHERE StageName = :stageNameFilter WITH SYSTEM_MODE];
		return oppList; // Replace null with the variable you used to store the result
	}

	/**
	 * Question 25
	 * Sets the 'Primary_Contact__c' field for all Closed Won Opportunities to the Contact on the associated Account with the alphabetically first first name.
	 * Example: if there are two Contacts on the Account, "Billy" and "Abby," the 'Primary_Contact__c' will be set to "Abby."
	 */
	public static void setPrimaryContact() {
		
		// Use the getOpportunityDetailsForClosedWon() method to get the Opportunities
		List<Opportunity> oppList = getOpportunityDetailsForClosedWon();
				
		// Create a set of Account Ids from the Opportunities
		// Is there a 'shorthand' contructor method to do this?
		Set<Id> acctIds = new Set<Id>();
		for (Opportunity opp : oppList) {
			acctIds.add(opp.AccountId);
		}
				
		// Query the Contacts
		List<Contact> contList = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE AccountId IN :acctIds ORDER BY FirstName, Account.Name];
		
		// Loop through each Contact and add the Account Id and Contact to the map
		Map<Id,Id> accountToContactMap = new Map<Id,Id>();
		for (Contact cont : contList ) {
			// Need to check if cont.AccountId already exists in Map - only .add if it does NOT already exist
			if ( !accountToContactMap.containsKey(cont.AccountId) ) {
				accountToContactMap.put( cont.AccountId, cont.Id  );
			}
		}

		// Loop through each Opportunity
		for (Opportunity opp : oppList ) {
			// Update the Opportunity primary contact from accountToContactMap
			opp.Primary_Contact__c = accountToContactMap.get(opp.AccountId);
		}
		
		// Update the Opportunities	
		update oppList;
	}
}
