class FriendshipsController < ApplicationController
  before_action :not_enter, only: [:show, :edit]
  before_action :validate_user
  
  def not_enter
    redirect_to friendships_path and return
  end

  def index
    received_pending_friendships = current_user.received_friendships.pending.map do |f|
      {
        id: f.id,
        friend_id: f.user_id,
        friend: f.user,
        status: f.status
      }
    end
    @friendship_requests = received_pending_friendships

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

    initiated_friendship = current_user.initiated_friendships.where(friend_id: @friend.id).first
    received_friendship = @friend.initiated_friendships.where(friend_id: current_user.id).first
  
    if initiated_friendship || received_friendship
      redirect_to friendships_path, alert: 'La amistad ya existe.'
      return
    end

    @friendship = current_user.initiated_friendships.build(friend: @friend)

    if @friendship.save
      after_friendship_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    friendship = Friendship.find(params[:id])
    if friendship.status == 'pending'
      friendship.update(status: 'accepted')
      flash[:notice] = "Friendship accepted!"
    end
    after_friendship_edit
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    
    if @friendship.destroy
      after_friendship_delete
    else
      redirect_to friendships_path, notice: 'Failed to destroy friendship.'
    end
  end

  protected
    def after_friendship_create
      redirect_to friendships_path, notice: 'Friendship was successfully created.' and return
    end
    def after_friendship_edit
      redirect_to friendships_path, notice: 'Friendship was successfully updated.' and return
    end
    def after_friendship_delete
      redirect_to friendships_path, notice: 'Friendship  was successfully destroy.' and return
    end
  private
    def friendship_params
      params.require(:friendship).permit(:friend_id, :status)
    end
end
