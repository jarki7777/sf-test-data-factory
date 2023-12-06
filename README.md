<a href="https://githubsfdeploy.herokuapp.com?owner=jarki7777&repo=test-data-factory&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

#
## Simplifying Apex Test Data Creation with Multipurpose Data Factory
When working with Salesforce Apex Tests, the need to create dummy data often results in clunky @TestSetup methods or monolithic test data factory classes. These approaches introduce duplicated code, making maintenance challenging.

### Common Challenges in Apex Testing

- Duplicated code in @TestSetup methods.
- Maintenance overhead when dealing with changes in picklist values, RecordTypes, or required fields.

### Introducing the Multipurpose Data Factory

This project proposes a single, versatile data factory designed to address these challenges. The factory allows you to create or insert any SObject, handling various record creation constraints.

### Key Features

- Simplifies data creation for Apex tests.
- Addresses challenges posed by changes in schema elements.
- Reusable and adaptable for different test scenarios.
- Autopopulate required fields

### Limitations

While the data factory covers a wide range of scenarios, a few exceptions exist. These are documented to provide transparency about the tool's limitations.

- Code coverage for the class will plummet well below 75% if the org has no RecordTypes nor dependant picklists.
- As of Summer 23' Allowed picklist values by RecordType are only available through UI API. Beacuse of this if a RecordType is specified, the picklist values must be provided aswell.

### Usage
To create data for your tests just create a new TestDataFactory instance and use the make method overloads. Then you can just directly insert the data or get the created objects, you'll have to cast the obj variable:
````java
@TestSetup
static void makeData() {
    // the simplest way:
    TestDataFactory tdf = new TestDataFactory('Account')
        .create()
        .insertData();

    //////////////////////////////////////////////////////
    // populate some fields before inserting the data:
    TestDataFactory tdf = new TestDataFactory('Account')
        .create()
        .withField('Name', 'tdf account')
        .withField('Type', 'Prospect')
        .withField('Industry', 'Technology')
        .insertData();

    //////////////////////////////////////////////////////
    // just create for later manipulation:
    TestDataFactory tdf = new TestDataFactory('Account')
        .count(10)
        .create();
    List<Case> c = (List<Case>) tdf.objs;
    // do stuff to your cases befor insert;
    insert c;

    //////////////////////////////////////////////////////
    // Use all the features:
    TestDataFactory tdf = new TestDataFactory('Account')
        .count(3)
        .recordType('MyAcctRecordTypeApiName')
        .withField('Type', 'Prospect')
        .create()
        .insertData()
        .withChild('Opportunity')
        .withChildCount(5)
        .withChildRecordType('MyOppRecordTypeApiName')
        .createChildren()
        .insertChildren();
}
````
#
#### make method overloads:  
````java
make(sObjectApiName);
make(sObjectApiName, count);
make(sObjectApiName, rtDevName);
make(sObjectApiName, rtDevName, count);
````
#
#### Test coverage
To get a proper code coverage I suggest you to go to TestDataFactory_Test and uncomment and modify accordingly the last 3 tests. The last one is specially important if you have any dependant picklist in your org.
#
#### What's next?
I want to add an onCascade and onReverseCaseCade methods to populate both parent and children related objects.