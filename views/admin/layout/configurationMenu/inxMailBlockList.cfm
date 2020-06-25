<cfif hasCmsPermission( "inxmailBounces.manage" )>
	<cfoutput>
		<li>
			<a href="#event.buildAdminLink( objectName="inxmail_blocked_email" )#">
				<i class="fa fa-fw #translateResource( 'preside-objects.inxmail_blocked_email:iconClass' )#"></i>
				#translateResource( 'preside-objects.inxmail_blocked_email:system.menu.link' )#
			</a>
		</li>
	</cfoutput>
</cfif>