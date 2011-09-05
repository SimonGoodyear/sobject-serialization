global class StringSerializer implements Serializer{
	
	global static string Serialize( object obj ){
		if( obj instanceof sObject )
			return string.valueOf( obj );
			
		if( obj instanceof Blob )
			return 'Blob:{' + string.valueOf(obj) + '}';
			
		if( obj instanceof Boolean )
			return 'Boolean:{' + string.valueOf(obj) + '}';

		if( obj instanceof Date )
			return 'Date:{' + string.valueOf(obj) + '}';
			
		if( obj instanceof Datetime )
			return 'Datetime:{' + string.valueOf(obj) + '}';
			
		if( obj instanceof Integer )
			return 'Integer:{' + string.valueOf(obj) + '}';
			
		if( obj instanceof Long )
			return 'Long:{' + string.valueOf(obj) + '}';

		if( obj instanceof Double )
			return 'Double:{' + string.valueOf(obj) + '}';
						
		if( obj instanceof Decimal )
			return 'Decimal:{' + string.valueOf(obj) + '}';
			
		if( obj instanceof String )
			return 'String:{' + obj + '}';
			
		if( obj instanceof List<object> )
			return SerializeList((List<object>)obj);
			
		throw new UnknownTypeException();
		
	}

	global static object Deserialize( string input ){
		
		Integer iEnd = input.indexOf( ':' );
		if( iEnd == -1 )
			return null;

		String objectName = input.substring(0, iEnd);
		String value = input.substring( iEnd + 2, input.length() - 1 );
		
		if( objectName == 'Blob' )
			return Blob.valueOf(value);
		
		if( objectName == 'Boolean' )
			return Boolean.valueOf(value);
		
		if( objectName == 'Date' )
			return Date.valueOf(value);
		
		if( objectName == 'Datetime' )
			return Datetime.valueOfGmt(value);

		if( objectName == 'Decimal' )
			return Decimal.valueOf(value);

		if( objectName == 'Double' )
			return Double.valueOf(value);
		
		if( objectName == 'Integer' )
			return Integer.valueOf(value);
		
		if( objectName == 'Long' )
			return Long.valueOf(value);
		
		if( objectName == 'String')
			return value;
		
		if( objectName == 'List' )
			return DeserializeList(value);
			
		return DeserializeSObject(objectName, value);
		
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
	
	private static string SerializeList( List<object> input ){
		string ret = 'List:{';
		
		for(object obj : input)
			ret += Serialize(obj) + ',';
		
		if( input.size() > 0 )
			ret = ret.substring(0, ret.length()-1);
		
		ret += '}';
		
		return ret;
	}

	private static List<object> DeserializeList( string value ){
		
		List<object> ret = new List<object>();
		if( value.length() == 0 )
			return ret;
			
		List<string> items;
		Integer iColon = value.indexOf( ':' );
		if( iColon == -1 )
			return ret;
				
		string listType = value.substring(0, iColon); 
		value = ',' + value;
		items = value.split(',' + listType + ':');
		items.remove(0);
	
		for(string item : items){
			ret.add(Deserialize(listType + ':' + item));
		}
		
		return ret;
	}
	
	private static sObject DeserializeSObject( string objectName, string value ){
		sObject obj = getSObject( objectName, null );
		if( obj == null )
			return null;

		String objectFields = ', ' + value;
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
}