FactoryGirl.define do
  factory :tome do
    owner
    level              3
    profession         "Dude"
    name               "Findrall Fourblades"
    intelligence       77
    charisma           65
    strength           57
    wisdom             66
    will               68
    confidence         44
    morality           77
    ethics             68
    publicly_available true
  end
end
