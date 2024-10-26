class QuestionAdvice < ApplicationRecord
  # attr_accessible :score, :advice
  belongs_to :item

  # This method returns an array of fields present in item advice model
  def self.export_fields(_options)
    fields = []
    QuestionAdvice.columns.each do |column|
      fields.push(column.name)
    end
    fields
  end

  # This method adds the item advice data to CSV for the respective itemnaire
  def self.export(csv, parent_id, _options)
    itemnaire = Questionnaire.find(parent_id)
    items = itemnaire.items
    items.each do |item|
      item_advices = QuestionAdvice.where('item_id = ?', item.id)
      item_advices.each do |advice|
        tcsv = []
        advice.attributes.each_pair do |_name, value|
          tcsv.push(value)
        end
        csv << tcsv
      end
    end
  end
end
