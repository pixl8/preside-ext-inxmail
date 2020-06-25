component {

	public void function configure( required struct config ) {
		var settings = arguments.config.settings ?: {};

		_setupEmailProvider( settings );
		_setupAdminNavigation( settings );
		_setupEnums( settings );
		_setupAdminPermissions( settings );
	}

	private void function _setupEmailProvider( settings ) {
		settings.email.serviceProviders.inxmail = {};
	}

	private void function _setupAdminNavigation( settings ) {
		settings.adminConfigurationMenuItems = settings.adminConfigurationMenuItems ?: [];

		ArrayAppend( settings.adminConfigurationMenuItems, "inxMailBlockList" );
	}

	private void function _setupEnums( settings ) {
		settings.enum.inxmailBlockType = [ "explicit", "hardbounce" ]
	}

	private void function _setupAdminPermissions( settings ) {
		settings.adminPermissions.inxmailBounces = [ "manage" ];

		if ( StructKeyExists( settings.adminRoles, "sysadmin" ) ) {
			ArrayAppend( settings.adminRoles.sysadmin, "inxmailBounces.*" );
		}
	}
}
