class AddAttachmentToResearchPapers < ActiveRecord::Migration
  def change
    add_column :research_papers, :attachment, :string
  end
end
