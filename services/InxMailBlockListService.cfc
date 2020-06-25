/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="inxMailApiWrapper"   inject="inxMailApiWrapper";

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public array function removeBlockedEmailsFromSendList( required array sendList ) {
		var cleanList = [];
		var dao       = $getPresideObject( "inxmail_blocked_email" );

		for( var emailAddress in sendList ) {
			var cleanAddress = Trim( ReReplaceNoCase( emailAddress, "^.*?<(.*)>$", "\1" ) );

			if ( !dao.dataExists( filter={ email_address=cleanAddress } ) ) {
				ArrayAppend( cleanList, emailAddress );
			}
		}

		return cleanList;
	}

	public boolean function unblockEmail( required string emailAddress ) {
		inxMailApiWrapper.call(
			  uri    = "/blocklist/#arguments.emailAddress#"
			, method = "DELETE"
		);

		$getPresideObject( "inxmail_blocked_email" ).deleteData( filter={ email_address=arguments.emailAddress } );

		return true;
	}

// PRIVATE HELPERS

// GETTERS AND SETTERS

}