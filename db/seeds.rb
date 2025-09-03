# テスト用シードデータ

# 組織を作成
organization = Organization.create!(
  name: 'テック株式会社',
  description: 'ポジティブフィードバックをテストするための組織です',
  domain: 'tech.example.com',
  active: true
)

puts "Created organization: #{organization.name}"

# 部署を作成
engineering = Department.create!(
  organization: organization,
  name: 'エンジニアリング部',
  description: 'プロダクト開発を担当',
  active: true
)

design = Department.create!(
  organization: organization,
  name: 'デザイン部',
  description: 'UI/UXデザインを担当',
  active: true
)

sales = Department.create!(
  organization: organization,
  name: '営業部',
  description: '営業・マーケティングを担当',
  active: true
)

puts "Created departments: Engineering, Design, Sales"

# 管理者ユーザーを作成
admin = User.create!(
  organization: organization,
  email: 'admin@tech.example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: '管理',
  last_name: '太郎',
  display_name: '管理太郎',
  job_title: 'システム管理者',
  role: 'admin',
  active: true
)

puts "Created admin user: #{admin.display_name}"

# 一般ユーザーを作成
users_data = [
  { email: 'taro@tech.example.com', first_name: '太郎', last_name: '田中', job_title: 'シニアエンジニア', department: engineering },
  { email: 'hanako@tech.example.com', first_name: '花子', last_name: '佐藤', job_title: 'UI/UXデザイナー', department: design },
  { email: 'jiro@tech.example.com', first_name: '次郎', last_name: '山田', job_title: '営業マネージャー', department: sales },
  { email: 'yuki@tech.example.com', first_name: '雪子', last_name: '高橋', job_title: 'エンジニア', department: engineering },
  { email: 'ken@tech.example.com', first_name: '健', last_name: '鈴木', job_title: 'プロダクトマネージャー', department: engineering },
]

users = users_data.map do |user_data|
  User.create!(
    organization: organization,
    email: user_data[:email],
    password: 'password123',
    password_confirmation: 'password123',
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    display_name: "#{user_data[:first_name]}#{user_data[:last_name]}",
    job_title: user_data[:job_title],
    department: user_data[:department],
    role: 'member',
    active: true
  )
end

puts "Created #{users.count} member users"

# サンプルフィードバックを作成
feedback_messages = [
  { category: 'gratitude', message: 'プロジェクトでのサポートありがとうございました！とても助かりました。' },
  { category: 'admiration', message: '素晴らしいデザインですね！ユーザビリティが格段に向上しました。' },
  { category: 'appreciation', message: '遅い時間まで対応お疲れさまでした。品質の高い成果物でした。' },
  { category: 'respect', message: 'さすがの判断力ですね！リスクを適切に回避できました。' },
  { category: 'gratitude', message: 'レビューでの的確な指摘、ありがとうございます。勉強になりました。' },
  { category: 'admiration', message: '短期間でここまで仕上げるなんて、すごい実行力ですね！' },
]

# フィードバックをランダムに作成
20.times do
  sender = users.sample
  receiver = (users - [sender]).sample
  feedback_data = feedback_messages.sample
  
  Feedback.create!(
    sender: sender,
    receiver: receiver,
    organization: organization,
    category: feedback_data[:category],
    message: feedback_data[:message],
    is_anonymous: [true, false].sample
  )
end

puts "Created 20 sample feedbacks"

# サンプルリアクションを作成
Feedback.all.sample(10).each do |feedback|
  # ランダムなユーザーがリアクション
  reactor = (users - [feedback.sender]).sample
  reaction_type = FeedbackReaction.reaction_types.keys.sample
  
  FeedbackReaction.create!(
    feedback: feedback,
    user: reactor,
    reaction_type: reaction_type
  )
end

puts "Created sample reactions"

puts "\n=== Seed data created successfully! ==="
puts "Organization: #{organization.name}"
puts "Admin user: admin@tech.example.com / password123"
puts "Test users:"
users_data.each do |user_data|
  puts "  #{user_data[:email]} / password123"
end
puts "\nYou can now test the API endpoints!"
