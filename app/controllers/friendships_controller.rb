class FriendshipsController < ApplicationController
  before_action :not_enter, only: [:show, :edit, :update]
  before_action :validate_user
  
  def not_enter
    redirect_to friendships_path and return
  end

  def index
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
    @users = User.where.not(id: current_user.id)
    @friendship = Friendship.new
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
      redirect_to friendships_path, notice: 'Notification sent to your friend'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    
    if @friendship.destroy
      redirect_to friendships_path, notice: 'Friendship was successfully destroyed.'
    else
      redirect_to friendships_path, notice: 'Failed to destroy friendship.'
    end
  end

  private
    def friendship_params
      params.require(:friendship).permit(:friend_id, :status)
    end
end
