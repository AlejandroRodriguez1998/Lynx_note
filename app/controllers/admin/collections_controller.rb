module Admin
  class CollectionsController < CollectionsController
    before_action :is_login

    def is_login
      if session[:role] != "admin" && session[:user].present?
        redirect_to root_url
      end
    end

    def index
      @collections = Collection.all.map do |collection|
        notes = []
      
        collection.notes.each do |note_id|
          note = Note.find(note_id)
          notes << note
        end
        collection.assign_attributes(notes: notes)
        
        collection #es como si fuese un return
      end
    end

    protected
    def after_collection_create
      redirect_to admin_collections_path, notice: 'Collection was successfully created.' and return
    end

    def after_collection_update
      redirect_to admin_collections_path, notice: "Collection was successfully updated." and return
    end

    def after_collection_delete
      redirect_to admin_collections_path, notice: "Collection was successfully destroyed." and return 
    end
  end
end
