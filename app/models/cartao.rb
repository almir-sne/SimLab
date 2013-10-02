class Cartao < ActiveRecord::Base
  attr_accessible :atividade_id, :cartao_id, :duracao
  belongs_to :atividade
  
  validates :atividade_id, :presence => true
  
  def self.horas_trabalhadas(cid)
    Cartao.where(cartao_id: cid).sum(:duracao)/60
  end
  
  def self.update_on_trello(key, token, id)
    data = get_trello_data(key, token, id)
    name = data["name"].sub(/[ ][(][0-9]+[)]/, "") +
      " (" + Cartao.horas_trabalhadas(id).to_s + ")"
    uri = URI('https://trello.com/1/cards/' + id + '/name')
    uri.query = URI.encode_www_form({:key => key, :token => token })
    req = Net::HTTP::Put.new(uri)
    req.set_form_data({"value" => name})
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.request(req)
  end
  
  def self.get_trello_data(key, token, id)
    uri = URI('https://trello.com/1/cards/' + id)
    uri.query = URI.encode_www_form({:key => key, :token => token })
    response = Net::HTTP.get_response(uri)
    JSON.parse response.body
  end
end
