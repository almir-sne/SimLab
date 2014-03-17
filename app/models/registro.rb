class Registro < ActiveRecord::Base
  validates :atividade_id, :presence => true
  validates :autor_id, :presence => true
  validates :modificacao, :presence => true

  belongs_to :atividade
  belongs_to :autor, :class_name => "Usuario"

  def modificação
    modificacao
  end

  def modificação=(valor)
    modificacao = valor
  end

  def atividade_mudanças_em_modificação(hash)
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
          log << " adicionou um projeto,"
        else
          log << (" alterou o projeto de " + Projeto.find(valores.first).nome + " para " + Projeto.find(valores.last).nome + ",")
        end
      when "aprovacao"
        log << " alterou a aprovação,"
      when "avaliador_id"
        if valores.first.nil?
          log << " virou avaliador,"
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

  def par_mudança_em_modificação(hash)
    log = String.new
    hash.each do |atributo, valores|
      case atributo
      when "par_id"
        if valores.first.nil?
          log << " adicionou um par,"
        else
          log << (" alterou um par de " + Usuario.find(valores.first).nome + " para " +
            Usuario.find(valores.last).nome + ",")
        end
      when "duracao"
        if valores.first.nil?
          log << " adicionou " + Time.at(valores.first).utc.strftime("%H:%M") + " a um pareamento,"
        else
          log << (" atualizou a duração de " + Time.at(valores.first).utc.strftime("%H:%M") +
            " para " + Time.at(valores.last).utc.strftime("%H:%M") + " em um pareamento,")
        end
      end
    end
    self.modificacao = log[0..-2]
  end

end
