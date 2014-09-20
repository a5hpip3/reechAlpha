class UserSession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  single_access_allowed_request_types :any
  params_key :api_key
end
