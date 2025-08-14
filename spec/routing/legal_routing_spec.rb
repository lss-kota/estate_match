require 'rails_helper'

RSpec.describe LegalController, type: :routing do
  describe "routing" do
    it "routes to #terms" do
      expect(get: "/terms").to route_to("legal#terms")
    end

    it "routes to #privacy" do
      expect(get: "/privacy").to route_to("legal#privacy")
    end

    it "routes to #company" do
      expect(get: "/company").to route_to("legal#company")
    end

    it "routes to #tokutei" do
      expect(get: "/tokutei").to route_to("legal#tokutei")
    end
  end
end