require 'prawn'
require 'rest-client'
require 'rubygems'
require 'zip'
require 'json'

repo_url, = ARGV

unless /^https:\/\/github\.com\/([^\/]+)\/([^\/]+)\/?$/ =~ repo_url
  abort('Please specify full repo url, etc. https://github.com/rails/rails/')
end

git_user = $1
git_name = $2

path = './pdf'
Dir.mkdir(path) unless Dir.exists?(path)

# get contributors list
json = JSON.parse(
    RestClient.get("https://api.github.com/repos/#{git_user}/#{git_name}/contributors")
)
contributors = json
                   .sort_by { |c| c['contributions'] }
                   .reverse!
                   .map { |c| [c['login'], c['contributions']] }
                   .take(3)

# generate pdf
contributors.each_with_index do |(name, contributions), i|
  place = i + 1
  Prawn::Document.generate("#{path}/diploma-#{place}-#{name}.pdf", page_size: 'A4') do
    width = 521
    height = 770

    line_width(5)

    stroke_bounds

    bounding_box([width/2 - 150, height/2 + 150], :width => 300, :height => 300) do
      text "PDF ##{place}", :align => :center, :size => 24
      text 'The award goes to', :align => :center, :size => 18
      text name, :align => :center, :size => 14
      text "contributions: #{contributions}", :align => :center, :size => 10
    end

    stroke
  end
end

# compress
input_filenames = Dir.glob(File.join(path, '*.pdf')).map { |file| File.basename(file) }
zipfile_name = File.join(path, 'diplomas.zip')
Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
  input_filenames.each do |filename|
    zipfile.add(filename, File.join(path, filename))
  end
end
input_filenames.each { |filename| File.delete(File.join(path, filename)) }