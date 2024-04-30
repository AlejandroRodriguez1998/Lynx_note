class CollectionsNotesService
  def initialize(note)
    @note = note
  end

  def get_collections(collections)
    collection_found = collections.select do |collection|
        collection.notes.map(&:to_s).include?(@note.id.to_s)
      end.map(&:id).map(&:to_s)

      return collection_found
  end

  def add_collections(collection_ids)
    if !collection_ids.blank?
        collection_ids.each do |collection_id|
          collection = Collection.find(collection_id)
          collection.notes.push(@note.id)
          collection.save
        end
    end
  end

  def update_collections(desired_collection)
    #Obtengo las marcadas y las convierto a BSON::ObjectId
    desired_collection_ids = desired_collection ? desired_collection.map { |id| BSON::ObjectId.from_string(id) } : []
    
    # Encuentra todas las colecciones que contienen la nota
    current_collections = Collection.where(:notes.in => [@note.id])

    # Eliminar la nota de las colecciones que ya no están seleccionadas
    current_collections.each do |collection|
      unless desired_collection_ids.include?(collection.id)
        collection.notes.delete(@note.id)
        collection.save
      end
    end

    # Añadir la nota a las colecciones seleccionadas
    desired_collection_ids.each do |collection_id|
      collection = Collection.find(collection_id)
      unless collection.notes.include?(@note.id)
        collection.notes.push(@note.id)
        collection.save
      end
    end
  end

  def delete_collections
    current_collections = Collection.where(:notes.in => [@note.id])

    current_collections.each do |collection|
      collection.notes.delete(@note.id)
      collection.save
    end
  end
end
