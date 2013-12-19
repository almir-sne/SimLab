class MigratePlanningPokerData < ActiveRecord::Migration
  def up
    deck = Deck.where(nome: "Fibonacci").first
    inf = deck.planning_cards.where(nome: "Infinito").first
    int = deck.planning_cards.where(nome: "?").first
    Estimativa.all.each do |e|
      r = Rodada.find_or_create_by_cartao_id_and_numero(e.cartao.id, e.rodada)
      r.fechada = true
      r.deck = deck
      r.save
      e.rodada_id = r.id
      if e.valor == -2
        e.planning_card = inf
      elsif e.valor == -1
        e.planning_card = int
      elsif !e.valor.blank?
        e.planning_card = deck.planning_cards.where(valor: e.valor).first
      end
      e.save
    end
  end

  def down
    deck = Deck.where(nome: "Fibonacci").first
    inf = deck.planning_cards.where(nome: "Infinito").first
    int = deck.planning_cards.where(nome: "?").first
    Estimativa.all.each do |e|
      e[:rodada] = (Rodada.find e.rodada_id).numero
      if e.planning_card == inf
        e.valor == -2
      elsif e.planning_card == int
         e.valor == -1
      elsif e.planning_card
        e.valor = e.planning_card.valor
      end
      e.save
    end
    Cartao.all.each do |c|
      c.rodada = c.rodadas.maximum(:numero) || 1
      if c.estimativa
        c.estimado = true
      else
        c.estimado = false
      end
      c.save
    end
  end
end
