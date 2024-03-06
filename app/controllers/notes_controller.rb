class NotesController < ApplicationController
  
  def index
      @notes = Note.all
    end

  def show
    @note = Note.find(params[:id])
    respond_to do |format|
      format.json {
        images_urls = @note.images.map { |image| url_for(image) }
        render json: @note.as_json.merge({ image: images_urls })
      }
    end
  end

  def new
      @note = Note.new
  end

  def create
      @note = Note.new(note_params)
      if @note.save
        redirect_to notes_path, notice: 'Note was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
  end

  def edit
    @note = Note.find(params[:id])
  end
  
  def update
    @note = Note.find(params[:id])
    
    # Procesa la eliminación de las imágenes seleccionadas antes de actualizar la nota.
    if params[:note][:images_to_delete].present?
      params[:note][:images_to_delete].reject(&:blank?).each do |image_id|
        image = @note.images.find(image_id)
        image.purge
      end
    end
    
    if @note.update(note_params.except(:images_to_delete, :images))
      @note.images.attach(params[:note][:images]) if params[:note][:images].present?
      redirect_to notes_path, notice: 'Note was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    redirect_to notes_url, notice: 'Note was successfully destroyed.'
  end

  private

    def note_params
      params.require(:note).permit(:text, :list, images: [], images_to_delete: [])
    end
end