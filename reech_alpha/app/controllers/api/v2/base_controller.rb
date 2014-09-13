module Api
  module V2
    class BaseController < CrudController

      def current_user
        User.find 11
      end

    end
  end
end
