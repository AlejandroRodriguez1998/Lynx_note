class CollectionsController < ApplicationController

  # GET /collections or /collections.json
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

  # GET /collections/id
  def show
    @collection = Collection.find(params[:id])
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/id/edit
  def edit
    @collection = Collection.find(params[:id])
  end

  # POST /collections
  def create
    @collection = Collection.new(collection_params.merge(user: session[:user_id]))

    if @collection.save
      redirect_to collections_url, notice: 'Collection was successfully created.' and return
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/id 
  def update
    @collection = Collection.find(params[:id])
    if @collection.update(collection_params)
      redirect_to collections_url, notice: "Collection was successfully updated." and return
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /collections/id
  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
    redirect_to collections_path, notice: "Collection was successfully destroyed."
  end

  private
  def collection_params
    params.require(:collection).permit(:name, :user, :notes)
  end

end
