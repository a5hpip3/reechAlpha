module Api
  module V2
    class QuestionsController < BaseController
    	before_filter :require_current_user
    	before_filter :set_create_params, only: [:create]
      after_filter :send_notifications, only: [:create]

      def index
        render "index.json.jbuilder"
      end


      def show
        # question = Question.find(params[:id])
        # render json: question.as_json(include: :solutions)
        render "show.json.jbuilder"
      end

      def star_question
        current_user.starred_questions << Question.find(params[:question_id]) unless Question.find(params[:question_id]).nil?
        render status: 201, json: "success"
      end
    	private
      def set_create_params
            if params.has_key?(:file)
                params[:question] = JSON.parse(params[:question])
                params[:question][:avatar] = params[:file]
            end
            if params[:question][:audien_details].blank? || (params[:question][:audien_details][:reecher_ids].blank? && params[:question][:audien_details][:emails].blank? && params[:question][:audien_details][:phone_numbers].blank? && params[:question][:audien_details][:groups].blank?)
                params[:question][:is_public] = true
            end

    	end

      def send_notifications
          if !params[:question][:audien_details].nil?
              QuestionsWorker.perform_async(action_name, params[:question]["audien_details"], current_user.id, entry.id, PUSH_TITLE_ASKHELP, "ASKHELP", "ASK")
          end
      end
    end
  end
end
