/**
 * @versioned          false
 * @nodatemodified     true
 * @labelfield         email_address
 * @datamanagerEnabled true
 */
component {
	property name="email_address" type="string" dbtype="varchar" maxlength="255" required=true uniqueindexes="email";
	property name="block_date"    type="date"   dbtype="datetime"                required=true indexes="blockdate";
	property name="block_reason"  type="string" dbtype="varchar"                 required=true indexes="blockreason";
	property name="sync_job"      type="string" dbtype="varchar" maxlength="35"  required=true indexes="syncjob";
}