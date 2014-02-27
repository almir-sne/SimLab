class Projeto < ActiveRecord::Base
  validates :data_de_inicio, :presence => true

  validates :descricao,      :presence => true

  validates :nome,           :presence  => true,
    :uniqueness => true

  belongs_to :super_projeto, :class_name => "Projeto"
  has_many :sub_projetos, :class_name => "Projeto", :foreign_key => "super_projeto_id", :dependent => :nullify
  has_many :atividades
  has_many :usuarios, :through => :workons
  has_many :workons, :dependent => :destroy
  has_many :boards
  has_many :ausencias
  has_many :campos
  has_many :dados, :through => :campos
  accepts_nested_attributes_for :workons, :allow_destroy => true
  accepts_nested_attributes_for :boards, :allow_destroy => true
  accepts_nested_attributes_for :sub_projetos, :reject_if => lambda { |a| a[:content].blank? }
  accepts_nested_attributes_for :campos, :allow_destroy => true
  accepts_nested_attributes_for :dados, :allow_destroy => true
  scope :ativo, where(ativo: true)
  scope :inativo, where(ativo: false)
  
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

  # fix temporário devido a problemas de compatibilidade com o cancan
  def autorizacao(usuario, acao)
    if usuario.role == 'admin'
      true
    else
      workon = workons.find_by(usuario_id: usuario.id)
      if workon
        case acao
        when "destroy"
          if workon.permissao.nome == "admin"
            true
          else
            false
          end
        when "edit"
          if workon
            true
          else
            false
          end
        when "update"
          if workon.permissao.nome == "admin" or workon.permissao.nome == "coordenador"
            true
          else
            false
          end
        end
      else
        false
      end
    end
  end

  def admins_ids
    workons.joins(:permissao).where{permissao.nome == "admin"}.map{|workon| workon.usuario_id}
  end

end
