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
          redirect_to @note, notice: 'Note was successfully created.'
        else
          render :new
        end
    end

    private
        def note_params
            params.require(:note).permit(:text, :list, images: [])
        end
end
