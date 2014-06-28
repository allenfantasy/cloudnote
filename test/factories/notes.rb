FactoryGirl.define do
  factory :note do
    sequence(:body) { |n| "Note No.#{n}" }
    timestamp Time.now.to_i.to_s
  end
end
