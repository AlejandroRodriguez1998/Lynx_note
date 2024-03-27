class NotesController < ApplicationController
  
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
    imagen_to_delete = params[:note][:images_to_delete]

    @note.title = note_params[:title]

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

      if !imagen_to_delete.blank?
        @note.content.reject! do |content_string|
          item = JSON.parse(content_string)
          item['type'] == 'file' && imagen_to_delete.include?(item['value'])
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
      render :edit, status: :unprocessable_entity 
    end
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    redirect_to notes_path, notice: 'Note was successfully destroyed.' 
  end

  private
    def note_params
      params.require(:note).permit(:title, content: [:type, :value])
    end

    def handle_uploaded_file(uploaded_file)
      if uploaded_file.blank?
        return ""
      else
        if uploaded_file.is_a?(String)
          return uploaded_file
        else
          # Genera un nombre de archivo único para evitar sobrescrituras
          file_name = SecureRandom.uuid + File.extname(uploaded_file.original_filename)
          
          # Construye la ruta completa donde se guardará el archivo
          file_path = Rails.root.join('public', 'uploads', file_name)
          
          # Mueve el archivo subido al directorio de destino
          File.open(file_path, 'wb') do |file|
            file.write(uploaded_file.read)
          end
          
          # Devuelve la URL al archivo subido
          # Esto asume que 'public' es servido directamente. Ajusta la ruta según tu configuración.
          return "/uploads/#{file_name}"
        end
      end
    end
end