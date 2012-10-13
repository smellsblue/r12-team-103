require "spec_helper"

describe TomesController do
  let(:my_user) { FactoryGirl.create :user }
  let(:my_tome) { FactoryGirl.create :tome, :owner => my_user }

  describe "going to 'my tome'" do
    it "creates a user if the session has none" do
      User.should_receive(:create!).with().and_return(my_user)
      get :me
      response.should redirect_to("/tomes/#{my_user.id}")
    end

    it "uses the existing user if the session has one" do
      session[:user_id] = my_user.id
      get :me
      response.should redirect_to("/tomes/#{my_user.id}")
    end

    it "creates a tome if the user doesn't have one" do
      session[:user_id] = my_user.id
      User.find(my_user.id).tome.should_not be
      get :me
      User.find(my_user.id).tome.should be
    end

    it "uses the existing tome if the user has one" do
      session[:user_id] = my_user.id
      my_tome
      get :me
      Tome.where(:owner_id => my_user.id).size.should == 1
    end
  end
end
