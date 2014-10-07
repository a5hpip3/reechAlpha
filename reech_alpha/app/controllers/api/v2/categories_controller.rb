module Api
  module V2
    class CategoriesController < BaseController
      before_filter :require_current_user
      
      def index
        render "index.json.jbuilder"
      end
    end
  end
end
