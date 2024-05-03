module Admin
  class NotesController < NotesController
    skip_before_action :is_mine , only: [:destroy]
    skip_before_action :is_shared , only: [:show, :edit, :update]
    before_action :validate_admin
   
    def index
      @browser = Browser.new(request.user_agent)
      @notes = Note.all
    end
    
    protected
    def after_note_create
      redirect_to admin_notes_path, notice: 'Note was successfully created.'
    end

    def after_note_update
      redirect_to admin_notes_path, notice: 'Note was successfully updated.'
    end

    def after_note_delete
      redirect_to admin_notes_path, notice: 'Note was successfully destroyed.'
    end
  end
end