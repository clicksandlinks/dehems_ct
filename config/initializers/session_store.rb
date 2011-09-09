# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_EcoServe_v1.0_session',
  :secret      => 'ff158a1ad3340dad4540da4a54759d4bdc2e50f5b4d6f3ce2ca4bf194d5ad7ebf98726fd76ccd319649f41c4161a81acbe9273a51034cb7d2148e61e66d85f68'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
