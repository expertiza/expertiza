class RemoveSurveyNodes < ActiveRecord::Migration
  def change
    survey_nodes = []
    survey_nodes << TreeFolder.where(name: 'Assignment Survey')
    survey_nodes << TreeFolder.where(name: 'Global Survey')
    survey_nodes << TreeFolder.where(name: 'Course Survey')
    survey_nodes.each do |node|
      node.destroy_all
    end
  end
end
