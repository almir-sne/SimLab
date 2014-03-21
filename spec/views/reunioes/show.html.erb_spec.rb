require 'spec_helper'

describe "reunioes/show" do
  before(:each) do
    @reuniao = assign(:reuniao, stub_model(Reuniao,
      :projeto_id => 1,
      :criador_id => 2,
      :concluida => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/false/)
  end
end
