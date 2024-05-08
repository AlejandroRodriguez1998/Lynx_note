module Admin
  class FriendshipsController < FriendshipsController
    skip_before_action :not_enter, only: [:show]
    before_action :validate_admin
    
    def index
      friendship = Friendship.all

      @friendships = friendship.map do |f| 
        {
          id: f.id,
          status: f.status,
          user: User.find(f.user_id),
          friend: User.find(f.friend_id)
        }
      end

    end

    def show
      friendship = Friendship.find(params[:id])
      @friendship = {
          id: friendship.id,
          status: friendship.status,
          user: User.find(friendship.user_id),
          friend: User.find(friendship.friend_id)
      }
    end

    def new 
      fill_in
    end

    def create
      if params[:friend].blank?
        fill_in
        flash.now[:alert] = "Friends can't be blank"
        render :new, status: :unprocessable_entity and return
      end
  
      @friend = User.find(params[:friend])
      @friend_one = User.find(params[:friend_one])

      if @friend_one == @friend
        fill_in
        flash.now[:alert] = "You can't add yourself as a friend."
        render :new, status: :unprocessable_entity and return
      end
  
      initiated_friendship = @friend_one.initiated_friendships.where(friend_id: @friend.id).first
      received_friendship = @friend.initiated_friendships.where(friend_id: @friend_one.id).first
    
      if initiated_friendship || received_friendship
        fill_in
        flash.now[:alert] = "Friendship already exists."
        render :new, status: :unprocessable_entity and return
      end
  
      @friendship = Friendship.new(user_id: @friend_one, friend_id: @friend, status: 'accepted')
  
      if @friendship.save
        after_friendship_create
      else
        fill_in
        render :new, status: :unprocessable_entity
      end
    end

    protected
      def after_friendship_create
        redirect_to admin_friendships_path, notice: 'Friendship was successfully created.' and return
      end
      
      def after_friendship_edit
        redirect_to admin_friendships_path, notice: 'Friendship was successfully updated.' and return
      end

      def after_friendship_delete(friendship)
        redirect_to admin_friendships_path, notice: 'Friendship  was successfully destroy.' and return
      end

    private
      def fill_in
        @friendship = Friendship.new
        @users = User.all
        @is_admin = true
      end
  end
end