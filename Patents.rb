require './GrantsParser'
require './ApplicationsParser'

# grants_files = [ "./grants/xml24/grants_2001_sample.xml", "./grants/xml2/grants_2004_sample.xml" ]
grants_files = []
applications_files = [ "./applications/xml1/applications_sample_2001.xml", "./applications/xml1/applications_sample_2004.xml" ]

grants_files.each do |file|
  count = 0
  GrantsParser.process_bundle(file) do |fragment|
    p = GrantsParser.new(fragment) unless fragment.empty?
    if p.patent_type == :utility
      p "document number => " + p.doc_num
      p "patent kind => " + p.kind
      p "publishing date => " + p.pub_date
      p "country => " + p.country
      p "filing date => " + p.filing_date
      p "patent type => " + p.patent_type.to_s
      p "classifications => " + p.classifications.to_s
      p "title => " + p.title
      p "abstract => " + p.abstract
      p "number of claims => " + p.num_claims_alt.to_s
      p "exemplary of claims => " + p.exem_claim.to_s
      p "claims => " + p.claims.to_s
      p "applicants => " + p.applicants.to_s
      p "inventors => " + p.inventors.to_s
      p "assignees => " + p.assignees.to_s
      p "agents => " + p.agents.to_s
      p "examiners => " + p.examiners.to_s
      p "description => " + p.description
      p "grant info => " + p.grant_info.to_s
      count = count + 1
    end
  end
end

applications_files.each do |file|
  count = 0
  ApplicationsParser.process_bundle(file) do |fragment|
    p = ApplicationsParser.new(fragment) unless fragment.empty?
    p "document number => " + p.doc_num
    p "patent kind => " + p.kind
    p "publishing date => " + p.pub_date   
    p "application number => " + p.app_num
    p "filing date => " + p.filing_date   
    p "series code => " + p.series_code
    p "title => " + p.title   
    p "abstract => " + p.abstract    
    p "description => " + p.description    
  end
end

