package openfl.net.dns;

#if (!flash && sys && (!flash_doc_gen || air_doc_gen))
/**
	The ResourceRecord class is the base class for Domain Name System resource
	record classes.
**/
class ResourceRecord
{
	private function new() {}

	public var name:String;
	public var ttl:Int;
}
#else
#if air
typedef ResourceRecord = flash.net.dns.ResourceRecord;
#end
#end
