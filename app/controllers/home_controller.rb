class HomeController < ApplicationController

  def index
    url = params[:diploma] ? params[:diploma][:url] : 'https://github.com/'
    @diploma = Diploma.new(url: url)
  end

  def create
    @diploma = Diploma.new(params[:diploma])

    if @diploma.valid?
      begin
        gen = DiplomaGenerator.new(@diploma)
        @diploma = gen.generate
      rescue RestClient::NotFound => err
        flash.now[:error] = 'Repository not found'
      end
    end

    render :index
  end
end