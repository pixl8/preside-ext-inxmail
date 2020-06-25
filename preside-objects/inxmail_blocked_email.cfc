/**
 * @versioned                    false
 * @nodatemodified               true
 * @labelfield                   email_address
 * @datamanagerEnabled           true
 * @datamanagerAllowedOperations read
 * @datamanagerGridFields        email_address,block_date,block_reason
 */
component {
	property name="email_address" type="string" dbtype="varchar" maxlength="255" required=true uniqueindexes="email";
	property name="block_date"    type="date"   dbtype="datetime"                required=true indexes="blockdate";
	property name="block_reason"  type="string" dbtype="varchar"                 required=true indexes="blockreason" enum="inxmailBlockType";
	property name="sync_job"      type="string" dbtype="varchar" maxlength="35"  required=true indexes="syncjob" autofilter=false;
}