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

	public boolean function syncBlockList( any logger ) {
		var canLog         = !IsNull( arguments.logger );
		var canInfo        = canLog && arguments.logger.canInfo();
		var result         = "";
		var blockList      = "";
		var blockListCount = "";
		var params      = {
			  page = 0
			, size = 200
		};
		var syncJob = CreateUUId();
		var dao     = $getPresideObject( "inxmail_blocked_email" );

		if ( canInfo ) {
			arguments.logger.info( "Syncing InxMail block list..." );
		}

		do {
			result = inxMailApiWrapper.call(
				  uri    = "/blocklist"
				, params = params
			);
			blockList = result._embedded.blockList ?: [];
			blockListCount = ArrayLen( blockList );
			if ( canInfo ) {
				if ( blockListCount ) {
					arguments.logger.info( "Fetched [#blockListCount#] block list records from InxMail, recording in Preside now..." );
				} else if ( params.page == 0 ) {
					arguments.logger.info( "No blocked emails to record." );
				}
			}
			for( var blockedEmail in blockList ) {
				var updated = dao.updateData( filter={ email_address=blockedEmail.email }, data={
					  block_date   = blockedEmail.blockDate
					, block_reason = blockedEmail.blockType
					, sync_job     = syncJob
				} );
				if ( !updated ) {
					dao.insertData( data={
						  email_address = blockedEmail.email
						, block_date    = blockedEmail.blockDate
						, block_reason  = blockedEmail.blockType
						, sync_job      = syncJob
					} );
				}
			}
		} while( ++params.page <= Val( result.page.totalPages ?: "" ) );

		var removedEntries = dao.deleteData( filter="sync_job != :sync_job", filterParams={ sync_job=syncJob } );
		if ( canInfo ) {
			if ( removedEntries ) {
				arguments.logger.info( "Removed [#NumberFormat( removedEntries )#] blocked emails from local list - no longer found in INXMail block list." );
			} else {
				arguments.logger.info( "Checked for local blocked emails that are no longer blocked in INXMail. None were found and no action was taken." );

			}
		}

		if ( canInfo ) {
			arguments.logger.info( "Finished syncing InxMail blocklist." );
		}

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
		var canLog        = !IsNull( arguments.logger );
		var canInfo       = canLog && arguments.logger.canInfo();
		var lastSuccess   = _getLatestSuccess( arguments.eventType );
		var result        = "";
		var reactions     = [];
		var reactionCount = 0;
		var params        = {
			  correlationId1 = _getAppId()
			, page           = 0
			, size           = 50
		};

		if ( IsDate( lastSuccess ) ) {
			params.begin = ReReplace( lastSuccess, "\+0000$", "Z" ); // changed format for the BEGIN param
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
			var regPattern = "^(.*:)([0-9]{2}\.[0-9]{3})(\+0000)$";
			var secondsAndMillis = NumberFormat( Val( ReReplace( latest.value, regPattern, "\2" ) ) + 0.001, "0.000" );
			var nextDate = ReReplace( latest.value, regPattern, "\1{secondsAndMillis}\3" );

			return Replace( nextDate, "{secondsAndMillis}", secondsAndMillis );
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