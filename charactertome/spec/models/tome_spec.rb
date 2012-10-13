require "spec_helper"

describe Tome do
  it "allows updating values" do
    tome = FactoryGirl.create :tome, :profession => "OldProf"
    tome.update_value!(:attribute => "profession", :value => "New Profession").should include(:new_value => "New Profession")
    tome.update_value!(:attribute => "profession", :value => "   ").should include(:new_value => "New Profession")
    tome.update_value!(:attribute => "profession", :value => nil).should include(:new_value => "New Profession")
  end

  it "will give experience when setting an attribute" do
    original_tome = FactoryGirl.create :tome, :profession => nil
    tome = Tome.find original_tome.id
    current_xp = tome.xp_total
    result = tome.update_value! :attribute => "profession", :value => "New Profession"
    result.should include(:new_xp_total => current_xp + 25, :xp_gained => 25)
    tome.xp_total.should == (current_xp + 25)
  end

  it "will only give experience for setting an attribute once" do
    original_tome = FactoryGirl.create :tome, :profession => nil
    tome = Tome.find original_tome.id
    tome.update_value! :attribute => "profession", :value => "New Profession"
    tome = Tome.find original_tome.id
    tome.profession = nil
    tome.save!
    tome = Tome.find original_tome.id
    current_xp = tome.xp_total
    result = tome.update_value! :attribute => "profession", :value => "New Profession 2"
    Experience.where(:tome_id => tome.id, :source_type => "profession").size.should == 1
    result.should include(:new_xp_total => current_xp, :xp_gained => 0)
    tome.xp_total.should == current_xp
  end

  it "updates the level after save" do
    original_tome = Tome.create! :owner => FactoryGirl.create(:owner)
    FactoryGirl.create :experience, :tome => original_tome, :value => 1000
    tome = Tome.find original_tome.id
    current_level = tome.level
    result = tome.update_value! :attribute => "profession", :value => "New Profession"
    result.should include(:levels_gained => (5 - current_level), :new_level => 5)
    tome.level.should == 5
  end

  it "allows getting xp cutoff levels" do
    Tome.xp_cutoff(0).should == 0
    Tome.xp_cutoff(1).should == 0
    Tome.xp_cutoff(2).should == 100
    Tome.xp_cutoff(3).should == 300
    Tome.xp_cutoff(4).should == 600
    Tome.xp_cutoff(5).should == 1000
    Tome.xp_cutoff(6).should == 1500
    Tome.xp_cutoff(7).should == 2100
    Tome.xp_cutoff(8).should == 2800
    Tome.xp_cutoff(9).should == 3600
  end
end
