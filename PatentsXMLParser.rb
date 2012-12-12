require "rubygems"
require "bundler/setup"
require "nokogiri"

class PatentsXMLParser
  # Each of the patent files might include more than one patents represented in the XML format (well-formed or malformed).
  # This PATENT_REGX (non-greedy) can be used to extract the patent grants from the patent grant files that conform to
  # SGML2.4 and XML2.5 format.
  # It is not necessary to use the group (.*?) here, but it might be convenient for the future.
  PATENT_REGX = Regexp.new(/<PATDOC.*?>(.*?)<\/PATDOC.*?>/imu)

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

  # Utility function to extract %NAM
  def extract_nam(node)
    h = Hash.new

    # Look for elements (such as fnm, snm, etc) relative to the current element
    # Elements within <NAM>...</NAM>
    # fnm => Given and Middle Name(s) and/or Initials
    first_name = node.at_xpath(".//nam/fnm")
    # snm => Family name , last, surname or, if unable to distinguish: whole personal or organization name
    last_name = node.at_xpath(".//nam/snm")
    # suffix => Suffix (e.g., II, Jr., Sr., Esq., et al.)
    suffix = node.at_xpath(".//nam/sfx")
    # onm => Organization name
    organization = node.at_xpath(".//nam/onm")
    # odv => Division of Organization
    division = node.at_xpath(".//nam/odv")
    h.store(:first_name, extract_inner_text(first_name)) unless first_name == nil
    h.store(:last_name, extract_inner_text(last_name)) unless last_name == nil
    h.store(:suffix, extract_inner_text(suffix)) unless suffix == nil
    h.store(:organization, extract_inner_text(organization)) unless organization == nil
    h.store(:division, extract_inner_text(division)) unless division == nil

    h
  end
  private :extract_nam

  # Utility function to extract %PARTY
  def extract_party(node)
    h = Hash.new
    # Look for elements (such as fnm, snm, etc) relative to the current element
    # Elements within <PARTY-XX>...</PARTY-XX>
    # nctry => Country of Nationality
    residence = node.at_xpath(".//nctry")
    # rctry => Country of Residence
    nationality = node.at_xpath(".//rctry")
    # Elements within <PARTY-XX><NAM>...</NAM></PARTY-XX>
    # fnm => Given and Middle Name(s) and/or Initials
    first_name = node.at_xpath(".//nam/fnm")
    # snm => Family name , last, surname or, if unable to distinguish: whole personal or organization name
    last_name = node.at_xpath(".//nam/snm")
    # suffix => Suffix (e.g., II, Jr., Sr., Esq., et al.)
    suffix = node.at_xpath(".//nam/sfx")
    # onm => Organization name
    organization = node.at_xpath(".//nam/onm")
    # odv => Division of Organization
    division = node.at_xpath(".//nam/odv")
    # Elements within <PARTY-XX><ADR>...</ADR></PARTY-XX>
    # city => City or Town
    city = node.at_xpath(".//adr/city")
    # state => Region of Country (State, Province, etc.)
    state = node.at_xpath(".//adr/state")
    # pcode => Postal Code
    pcode = node.at_xpath(".//adr/pcode")
    # ctry => Country
    country = node.at_xpath(".//adr/ctry")
    h.store(:residence, extract_inner_text(residence)) unless residence == nil
    h.store(:nationality, extract_inner_text(nationality)) unless nationality == nil
    h.store(:first_name, extract_inner_text(first_name)) unless first_name == nil
    h.store(:last_name, extract_inner_text(last_name)) unless last_name == nil
    h.store(:suffix, extract_inner_text(suffix)) unless suffix == nil
    h.store(:organization, extract_inner_text(organization)) unless organization == nil
    h.store(:division, extract_inner_text(division)) unless division == nil
    h.store(:city, extract_inner_text(city)) unless city == nil
    h.store(:state, extract_inner_text(state)) unless state == nil
    h.store(:pcode, extract_inner_text(pcode)) unless pcode == nil
    h.store(:country, extract_inner_text(country)) unless country == nil

    h
  end
  private :extract_party

  # Utility function to extract %PCIT
  def extract_pcit

  end

  def doc_id
  end

  def doc_type
    :us_patent_grant
  end

  # :uspto_xml_v4, , :uspto_xml_v2, :uspto_xml_v1, or :uspto_sgml_v2
  # TODO: further review needed
  def source_version
    :uspto_xml_v2
  end

  # The member functions below help to extract information from the patent
  # If the patent is constructed as Nokogiri::HTML object, all the element names are lower-cased.
  # If the patent is constructed as Nokogiri::XML object, all the element names are kept as the original inputs.

  # B110 - number of document
  def doc_num
    node = @doc.at_xpath("//b110")
    extract_inner_text(node)
  end

  # B130 - kind of document
  def kind
    node = @doc.at_xpath("//b130")
    extract_inner_text(node)
  end

  # TODO: further review needed
  def patent_type
    kind =~ PATENT_KIND_REGX ? :utility : :other
  end

  # B140 - date of publication
  def pub_date
    node = @doc.at_xpath("//b140")
    extract_inner_text(node)
  end

  # B190 - publishing country or organization
  # TODO: further review needed
  def country
    node = @doc.at_xpath("//b190")
    extract_inner_text(node)
  end

  # B210 - application number
  def app_num
    node = @doc.at_xpath("//b210")
    extract_inner_text(node)
  end

  # B220 - application filing date
  def filing_date
    node = @doc.at_xpath("//b220")
    extract_inner_text(node)
  end

  # B510 - international patent classification (IPC) data
  # B511 - main classification
  # B512 - further classification
  # B520 - domestic or national classification
  # B521 - main classification
  # B522 - further classification
  # B527 - country
  # Each of the patents might have both international patent classification and domestic or national classification.
  # There can be more than one main classification.
  # There can be more than one further classification.
  # TODO: further review required
  def classifications
    classes = Hash.new

    h = Hash.new
    if b510 = @doc.at_xpath("//b510")
      # Collect the main classification
      b511_ns = b510.xpath(".//b511")
      mclasses = []
      if b511_ns != nil
        b511_ns.each do |cls|
          mc = extract_inner_text(cls)
          mclasses << mc unless mc.empty?
        end
        h.store(:mainclass, mclasses) unless mclasses.empty?
      end

      # Collect the further classification, if any
      b512_ns = b510.xpath(".//b512")
      fclasses = []
      if b512_ns != nil
        b512_ns.each do |cls|
          fc = extract_inner_text(cls)
          fclasses << fc unless fc.empty?
        end
        h.store(:subclass, fclasses) unless fclasses.empty?
      end
    end
    classes.store(:domestic_classifications, h) unless h.empty?

    h = Hash.new
    if b520 = @doc.at_xpath("//b520")
      h = Hash.new

      # Collect the main classification
      b521_ns = b520.xpath(".//b521")
      mclasses = []
      if b521_ns != nil
        b521_ns.each do |cls|
          mc = extract_inner_text(cls)
          mclasses << mc unless mc.empty?
        end
        h.store(:mainclass, mclasses) unless mclasses.empty?
      end

      # Collect the further classification, if any
      b522_ns = b520.xpath(".//b522")
      fclasses = []
      if b522_ns != nil
        b522_ns.each do |cls|
          fc = extract_inner_text(cls)
          fclasses << fc unless fc.empty?
        end
        h.store(:subclass, fclasses) unless fclasses.empty?
      end

      # Collect the country
      b527 = b520.at_xpath(".//b527")
      country = extract_inner_text(b527)
      h.store(:country, country) unless country.empty?
    end
    classes.store(:international_classifications, h) unless h.empty?

    classes
  end

  def references

  end

  # B540 - title
  def title
    node = @doc.at_xpath("//b540")
    extract_inner_text(node)
  end

  # B710 - applicant information
  # B711 - name & address
  # This function returns the inventor information as an array of hashes.
  def applicants
    results = []

    if b710 = @doc.at_xpath("//b710")
      if b711_ns = b720.xpath(".//b711")
        b711_ns.each do |b711|
          r = extract_party(b711)
          results << r unless r.empty?
        end
      end
    end

    results
  end

  # B720 - inventor information
  # B721 - name & address
  # This function returns the inventor information as an array of hashes.
  def inventors
    results = []

    if b720 = @doc.at_xpath("//b720")
      if b721_ns = b720.xpath(".//b721")
        b721_ns.each do |b721|
          r = extract_party(b721)
          results << r unless r.empty?
        end
      end
    end

    results
  end

  # B730 - assignee information
  # B731 - name & address
  # B732US - Assignee type code (USPTO)
  # This function returns the assignee information as an array of hashes.
  def assignees
    results = []

    if b730 = @doc.at_xpath("//b730")
      h = Hash.new

      if b731_ns = b730.xpath(".//b731")
        b731_ns.each do |b731|
          r = extract_party(b731)
          results << r unless r.empty?
        end
      end

      b732us = b730.at_xpath(".//b732us")
      assignee_role = extract_inner_text(b732us)
      h.store(:assignee_role, assignee_role) unless assignee_role.empty?

    results << h unless h.empty?
    end

    results
  end

  # B740 - attorney, agent, representative information
  # B741 - name & address
  # This function returns the assignee information as an array of hashes.
  # TODO: further review needed; B740 can represent either attorneys or agents
  def agents
    results = []

    if b740 = @doc.at_xpath("//b740")
      h = Hash.new

      if b741_ns = b740.xpath(".//b741")
        b741_ns.each do |b741|
          r = extract_party(b741)
          results << h unless h.empty?
        end
      end
    end

    results
  end

  # B745 - persons acting upon the document
  # B746 - primary examiner
  # B747 - assistant examiner
  # B748US - art Group/Unit (USPTO)
  # This function returns the assignee information as an array of hashes.
  # TODO: further review required; dept is associated with the whole group of examiners
  def examiners
    results = []

    if b745 = @doc.at_xpath("//b745")
      h = Hash.new

      if b746_ns = b745.xpath(".//b746")
        b746_ns.each do |b746|
          r = extract_party(b746)
          h.store(:primary, r) unless r.empty?
        end
      end

      # Collect assistant examiners information
      if b747_ns = b745.xpath(".//b747")
        b747_ns.each do |b747|
          r = extract_party(b747)
          h.store(:assistant, r) unless r.empty?
        end
      end

      b748us = b745.at_xpath(".//b748us")
      dept = extract_inner_text(b748us)
      h.store(:dept, dept) unless dept.empty?

    results << h unless h.empty?
    end

    results
  end

  # SDOAB - abstract
  def abstract
    node = @doc.at_xpath("//sdoab")
    extract_inner_text(node)
  end

  # SDOCL - claims
  def claims
    clms = []

    node = @doc.at_xpath("//sdocl")
    if node
      # Search and loop through all CLM elements
      # <SDOCL>
      #   <CL>
      #     <CLM ID="..."></CLM>
      #     <CLM ID="..."></CLM>
      #     ...
      #   <CL>
      # </SDOCL>
      # , then parse the CLM / claim element
      node.xpath(".//clm").each do |clm|
        m = Hash.new

        # The ID attribute of CLM element represents the claim number.
        # The format of the ID attribute is CLM-ddddd.
        number = clm['id']
        number = number.scan(/\d+/)[0].to_i unless number == nil
        text = extract_inner_text(clm)
        m.store("number", number) unless number == nil
        m.store("text", text) unless text.empty?
        clms << m unless m.empty?
      end
    end

    clms
  end

  # B577 - number of claims
  # TODO: further review required: currently, the claims are parsed SDOCL, not B57X
  def num_claims
    nclm = 0

    if b570 = @doc.at_xpath("//570")
      b577 = b570.at_xpath(".//577")
      nc = extract_inner_text(b577)
    nclm = nc.to_i unless nc.empty?
    end

    nclm
  end

  # Alternative to calculate the number of claims of the patent.
  def num_claims_alt
    nclms = 0
    node = @doc.at_xpath("//sdocl")

    # More than one claim per patent
    # <SDOCL>
    #   <CL>
    #     <CLM ID="..."></CLM>
    #     <CLM ID="..."></CLM>
    #     ...
    #   <CL>
    # </SDOCL>
    if node
      if clms = node.xpath(".//clm")
      nclms = clms.size
      end
    end

    nclms
  end

  # B578US -  exemplary claim number (USPTO)
  def exem_claim
    clm = 1

    if b570 = @doc.at_xpath("//570")
      b578us = b750.at_xpath(".//578us")
      exem = extract_inner_text(b578us)
    clm = exem.to_i unless exem.empty?
    end

    clm
  end

  # SDOD - description
  def description
    node = @doc.at_xpath("//sdod")
    extract_inner_text(node)
  end

  # Specification is equal to description concatenated with claims
  def spec
    description + "\n" + claims
  end

  # B400 - public availability dates
  # B472 - term of grant
  # B473US - disclaimer date
  # B474US - length of the extension
  # TODO: further review required
  def grant_info
    gi = Hash.new

    if b400 = @doc.at_xpath("//400")
      if b472 = b400.at_xpath(".//b472")
        b473us b472.at_xpath(".//b473us")
        disclaimer = extract_inner_text(b473us)
        gi.store(:disclaimer, disclaimer) unless disclaimer.empty?

        b474us = b472.at_xpath(".//b474us")
        length = extract_inner_text(b474us)
        gi.store(:length, length) unless length.empty?
      end

    end

    gi
  end
end
