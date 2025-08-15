require 'rails_helper'

RSpec.describe "Internationalization (i18n)", type: :request do
  describe "Japanese localization" do
    before do
      I18n.locale = :ja
    end
    
    after do
      I18n.locale = I18n.default_locale
    end

    it "displays Japanese locale correctly" do
      expect(I18n.locale).to eq(:ja)
    end

    it "translates ActiveRecord model names to Japanese" do
      expect(Property.model_name.human).to eq("物件")
      expect(User.model_name.human).to eq("ユーザー")
    end

    it "translates Property attributes to Japanese" do
      expect(Property.human_attribute_name(:title)).to eq("物件名")
      expect(Property.human_attribute_name(:description)).to eq("説明")
      expect(Property.human_attribute_name(:prefecture)).to eq("都道府県")
    end

    it "translates User attributes to Japanese" do
      expect(User.human_attribute_name(:email)).to eq("メールアドレス")
      expect(User.human_attribute_name(:password)).to eq("パスワード")
    end

    it "translates time distance words to Japanese" do
      travel_to Time.current do
        past_time = 5.minutes.ago
        distance = ActionController::Base.helpers.time_ago_in_words(past_time)
        expect(distance).to eq("5分")
      end
    end

    it "translates date formats to Japanese" do
      date = Date.new(2025, 8, 14)
      expect(I18n.l(date)).to eq("2025年08月14日")
    end

    it "translates error messages to Japanese" do
      property = Property.new(title: "", prefecture: "")
      property.valid?
      
      error_messages = property.errors.full_messages
      expect(error_messages).to include("物件名 を入力してください")
    end

    it "translates Devise error messages to Japanese" do
      expect(I18n.t('devise.failure.invalid')).to eq("メールアドレスまたはパスワードが正しくありません。")
      expect(I18n.t('devise.registrations.signed_up')).to eq("アカウント登録が完了しました。ようこそ！")
    end

    context "when viewing property listing page" do
      let(:owner) { create(:user, :owner) }
      
      before do
        3.times { create(:property, user: owner, status: :active) }
      end

      it "displays Japanese text on properties index" do
        get properties_path
        expect(response.body).to include("件の物件")
        expect(response.body).to include("物件を探す")
        expect(response.body).to include("検索条件")
      end
    end

    context "when user registration has errors" do
      it "responds with error status" do
        post user_registration_path, params: {
          user: {
            email: "invalid_email",
            password: "short",
            password_confirmation: "different"
          }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end