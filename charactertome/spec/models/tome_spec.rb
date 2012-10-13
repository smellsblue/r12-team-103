require "spec_helper"

describe Tome do
  it "allows updating values" do
    tome = FactoryGirl.create :tome, :profession => "OldProf"
    tome.update_value!(:attribute => "profession", :value => "New Profession").should include(:new_value => "New Profession")
    tome.update_value!(:attribute => "profession", :value => "   ").should include(:new_value => "New Profession")
    tome.update_value!(:attribute => "profession", :value => nil).should include(:new_value => "New Profession")
  end
end
