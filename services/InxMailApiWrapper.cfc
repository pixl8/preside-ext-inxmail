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
	public any function call(
		  required string uri
		,          string method = "GET"
		,          struct params = {}
		,          string body
	) {
		var settings   = $getPresideCategorySettings( "emailServiceProviderinxmail" );
		var apiUrl     = _buildUrl( arguments.uri, settings );
		var authHeader = _getAuthHeader( settings );
		var paramType  = arguments.method == "GET" ? "url" : "formfield";
		var result     = "";

		http url=apiUrl method=arguments.method timeout="30" throwonerror=false result="result" {
			httpparam name="Authorization" type="header" value=authHeader;
			httpparam name="Accept"        type="header" value="application/json";

			for( var key in arguments.params ) {
				httpparam name=key type=paramType value=arguments.params[ key ];
			}
		}

		return _processResult( result );
	}

// PRIVATE HELPERS
	private string function _buildUrl( required string uri, required struct settings ) {
		var spaceId = arguments.settings.inxmail_space ?: "";
		var baseUrl = "https://#Trim( spaceId )#.api.inxmail-commerce.com/api-service/v1";

		return baseUrl & uri;
	}

	private string function _getAuthHeader( required struct settings ) {
		var userName = Trim( settings.inxmail_api_key    ?: "" );
		var pw       = Trim( settings.inxmail_api_secret ?: "" );

		return "Basic #ToBase64( '#userName#:#pw#' )#";
	}

	private any function _processResult( required any result ) {
		if ( IsJson( result.filecontent ?: "" ) ) {
			var parsed = DeserializeJson( result.fileContent );

			if ( Len( Trim( parsed.error ?: "" ) ) ) {
				var msg = parsed.error & ": " & ( parsed.message ?: "An unexpected from the INXMail server. See error detail for detailed response" );
				var code = Val( parsed.status ?: "" );

				throw( msg, "inxmail.response.error", result.fileContent, code );
			}

			return parsed;
		}

		throw( "An unexpected response was returned from the INXMail server. See error detail for detailed response.", "inxmail.response.error", SerializeJson( result ) );
	}

}