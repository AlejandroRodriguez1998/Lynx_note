class NotesController < ApplicationController
  before_action :is_login

  def is_login
    if !session[:user].present?
      redirect_to root_url
    end
  end

  def index
    @browser = Browser.new(request.user_agent)
    @notes = Note.all
  end

  def show
    @note = Note.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { render json: @note }
    end
  end

  def new
      @note = Note.new
  end

  def create
    @note = Note.new(title: note_params[:title])
  
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
      if browser.device.mobile?
        redirect_to @note, notice: 'Note was successfully created.' and return
      else
        redirect_to notes_path(number: @note.id), notice: 'Note was successfully created.'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
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
      if browser.device.mobile?
        redirect_to @note, notice: 'Note was successfully updated.' and return
      else
        redirect_to notes_path(number: @note.id), notice: 'Note was successfully updated.'
      end
    else
      @note.reload
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note = Note.find(params[:id])

    @note.content.each do |content_string|
      content_item = JSON.parse(content_string)
      
      if content_item['type'] == 'file'
        deleteImage(content_item['value'])
      end
    end

    @note.destroy
    redirect_to notes_path, notice: 'Note was successfully destroyed.' 
  end

  private
    def note_params
      params.require(:note).permit(
        :title, 
        content: [:type,{value: []},:value],
        images_to_update: [:index,:value],
        images_to_delete: []
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
end