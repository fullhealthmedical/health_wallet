class Patient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :dob, type: Date
  field :sex_at_birth, type: String

  has_many :assessments

  # Validations
  validates :name, presence: true
  validates :dob, presence: true
  validates :sex_at_birth, presence: true
end
