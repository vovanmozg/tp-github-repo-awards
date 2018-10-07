RSpec.describe Diploma, type: :model do
  it 'does not invalidate empty url' do
    expect(Diploma.new).to be_invalid
  end

  it 'does not invalidate invalid url' do
    dq = Diploma.new(url: 'https://github.com/')
    expect(dq).to be_invalid
  end

  it 'validates valid url' do
    dq = Diploma.new(url: 'https://github.com/rails/rails')
    expect(dq).to be_valid
  end
end