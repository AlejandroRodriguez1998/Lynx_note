class CollectionsController < ApplicationController
  before_action :is_login
  before_action :is_mine , only: [:edit, :update, :destroy]

  def is_login
    if !session[:user].present?
      redirect_to root_url
    end
  end

  def is_mine
    if current_user.id.to_s != session[:user_id]["$oid"].to_s
      redirect_to root_url
    end
  end

  # GET /collections or /collections.json
  def index
    @collections = current_user.collections.map do |collection|
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
    @collection = Collection.new(collection_params)
    @collection.user = current_user

    if @collection.save
      after_collection_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /collections/id 
  def update
    @collection = Collection.find(params[:id])
    if @collection.update(collection_params)
      after_collection_update
    else
      @collection.reload
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /collections/id
  def destroy
      @collection = Collection.find(params[:id])
      @collection.destroy
      after_collection_delete
  end

  protected
    def after_collection_create
      redirect_to collections_path, notice: 'Collection was successfully created.' and return
    end

    def after_collection_update
      redirect_to collections_path, notice: "Collection was successfully updated." and return
    end

    def after_collection_delete
      redirect_to collections_path, notice: "Collection was successfully destroyed." and return 
    end

  private
    def collection_params
      params.require(:collection).permit(:name, :user, :notes)
    end
end