class Projeto < ActiveRecord::Base
  attr_accessible :data_de_inicio, :descricao, :nome, :workons_attributes, :super_projeto_id, :sub_projetos_attributes

  validates :data_de_inicio, :presence => true

  validates :descricao,      :presence => true

  validates :nome,           :presence  => true,
                             :uniqueness => true

  belongs_to :super_projeto, :class_name => "Projeto"
  has_many :sub_projetos, :class_name => "Projeto", :foreign_key => "super_projeto_id", :dependent => :nullify
  has_many :atividades
  has_many :usuarios,  :through => :workon
  has_many :workons
  has_many :boards
  accepts_nested_attributes_for :workons, :allow_destroy => true
  accepts_nested_attributes_for :boards, :allow_destroy => true
  accepts_nested_attributes_for :sub_projetos, :reject_if => lambda { |a| a[:content].blank? }

  #def coordenadores
    #self.usuarios.includes(:workon).where("workons.coordenador" => true)
  #end

  #def coordenadores
     #self.usuarios.includes(:workon).where("workons.coordenador" => true) |
       #(super_projeto.nil? ? [] : super_projeto.try(:usuarios).includes(:workon).where("workons.coordenador" => true))
  #end


  def horas_totais
    if sub_projetos.blank?
      (atividades.where(:aprovacao => true).sum(:duracao)/3600).to_i
    else
      sub_projetos.map{|proj| proj.horas_totais}.sum
    end
  end

  def valor
    if sub_projetos.blank?
      atividades.joins(:usuario => :contratos).
        where("atividades.aprovacao = 1 and contratos.inicio < atividades.data and contratos.fim >= atividades.data").
        sum("atividades.duracao/3600 * contratos.valor_hora").to_i
    else
      sub_projetos.map{ |proj| proj.valor }.sum
    end
  end
end
