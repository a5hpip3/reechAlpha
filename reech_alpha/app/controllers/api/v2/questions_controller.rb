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
            if action_name == "post_question_with_image"
                params[:question] = JSON.parse(params[:question])
                params[:question][:avatar] = params[:questions_avatar]
            end
            puts "@@@@@@@@@@@@@@@@"
            puts params[:question]
    		if params[:question][:audien_details].blank? || (params[:question][:audien_details][:reecher_ids].blank? && params[:question][:audien_details][:emails].blank? && params[:question][:audien_details][:phone_numbers].blank? && params[:question][:audien_details][:groups].blank?) 
                params[:question][:is_public] = true
            end
    		
    	end
    end
  end
end
