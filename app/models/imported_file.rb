class ImportedFile
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relationships
  belongs_to :assessment

  # Fields
  field :status, type: String, default: 'pending'
  field :filename, type: String
  field :file_content, type: String
  field :patients_created_count, type: Integer, default: 0
  field :patients_updated_count, type: Integer, default: 0
  field :assessments_created_count, type: Integer, default: 0
  field :assessments_updated_count, type: Integer, default: 0
  field :observations_created_count, type: Integer, default: 0
  field :observations_updated_count, type: Integer, default: 0
  field :error_count, type: Integer, default: 0
  field :error_messages, type: Array, default: []

  # Validations
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  validate :file_must_be_present

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :processing, -> { where(status: 'processing') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }

  # Instance methods
  def total_created
    patients_created_count + assessments_created_count + observations_created_count
  end

  def total_updated
    patients_updated_count + assessments_updated_count + observations_updated_count
  end

  def processing!
    update(status: 'processing')
  end

  def completed!
    update(status: 'completed')
  end

  def failed!(error_message = nil)
    if error_message
      self.error_messages ||= []
      self.error_messages << error_message
      self.error_count += 1
    end
    update(status: 'failed')
  end

  def add_error(message)
    self.error_messages ||= []
    self.error_messages << message
    self.error_count += 1
    save
  end

  private

  def file_must_be_present
    errors.add(:file, "must be present") if file_content.blank?
  end
end
