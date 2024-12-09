FactoryBot.define do
  factory :sleep_record do
    association :user
    sleep_time { Time.now - 8.hours }
    wake_time { Time.now }
  end
end
