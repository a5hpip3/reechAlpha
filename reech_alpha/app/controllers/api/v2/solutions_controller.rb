module Api
  module V2
    class SolutionsController < BaseController
    	before_filter :require_current_user
    end
  end
end
