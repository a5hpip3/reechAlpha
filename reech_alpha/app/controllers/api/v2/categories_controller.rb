module Api
  module V2
    class CategoriesController < BaseController
      def index
        render "index.json.jbuilder"
      end
    end
  end
end
