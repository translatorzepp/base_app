require "~/Documents/API/treebrain-integrations/bellsandwhistles/bellsandwhistles-auto.rb"

get '/' do

    erb :bellsandwhistleschooseyourownadventure

end

post '/checkout' do 

    customer = params[:customer]
    @show_subscription_checkbox = true
    case customer
    when CREATE_NEW_CUSTOMER
        # TO DO: wrap in try-catch; if exception, location.reload(true); ???
        result = Braintree::Customer.create!()
        customer = result.id
        @customer_name = "New Customer"
    when DO_NOT_STORE_CUSTOMER
        customer = "" # this is OK, because if you generate a client token with the customer ID as the empty string, it treats it as if you hadn't passed in a customer ID at all
        @customer_name = "Non-Existent Customer"
        @show_subscription_checkbox = false
    else
        # TO DO: wrap in try-catch; if exception, location.reload(true);
        # verify that the customer exists:
        result = Braintree::Customer.find(customer)
        @customer_name = result.first_name + " " + result.last_name
        # TO DO: will this return an exception if there are no transactions? 
        transaction_history = Braintree::Transaction.search do |search|
          search.customer_id.is customer
          search.status.in(
            Braintree::Transaction::Status::Authorized,
            Braintree::Transaction::Status::SubmittedForSettlement,
            Braintree::Transaction::Status::Settled,
          )
        end
        last_transaction = transaction_history.first
        # TO DO: fix amount.to_s returning the number in scientific notation :D
        @last_transaction_info = "Your last transaction was on " + last_transaction.created_at.to_s + " for " + last_transaction.amount.to_s + " " + last_transaction.currency_iso_code
        if last_transaction.subscription_id
            @last_transaction_info = @last_transaction_info + ", from subscription ID \"" + last_transaction.subscription_id + "\""
        end

    end

    @client_token = Braintree::ClientToken.generate(
        :customer_id => customer
    )

    erb :bellsandwhistlescheckout

end


post '/create_transaction' do

    currency = params[:currency]
    case currency
    when "USD"
        currency_matched_plan_id = "crazyscience"
        currency_matched_merchant_account_id = MERCHANT_ACCOUNT_ID_USD
    when "CAD"
        currency_matched_plan_id = "cloneclub"
        currency_matched_merchant_account_id = MERCHANT_ACCOUNT_ID_CAD
    when "GBP"
        currency_matched_plan_id = "gunsforfunds2"
        currency_matched_merchant_account_id = MERCHANT_ACCOUNT_ID_GBP
    when "EUR"
        currency_matched_plan_id = "noIRBapproval"
        currency_matched_merchant_account_id = MERCHANT_ACCOUNT_ID_EUR
    else
        # TO DO: error handling
        currency_matched_plan_id = "improvisedweaponofthemonth"
        currency_matched_merchant_account_id = MERCHANT_ACCOUNT_ID_USD
    end

    create_subscription = params[:subscription]
    if create_subscription
        result = Braintree::Subscription.create(
            :price => params[:amount],
            :payment_method_nonce => params[:noncense],
            :merchant_account_id => currency_matched_merchant_account_id,
            :plan_id => currency_matched_plan_id,
            :options => {
                :start_immediately => true,
            }
        )
    else
        result = Braintree::Transaction.sale(
            :amount => params[:amount],
            :payment_method_nonce => params[:noncense],
            :merchant_account_id => currency_matched_merchant_account_id,
            :customer_id => @existing_customer_id, #verified this assigns no customer with the empty string
            :device_data => params[:device_data],
            :options => {
              :submit_for_settlement => true,
            },
        )
    end

    if result.success?
    # Transaction created successfully
        @successful = "successful"
        @message = "Transaction created."
        if result.subscription
            @link = 'https://sandbox.braintreegateway.com/merchants/' + MERCHANT_ID + '/transactions/' + result.subscription.transactions[0].id
            @subscription_message = "You are signed up for a subscription. Next bill date: " + result.subscription.next_billing_date + " for " + result.subscription.price.to_s + " on the \"" + result.subscription.plan_id + "\" plan."
        else
            @link = 'https://sandbox.braintreegateway.com/merchants/' + MERCHANT_ID + '/transactions/' + result.transaction.id
            @subscription_message = "You are not signed up for a subscription."
        end
    else
        @successful = "unsuccessful"
        @message = result.message
        if result.transaction
            # Transaction created unsuccessfully
            # TO DO: this @link = is a duplicate line with an above condition. figure out a way to consolidate.
            # TO DO: in fact, figure out better error handling structure in general
            @link = 'https://sandbox.braintreegateway.com/merchants/' + MERCHANT_ID + '/transactions/' + result.transaction.id
            if result.transaction.status === Braintree::Transaction::Status::ProcessorDeclined
                # BIN lookup to identify bank and point customer to call
                @message = @message + ": try again later."
            elsif result.transaction.status === Braintree::Transaction::Status::GatewayRejected
                @message = @message + ": check your payment information and try again."
            end
        else
            # Transaction not created; validation error
            @link = 'https://developers.braintreepayments.com'
            @message = @message + " Send this to the webmaster:"
        end
    end

    erb :bellsandwhistlesresult

end

       # # TEST IF THIS WORKS
    # if trans = result.transaction
    #     id = result.transaction.id
    #     @link = 'https://sandbox.braintreegateway.com/merchants/ryqy4yyw7m5bf92h/transactions/' + id
    #     if result.success?
    #         # Successful Transaction
    #     else
    #         @message = result.message
    #         # Unsuccessful Transaction
    # else
    #     # Validation Error
    # end


    # if result.transaction does not exist
    #     validation error
    #     message = result.message
    #     successful = Failure



   # if result.message
   #      @message = result.message


    # elsif result.transaction
    # # Transaction created unsuccessfully (transaction created but processor declined or gateway rejected)
    #     @successful = "Failure!"
    #     @link = 'https://sandbox.braintreegateway.com/merchants/ryqy4yyw7m5bf92h/transactions/' + id
    #     if result.transaction.status == "processor_declined"
    #         @message = result.message + "."
    #     elsif result.transaction.status == "gateway_rejected"
    #         @mm
    #     end
    # else
    #     # transaction not created
    #     @successful = "Failure!"
    #     @message = result.message
    #     @link = 'https://developers.braintreepayments.com/'
    # # TO DO: ADD RESULT HANDLING FOR DECLINE/REJECTION VS VALIDATION ERROR
    # end

    # @successful = "Success!"
    # @message = "Transaction created."
    # @id = result.transaction.id




# post '/cancel_subscription' do

#     sub_to_cancel = params[:]

# end