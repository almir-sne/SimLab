require_relative '../spec_helper'

describe Anexo do
	it { should belong_to(:usuario) }
	it { should belong_to(:pagamento) }
	it { should belong_to(:ausencia) }
end
