FactoryGirl.define do
  factory :user, :aliases => [:owner] do
    name  "John Doe"
    email "john.doe@example.com"
  end
end
