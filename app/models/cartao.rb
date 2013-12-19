class Cartao < ActiveRecord::Base
  validates :trello_id, :uniqueness => true, :presence => true

  has_many :atividades
  has_many :rodadas

  belongs_to :pai, :class_name => "Cartao"
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :tags

  def self.horas_trabalhadas(trello_id)
    Cartao.where(trello_id: trello_id).last.atividades.sum(:duracao)/3600
  end

  def self.horas_trabalhadas_format(cid)
    h = self.horas_trabalhadas(cid)
    "#{h.to_i}:#{((h - h.to_i) * 60).round}"
  end

  def rodada_aberta?
    !self.rodadas.where(fechada: false).blank?
  end

  def fechar_rodada(user)
    rodada = self.rodadas.where(fechada: false).last
    if rodada
      rodada.fechada = true
      rodada.fim = Time.now
      rodada.finalizador = user
      rodada.save
    end
  end

  def self.update_on_trello(key, token, id, tags)
    data = get_trello_data(key, token, id)
    unless (data == :error)
      regex_horas = /[ ][(]\d+[.]?\d*[)]$/

      horas_remoto = data["name"].match(regex_horas).to_s.match(/\d+[.]?\d*+/).to_s

      tags_remoto = extract_tags(data["name"])

      horas_local = "%.1f" % Cartao.horas_trabalhadas(id)
      nome_novo = remove_tags(data["name"]);
      tags_texto = ""
      unless tags.nil?
        tags.each do |t|
          tags_texto += "[" + t.to_s + "] "
        end
        if (!tags_texto.blank?)
          nome_novo = tags_texto + " " + nome_novo
        end
      end

      if (horas_remoto != horas_local)
        name = "#{nome_novo.sub(regex_horas, "")} (#{horas_local})"
      else
        name = nome_novo
      end
      uri = URI('https://trello.com/1/cards/' + id + '/name')
      uri.query = URI.encode_www_form({:key => key, :token => token })
      req = Net::HTTP::Put.new(uri)
      req.set_form_data({"value" => name})
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      http.request(req)
    end
  end

  def self.get_trello_data(key, token, id)
    uri = URI('https://trello.com/1/cards/' + id)
    uri.query = URI.encode_www_form({:key => key, :token => token })
    response = Net::HTTP.get_response(uri)
    if response.code == "200"
      JSON.parse response.body
    else
      :error
    end
  end
end
