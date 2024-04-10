module Admin
    class NotesController < NotesBaseController
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