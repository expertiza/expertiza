class BookmarkTag < ActiveRecord::Base
  has_many(:bmappings_tagses)
end
