class UserProfileWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(user_id, pass_token)
    user = User.find(user_id)
    begin
      UserMailer.send_new_password_as_forgot_password(user, pass_token).deliver unless user.email.blank?
      client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
      sms = client.account.sms.messages.create(
        from: TWILIO_CONFIG['from'],
        to: user.phone_number,
        body: "Username= #{user.original_phone_number} and Temporary password= #{pass_token}"
      )
    rescue Exception => e
      puts e.backtrace.join("\n")
    end
  end
end
