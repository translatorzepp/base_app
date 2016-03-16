A basic multi-page checkout app, using [Braintree]("https://developers.braintreepayments.com"). Implements the Drop-in User Interface with customer ID, PayPal New Vault flow, 3D Secure, transactions and subscriptions, device data.

<h4>Before using:</h4>

+ Verify that all files are present and in the following directory structure:
```
autoloader_braintree_config.rb
single_page_app.rb
views
	single_page_checkout.erb
	single_page_result.erb
```
+ Make sure rubygems, braintree, and sinatra are installed and up-to-date
 + This app was created with braintree v. 2.56.0-2.58.0, but should run with most recent versions of the gem. Minimum version: 2.43.0
 + See [developers.braintreepayments.com/start/hello-server/ruby]("developers.braintreepayments.com/start/hello-server/ruby") for Braintree's requirements for Ruby version, etc


 <h4>To use:</h4>

 Run app.rb from the command line with

 `shotgun app.rb`

and visit the appropriate localhost address. Choose an existing customer, to be a new customer, or to not create a customer (and not store payment information.) Continue to the next page, fill in amount, currency, and payment information, and choose (if it's an option) whether you would like a subscription, and continue; verify 3D Secure. Observe results.

<h4>Breakdown of flow by files:</h4>

*autoloader_braintree_config*:
+ requires the necessary gems: braintree and sinatra for running the app
+ implements Braintree::Configuration to set the API keys
+ sets constants for use throughout the app: merchant ID, merchant account IDs, customer management flags

*app*: on first loading, presents customer selection page

*chooseyourownadventure*: customer selection page

on submission of this form, *app*:
+ decides whether or not to show the subscription option
+ creates a customer if new customer was selected
+ checks that the selected customer exists if an existing customer was selected
+ pulls transaction history if an existing customer was selected
+ generates a client token with customer ID
+ Presents checkout page

*checkout*:
+ provides a back button
+ provides an amount and currency selector, and a checkbox to create a subscription (unless no customer has been selected)
+ implements the Drop-in with customer ID with PayPal New Vault and 3D Secure

on submission of checkout form, *app*:
+ checks the selected currency and grabs the appropriate merchant account ID and plan ID
+ if a subscription was selected, create a subscription with the specified parameters
+ if not, creates a transaction
+ grabs information about the success/failure/resulting transaction from whichever API call was made
+ presents result page

*result*:
+ displays information about the successful or failed transaction or subscription
+ allows you to go back and start over
