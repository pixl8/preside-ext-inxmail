component {

	property name="datamanagerService" inject="datamanagerService";

// PUBLIC ACTIONS

// DATAMANAGER CUSTOMIZATIONS
	private boolean function checkPermission( event, rc, prc, args={} ) {
		var alwaysDisallowed = [ "manageContextPerms", "viewversions" ];
		var allowedOps       = datamanagerService.getAllowedOperationsForObject( "inxmail_blocked_email" );
		var operationMapped  = [ "read", "add", "edit", "delete", "clone" ];
		var hasPermission    = !alwaysDisallowed.find( args.key )
		                    && ( !operationMapped.find( args.key ) || allowedOps.find( args.key ) )
		                    && hasCmsPermission( "inxmailBounces.manage" );

		if ( !hasPermission && IsTrue( args.throwOnError ?: "" ) ) {
			event.adminAccessDenied();
		}

		return hasPermission;
	}

	private string function renderRecord( event, rc, prc, args={} ) {
		// do not show view record screen - just go back to listing
		setNextEvent( url=event.buildAdminLink( objectName="inxmail_blocked_email" ) );
	}

}