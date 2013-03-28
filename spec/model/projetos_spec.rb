require 'spec_helper'

describe Projeto do
  it "verifica criacao" do
    user = FactoryGirl.build :projeto, name: "Atlas"
    assert_equal user.name, "Atlas"
  end
end