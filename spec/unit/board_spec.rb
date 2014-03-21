require_relative '../spec_helper'

describe Board do
	describe "relationships" do
		it { should belong_to(:projeto) }
	end
end
