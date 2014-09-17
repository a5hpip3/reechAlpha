module Api
  module V2
    class QuestionsController < BaseController
    	before_filter :require_current_user
    end
  end
end
