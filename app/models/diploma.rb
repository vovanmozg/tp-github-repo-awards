class Diploma
  include ActiveModel::Validations

  attr_accessor :id
  attr_accessor :user
  attr_accessor :repo
  attr_accessor :url
  attr_accessor :champions
  validates_format_of :url, with: %r{\Ahttps://github\.com/([^/]+)/([^/]+)/?\z}

  def initialize(params = {})
    if params
      @url = params[:url]
      @id = params[:id] || SecureRandom.uuid
      parse_url
    end
  end

  private

  def parse_url
    if /^https:\/\/github\.com\/([^\/]+)\/([^\/]+)\/?$/ =~ @url
      @user = $1
      @repo = $2
    end
  end

  def persisted?
    false
  end
end
