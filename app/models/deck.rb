class Deck < ActiveRecord::Base
  attr_accessible :nome, :minimum, :maximum, :planning_cards_attributes
  
  has_one :minimum, :class_name => "PlanningCard"
  has_one :maximum, :class_name => "PlanningCard"
  
  has_many :planning_cards, :dependent => :destroy
  accepts_nested_attributes_for :planning_cards, :allow_destroy => true
end
