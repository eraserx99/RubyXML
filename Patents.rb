require './PatentsXMLParser'

files = [ "./grants/xml24/grants_2001_sample.xml", "./grants/xml2/grants_2004_sample.xml" ]

files.each do |file|
  count = 0
  PatentsXMLParser.process_bundle(file) do |fragment|
    p = PatentsXMLParser.new(fragment) unless fragment.empty?
    p p.doc_num
    p p.kind.to_s
    p p.pub_date
    p p.country
    p p.filing_date
    p p.patent_type.to_s
    p p.pub_classes
    p p.title
    p p.abstract
    p p.claims
    p "number of claims => " + p.num_claims.to_s
    p p.inventors.to_s
    p p.assignee.to_s
    p p.description
    count = count + 1
  end
end

