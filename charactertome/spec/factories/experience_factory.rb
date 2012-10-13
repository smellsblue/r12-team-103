FactoryGirl.define do
  factory :experience do
    tome
    label       "You gained random experience."
    value       25
    source_type "random"
  end
end
