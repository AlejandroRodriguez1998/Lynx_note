class CollectionsController < ApplicationController
  before_action :validate_user
  before_action :is_mine , only: [:destroy]
  before_action :is_shared , only: [:show, :edit, :update]

  def is_mine
    @collection = Collection.find(params[:id])
    unless @collection.user_id == current_user.id
      redirect_to root_url
    end
  end

  def is_shared
    @collection = Collection.find(params[:id])
    @friend_sharing = @collection.sharings.any? && !(@collection.user_id == current_user.id)
    unless @collection.sharings.any? || @collection.user_id == current_user.id
      redirect_to root_url
    end
  end
  
  def index
    @collections = current_user.collections.map do |collection|
      notes = []
    
      collection.notes.each do |note_id|
        note = Note.find(note_id)
        if note.user_id == current_user.id
          notes << note
        end
      end
      collection.assign_attributes(notes: notes)
      collection.assign_attributes(sharing: {shared: collection.sharings.any?, id: collection.sharings.first&.id})
      
      collection #es como si fuese un return
    end.sort_by { |collection| -collection.notes.size } #para mostrar la que mas notas tiene primero

    @collections_shared = current_user.shared_collections.map do |collection|
      notes = []
    
      collection.notes.each do |note_id|
        note = Note.find(note_id)
        if note.user_id == current_user.id
          notes << note
        end
      end
      collection.assign_attributes(notes: notes)
  
      collection #es como si fuese un return
    end.sort_by { |collection| -collection.notes.size } #para mostrar la que mas notas tiene primero
  end

  def show
    if @friend_sharing
      @collection = Collection.find(params[:id])
    else
      redirect_to collections_path
    end
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
      if @friend_sharing
        redirect_to collection_path(@collection), notice: "Collection was successfully updated." and return
      else 
        redirect_to collections_path, notice: "Collection was successfully updated." and return
      end
    end

    def after_collection_delete
      redirect_to collections_path, notice: "Collection was successfully destroyed." and return 
    end

  private
    def collection_params
      params.require(:collection).permit(:name, :user, :notes)
    end
end