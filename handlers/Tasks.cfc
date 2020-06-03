component {

	property name="inxMailEventSyncService" inject="inxMailEventSyncService";

	/**
	 * Sync INXMail bounces and complaints
	 *
	 * @priority     5
	 * @schedule     0 *\/5 * * * *
	 * @displayName  Sync INXMail bounces and complaints
	 * @displayGroup Email
	 */
	private boolean function syncInxMailDeliveryNotifications( logger ) {
		return inxMailEventSyncService.syncDeliveryNotifications( arguments.logger ?: NullValue() );
	}

}