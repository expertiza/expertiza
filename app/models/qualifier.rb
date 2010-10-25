class Qualifier < ActiveRecord::Base
  belongs_to :resource
  belongs_to :tag


end