class FriendshipsController < ApplicationController
  before_action :not_enter, only: [:show, :edit]
  before_action :validate_user
  
  def not_enter
    redirect_to friendships_path and return
  end

  def index
    @friendship_requests = current_user.received_friendships.pending.map do |f|
      { id: f.id, friend: f.user }
    end

    @pending_friendships = current_user.initiated_friendships.pending.map do |f|
      { id: f.id, friend: f.friend}
    end

    @friendships = current_user.initiated_friendships.accepted.map do |f| {
      id: f.id,
      friend_id: f.friend_id,
      friend: f.friend
    }
    end + current_user.received_friendships.accepted.map do |f| {
      id: f.id,
      friend_id: f.user_id,
      friend: f.user
    }
    end
    
  end
  
  def show
  end

  def new
    @friendship = Friendship.new
  
    pending_friend_ids = current_user.initiated_friendships.pending.pluck(:friend_id)
    accepted_friend_ids = current_user.initiated_friendships.accepted.pluck(:friend_id)
    received_pending_friend_ids = current_user.received_friendships.pending.pluck(:user_id)
    received_accepted_friend_ids = current_user.received_friendships.accepted.pluck(:user_id)
  
    excluded_user_ids = pending_friend_ids + accepted_friend_ids + received_pending_friend_ids + received_accepted_friend_ids
  
    @users = User.where.not(id: current_user.id).to_a
    @users = @users.reject { |user| excluded_user_ids.include?(user.id) }
    
  end  
  

  def create
    if params[:friend].blank?
      redirect_to new_friendship_path, alert: 'You must select a friend.' and return
    end

    @friend = User.find(params[:friend])
    @friendship = current_user.initiated_friendships.build(friend: @friend)

    if @friendship.save
      Notification.create(user: @friend, message: "#{current_user.name.capitalize} sent you a friend request.", notification_type: 'friend_request')
      after_friendship_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @friendship = Friendship.find(params[:id])
    if @friendship.status == 'pending'
      @friendship.update(status: 'accepted')
      Notification.where(user: @friendship.friend, notification_type: 'friend_request').destroy_all
      Notification.create(user: @friendship.user, message: "#{current_user.name.capitalize} has accepted your friendship request.", notification_type: 'friend_request')
      flash[:notice] = "Friendship accepted!"
    end
    after_friendship_edit
  end

  def destroy
    @friendship = Friendship.find(params[:id])

    pending = @friendship.status == 'pending'
    
    if @friendship.destroy 
      if pending
        Notification.where(user: @friendship.friend, notification_type: 'friend_request').destroy_all
      else 
        Notification.where(user: @friendship.friend, notification_type: 'friend_request').destroy_all
        Notification.create(user: @friendship.user, message: "#{current_user.name.capitalize} has deleted your request.", notification_type: 'friend_request')
      end
      after_friendship_delete
    else
      redirect_to friendships_path, notice: 'Failed to destroy friendship.'
    end
  end

  protected
    def after_friendship_create
      redirect_to friendships_path, notice: 'Friendship request has been sent.' and return
    end

    def after_friendship_edit
      redirect_to friendships_path, notice: 'Friendship has been accepted.' and return
    end

    def after_friendship_delete
      redirect_to friendships_path, notice: 'Friendship  was successfully destroy.' and return
    end
    
  private
    def friendship_params
      params.require(:friendship).permit(:friend_id, :status)
    end
end