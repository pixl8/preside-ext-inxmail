# INXMail SMTP Provider

The INXMail SMTP provider allows you to use the [INXMail SMTP Relay service](https://www.inxmail.com/products/mail-relay) with Preside Email Center.

Once installed, the extension will add an INXMail tab to your email settings page. Configure your SMTP credentials and API keys and you are good to go.

Maintained by [Team Elf](https://mis.pixl8.cloud/mis/wikispace/team-elf/).

## Recommendations

We recommend that you set the following feature flag in your application's config.cfc if you are using this extension to send mail:

```cfc
settings.features.emailDeliveryStats.enabled = false;
```

The reason for this is that we do not have actual delivery statistics from INXMail - having delivery stats in the Preside UI leads to confusion and mistrust from the user.

**Note** This feature flag is effective as of **Preside 10.12.0-SNAPSHOT6447**.