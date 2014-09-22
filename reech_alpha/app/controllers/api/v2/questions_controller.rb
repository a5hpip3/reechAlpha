module Api
  module V2
    class QuestionsController < BaseController
    	before_filter :require_current_user
    	before_filter :set_create_params, only: [:create]
        after_filter :send_notifications, only: [:create]

      def index
        questions = Question.page(params[:page] ? params[:page] : 1).per(params[:per_page] ? params[:per_page] : 3)        
        render json: [questions, Question.count]
      end


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
            if params[:question][:audien_details].blank? || (params[:question][:audien_details][:reecher_ids].blank? && params[:question][:audien_details][:emails].blank? && params[:question][:audien_details][:phone_numbers].blank? && params[:question][:audien_details][:groups].blank?)
                params[:question][:is_public] = true
            end

    	end

        def send_notifications
            puts "@@@@@@@@@@@@@@@@@@@"
            puts "entered notifications"
            if !params[:question][:audien_details].nil?
                puts "enter worker"
                QuestionsWorker.perform_async(action_name, params[:question]["audien_details"], current_user.id, entry.id, PUSH_TITLE_ASKHELP, "ASKHELP", "ASK")
                puts "done worker"
            end
        end
    end
  end
end
