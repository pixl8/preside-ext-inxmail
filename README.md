# InxMail SMTP Provider

The InxMail SMTP provider allows you to use the [InxMail SMTP Relay service](https://www.inxmail.com/products/mail-relay) with Preside Email Center.

Once installed, the extension will add an InxMail tab to your email settings page. Configure your SMTP credentials and API keys and you are good to go.

## Permissions

The extension adds the following admin permission key: `inxmailBounces.bounces`. This is used to control access to the InxMail blocklist management screens from within the Preside admin. The permission is added to the default Preside `sysadmin` role but _you will need to add the key to any other admin user roles who you wish to have access to this feature_.

## Recommendations

We recommend that you set the following feature flag in your application's config.cfc if you are using this extension to send mail:

```cfc
settings.features.emailDeliveryStats.enabled = false;
```

The reason for this is that we do not have actual delivery statistics from InxMail - having delivery stats in the Preside UI leads to confusion and mistrust from the user.

**Note** This feature flag is effective as of **Preside 10.12.0-SNAPSHOT6447**.

## License

This project is licensed under the GPLv2 License - see the [LICENSE.txt](https://github.com/pixl8/preside-ext-inxmail/blob/stable/LICENSE.txt) file for details.

## Authors

The project is maintained by [The Pixl8 Group](https://www.pixl8.co.uk). The lead developer is [Dominic Watson](https://github.com/DominicWatson) and the project is supported by the community ([view contributors](https://github.com/pixl8/preside-ext-inxmail/graphs/contributors)).

## Code of conduct

We are a small, friendly and professional community. For the eradication of doubt, we publish a simple [code of conduct](https://github.com/pixl8/preside-ext-inxmail/blob/stable/CODE_OF_CONDUCT.md) and expect all contributors, users and passers-by to observe it.