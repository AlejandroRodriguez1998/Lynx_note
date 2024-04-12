class NotesController < ApplicationController
  before_action :is_login
  before_action :is_mine , only: [:edit, :update, :destroy]

  def is_login
    if !session[:user].present?
      redirect_to root_url
    end
  end

  def is_mine
    if current_user.id.to_s != session[:user_id]["$oid"].to_s
      redirect_to root_url
    end
  end
    

  def index
    @browser = Browser.new(request.user_agent)
    @notes = current_user.notes
  end

  def show
    @note = Note.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { render json: @note }
    end
  end

  def new
    @collections = current_user.collections
    @collection_found = []
    @note = Note.new
  end

  def create
      @note = Note.new(title: note_params[:title])
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
        add_collections(@note.id)
        after_note_create
      else
        @collection_found = []
        @collections = current_user.collections
        render :new, status: :unprocessable_entity
      end
  end

  def edit
    @collections = current_user.collections
    @collection_found = get_collection(params[:id].to_s)
    @note = Note.find(params[:id])
  end
  
  def update
    @note = Note.find(params[:id])
    browser = Browser.new(request.user_agent)
    image_to_delete = params[:note][:images_to_delete]
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
      update_collections(@note.id)
      after_note_update
    else
      @collections = current_user.collections
      @collection_found = get_collection(params[:id].to_s)
      @note.reload
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note = Note.find(params[:id])

    delete_collections(@note.id)

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
      if browser.device.mobile?
        redirect_to @note, notice: 'Note was successfully updated.' and return
      else
        redirect_to notes_path(number: @note.id), notice: 'Note was successfully updated.'
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

    def get_collection(note_id)
      collection_found = @collections.select do |collection|
        collection.notes.map(&:to_s).include?(note_id)
      end.map(&:id).map(&:to_s)

      return collection_found
    end

    def add_collections(note)
      if !note_params[:collection_ids].blank?
        note_params[:collection_ids].each do |collection_id|
          collection = Collection.find(collection_id)
          collection.notes.push(note)
          collection.save
        end
      end
    end

    def update_collections(note)
      #Obtengo las marcadas
      desired_collection_ids = note_params[:collection_ids] ? note_params[:collection_ids].map { |id| BSON::ObjectId.from_string(id) } : []
      
      # Encuentra todas las colecciones que contienen la nota
      current_collections = Collection.where(:notes.in => [note])

      # Eliminar la nota de las colecciones que ya no están seleccionadas
      current_collections.each do |collection|
        unless desired_collection_ids.include?(collection.id)
          collection.notes.delete(note)
          collection.save
        end
      end

      # Añadir la nota a las colecciones seleccionadas
      desired_collection_ids.each do |collection_id|
        collection = Collection.find(collection_id)
        unless collection.notes.include?(note)
          collection.notes.push(note)
          collection.save
        end
      end
    end

    def delete_collections(note)
      current_collections = Collection.where(:notes.in => [note])

      current_collections.each do |collection|
        collection.notes.delete(note)
        collection.save
      end
    end
end