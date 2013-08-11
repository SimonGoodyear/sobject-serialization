@isTest
private class TestJSONSerializer {

	private static testMethod void testSerialize(){
		
		Account a1 = new Account(Name='hello', NumberOfEmployees=45);
		
		string s1 = JSONSerializer.Serialize( a1 );
		
		System.assertEquals( '{"objecttype":"Account","Name":"hello","NumberOfEmployees":"45"}', s1 );
	}

	private static testMethod void testDeSerialize(){
		
		system.assertEquals( null, JSONSerializer.Deserialize('') );
		system.assertEquals( null, JSONSerializer.Deserialize('RandomObject:{somefields}') );
		
		Account a1 = new Account(Name='hello', NumberOfEmployees=45, AnnualRevenue=459700.32);
		Account a2 = (Account)JSONSerializer.Deserialize( JSONSerializer.Serialize( a1 ) );
		System.assertEquals( a1.name, a2.Name );
		System.assertEquals( a1.NumberOfEmployees, a2.NumberOfEmployees );
		System.assertEquals( a1.AnnualRevenue, a2.AnnualRevenue );
		
		Contact c1 = new Contact(Lastname='Surname', EmailBouncedDate=datetime.now(), Birthdate=date.today());
		insert c1;
		
		Contact c2 = [SELECT Id FROM Contact WHERE Id = :c1.Id limit 1];
		Contact c3 = (Contact)JSONSerializer.Deserialize( JSONSerializer.Serialize( c2 ) );
		System.assertEquals( c2.Id, c3.Id );
		
		c2 = [SELECT Id, EmailBouncedDate, Birthdate FROM Contact WHERE Id = :c1.Id limit 1];
		c3 = (Contact)JSONSerializer.Deserialize( JSONSerializer.Serialize( c2 ) );
		System.assertEquals( c2.EmailBouncedDate, c3.EmailBouncedDate );
		System.assertEquals( c2.Birthdate, c3.Birthdate );
		
		Task t1 = new Task(IsReminderSet=false);
		Task t2 = (Task)JSONSerializer.Deserialize( JSONSerializer.Serialize( t1 ) );
		System.assertEquals( t1.IsReminderSet, t2.IsReminderSet );
		
	}
	
	private static testMethod void testDeSerializeCustomObject(){
		
		Contact c1 = new Contact(Lastname='Surname', EmailBouncedDate=datetime.now(), Birthdate=date.today());
		insert c1;
		
		Contact c2 = [SELECT Id FROM Contact WHERE Id = :c1.Id limit 1];
		Contact c3 = (Contact)JSONSerializer.Deserialize( JSONSerializer.Serialize( c2 ) );
		System.assertEquals( c2.Id, c3.Id );
		
		c2 = [SELECT Id, EmailBouncedDate, Birthdate FROM Contact WHERE Id = :c1.Id limit 1];
		c3 = (Contact)JSONSerializer.Deserialize( JSONSerializer.Serialize( c2 ) );
		System.assertEquals( c2.EmailBouncedDate, c3.EmailBouncedDate );
		System.assertEquals( c2.Birthdate, c3.Birthdate );
		
		/** 
		* Replace Case_Record__c in this section to perform a test using a custom object in your environment. 
		* Make sure that you include a custom field on the custom object (something other than Id, Name, etc)
		* so that namespace testing will occur.
		*/
		//Case_Record__c cr1 = new Case_Record__c(Name='Test Case Record',Main_Client__c=c1.Id);
		//insert cr1;
		
		//Case_Record__c cr2 = [Select Id, Name, Main_Client__c From Case_Record__c Where Id=:cr1.Id limit 1];
		//Case_Record__c cr3 = (Case_Record__c)StringSerializer.Deserialize( StringSerializer.Serialize( cr2 ) );
		//System.assertEquals( cr2.Name, cr3.Name );
		//System.assertEquals( cr2.Main_Client__c, cr3.Main_Client__c );
		
	}
	
}