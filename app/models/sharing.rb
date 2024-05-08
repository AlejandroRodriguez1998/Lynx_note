class Sharing
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :owner, class_name: 'User', inverse_of: :sharings

    # Relación polimórfica para manejar tanto notas como colecciones
    belongs_to :shareable, polymorphic: true

    field :shared_with, type: Array, default: []
end