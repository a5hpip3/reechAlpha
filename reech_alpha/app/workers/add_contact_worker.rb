class AddContactWorker
  include ApplicationHelper
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(email, phone, user)
    UserMailer.send_invitation_email_for_new_contact(email, user).deliver if email
    if phone
      client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
      begin
        sms = client.account.sms.messages.create(
            from: TWILIO_CONFIG['from'],
            to: phone,
            body: "your friend #{user.first_name} #{user.last_name} needs to add you as a contact on Reech."
        )
      rescue Exception => e
        puts e.backtrace.join("\n")
     end
  end
end
