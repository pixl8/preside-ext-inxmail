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

		// TODO: add custom params for
		// sendArgs.params = sendArgs.params ?: {};
		// sendArgs.params[ "X-Mailgun-Variables" ] = {
		// 	  name  = "X-Mailgun-Variables"
		// 	, value =  SerializeJson( { presideMessageId = sendArgs.messageId ?: "" } )
		// };
		// if ( Len( Trim( template.name ?: "" ) ) ) {
		// 	sendArgs.params[ "X-Mailgun-Tag" ] = {
		// 		  name  = "X-Mailgun-Tag"
		// 		, value =  template.name
		// 	};
		// }

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
}