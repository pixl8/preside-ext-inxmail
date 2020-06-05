/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="inxMailApiWrapper"   inject="inxMailApiWrapper";
	property name="sysConfigDao"        inject="presidecms:object:system_config";
	property name="emailLoggingService" inject="emailLoggingService";

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public boolean function syncDeliveryNotifications( any logger ) {
		if ( !_checkSettings( arguments.logger ?: NullValue() ) ) {
			return false;
		}

		_syncBounces( arguments.logger ?: NullValue() );
		_syncComplaints( arguments.logger ?: NullValue() );

		return true;
	}

// PRIVATE HELPERS
	public void function _syncBounces( any logger ) {
		_syncReactions(
			  eventType    = "bounce"
			, apiUri       = "/relaybounces"
			, resultEntity = "relayBounces"
			, dateField    = "bounceDate"
			, process      = function( sendLogId, bounce ){ emailLoggingService.markAsFailed( id=sendLogId, reason=bounce.bounceType ?: "" ) }
			, logger       = arguments.logger ?: NullValue()
		);
	}

	public void function _syncComplaints( any logger ) {
		_syncReactions(
			  eventType    = "complaint"
			, apiUri       = "/relaycomplaints"
			, resultEntity = "relayComplaints"
			, dateField    = "complaintDate"
			, process      = function( sendLogId ){ emailLoggingService.markAsMarkedAsSpam( id=sendLogId ) }
			, logger       = arguments.logger ?: NullValue()
		);
	}

	private void function _syncReactions(
		  required string eventType
		, required string apiUri
		, required string resultEntity
		, required string dateField
		, required any    process
		,          any    logger
	) {
		var canLog      = !IsNull( arguments.logger );
		var canInfo     = canLog && arguments.logger.canInfo();
		var lastSuccess = _getLatestSuccess( arguments.eventType );
		var result      = "";
		var bounces     = [];
		var bounceCount = 0;
		var params      = {
			  correlationId1 = _getAppId()
			, page           = 0
			, size           = 50
		};

		if ( IsDate( lastSuccess ) ) {
			params.begin = lastSuccess;
			if ( canInfo ) {
				arguments.logger.info( "Syncing InxMail #eventType# events since [#lastSuccess#]..." );
			}
		} else if ( canInfo ) {
			arguments.logger.info( "Syncing InxMail #eventType# events since the beginning of time..." );
		}

		do {
			result = inxMailApiWrapper.call(
				  uri    = arguments.apiUri
				, params = params
			);
			reactions = result._embedded[ arguments.resultEntity ] ?: [];
			reactionCount = ArrayLen( reactions );
			if ( canInfo ) {
				if ( reactionCount ) {
					arguments.logger.info( "Fetched [#reactionCount#] #eventType# records from InxMail, recording in Preside now..." );
				} else if ( params.page == 0 ) {
					arguments.logger.info( "No #eventType# events to record." );
				}
			}
			for( var reaction in reactions ) {
				var sendLogId = reaction.correlationId3 ?: "";
				if ( Len( sendLogId ) ) {
					try {
						arguments.process( sendLogId, reaction );//emailLoggingService.markAsFailed( id=sendLogId, reason=reaction.bounceType ?: "" );
					} catch( any e ){}
				}
			}
			if ( reactionCount && IsDate( reactions[ reactionCount ].bounceDate ?: "" ) ) {
				_updateLastSuccess( arguments.eventType, reactions[ reactionCount ][ arguments.dateField ] );
			}

		} while( ++params.page <= Val( result.page.totalPages ?: "" ) );

		if ( canInfo ) {
			arguments.logger.info( "Finished syncing InxMail #eventType# events" );
		}
	}

	private string function _getLatestSuccess( required string eventType ) {
		var latest = sysConfigDao.selectData( filter={ category="inxmailsync", setting="latest_#arguments.eventType#" }, selectFields=[ "value" ] );

		if ( IsDate( latest.value ?: "" ) ) {
			var nextDate = DateAdd( 'l', 1, latest.value );

			return DateFormat( nextDate, "yyyy-mm-dd" ) & "T" & TimeFormat( nextDate, "HH:mm:ss.lll" ) & "+0000";
		}

		return "";
	}

	private void function _updateLastSuccess( required string eventType, required date lastSuccess ) {
		var updated = sysConfigDao.updateData( filter={ category="inxmailsync", setting="latest_#arguments.eventType#" }, data={ value=arguments.lastSuccess }  );

		if ( !updated ) {
			sysConfigDao.insertData({
				  category = "inxmailsync"
				, setting  = "latest_#arguments.eventType#"
				, value    = arguments.lastSuccess
			});
		}
	}

	private boolean function _checkSettings( any logger ) {
		var settings = $getPresideCategorySettings( "emailServiceProviderinxmail" );
		var requiredFields = [ "inxmail_space", "inxmail_api_key", "inxmail_api_secret" ];

		for( var field in requiredFields ) {
			if ( !Len( Trim( settings[ field ] ?: "" ) ) ) {
				if ( !IsNull( arguments.logger ) && arguments.logger.canWarn() ) {
					arguments.logger.warn( "No API credentials have been setup for InxMail. Go to email settings to configure InxMail API connection and enable syncing of email events." );
				}

				return false;
			}
		}

		return true;
	}

	private string function _getAppId() {
		var setting = $getPresideSetting( "emailServiceProviderinxmail", "inxmail_appid" );
		if ( Len( Trim( setting ) ) )  {
			return setting;
		}

		var appSettings = getApplicationMetadata();
		return appSettings.name ?: "Preside";
	}
}