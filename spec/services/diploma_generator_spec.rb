RSpec.describe DiplomaGenerator do
  let(:diploma) { Diploma.new }
  let(:dir) { File.join(Rails.root, 'tmp', 'spec', diploma.id) }
  let(:file) { File.join(Rails.root, 'tmp', 'spec', diploma.id, 'diploma-1.pdf') }

  before :each do
    FileUtils.mkdir_p(dir)
  end

  after :each do
    FileUtils.rm_rf(dir)
  end

  it 'generate_pdf generates pdf' do
    dq = DiplomaGenerator.new(diploma)
    contributors = [['hdd', 3000]]
    dq.send(:generate_pdf, contributors, dir)
    expect(File).to exist(file)
  end
end