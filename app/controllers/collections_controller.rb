class CollectionsController < CollectionsBaseController
  protected
  def after_collection_create
    redirect_to collections_url, notice: 'Collection was successfully created.' and return
  end

  def after_collection_update
    redirect_to collections_url, notice: "Collection was successfully updated." and return
  end

  def after_collection_delete
    redirect_to collections_path, notice: "Collection was successfully destroyed." and return 
  end
end
