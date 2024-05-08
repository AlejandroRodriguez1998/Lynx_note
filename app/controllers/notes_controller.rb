class NotesController < ApplicationController
  before_action :validate_user
  before_action :is_mine , only: [:destroy]
  before_action :is_shared , only: [:show, :edit, :update]

  def is_mine
    @note = Note.find(params[:id])
    unless @note.user_id == current_user.id
      redirect_to root_url
    end
  end

  def is_shared
    @note = Note.find(params[:id])
    sharing = Sharing.where(shareable_id: @note.id).first
    @friend_sharing = @note.sharings.any? && sharing&.shared_with&.include?(current_user.id.to_s)

    unless @note.user_id == current_user.id || sharing&.shared_with&.include?(current_user.id.to_s)
      redirect_to root_url
    end
  end
    
  def index
    @browser = Browser.new(request.user_agent)
    @notes = current_user.notes
  end
6
  def show
    @note = Note.find(params[:id])
    @shared = @note.sharings.any?
    @shared_id = @note.sharings.first&.id
    
    respond_to do |format|
      format.html
      format.json { render json: {
        note: @note,
        shared: @shared,
        shared_id: @shared_id
       } }
    end
  end

  def new
    @collections = get_collections_and_shared
    @collection_found = []
    @note = Note.new
  end

  def create
      @note = Note.new(title: note_params[:title])
      service = CollectionsNotesService.new(@note)
      @note.user = current_user
  
      if !params[:note][:content].blank?
        processed_content = params[:note][:content].map do |content_item|  
          case content_item[:type]
            when 'list'
              if !content_item[:value] == "" || !content_item[:value].all?(&:blank?)
                { type: 'list', value: content_item[:value].reject(&:blank?).join(';') }
              end
            when 'file'
              if !content_item[:value].blank?
                { type: 'file', value: handle_uploaded_file(content_item[:value]) }
              end
            when 'text'
              if !content_item[:value].blank?
                content_item       
              end 
          end
        end.compact
          
        @note.content = processed_content.map { |content_item| content_item.to_json }
      end

      if @note.save
        service.add_collections(note_params[:collection_ids])
        after_note_create
      else
        @collection_found = []
        @collections = get_collections_and_shared
        render :new, status: :unprocessable_entity
      end
  end

  def edit
    @note = Note.find(params[:id])

    @collections = get_collections_and_shared
    service = CollectionsNotesService.new(@note)
    @collection_found = service.get_collections(@collections)
  end
  
  def update
    @note = Note.find(params[:id])
    image_to_delete = params[:note][:images_to_delete]
    service = CollectionsNotesService.new(@note)
    browser = Browser.new(request.user_agent)
    image_to_update = {}

    @note.title = note_params[:title]

    if !params[:note][:content].blank?
      unless params[:note][:images_to_update].blank?
        image_to_update = params[:note][:images_to_update].each_with_object({}) do |image, hash|
          index = image[:index].to_i # Convertimos el index a int
          hash[index] = image[:value] # Asignamos el valor al index, es decir: {index => 'valor'}
        end
      end 

      processed_content = params[:note][:content].each_with_index.map do |content_item, index|
        case content_item[:type]
          when 'list'
            if !content_item[:value] == "" || !content_item[:value].all?(&:blank?)
              { type: 'list', value: content_item[:value].reject(&:blank?).join(';') }
            end
          when 'file'
            if !content_item[:value].blank?
              image = image_to_update[index]

              if !image.blank?
                { type: 'file', value: handle_uploaded_file(image) }
              else
                { type: 'file', value: handle_uploaded_file(content_item[:value]) }
              end
            end
          when 'text'
            if !content_item[:value].blank?
              content_item       
            end 
          end
      end.compact
  
      @note.content = processed_content.map { |content_item| content_item.to_json }

      if !image_to_delete.blank?
        @note.content.reject! do |content_string|
          item = JSON.parse(content_string)
          if item['type'] == 'file' && image_to_delete.include?(item['value'])
            deleteImage(item['value'])
            true 
          else
            false
          end
        end
      end
    end

    if @note.save
      service.update_collections(note_params[:collection_ids])
      after_note_update
    else
      @note.reload

      @collections = get_collections_and_shared
      service = CollectionsNotesService.new(@note)
      @collection_found = service.get_collections(@collections)

      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note = Note.find(params[:id])
      
    service = CollectionsNotesService.new(@note)
    service.delete_collections
  
    unless @note.content.blank?
      @note.content.each do |content_string|
        content_item = JSON.parse(content_string)
        
        if content_item['type'] == 'file'
          deleteImage(content_item['value'])
        end
      end
    end

    @note.destroy
    after_note_delete
  end

  protected
    def after_note_create
      if browser.device.mobile?
        redirect_to @note, notice: 'Note was successfully created.' and return
      else
        redirect_to notes_path(number: @note.id), notice: 'Note was successfully created.'
      end
    end

    def after_note_update
      if @friend_sharing
        redirect_to @note, notice: 'Note was successfully updated.' and return
      else
        if browser.device.mobile?
          redirect_to @note, notice: 'Note was successfully updated.' and return
        else
          redirect_to notes_path(number: @note.id), notice: 'Note was successfully updated.'
        end
      end
    end

    def after_note_delete
      redirect_to notes_path, notice: 'Note was successfully destroyed.' 
    end

  private
    def note_params
      params.require(:note).permit(
        :title,
        :user,
        content: [:type,{value: []},:value],
        images_to_update: [:index,:value],
        images_to_delete: [],
        collection_ids: []
      )
    end

    def deleteImage(image_path)
      file_path = Rails.root.join('public', 'uploads', image_path.split('/').last) 
      File.delete(file_path) if File.exist?(file_path)
    end

    def handle_uploaded_file(uploaded_file)
      if uploaded_file.blank?
        return ""
      else     
          if uploaded_file.is_a?(String)
            return uploaded_file
          else
            file_name = SecureRandom.uuid + File.extname(uploaded_file.original_filename)
            file_path = Rails.root.join('public', 'uploads', file_name)

            File.open(file_path, 'wb') do |file|
              file.write(uploaded_file.read)
            end

            return "/uploads/#{file_name}"
          end
      end
    end

    def get_collections_and_shared
      collections = current_user.collections
      Rails.logger.debug "Collections: #{collections}"
      collection_shared = current_user.shared_collections
      Rails.logger.debug "Collections Shared: #{collection_shared}"
      collections_and_shared = (collections + collection_shared).uniq
      Rails.logger.debug "Collections and Shared: #{collections_and_shared}"
      return collections_and_shared
    end
end