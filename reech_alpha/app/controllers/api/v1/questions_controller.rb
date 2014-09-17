module Api
  module V1
    class QuestionsController < ApiController
    #http_basic_authenticate_with name: "admin", password "secret"
    require 'thread'
    before_filter :restrict_access , :except =>[:send_apns_notification,:send_gcm_notification]
    before_filter :set_create_params, only: [:create, :post_question_with_image]
    after_filter :send_notifications, only: [:create, :post_question_with_image]
    #doorkeeper_for :all
    respond_to :json

    def index
      @questions = Question.get_questions(params[:type], current_user)

      render "index.json.jbuilder"
    end

    def show
        question = Question.find(params[:id])
        solutions = Solution.filter(question, current_user)
        allsolutions = question.posted_solutions
        respond_with question, solutions, allsolutions
    end

    def mark_question_stared
      @question = Question.find_by_question_id(params[:question_id])
      if !@question.blank?
        @voting = Voting.where(user_id: current_user.id, question_id: @question.id).first
        @question.votings.create(user_id: current_user.id) if(params[:stared] == "true" && @voting.blank?)
        @voting.destroy if(params[:stared] == "false" && @voting.present?)
        msg = {:status => 200, :message => (params[:stared] == "true" ? "Successfully Stared" : "Successfully UnStared"),:is_login_user_starred_qst=> (params[:stared] == "true" ? true : false)}
      else
        msg = {:status => 404, :message => "Failed!",:is_login_user_starred_qst=>false}
      end      
      render :json => msg 
    end 

    def linked_questions
      sql_str = "select q.question_id as q_id, (select count(*)  from purchased_solutions  WHERE user_id = (select id from users where reecher_id=posted_by_uid)  AND solution_id IN (select id from solutions where question_id = q_id)) AS ops,  NULL as pqtfs from questions q WHERE q.question_id IN (select l.question_id from linked_questions l where l.user_id = \'#{current_user.reecher_id}\' AND l.linked_type='LINKED' ORDER BY l.id DESC)"
      @questions = ActiveRecord::Base.connection.execute(sql_str)
      render "index.json.jbuilder"
    end

    def link_questions_to_expert
      @question = Question.find_by_question_id(params[:question_id]) 
      puts "link_questions_to_expert==#{params.inspect}"
      if !@question.blank?
      # Outer if condition    
          if !params[:audien_details].nil?
            QuestionsWorker.perform_async(action_name, params[:audien_details], current_user.id, @question.id, PUSH_TITLE_LINKED, "LINKED", "LINKED")            
          end
      # end of outer  if loop
      end
      msg = { :status => 200, :message => "success"}
      render :json =>msg 
    end
  
    def post_question_with_image(options = {}, &block)   
      assign_attributes
      created = with_callbacks(:create, :save) { entry.save }
      respond_options = options.reverse_merge(success: created)
      if entry.errors.any?
        render json: {status: 403, message: entry.errors}
      else
        render json: {status: 200, controller_name => entry, message: (I18n.t "#{controller_name}.#{action_name}.message")}
      end
    end
    
  #  End for class, modules
    private

    def set_create_params
      old_params = params
      
      params[:question] = {
        post: old_params[:question], 
        posted_by_uid: current_user.reecher_id, 
        posted_by: current_user.full_name,
        ups: 0,
        downs: 0,
        Charisma: 5,
        category_id: old_params[:category_id],
      }

      if action_name == "post_question_with_image"
        if !old_params[:file].blank? 
          params[:question][:avatar] = params[:file]  
        end 
        params[:audien_details] = JSON.parse(params[:audien_details]) if !params[:audien_details].blank?

      else
        if !old_params[:attached_image].blank? 
          data = StringIO.new(Base64.decode64(old_params[:attached_image]))
          params[:question][:avatar] = data
        end
        params[:audien_details] = old_params[:audien_details]
      end

      if params[:audien_details].blank? || (params[:audien_details][:reecher_ids].blank? && params[:audien_details][:emails].blank? && params[:audien_details][:phone_numbers].blank?) 
        params[:question][:is_public] = true
      end
      
    end

    def send_notifications
      if !params[:audien_details].nil?
        QuestionsWorker.perform_async(action_name, params["audien_details"], current_user.id, entry.id, PUSH_TITLE_ASKHELP, "ASKHELP", "ASK")
      end
      post_quest_to_frnd = []
      if !post_quest_to_frnd.blank? 
        post_quest_to_frnd.each do|pqf|                 
          @pqtf= PostQuestionToFriend.find(pqf)                 
          @pqtf.update_attributes(:question_id=>entry.question_id) 
        end
      end
    end

    def send_gcm_notification
        destination = ["APA91bFbYwmetpiv96X1c52tV_sOpT9ZkAZlDyqk1AWKXvwe7bjVUJJ8QwsGB4kkHFt-JiIfIrGh7ScM6ZrTdBe5GCAXkwzncQ4ynAk9zcnVkP5OvYhwVriVcsdgrzfFqZsd4vu6CLoCGMerOP0BH1evR8YqtjcgkA"]#params[:device_token]
        message_options = {
        #optional parameters below.  Read the docs here: http://developer.android.com/guide/google/gcm/gcm.html#send-msg
          :collapse_key => "foobar",
          :data => { :score => "3x1" },
          :delay_while_idle => true,
          :time_to_live => 1,
          :registration_ids => destination
        }
        response = SpeedyGCM::API.send_notification(message_options)
        msg = { :status => 200, :code => response[:code],:data=>response[:data]}
        render :json =>msg 
    end
    
    end
  end
end
