global interface Serializer{
	string Serialize( sObject input );
	sObject Deserialize( string input );
}