class CreateSampleTags < ActiveRecord::Migration[8.0]
  def up
    # 条件系タグ
    Tag.create!([
      { name: "賃貸可", color: "#28a745", category: "条件", description: "賃貸として利用可能" },
      { name: "売買可", color: "#007bff", category: "条件", description: "売買対象物件" },
      { name: "即入居可", color: "#17a2b8", category: "条件", description: "すぐに入居できます" },
      { name: "事業用可", color: "#6c757d", category: "条件", description: "事業用途での利用可能" }
    ])

    # 設備系タグ
    Tag.create!([
      { name: "駐車場あり", color: "#6f42c1", category: "設備", description: "駐車場完備" },
      { name: "ペット可", color: "#e83e8c", category: "設備", description: "ペット飼育可能" },
      { name: "エアコン付", color: "#20c997", category: "設備", description: "エアコン設置済み" },
      { name: "インターネット完備", color: "#fd7e14", category: "設備", description: "インターネット環境完備" }
    ])

    # 状態系タグ
    Tag.create!([
      { name: "リフォーム済み", color: "#ffc107", category: "状態", description: "リフォーム・リノベーション済み" },
      { name: "新築", color: "#dc3545", category: "状態", description: "新築物件" },
      { name: "古民家", color: "#795548", category: "状態", description: "趣のある古民家" },
      { name: "空き家", color: "#9e9e9e", category: "状態", description: "現在空き家状態" }
    ])
  end

  def down
    Tag.delete_all
  end
end
