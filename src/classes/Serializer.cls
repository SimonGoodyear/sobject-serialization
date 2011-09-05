global interface Serializer{
	string Serialize( object input );
	object Deserialize( string input );
}