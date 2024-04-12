module Admin
  class NotesController < NotesController
    before_action :is_login

    def is_login
      if session[:role] != "admin" && session[:user].present?
        redirect_to root_url
      end
    end
    
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