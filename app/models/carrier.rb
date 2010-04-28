class Carrier < ActiveRecord::Base
  belongs_to :country
  has_many :mobile_numbers
  
  def self.all
    carriers = Rails.cache.read 'carriers'
    if not carriers
      carriers = super
      carriers.sort!{|x, y| x.name <=> y.name}
      Rails.cache.write 'carriers', carriers
    end
    carriers
  end
  
  def self.all_with_countries
    countries = Country.all.inject({}) { |memo, obj| memo[obj.id] = obj; memo }
  
    carriers = all
    carriers.each {|c| c.country = countries[c.country_id]}
    carriers
  end
  
  def self.find_by_country_id(country_id)
    all.select {|x| x.country_id == country_id}
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.carrier :name => name, :guid => guid, :country_iso2 => country.iso2
  end
  
  def to_json(options = {})
    "{\"name\":\"#{escape(name)}\",\"guid\":\"#{escape(guid)}\",\"country_iso2\":\"#{escape(country.iso2)}\"}"
  end
  
  private
  
  def escape(str)
    str.gsub('"', '\\\\"')
  end
end
