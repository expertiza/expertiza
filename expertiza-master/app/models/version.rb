class Version < PaperTrail::Version
  belongs_to :item, polymorphic: true
end
