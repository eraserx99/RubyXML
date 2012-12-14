require "rubygems"
require "bundler/setup"
require "nokogiri"

class ApplicationsParser
  # Each of the patent files might include more than one patents represented in the XML format (well-formed or malformed).
  # This PATENT_REGX (non-greedy) can be used to extract the patent grants from the patent application files that conform to
  # XML1.x format.
  # It is not necessary to use the group (.*?) here, but it might be convenient for the future.
  
  PATENT_REGX = Regexp.new(/<patent-application-publication.*?>(.*?)<\/patent-application-publication.*?>/imu)

  # The PATENT_KIND_REGX is used to include the patents we are interested.
  # Based on the explanation of RECOMMENDATED STANDARD CODE FOR THE IDENTIFICATION OF
  # DIFFERENT KINDS OF PATENT DOCUMENTS STANDARD ST. 16.
  # The KIND code is presented in the format ONE LETTER CODE and ONE DIGIT CODE.
  # The ONE LETTER CODE is subdivided into mutually exclusive groups of letters. The groups of characterize patent documents.
  # TODO: further review needed
  PATENT_KIND_REGX = Regexp.new(/[ABCUYZ]\d/imu)
  
  # process_bundle parses the patent file
  def self.process_bundle(file)
    open(file) do |f|
    # Load the contents of the patent file
    # It might need some optimization here to prevent out-of-memory issues with super large patent files.
      str = f.read
      # Scan all the matched string fragments specified by the PATENT_REGX
      str.scan(PATENT_REGX) do |fragment|
      # Yield the matched string
        yield $&
      end
    end
  end

  # If the patent is constructed as Nokogiri::HTML object, all the element names are lower-cased.
  # If the patent is constructed as Nokogiri::XML object, all the element names are kept as the original inputs.
  def initialize(str)
    @text = str
    # Parse the string as XML
    # @doc = Nokogiri::XML(@text)
    # Parse the string as HTML
    @doc = Nokogiri::HTML(@text)
  end

  def text
    @text
  end

  # Extract the inner text of the element
  # It returns an empty string if the element is nil
  def extract_inner_text(element)
    element != nil ? element.inner_text.strip : ""
  end
  private :extract_inner_text
  
  def doc_type
    :us_patent_application
  end

  # :uspto_xml_v4, , :uspto_xml_v2, :uspto_xml_v1, or :uspto_sgml_v2
  # TODO: further review needed
  def source_version
    :uspto_xml_v1
  end

  # patent-application-publication/subdoc-bibliographic-information/document-id/doc-number
  def doc_num
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/document-id/doc-number")
    extract_inner_text(node)   
  end

  # patent-application-publication/subdoc-bibliographic-information/document-id/kind-code
  def kind
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/document-id/kind-code")
    extract_inner_text(node)       
  end

  def patent_type
    kind =~ PATENT_KIND_REGX ? :utility : :other
  end
  
  # patent-application-publication/subdoc-bibliographic-information/document-id/document-date
  def pub_date
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/document-id/document-date")
    extract_inner_text(node)     
  end

  # patent-application-publication/subdoc-bibliographic-information/document-id/country-code
  def country
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/document-id/country-code")
    ctry = extract_inner_text(node)        
    # If the country-code element does not exist, use "US" as the default
    ctry.empty? ? "US" : ctry
  end

  # patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/application-number/doc-number
  def app_num
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/application-number/doc-number")
    extract_inner_text(node)     
  end

  # patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/filing-date
  def filing_date
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/filing-date")
    extract_inner_text(node)        
  end
  
  # patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/application-number-series-code
  def series_code
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/domestic-filing-data/application-number-series-code")
    extract_inner_text(node)        
  end  
  
  # patent-application-publication/subdoc-bibliographic-information/technical-information/title-of-invention
  def title
    node = @doc.at_xpath("//patent-application-publication/subdoc-bibliographic-information/technical-information/title-of-invention")
    extract_inner_text(node)        
  end
  
  # patent-application-publication/subdoc-abstract
  # TODO: further review required; it might need to expand HTML special characters
  def abstract
    node = @doc.at_xpath("//patent-application-publication/subdoc-abstract")
    extract_inner_text(node)         
  end
  
  # patent-application-publication/subdoc-description
  # TODO: further review required; it might need to expand HTML special characters
  def description
    node = @doc.at_xpath("//patent-application-publication/subdoc-description")
    extract_inner_text(node)       
  end
 
  # 
  def applicants
  end 
  
  # patent-application-publication/subdoc-bibliographic-information/inventors
  def inventors
  end
  
  #
  def agents
  end

  # patent-application-publication/subdoc-bibliographic-information/assignee
  def assignees
  end
  
  #
  def examiners
  end
  
end
