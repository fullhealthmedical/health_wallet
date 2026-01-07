require "test_helper"

class LabResultsImportJobTest < ActiveJob::TestCase
  test "enqueues job" do
    assert_enqueued_with(job: LabResultsImportJob) do
      LabResultsImportJob.perform_later("/tmp/test_file.txt")
    end
  end
end
