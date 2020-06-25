/**
 * @presideService true
 * @singleton      true
 */
component {

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

// PRIVATE HELPERS

// GETTERS AND SETTERS

}