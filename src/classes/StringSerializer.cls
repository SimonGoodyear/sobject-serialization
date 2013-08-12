global class StringSerializer implements Serializer{
	private static String namespace;
	
	global static string Serialize( sObject obj ){
		return string.valueOf( obj );
	}

	global static sObject Deserialize( string input ){
		if( input == null || input.length() == 0 )
			return null;
			
		if(namespace == null) {
			namespace = [Select NameSpacePrefix From ApexClass Where Name = 'StringSerializer'].NameSpacePrefix;
			if(namespace == null) namespace = '';
		}
		
		if(namespace.length() > 0) {
			input = input.remove(namespace + '__');	
		}
		
		Integer iEnd = input.indexOf( ':' );
		if( iEnd == -1 )
			return null;

		String objectName = input.substring(0, iEnd);

		sObject obj = getSObject( objectName, null );
		if( obj == null )
			return null;

		String objectFields = ', ' + input.substring( iEnd + 2, input.length() - 1 );
		fields = objects.get( objectName ).getDescribe( ).fields.getMap( );
	
		Pattern p = Pattern.compile( ', ([^ ]*?)=' );		
		Matcher m = p.matcher( objectFields );
		
		List<string> delimiters = new List<string>( );
		List<string> fieldnames = new List<string>( );
		Boolean hasId = false;
		
		while( m.find() ){
			if( fields.containsKey( m.group( 1 ) ) ){
				delimiters.add( m.group(0) );
				fieldnames.add( m.group(1) );	
				if( m.group(1) == 'id' )
					hasId = true;		
			}
		}
			
		if( hasId ){
			for( integer i = 0; i < delimiters.size() - 1; i++ ){
				if( fieldnames[i] != 'id' )
					continue;

				obj = getSObject( objectName, extractField( objectFields, delimiters[i], delimiters[i+1] ) );
				hasId = false;
			}			
		}
		
		if( hasId && delimiters.size() > 0 ){
			obj = getSObject( objectName, extractField( objectFields, delimiters[delimiters.size()-1], null ) );
		}

		for( integer i = 0; i < delimiters.size() - 1; i++ ){
			putField( obj, fieldnames[i], extractField( objectFields, delimiters[i], delimiters[i+1] ) );
		}
		
		if( delimiters.size() > 0 ){
			putField( obj, fieldnames[fieldnames.size()-1], extractField( objectFields, delimiters[delimiters.size()-1], null ) );
		}
		
		return obj;
		
	}

	private static Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe( );
	private static Map<string, SObjectField> fields;
	
	private static string extractField( string source, string startDelimiter, string endDelimiter ){

		if( endDelimiter != null )
			return source.substring( source.indexOf( startDelimiter ) + startDelimiter.length(), source.indexOf( endDelimiter ) );
		else
			return source.substring( source.indexOf( startDelimiter ) + startDelimiter.length() );
		
	}
	
	private static sObject getSObject( string input, string id ){
		
		if( !objects.containsKey( input ) )
			return null;

		if( id == null )
			return objects.get( input ).newSObject( );
		else			
			return objects.get( input ).newSObject( id );
	} 
	
	private static void putField( SObject obj, string FieldName, string FieldValue ){
		
		Schema.DescribeFieldResult res = fields.get( FieldName ).getDescribe( );
		
		if( !res.isUpdateable() )
			return;
		
		Schema.Soaptype st = res.getSoapType();

		if( st == Schema.Soaptype.Boolean ){
			obj.put( FieldName, boolean.valueOf( FieldValue ) );
			return;
		}

		if( st == Schema.Soaptype.Date ){
			obj.put( FieldName, date.valueOf( FieldValue ) );
			return;
		}		
		
		if( st == Schema.Soaptype.DateTime ){
			obj.put( FieldName, dateTime.valueOfGmt( FieldValue ) );
			return;
		}
		
		if( st == Schema.Soaptype.Double ){
			obj.put( FieldName, double.valueOf( FieldValue ) );
			return;
		}
		
		if( st == Schema.Soaptype.Id || st == Schema.SoapType.String ){
			obj.put( FieldName, FieldValue );
			return;
		}
		
		if( st == Schema.Soaptype.Integer ){
			obj.put( FieldName, integer.valueOf( FieldValue ) );
			return;
		}
		
		if( st == Schema.Soaptype.base64binary ){
			obj.put( FieldName, blob.valueOf( FieldValue ) );
			return;
		}
	}
}