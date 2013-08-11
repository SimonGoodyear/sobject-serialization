global class JSONSerializer implements Serializer{
	private static String namespace;
	private static Map<string, List<Schema.DescribeFieldResult>> fields = new Map<string, List<Schema.DescribeFieldResult>>();
	private static Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe( );
	private static string objTypeField = 'objecttype';
	
	global static string Serialize( sObject obj ){
		
		initialiseSchema(obj);
		
		string objName = obj.getSObjectType().getDescribe().getName();
		string output = '{"' + objTypeField + '":"' + objName + '"';
		
		for(Schema.DescribeFieldResult field : fields.get(objName)){
			string name = field.getName();
			
			try{ 
				if(obj.get(name) != null){
					output += ',"' + field.getName() + '":"' + escape(string.valueOf(obj.get(field.getName()))) + '"';
				}
			} catch(System.SObjectException ex){
				// Just swallow this
			}
		}
		
		output += '}';
		
		return output;
	}

	global static sObject Deserialize( string input ){
		
		if( input == null || input.length() < 5 )
			return null;
			
		if(namespace == null) {
			namespace = [Select NameSpacePrefix From ApexClass Where Name = 'JSONSerializer'].NameSpacePrefix;
			if(namespace == null) namespace = '';
		}
		
		if(namespace.length() > 0) {
			input = input.remove(namespace + '__');	
		}
			
		input = input.substring(2, input.length()-2);
		
		string[] pairs = input.split('" *, *"');
		Map<string,string> keyPairs = new Map<string,string>();
		
		for(string pair : pairs){
			string[] parts = pair.split('" *: *"');
			if(parts.size() != 2)
				continue;
			keyPairs.put(parts[0], parts[1]);
		}

		sObject obj = getsObject(keyPairs);
		if( obj == null )
			return obj;
			
		initialiseSchema(obj);
		
		for(string key : keyPairs.keySet()){
			if( key == objTypeField )
				continue;
			
			obj = addField(obj, keyPairs.get(objTypeField), key, unescape(keyPairs.get(key)));
				
		}		
		
		return obj;
	} 
	
	private static void initialiseSchema( sObject obj ){
		
		Schema.SObjectType objType = obj.getSObjectType();
		string objName = objType.getDescribe().getName();
		if( fields.get(objName) != null )
			return;
			
		fields.put(objName, new List<Schema.DescribeFieldResult>());
		for(Schema.SObjectField field : objType.getDescribe().fields.getMap().values()){
			fields.get(objName).add(field.GetDescribe());
		} 
	}
	
	private static sObject addField( sObject obj, string objName, string fieldName, string fieldValue ){

		Schema.DescribeFieldResult field  = getFieldDescription(objName, fieldName);
		if( field == null || !field.isUpdateable() )
			return obj;
		Schema.Soaptype st = field.getSoapType();
		
		if( st == Schema.Soaptype.Id || st == Schema.SoapType.String ){
			obj.put( fieldName, fieldValue );
			return obj;
		}
		
		if( st == Schema.Soaptype.Integer ){
			obj.put( fieldName, integer.valueOf( fieldValue ) );
			return obj;
		}
		
		if( st == Schema.Soaptype.Boolean ){
			obj.put( fieldName, boolean.valueOf( fieldValue ) );
			return obj;
		}

		if( st == Schema.Soaptype.Date ){
			obj.put( fieldName, date.valueOf( fieldValue ) );
			return obj;
		}
		
		if( st == Schema.Soaptype.DateTime ){
			obj.put( fieldName, dateTime.valueOfGmt( fieldValue ) );
			return obj;
		}
		
		if( st == Schema.Soaptype.Double ){
			obj.put( fieldName, double.valueOf( fieldValue ) );
			return obj;
		}
		
		if( st == Schema.Soaptype.base64binary ){
			obj.put( fieldName, blob.valueOf( fieldValue ) );
			return obj;
		}
			
		return obj;
		
	}
	
	private static sObject getsObject( Map<string, string> parts ){
		
		string objectType = parts.get(objTypeField);
		if( objectType == null || objects.get(objectType) == null)
			return null;
			
		if( parts.get('Id') == null )
			return objects.get(objectType).newSObject();
		else
			return objects.get(objectType).newSObject(parts.get('Id')); 
 
	}
	
	private static Schema.DescribeFieldResult getFieldDescription(string objectName, string fieldName){
		
		for(Schema.DescribeFieldResult description : fields.get(objectName)){
			if( description.getName() == fieldName)
				return description;
		}
		
		return null;
	}
	
	private static string escape( string value ){
		return value.replace('\\', '\\\\').replace('/', '\\/').replace('"', '\\"');
	}
	
	private static string unescape( string value ){
		return value.replace('\\"', '"').replace('\\/', '/').replace('\\\\', '\\');
	}

}