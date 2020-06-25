component {

	property name="datamanagerService"      inject="datamanagerService";
	property name="inxMailBlockListService" inject="inxMailBlockListService";
	property name="messageBox"              inject="messagebox@cbmessagebox";

// PUBLIC ACTIONS
	public void function unblockAction( event, rc, prc ) {
		if ( !hasCmsPermission( "inxmailBounces.manage" ) ) {
			event.adminAccessDenied();
		}

		var objectName = "inxmail_blocked_email";
		var recordId   = rc.id ?: "";

		event.initializeDatamanagerPage( objectName, recordId );

		inxMailBlockListService.unblockEmail( prc.record.email_address ?: "" );
		messageBox.info( translateResource( uri="preside-objects.inxmail_blocked_email:unblocked.confirmation", data=[ prc.record.email_address ?: "" ] ) );

		setNextEvent( url=event.buildAdminLink( objectName="inxmail_blocked_email" ) );
	}

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

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		return [ {
			  link = event.buildAdminLink( linkto="datamanager.inxmail_blocked_email.unblockAction", queryString="id=#recordId#" )
			, icon = "fa-clipboard-check green"
			, class = "confirmation-prompt"
			, title = translateResource( uri="preside-objects.inxmail_blocked_email:unblock.prompt", data=[ record.email_address ?: "" ] )
		} ];
	}

	private string function renderRecord( event, rc, prc, args={} ) {
		// do not show view record screen - just go back to listing
		setNextEvent( url=event.buildAdminLink( objectName="inxmail_blocked_email" ) );
	}

}