class Registro < ActiveRecord::Base
  attr_accessible :atividade_id, :autor_id, :modificacao

  validates :atividade_id, :presence => true
  validates :autor_id, :presence => true
  validates :modificacao, :presence => true

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
          log << (" alterou a data de " + Dia.find(valores.first).data.to_s + " para " +
            Dia.find(valores.last).data.to_s + ",")
        end
      when "observacao"
        if valores.first.nil?
          log << " adicionou uma observação,"
        else
          log << (" alterou a observação de '" + valores.first + "' para '" + valores.last + "',")
        end
      when "projeto_id"
        if valores.first.nil?
          log << " adicionou um projeto"
        else
          log << (" alterou o projeto de " + Projeto.find(valores.first).nome + " para " + Projeto.find(valores.last).nome)
        end
      when "aprovacao"
        log << " alterou a aprovação,"
      when "avaliador_id"
        if valores.first.nil?
          log << " virou avaliador"
        else
          log << (" alterou o avaliador de " + Usuario.find(valores.first).nome  + " para " + Usuario.find(valores.last).nome + ",")
        end
      when "duracao"
        if valores.first.nil?
          log << " adicionou " + Time.at(valores.last).utc.strftime("%H:%M") + " ,"
        else
          log << (" atualizou a duração de " + Time.at(valores.first).utc.strftime("%H:%M") +
            " para " + Time.at(valores.last).utc.strftime("%H:%M") + ",")
        end
      when "cartao_id"
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
