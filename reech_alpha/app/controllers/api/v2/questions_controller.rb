module Api
  module V2
    class QuestionsController < BaseController
    	before_filter :require_current_user
    	before_filter :set_create_params, only: [:create]

      def show
        question = Question.find(params[:id])
        render json: question.as_json(include: :solutions)
      end

    	private

    	def set_create_params
    		params[:question][:posted_by_uid] = current_user.reecher_id
    		params[:question][:posted_by] = current_user.full_name
    		params[:question][:ups] = 0
    		params[:question][:downs] = 0
    		params[:question][:Charisma] = 5
    		params[:question][:is_public] = true
    		params[:question][:avatar] = StringIO.new(Base64.decode64(params[:question][:avatar]))
    	end
    end
  end
end
