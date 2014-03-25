require_relative '../spec_helper'

describe Address do
  it { should belong_to(:usuario) }
end
