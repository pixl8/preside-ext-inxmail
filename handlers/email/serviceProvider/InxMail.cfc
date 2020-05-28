/**
 * Service provider for email sending through InxMail SMTP
 *
 */
component {
	property name="emailTemplateService" inject="emailTemplateService";

	private boolean function send( struct sendArgs={}, struct settings={} ) {
		var template = emailTemplateService.getTemplate( sendArgs.template ?: "" );
		var smtpSettings = {
			  server   = settings.inxmail_server   ?: "smtp.inxmail-commerce.com"
			, port     = settings.inxmail_port     ?: 587
			, username = settings.inxmail_username ?: ""
			, password = settings.inxmail_password ?: ""
			, use_tls  = true
		};

		_addInxHeaders( argumentCollection=arguments );

		return runEvent(
			  event          = "email.serviceProvider.smtp.send"
			, private        = true
			, prepostExempt  = true
			, eventArguments = {
				  sendArgs = sendArgs
				, settings = smtpSettings
			  }
		);
	}

	private any function validateSettings( required struct settings, required any validationResult ) {
		var smtpSettings = {
			  server           = settings.inxmail_server   ?: "smtp.inxmail-commerce.com"
			, port             = settings.inxmail_port     ?: 587
			, username         = settings.inxmail_username ?: ""
			, password         = settings.inxmail_password ?: ""
			, use_tls          = true
			, check_connection = IsTrue( settings.inxmail_verify ?: "" )
		};

		StructDelete( settings, "inxmail_verify" );

		validationResult = runEvent(
			  event          = "email.serviceProvider.smtp.validateSettings"
			, private        = true
			, prepostExempt  = true
			, eventArguments = {
				  validationResult = validationResult
				, settings         = smtpSettings
			  }
		);

		if ( !validationResult.validated() ) {
			var messages = validationResult.getMessages();
			var newMessages = {};

			for( var key in messages ) {
				newMessages[ "inxmail_#key#" ] = messages[ key ];
			}

			validationResult.setMessages( newMessages );
		}

		return validationResult;
	}

// HELPERS
	private void function _addInxHeaders( struct sendArgs={}, struct settings={} ) {
		sendArgs.params = sendArgs.params ?: {};

		if ( Len( Trim( arguments.settings.inxmail_appid ?: "" ) ) )  {
			sendArgs.params[ "X-inx-correlationId1" ] = Trim( arguments.settings.inxmail_appid );
		} else {
			var appSettings = getApplicationMetadata();
			sendArgs.params[ "X-inx-correlationId1" ] = appSettings.name ?: "Preside";
		}

		if ( Len( Trim( template.name ?: "" ) ) ) {
			sendArgs.params[ "X-inx-correlationId2" ] = Trim( template.name );
		}

		if ( Len( sendArgs.messageId ?: "" ) ) {
			sendArgs.params[ "X-inx-correlationId3" ] = sendArgs.messageId;
		}
	}
}