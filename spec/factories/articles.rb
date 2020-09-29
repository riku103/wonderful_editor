FactoryBot.define do
  factory :article do
    title { Faker::Lorem.word }
    body { Faker::Lorem.sentence }
    # association :user
    # ⬇️factoryで定義してる名称が一致しているためOK
    user
  end
end
