require 'spec_helper'

describe BancoDeHora do
  it { should validate_presence_of :projeto_id }
  it { should validate_presence_of :usuario_id }
end