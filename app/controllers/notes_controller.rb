class NotesController < NotesBaseController
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
end