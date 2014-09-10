class UserSettings < ActiveRecord::Base
  attr_accessible :emailnotif_is_enabled, :location_is_enabled, :notify_linked_to_question, :notify_question_when_answered, :notify_solution_got_highfive, :pushnotif_is_enabled

  belongs_to :user,:primary_key=>:reecher_id,:foreign_key=>:reecher_id

  before_create :set_values

  def set_values
    self.location_is_enabled = true
    self.pushnotif_is_enabled = true
    self.emailnotif_is_enabled = true
    self.notify_question_when_answered = true
    self.notify_linked_to_question = true
    self.notify_solution_got_highfive = true
    self.notify_audience_if_ask_for_help = true
    self.notify_when_someone_grab_my_answer = true
    self.notify_when_my_stared_question_get_answer = true
  end


end
