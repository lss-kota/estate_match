require 'rails_helper'

RSpec.describe Partnership, type: :model do
  let(:agent) { create(:user, :agent) }
  let(:owner) { create(:user, :owner) }
  let(:partnership) { build(:partnership, agent: agent, owner: owner) }

  describe 'associations' do
    it { should belong_to(:agent).class_name('User') }
    it { should belong_to(:owner).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:agent_id) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:commission_rate) }
    it { should validate_numericality_of(:commission_rate).is_greater_than(0).is_less_than_or_equal_to(100) }
    
    it 'validates uniqueness of agent_id scoped to owner_id' do
      create(:partnership, agent: agent, owner: owner)
      duplicate_partnership = build(:partnership, agent: agent, owner: owner)
      expect(duplicate_partnership).not_to be_valid
      expect(duplicate_partnership.errors[:agent_id]).to include('has already been taken')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, active: 1, inactive: 2, terminated: 3) }
  end

  describe 'scopes' do
    let!(:active_partnership) { create(:partnership, status: :active) }
    let!(:pending_partnership) { create(:partnership, status: :pending) }
    let!(:terminated_partnership) { create(:partnership, status: :terminated) }

    describe '.active' do
      it 'returns only active partnerships' do
        expect(Partnership.active).to contain_exactly(active_partnership)
      end
    end

    describe '.pending' do
      it 'returns only pending partnerships' do
        expect(Partnership.pending).to contain_exactly(pending_partnership)
      end
    end

    describe '.for_agent' do
      it 'returns partnerships for specified agent' do
        expect(Partnership.for_agent(active_partnership.agent_id)).to contain_exactly(active_partnership)
      end
    end

    describe '.for_owner' do
      it 'returns partnerships for specified owner' do
        expect(Partnership.for_owner(active_partnership.owner_id)).to contain_exactly(active_partnership)
      end
    end
  end

  describe 'custom validations' do
    describe '#validate_user_types' do
      it 'is invalid when agent is not an agent' do
        buyer = create(:user, :buyer)
        partnership = build(:partnership, agent: buyer, owner: owner)
        expect(partnership).not_to be_valid
        expect(partnership.errors[:agent]).to include('は不動産業者である必要があります')
      end

      it 'is invalid when owner is not an owner' do
        buyer = create(:user, :buyer)
        partnership = build(:partnership, agent: agent, owner: buyer)
        expect(partnership).not_to be_valid
        expect(partnership.errors[:owner]).to include('はオーナーである必要があります')
      end
    end

    describe '#validate_dates' do
      it 'is invalid when ended_at is before started_at' do
        partnership = build(:partnership, 
                           started_at: 1.day.ago, 
                           ended_at: 2.days.ago)
        expect(partnership).not_to be_valid
        expect(partnership.errors[:ended_at]).to include('は開始日より後である必要があります')
      end
    end
  end

  describe 'instance methods' do
    describe '#activate!' do
      it 'sets status to active and started_at to current time' do
        partnership = create(:partnership, status: :pending, started_at: nil)
        freeze_time do
          partnership.activate!
          expect(partnership.status).to eq('active')
          expect(partnership.started_at).to eq(Time.current)
        end
      end
    end

    describe '#terminate!' do
      it 'sets status to terminated and ended_at to current time' do
        partnership = create(:partnership, status: :active, started_at: 1.day.ago, ended_at: nil)
        freeze_time do
          partnership.terminate!
          expect(partnership.status).to eq('terminated')
          expect(partnership.ended_at).to eq(Time.current)
        end
      end
    end

    describe 'mutual approval methods' do
      let(:partnership) { create(:partnership, status: :pending) }

      describe '#agent_request!' do
        it 'sets agent_requested_at to current time' do
          freeze_time do
            partnership.agent_request!
            expect(partnership.agent_requested_at).to eq(Time.current)
          end
        end

        it 'calls check_mutual_approval!' do
          expect(partnership).to receive(:check_mutual_approval!)
          partnership.agent_request!
        end

        context 'when both parties have requested' do
          it 'activates the partnership' do
            partnership.update!(owner_requested_at: 1.hour.ago)
            partnership.agent_request!
            expect(partnership.reload.status).to eq('active')
          end
        end
      end

      describe '#owner_request!' do
        it 'sets owner_requested_at to current time' do
          freeze_time do
            partnership.owner_request!
            expect(partnership.owner_requested_at).to eq(Time.current)
          end
        end

        it 'calls check_mutual_approval!' do
          expect(partnership).to receive(:check_mutual_approval!)
          partnership.owner_request!
        end

        context 'when both parties have requested' do
          it 'activates the partnership' do
            partnership.update!(agent_requested_at: 1.hour.ago)
            partnership.owner_request!
            expect(partnership.reload.status).to eq('active')
          end
        end
      end

      describe '#agent_requested?' do
        it 'returns true when agent_requested_at is present' do
          partnership.update!(agent_requested_at: Time.current)
          expect(partnership.agent_requested?).to be true
        end

        it 'returns false when agent_requested_at is nil' do
          partnership.update!(agent_requested_at: nil)
          expect(partnership.agent_requested?).to be false
        end
      end

      describe '#owner_requested?' do
        it 'returns true when owner_requested_at is present' do
          partnership.update!(owner_requested_at: Time.current)
          expect(partnership.owner_requested?).to be true
        end

        it 'returns false when owner_requested_at is nil' do
          partnership.update!(owner_requested_at: nil)
          expect(partnership.owner_requested?).to be false
        end
      end

      describe '#both_requested?' do
        it 'returns true when both agent and owner have requested' do
          partnership.update!(
            agent_requested_at: Time.current,
            owner_requested_at: Time.current
          )
          expect(partnership.both_requested?).to be true
        end

        it 'returns false when only agent has requested' do
          partnership.update!(
            agent_requested_at: Time.current,
            owner_requested_at: nil
          )
          expect(partnership.both_requested?).to be false
        end

        it 'returns false when only owner has requested' do
          partnership.update!(
            agent_requested_at: nil,
            owner_requested_at: Time.current
          )
          expect(partnership.both_requested?).to be false
        end
      end

      describe '#cancel_request!' do
        context 'when called by agent' do
          it 'clears agent_requested_at' do
            partnership.update!(agent_requested_at: Time.current)
            partnership.cancel_request!(agent)
            expect(partnership.reload.agent_requested_at).to be_nil
          end
        end

        context 'when called by owner' do
          it 'clears owner_requested_at' do
            partnership.update!(owner_requested_at: Time.current)
            partnership.cancel_request!(owner)
            expect(partnership.reload.owner_requested_at).to be_nil
          end
        end
      end
    end

    describe '#mutual_approval_status' do
      let(:partnership) { create(:partnership, agent: agent, owner: owner) }

      context 'when called by agent' do
        context 'when both requested and active' do
          it 'returns :approved' do
            partnership.update!(
              agent_requested_at: Time.current,
              owner_requested_at: Time.current,
              status: :active
            )
            expect(partnership.mutual_approval_status(agent)).to eq(:approved)
          end
        end

        context 'when agent requested but waiting for owner' do
          it 'returns :waiting_for_owner' do
            partnership.update!(
              agent_requested_at: Time.current,
              owner_requested_at: nil
            )
            expect(partnership.mutual_approval_status(agent)).to eq(:waiting_for_owner)
          end
        end

        context 'when owner requested but agent has not' do
          it 'returns :pending_approval' do
            partnership.update!(
              agent_requested_at: nil,
              owner_requested_at: Time.current
            )
            expect(partnership.mutual_approval_status(agent)).to eq(:pending_approval)
          end
        end

        context 'when neither has requested' do
          it 'returns :not_requested' do
            partnership.update!(
              agent_requested_at: nil,
              owner_requested_at: nil
            )
            expect(partnership.mutual_approval_status(agent)).to eq(:not_requested)
          end
        end
      end

      context 'when called by owner' do
        context 'when both requested and active' do
          it 'returns :approved' do
            partnership.update!(
              agent_requested_at: Time.current,
              owner_requested_at: Time.current,
              status: :active
            )
            expect(partnership.mutual_approval_status(owner)).to eq(:approved)
          end
        end

        context 'when owner requested but waiting for agent' do
          it 'returns :waiting_for_agent' do
            partnership.update!(
              agent_requested_at: nil,
              owner_requested_at: Time.current
            )
            expect(partnership.mutual_approval_status(owner)).to eq(:waiting_for_agent)
          end
        end

        context 'when agent requested but owner has not' do
          it 'returns :pending_approval' do
            partnership.update!(
              agent_requested_at: Time.current,
              owner_requested_at: nil
            )
            expect(partnership.mutual_approval_status(owner)).to eq(:pending_approval)
          end
        end

        context 'when neither has requested' do
          it 'returns :not_requested' do
            partnership.update!(
              agent_requested_at: nil,
              owner_requested_at: nil
            )
            expect(partnership.mutual_approval_status(owner)).to eq(:not_requested)
          end
        end
      end

      context 'when called by non-participant user' do
        let(:buyer) { create(:user, :buyer) }

        it 'returns :not_applicable' do
          expect(partnership.mutual_approval_status(buyer)).to eq(:not_applicable)
        end
      end
    end

    describe '#duration_days' do
      it 'returns 0 when started_at is nil' do
        partnership = build(:partnership, started_at: nil)
        expect(partnership.duration_days).to eq(0)
      end

      it 'calculates days from started_at to ended_at' do
        partnership = build(:partnership, 
                           started_at: 5.days.ago, 
                           ended_at: 2.days.ago)
        expect(partnership.duration_days).to eq(3)
      end

      it 'calculates days from started_at to current time when ended_at is nil' do
        partnership = build(:partnership, 
                           started_at: 3.days.ago, 
                           ended_at: nil)
        expect(partnership.duration_days).to eq(3)
      end
    end

    describe '#formatted_commission_rate' do
      it 'returns commission rate with % symbol' do
        partnership = build(:partnership, commission_rate: 5.5)
        expect(partnership.formatted_commission_rate).to eq('5.5%')
      end
    end
  end

  describe 'private methods' do
    describe '#check_mutual_approval!' do
      let(:partnership) { create(:partnership, status: :pending) }

      it 'activates partnership when both parties have requested' do
        partnership.update!(
          agent_requested_at: Time.current,
          owner_requested_at: Time.current
        )
        partnership.send(:check_mutual_approval!)
        expect(partnership.reload.status).to eq('active')
      end

      it 'does not activate when only one party has requested' do
        partnership.update!(
          agent_requested_at: Time.current,
          owner_requested_at: nil
        )
        partnership.send(:check_mutual_approval!)
        expect(partnership.reload.status).to eq('pending')
      end

      it 'does not activate when partnership is not pending' do
        partnership.update!(
          status: :active,
          agent_requested_at: Time.current,
          owner_requested_at: Time.current
        )
        partnership.send(:check_mutual_approval!)
        expect(partnership.reload.status).to eq('active')
      end
    end

    describe '#agent_owner_partnership?' do
      it 'returns true when agent is agent type and owner is owner type' do
        partnership = build(:partnership, agent: agent, owner: owner)
        expect(partnership.send(:agent_owner_partnership?)).to be true
      end

      it 'returns false when agent is not agent type' do
        buyer = create(:user, :buyer)
        partnership = build(:partnership, agent: buyer, owner: owner)
        expect(partnership.send(:agent_owner_partnership?)).to be false
      end

      it 'returns false when owner is not owner type' do
        buyer = create(:user, :buyer)
        partnership = build(:partnership, agent: agent, owner: buyer)
        expect(partnership.send(:agent_owner_partnership?)).to be false
      end
    end
  end
end
