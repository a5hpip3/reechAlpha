class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  attr_accessor :access_token

  after_create :set_friendships

  def set_friendships
    graph = Koala::Facebook::API.new(self.access_token)
    friends = graph.get_connections("me", "friends")
    friends = User.where(id: (Authorization.where(provider: "facebook", uid: friends)).collect(&:id))
    friends.each do |friend|
      unless user.friends.collect(&:id).include? friend.id
        self.user.friendships.create(friend_reecher_id: friend.reecher_id, status: 'accepted')
        friend.friendships.create(friend_reecher_id: self.user.reecher_id, status: 'accepted')
      end
    end
  end

end
