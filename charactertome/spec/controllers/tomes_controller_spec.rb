require "spec_helper"

describe TomesController do
  describe "going to 'my tome'" do
    it "creates a user if the session has none"
    it "uses the existing user if the session has one"
    it "creates a tome if the user doesn't have one"
    it "uses the existing tome if the user has one"
  end
end
