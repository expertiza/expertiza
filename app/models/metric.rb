class Metric < ActiveRecord::Base
  enum source: [ :github ]
  belongs_to :team
  belongs_to :assignment
  has_many :metric_data_points, dependent: :destroy, foreign_key: 'metric_id'

  require 'open-uri/cached'

  def self.parseWiki(url)
    Nokogiri::HTML(open(url)).css('#bodyContent p').text()
  end

  def self.analyzeText(text)
    Odyssey.analyze_multi(text, ['FleschKincaidRe', 'FleschKincaidGl', 'Ari', 'ColemanLiau', 'GunningFog', 'Smog'], true)
  end

end
