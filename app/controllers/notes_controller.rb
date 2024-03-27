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
            { type: 'list', value: content_item[:value].reject(&:blank?).join(';') }
          when 'file'
            { type: 'file', value: handle_uploaded_file(content_item[:value]) }
          else
            content_item
        end
      end
      
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

    text = params[:note][:text]
    list_items = params[:note][:list].reject { |item| item.blank? } 
    images = params[:note][:images].reject(&:blank?) 
    # reject(&:blank?) Filtra cualquier cadena vacía que pueda estar en el array, ya que por defecto
    # images devuelve aunque no hayas metido una imagen [""] y eso no lo queremos.
    imagen_to_delete = params[:note][:images_to_delete]

    # Identifica directamente las imágenes a eliminar.
    if imagen_to_delete.present?
      images_to_delete_ids = imagen_to_delete.reject(&:blank?)
 
      # Si no se proporciona texto, lista o imágenes, y se eliminan todas las imágenes, se debe mostrar un error.
      if text.blank? && list_items.blank? && images.blank? && @note.images.count == images_to_delete_ids.count
        @note.errors.add(:base, "You cannot delete all photos without adding either a text, a list or another image.")
        render :edit, status: :unprocessable_entity and return
      else
        # Elimina las imágenes seleccionadas.
        @note.images.where(id: images_to_delete_ids).each(&:purge) 
      end
    else 
      # Si no se ha seleccionado porque no hay imagenes para eliminar o no quiere el usuario y los campos estan vacios.
      if text.blank? && list_items.blank? && images.blank? && @note.images.count == 0
        @note.errors.add(:base, "You must provide at least one text, a list or an image.")
        render :edit, status: :unprocessable_entity and return
      end
    end

    # Si ha pasado el filtrado y la eliminación, actualiza el resto de los campos.
    if @note.update(note_params.except(:images, :list))
      @note.list = list_items
      @note.save
      @note.images.attach(params[:note][:images]) if params[:note][:images].present?
    
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