class CreateDefaultDeck < ActiveRecord::Migration
  def up
    deck = Deck.new(nome: "Fibonacci")
    deck.save
    [["0.0", 0.0], ["0.5", 0.5], ["1", 1.0], ["2", 2.0], ["3", 3.0], ["5", 5.0],
      ["8", 8.0], ["13", 13.0], ["20", 20.0], ["40", 40.0], ["Infinito", "max"], ["?", nil]].each do |c|
      card = PlanningCard.new
      card.deck = deck
      card.nome = c[0]
      card.valor = c[1]
      card.save
    end    
  end

  def down
    Deck.where(nome: "Fibonacci").last.destroy
  end
end
