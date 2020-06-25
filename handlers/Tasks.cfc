component {

	property name="inxMailEventSyncService" inject="inxMailEventSyncService";

	/**
	 * Sync InxMail bounces and complaints
	 *
	 * @priority     5
	 * @schedule     0 *\/5 * * * *
	 * @displayName  Sync InxMail bounces and complaints
	 * @displayGroup Email
	 */
	private boolean function syncInxMailDeliveryNotifications( logger ) {
		return inxMailEventSyncService.syncDeliveryNotifications( arguments.logger ?: NullValue() );
	}

	/**
	 * Sync InxMail block list
	 *
	 * @priority     5
	 * @schedule     0 0 *\/2 * * *
	 * @displayName  Sync InxMail block list
	 * @displayGroup Email
	 */
	private boolean function syncInxMailBlockList( logger ) {
		return inxMailEventSyncService.syncBlockList( arguments.logger ?: NullValue() );
	}

}