module Api
  module V2
    class SolutionsController < BaseController
    	before_filter :require_current_user
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
        purchased_solution = PurchasedSolution.new(user_id: current_user.id, solution_id: params[:solution_id])
        if purchased_solution.save
          render status: 201, json: "success"
        else
         render status: 406, json: "Solution Purchased already!" 
        end   
      end
      def solution_hi5
        solution = Solution.find(params[:solution_id])
        solution.liked_by(current_user)        
        solution.disliked_by(current_user) unless solution.vote_registered?
        render status: 200, json: {hi5_count: solution.count_votes_up}
      end
     private

     def send_notification
      Notification.create(from_user: current_user.reecher_id, to_user: entry.question.posted_by_uid, message: "You got a solution for your question.", notification_type: "SOLUTION", record_id: entry.question.id)
    end

  end
end
end
