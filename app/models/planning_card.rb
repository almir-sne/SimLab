class PlanningCard < ActiveRecord::Base
  belongs_to :deck

  def valor=(val)
    if val.blank?
      self[:valor] = nil
    elsif val == "min"
      self[:valor] = nil
      self.deck.minimum = self
      self.deck.save
    elsif val == "max"
      self[:valor] = nil
      self.deck.maximum = self
      self.deck.save
    else
      if self.deck.minimum == self
        self.deck.minimum = nil
        self.deck.save
      elsif self.deck.maximum == self
        self.deck.maximum = nil
        self.deck.save
      end
      self[:valor] = val.to_f
    end
  end

  def valor
    if self.deck && self.deck.maximum == self
      "max"
    elsif self.deck && self.deck.minimum == self
      "min"
    else
      self[:valor]
    end
  end

  def nome
    unless self[:nome].blank?
      self[:nome]
    else
      self[:valor]
    end
  end
end
