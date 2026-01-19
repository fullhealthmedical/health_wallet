class Assessment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: String
  field :reference, type: String

  belongs_to :patient
  has_one :imported_file, dependent: :destroy

  embeds_many :observations
  accepts_nested_attributes_for :observations

  # Validations
  validates :reference, presence: true
  validates :date, presence: true
end
