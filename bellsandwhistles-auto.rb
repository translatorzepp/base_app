# require "rubygems"
require "braintree"
require "sinatra"

MERCHANT_ID = 'ryqy4yyw7m5bf92h'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = MERCHANT_ID
Braintree::Configuration.public_key = 'ymtqgy8773zq2fw3'
Braintree::Configuration.private_key = '7dd7253c4c53d675f15e869212659579'

MERCHANT_ACCOUNT_ID_USD = "q6p2fn8ssnfjfz2p"
MERCHANT_ACCOUNT_ID_CAD = "anti-dyad_CAD"
MERCHANT_ACCOUNT_ID_EUR = "anti-dyad_EUR"
MERCHANT_ACCOUNT_ID_GBP = "anti-dyad_GBP"

# TO DO: consider where it makes the most sense structurally to put these
DO_NOT_STORE_CUSTOMER = "don't store"
CREATE_NEW_CUSTOMER = "create new customer"