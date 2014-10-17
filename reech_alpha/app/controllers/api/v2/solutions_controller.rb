module Api
  module V2
    class SolutionsController < BaseController
    	before_filter :require_current_user
      before_filter :set_create_params, only: [:create]
    	after_filter :send_notification, only: [:create]

    	def preview_solution
        preview_solution = PreviewSolution.new(user_id: current_user.id, solution_id: params[:solution_id])
        if preview_solution.save
          render status: 201, json: "success"
        else
          render status: 406, json: "Solution  Previewed already!" 
        end
      end
      def purchase_solution
        if PurchasedSolution.where(user_id: current_user.id, solution_id: params[:solution_id]).exists?
          render status: 406, json: "Solution Purchased already!" 
        elsif current_user.points > 24
          purchased_solution = PurchasedSolution.new(user_id: current_user.id, solution_id: params[:solution_id])
          if purchased_solution.save
            current_user.subtract_points(25)
            make_friendship_standard(current_user.reecher_id, Solution.find(params[:solution_id]).solver_id)
            Notification.create(from_user: current_user.reecher_id, to_user: purchased_solution.solution.wrote_by.reecher_id, message: "#{current_user.full_name}" + PUSH_TITLE_GRABSOLS, notification_type: "GRABSOL", record_id: purchased_solution.solution.question.id)
            render status: 200, json: "success" 
          end          
        else
          render status: 406, json: "You Don't have sufficient curios!"
        end        
      end

      def solution_hi5
        solution = Solution.find(params[:solution_id])
        solution.liked_by(current_user)        
        solution.disliked_by(current_user) unless solution.vote_registered?
        Notification.create(from_user: current_user.reecher_id, to_user: solution.wrote_by.reecher_id, message: "#{current_user.full_name}" + PUSH_TITLE_HGHFV, notification_type: "HI5", record_id: solution.question.id) if solution.vote_registered?
        render status: 200, json: {hi5_count: solution.count_votes_up}
      end
     private
      def set_create_params
        if params.has_key?(:picture)
            params[:solution] = JSON.parse(params[:solution])
            params[:solution][:picture] = params[:picture]
        end
      end

     def send_notification
      Notification.create(from_user: entry.wrote_by.reecher_id, to_user: entry.question.posted_by_uid, message: "#{current_user.full_name}" + PUSH_TITLE_PRSLN, notification_type: "SOLUTION", record_id: entry.question.id)
    end

  end
end
end
