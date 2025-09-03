# 追加の100件のフィードバックデータを生成

categories = ['gratitude', 'admiration', 'appreciation', 'respect']
messages = {
  'gratitude' => [
    'いつもお疲れ様です。ありがとうございます！',
    '昨日の資料作成、とても助かりました。',
    'プロジェクトの成功はあなたのおかげです。',
    'いつも丁寧な説明をありがとうございます。',
    '困った時にいつも助けてくれてありがとう。',
    'レビューをしていただき、ありがとうございました。',
    '急なお願いにも快く対応してくださりありがとうございます。',
    'ミーティングでの貴重なご意見、ありがとうございました。'
  ],
  'admiration' => [
    '技術力の高さにいつも感心しています！',
    'あの複雑な問題をすぐに解決するなんてすごい！',
    'プレゼンテーションが素晴らしかったです。',
    '新しいアイデアがいつも斬新ですね。',
    'デバッグのスピードと正確性に驚きました。',
    'コードの品質が本当に高いですね。',
    'チームをまとめる力がすごいです。',
    'クリエイティブな解決策に感動しました。'
  ],
  'appreciation' => [
    '長時間の作業、本当にお疲れ様でした。',
    'プロジェクトの進行管理、お疲れ様です。',
    '細かい調整作業、お疲れ様でした。',
    'テストの実行、お疲れ様でした。',
    'ドキュメントの整備、お疲れ様です。',
    '品質管理の徹底、お疲れ様でした。',
    '夜遅くまでの対応、お疲れ様でした。',
    'バグ修正の作業、お疲れ様です。'
  ],
  'respect' => [
    '的確な判断力にいつも感服しています。',
    '困難な状況での冷静な対応、さすがです。',
    '豊富な経験に基づくアドバイス、さすがですね。',
    'チームのことを第一に考える姿勢、尊敬します。',
    '高い専門知識と人格、さすがです。',
    '後輩への指導方法、見習いたいです。',
    'プロフェッショナルな姿勢、さすがです。',
    '責任感の強さに頭が下がります。'
  ]
}

# すべてのユーザーIDを取得
user_ids = User.pluck(:id)

puts "#{user_ids.length} users found"
puts "Creating 100 additional feedback records..."

100.times do |i|
  category = categories.sample
  sender_id = user_ids.sample
  receiver_id = (user_ids - [sender_id]).sample # 送信者と受信者が同じにならないように
  
  # ランダムな過去30日以内の日付を生成
  created_at = rand(30.days.ago..Time.current)
  
  feedback = Feedback.create!(
    sender_id: sender_id,
    receiver_id: receiver_id,
    organization_id: 1, # 組織IDは1固定
    category: category,
    message: messages[category].sample,
    is_anonymous: [true, false].sample,
    created_at: created_at,
    updated_at: created_at
  )
  
  print "." if (i + 1) % 10 == 0
end

puts "\n✅ Successfully created 100 additional feedback records!"
puts "Total feedback count: #{Feedback.count}"

# カテゴリ別の内訳を表示
puts "\nFeedback by category:"
Feedback.group(:category).count.each do |category, count|
  puts "  #{category}: #{count}"
end