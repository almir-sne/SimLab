class Deck < ActiveRecord::Base
  belongs_to :minimum, :class_name => "PlanningCard"
  belongs_to :maximum, :class_name => "PlanningCard"

  has_many :planning_cards, :dependent => :destroy
  accepts_nested_attributes_for :planning_cards, :allow_destroy => true
end
