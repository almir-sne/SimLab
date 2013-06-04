class Dia < ActiveRecord::Base
  attr_accessible :entrada, :intervalo, :mes_id, :numero, :saida, :usuario_id

  belongs_to :usuario
  belongs_to :mes
	has_many :atividades, :dependent => :destroy

	accepts_nested_attributes_for :atividades

	attr_accessible :atividades_attributes

  validates :numero, :uniqueness => {:scope => :mes_id}

  def horas
    ((saida - entrada) - intervalo) / 3600
  end

  def formata_horas
    hora = (((saida - entrada) - intervalo) / 3600).to_i
    minuto = ((((saida - entrada) - intervalo) % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

  def formata_intervalo
    hora = (intervalo / 3600).to_i
    minuto = (( intervalo % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

	def bar_width
		width = horas.nil? ? "0" : (horas * 10).to_s
		width + "%"
	end

	def horas_atividades_formato
	  total_horas_atividade = 0
	  total_minutos_atividade = 0

	  self.atividades.each do |atividade|

	    if atividade.aprovacao
	      total_horas_atividade = total_horas_atividade + (atividade.horas.nil? ? 0 : (atividade.horas/3600)).to_i
        total_minutos_atividade = total_minutos_atividade + (atividade.horas.nil? ? 0 : ((atividade.horas % 3600) / 60)).to_i
	    end
	  end
	  total_horas_atividade.to_s.rjust(2, '0') + ":" + total_minutos_atividade.to_s.rjust(2, '0')
	end

	def horas_atividades
    retorno = 0
    self.atividades.each do |atividade|

      if atividade.aprovacao
        retorno = retorno + (atividade.horas.nil? ? 0 : atividade.horas.to_i)
      end
    end
    retorno/3600
  end

end
