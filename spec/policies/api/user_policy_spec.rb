# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::UserPolicy do
  subject { described_class }

  describe '#show?' do
    it 'returns true if users id matches id parameter' do
      user = build_stubbed(:user)
      id = user.id

      expect(subject.show?(user, id)).to be_truthy
    end

    it 'returns true if user is admin' do
      user = build_stubbed(:user, :admin)

      expect(subject.show?(user, nil)).to be_truthy
    end

    it 'returns false if users id does not match id parameter and user is not an admin' do
      user = build_stubbed(:user)
      id = 'invalid_id'

      expect(subject.show?(user, id)).to be_falsey
    end
  end

  describe '#create?' do
    it 'returns true if users is not admin but has permitted roles' do
      user = create(:user, :superuser)

      expect(subject.create?(user)).to be_truthy
    end

    it 'returns true if user is admin' do
      user = build_stubbed(:user, :admin)

      expect(subject.create?(user)).to be_truthy
    end

    it 'returns false if users is not admin and has unpermitted roles' do
      user = create(:user, :operator)

      expect(subject.create?(user)).to be_falsey
    end
  end
end
