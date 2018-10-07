class DiplomaGenerator
  def initialize(diploma_query)
    @diploma_query = diploma_query
  end

  def generate
    prepare_dir
    contributors = fetch_contributors
    generate_pdf(contributors, @pdf_dir)
    compress

    @diploma_query.champions = contributors.map { |c| c[0] }
    @diploma_query
  end

  private

  # All pdf and zip files contains in the /public/diplomas/:id directories
  def prepare_dir
    @dir = File.join(Rails.root, 'public', 'diplomas', @diploma_query.id)
    @pdf_dir = File.join(@dir, 'pdf')
    FileUtils.mkdir_p(@pdf_dir) unless File.directory?(@pdf_dir)
  end

  # Return contributors array (login, contributions)
  def fetch_contributors
    url = "https://api.github.com/repos/#{@diploma_query.user}/#{@diploma_query.repo}/contributors"
    json = JSON.parse(RestClient.get(url))

    json.sort_by { |c| c['contributions'] }
        .reverse!
        .map { |c| [c['login'], c['contributions']] }
        .take(3)
  end

  # Generate using Prawn
  # @param contributors [Array]
  def generate_pdf(contributors, pdf_dir)
    contributors.each_with_index do |(name, contributions), i|
      place = i + 1
      pdf_file_name = File.join(pdf_dir, "diploma-#{place}.pdf")
      Prawn::Document.generate(pdf_file_name, page_size: 'A4') do
        width = 521 # A4
        height = 770 # A4

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
  end

  # zip pdf-files
  def compress
    input_filenames = Dir.glob(File.join(@pdf_dir, '*.pdf')).map { |file| File.basename(file) }
    zipfile_name = File.join(@dir, 'diplomas.zip')
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, File.join(@pdf_dir, filename))
      end
    end
  end
end