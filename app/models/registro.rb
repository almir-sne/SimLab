class Registro < ActiveRecord::Base
  attr_accessible :atividade_id, :autor_id, :modificacao

  validates :atividade_id, :presence => true
  validates :autor_id, :presence => true

  belongs_to :atividade
  belongs_to :autor, :class_name => "Usuario"

  def transforma_hash_em_modificacao(hash)
    log = String.new
    hash.each do |atributo, valores|
      case atributo
      when "dia_id"
        if valores.first.nil?
          log << " adicionou um dia,"
        else
          log << (" alterou a data de " + Dia.find(valores.first).data.to_s + " para " + Dia.find(valores.last).data.to_s + ",")
        end
      when "observacao"
        if valores.first.nil?
          log << " adicionou uma observação,"
        else
          log << (" alterou a observação que era " + valores.first + ",")
        end
      when "projeto_id"
        if valores.first.nil?
          log << " adicionou um projeto"
        else
          log << (" alterou o projeto que era " + Projeto.find(valores.first).nome + ",")
        end
      when "aprovacao"
        log << " alterou a aprovação"
      when "avaliador_id"
        if valores.first.nil?
          log << " virou avaliador"
        else
          log << (" alterou o avaliador antes era " + Usuario.find(valores.first).nome + ",")
        end
      when "duracao"
        if valores.first.nil?
          log << " adicionou " + (valores.last/3600).to_s + " hs"
        else
          log << (" atualizou a duração de " + (valores.first/3600).to_s + "hs para " + (valores.last/3600).to_s + "hs,")
        end
      when "trello_id"
        if valores.first.nil?
          log << " adicionou um cartão,"
        else
          log << (" alterou o cartão,")
        end
      end
    end
    self.modificacao = log[0..-2]
  end

end
