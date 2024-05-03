class SharingController < ApplicationController
    before_action :validate_user
    before_action :browser_check, only: [:create, :update, :destroy]

    def browser_check
        @browser = Browser.new(request.user_agent)
    end

    def new
        @sharing = Sharing.new
        @object = params[:object].sub("object=", "")
        @friendships = current_user.initiated_friendships.accepted.map do |f| 
          { id: f.id, friend: f.friend }
        end + current_user.received_friendships.accepted.map do |f| 
          { id: f.id, friend: f.user }
        end

        respond_to do |format|
            format.html { render layout: false } 
        end
    end

    def create
        @sharing = Sharing.new
        @sharing.owner = current_user

        note = Note.where(id: params[:shareable_id]).first
        collection = Collection.where(id: params[:shareable_id]).first

        if note
            @sharing.shareable = note
        elsif collection
            @sharing.shareable = collection
        end
        if params[:sharing].present? && params[:sharing][:shared_with].present?
            @sharing.shared_with = params[:sharing][:shared_with]
        else
            if note
                if browser.device.mobile?
                    redirect_to note, alert: 'Please select a friend to share the note.' and return
                else
                    redirect_to notes_path(number: note._id), alert: 'Please select a friend to share the note.' and return
                end
            elsif collection
                redirect_to collections_path, alert: 'Please select a friend to share the collection.' and return
            end
        end
        if @sharing.save
            if note
                messageContent = "The user #{current_user.name.capitalize} has shared a note with you"
                type = "note_request"

                if browser.device.mobile?
                    redirect_to note, notice: 'The note has been shared.' and return
                else
                    redirect_to notes_path(number: note._id), notice: 'The note has been shared.'
                end
            elsif collection
                messageContent = "The user #{current_user.name.capitalize} has shared a collection with you"
                type = "collection_request"

                redirect_to collections_path, notice: 'The collection has been shared.'
            end

            @sharing.shared_with.each do |friend_id|
                user = User.find(friend_id)
                Notification.create(user: user.id, message: messageContent, notification_type: type)
            end
        else 
            Rails.logger.debug "Sharing not saved"
        end
    end

    def edit
        @sharing = Sharing.find(params[:id])
        @friendships = current_user.initiated_friendships.accepted.map do |f| 
            { id: f.id, friend: f.friend }
        end + current_user.received_friendships.accepted.map do |f| 
            { id: f.id, friend: f.user }
        end
        @friendship_shared = @sharing.shared_with

        respond_to do |format|
            format.html { render layout: false } 
        end
    end 

    def update
        @sharing = Sharing.find(params[:id])
        if params[:sharing].present? && params[:sharing][:shared_with].present?
            friends_ids = params[:sharing][:shared_with]
        else
            if @sharing.shareable_type == 'Note'
                if browser.device.mobile?
                    redirect_to "/note/#{@sharing.shareable._id}", alert: 'You cannot remove all friends from the note.' and return
                else
                    redirect_to notes_path(number: @sharing.shareable._id), alert: 'You cannot remove all friends from the note.' and return
                end
            elsif @sharing.shareable_type == 'Collection'
                redirect_to collections_path, alert: 'You cannot remove all friends from the collection.' and return
            end
        end

        current_shared_friend_ids = @sharing.shared_with
        new_friend_ids = friends_ids

        removed_friend_ids = current_shared_friend_ids - new_friend_ids
        removed_friend_ids.each do |id|

            if @sharing.shareable_type == 'Note'
                messageContent = "The user #{current_user.name.capitalize} has deleted a note with you"
                type = "note_request"
            elsif @sharing.shareable_type == 'Collection'
                messageContent = "The user #{current_user.name.capitalize} has deleted a collection with you"
                type = "collection_request"
            end

            user = User.find(id)
            Notification.create(user: user.id, message: messageContent, notification_type: type)

            @sharing.shared_with.delete(id)
        end

        added_friend_ids = new_friend_ids - current_shared_friend_ids
        added_friend_ids.each do |id|
            @sharing.shared_with << id
        end
        
        if @sharing.save
            if @sharing.shareable_type == 'Note'
                messageContent = "The user #{current_user.name.capitalize} has shared a note with you"
                type = "note_request"

                if browser.device.mobile?
                    redirect_to "/note/#{@sharing.shareable._id}", notice: 'The note has been shared.' and return
                else
                    redirect_to notes_path(number: @sharing.shareable._id), notice: 'The note has been shared.'
                end
            elsif @sharing.shareable_type == 'Collection'
                messageContent = "The user #{current_user.name.capitalize} has shared a collection with you"
                type = "collection_request"

                redirect_to collections_path, notice: 'The collection has been shared.'
            end

            added_friend_ids.each do |friend_id|
                user = User.find(friend_id)
                Notification.create(user: user.id, message: messageContent, notification_type: type)
            end
        else
            Rails.logger.debug "Sharing not saved"
        end
    end
    
    def destroy
        @sharing = Sharing.find(params[:id])
        @sharing.destroy

        if @sharing.shareable_type == 'Note'
            messageContent = "The user #{current_user.name.capitalize} has deleted a note with you"
            type = "note_request"

            redirect_to notes_path, notice: 'The note has been unshared'
        elsif @sharing.shareable_type == 'Collection'
            messageContent = "The user #{current_user.name.capitalize} has deleted a collection with you"
            type = "collection_request"

            redirect_to collections_path, notice: 'The collection has been unshared'
        end

        @sharing.shared_with.each do |friend_id|
            user = User.find(friend_id)
            Notification.create(user: user.id, message: messageContent, notification_type: type)
        end
    end

    private
    def sharing_params
        params.require(:sharing).permit(:shareable_id, :owner, shared_with: [])
    end

end