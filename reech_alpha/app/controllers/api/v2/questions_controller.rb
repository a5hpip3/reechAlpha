module Api
  module V2
    class QuestionsController < BaseController
    	before_filter :require_current_user
    	before_filter :set_create_params, only: [:create]
        after_filter :send_notifications, only: [:create]

      def index
        questions = Question.send(params[:scope], current_user)
        questions = questions.where(category_id: params[:category_id]) if !params[:category_id].blank?
        #questions = questions.page(params[:page] ? params[:page].to_i : 1).per_page(params[:per_page] ? params[:per_page].to_i : 3)
        #logger.info "#{questions.inspect}"
        render json: [questions, 3]
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
          if !params[:question][:audien_details].nil?
              QuestionsWorker.perform_async(action_name, params[:question]["audien_details"], current_user.id, entry.id, PUSH_TITLE_ASKHELP, "ASKHELP", "ASK")
          end
      end
    end
  end
end
