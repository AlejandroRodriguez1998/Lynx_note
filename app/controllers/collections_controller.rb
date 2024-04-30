class CollectionsController < ApplicationController
  before_action :not_enter, only: [:show]
  before_action :validate_user
  before_action :is_mine , only: [:edit, :update, :destroy]

  def not_enter
    redirect_to collections_path and return
  end

  def is_mine
    @collection = Collection.find(params[:id])
    unless @collection.user_id == current_user.id
      redirect_to root_url
    end
  end
  
  def index
    @collections = current_user.collections.map do |collection|
      notes = []
    
      collection.notes.each do |note_id|
        note = Note.find(note_id)
        notes << note
      end
      collection.assign_attributes(notes: notes)
      
      collection #es como si fuese un return
    end.sort_by { |collection| -collection.notes.size } #para mostrar la que mas notas tiene primero
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user

    if @collection.save
      after_collection_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    @collection = Collection.find(params[:id])
    if @collection.update(collection_params)
      after_collection_update
    else
      @collection.reload
      render :edit, status: :unprocessable_entity
    end
  end

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