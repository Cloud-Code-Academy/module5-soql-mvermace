// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Mike Vermace';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

// Q3
List<String> contLastNames = new List<String>('Smith', 'Jones');
List<Contact> contactIds = SOQL.getContactIds(List<String> contLastNames);
System.debug('contIds:'+contId);

Boolean m = Schema.sObjectType.Contact.fields.Name.isUpdateable();
System.debug(m);

//Q7
Contact testContact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john@example.com');
Contact testContact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane@example.com');
Contact testContact3 = new Contact(FirstName = 'Jack', LastName = 'Brown', Email = 'jack@other.com');
insert new List<Contact>{ testContact1, testContact2, testContact3 };
//List<Contact> contactsToReturn = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email LIKE '%example.com'];
List<Contact> contactsToReturn = SOQL.getall;

System.debug(contactsToReturn); 

Account testAccount = new Account(Name = 'Test Account');
insert testAccount;

Opportunity testOpportunity1 = new Opportunity(
    Name = 'Test Opportunity 1',
    StageName = 'Closed Won',
    CloseDate = Date.today(),
    AccountId = testAccount.Id,
    Amount = 1000
);
Opportunity testOpportunity2 = new Opportunity(
    Name = 'Test Opportunity 2',
    StageName = 'Closed Won',
    CloseDate = Date.today(),
    AccountId = testAccount.Id,
    Amount = 2000
);
Opportunity testOpportunity3 = new Opportunity(
    Name = 'Test Opportunity 3',
    StageName = 'Prospecting',
    CloseDate = Date.today(),
    AccountId = testAccount.Id,
    Amount = 3000
);
insert new List<Opportunity>{ testOpportunity1, testOpportunity2, testOpportunity3 };
List<Opportunity> opportunities = SOQL.closedWonOppsByAccountId(testAccount.Id);
System.debug(opportunities);


// Q7
Task testTask1 = new Task(Subject = 'Test Task 1', ActivityDate = Date.today().addDays(7)); // due in 7 days
Task testTask2 = new Task(Subject = 'Test Task 2', ActivityDate = Date.today().addDays(10)); // due in 8 days, should not be returned
Task testTask3 = new Task(Subject = 'Test Task 3', ActivityDate = Date.today().addDays(2)); // due in 6 days
Task testTask4 = new Task(Subject = 'Test Task 4', ActivityDate = Date.today().addDays(14)); // due in 14 days, should not be returned
Task testTask5 = new Task(Subject = 'Test Task 5', ActivityDate = Date.today().addDays(-5)); // due in the past, should not be returned
insert new List<Task>{ testTask1, testTask2, testTask3 };

// Call the method to test
Map<Id, Task> tasks = SOQL.tasksDueSoon(); //Replace null with your method call from SOQL class
System.debug(tasks);