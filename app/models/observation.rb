class Observation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :code, type: String
  field :value, type: Float
  field :units, type: String

  embedded_in :assessment

  # Validations
  validates :code, presence: true
  validates :value, presence: true
  validates :units, presence: true
end
