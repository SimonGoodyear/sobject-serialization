@isTest
private class TestStringSerializer {

	private static testMethod void testSerialize(){
		
		Account a1 = new Account(Name='hello', NumberOfEmployees=45);
		
		string s1 = StringSerializer.Serialize( a1 );
		
		System.assertEquals( string.valueOf(a1), s1 );
	}

	private static testMethod void testDeSerialize(){
		
		system.assertEquals( null, StringSerializer.Deserialize('') );
		system.assertEquals( null, StringSerializer.Deserialize('RandomObject:{somefields}') );
		
		Account a1 = new Account(Name='hello', NumberOfEmployees=45, AnnualRevenue=459700.32);
		Account a2 = (Account)StringSerializer.Deserialize( StringSerializer.Serialize( a1 ) );
		System.assertEquals( a1.name, a2.Name );
		System.assertEquals( a1.NumberOfEmployees, a2.NumberOfEmployees );
		System.assertEquals( a1.AnnualRevenue, a2.AnnualRevenue );
		
		Contact c1 = new Contact(Lastname='Surname', EmailBouncedDate=datetime.now(), Birthdate=date.today());
		insert c1;
		
		Contact c2 = [SELECT Id FROM Contact WHERE Id = :c1.Id limit 1];
		Contact c3 = (Contact)StringSerializer.Deserialize( StringSerializer.Serialize( c2 ) );
		System.assertEquals( c2.Id, c3.Id );
		
		c2 = [SELECT Id, EmailBouncedDate, Birthdate FROM Contact WHERE Id = :c1.Id limit 1];
		c3 = (Contact)StringSerializer.Deserialize( StringSerializer.Serialize( c2 ) );
		System.assertEquals( c2.EmailBouncedDate, c3.EmailBouncedDate );
		System.assertEquals( c2.Birthdate, c3.Birthdate );
		
		Task t1 = new Task(IsReminderSet=false);
		Task t2 = (Task)StringSerializer.Deserialize( StringSerializer.Serialize( t1 ) );
		System.assertEquals( t1.IsReminderSet, t2.IsReminderSet );
		
	}
	
	private static testMethod void testString(){
		string input = 'test, me: please';
		string output = (string)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testBoolean(){
		Boolean input = false;
		Boolean output = (Boolean)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testDate(){
		Date input = Date.today();
		Date output = (Date)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testDatetime(){
		Datetime input = Datetime.now();system.debug('** ' + StringSerializer.Serialize(input));
		Datetime output = (Datetime)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testDecimal(){
		Decimal input = 12.2;
		Decimal output = (Decimal)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testDouble(){
		Double input = 12.2;
		Double output = (Double)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testLong(){
		Long input = 122;
		Long output = (Long)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}

	private static testMethod void testInteger(){
		Integer input = 122;
		Integer output = (Integer)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input, output);
	}
	
	private static testMethod void testList(){
		List<string> input = new List<string>{'s:1', 's,2', 's3'};
		List<object> output = (List<object>)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input.size(), output.size());
	}		

	private static testMethod void testEmptyList(){
		List<string> input = new List<string>();
		List<object> output = (List<object>)StringSerializer.Deserialize(StringSerializer.Serialize(input));
		
		system.assertEquals(input.size(), output.size());
	}		
		
}