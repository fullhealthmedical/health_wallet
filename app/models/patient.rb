class Patient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :dob, type: Date
  field :sex_at_birth, type: String
end
