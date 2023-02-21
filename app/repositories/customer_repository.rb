# frozen_string_literal: true

class CustomerRepository
  class << self
    def save(customer)
      customer.save
    end

    def find(id, inactive_included: false)
      customer = Customer.find(id)
      return customer if inactive_included || customer.active?

      raise ActiveRecord::RecordNotFound
    end

    def all(inactive_included: false)
      return Customer.all if inactive_included

      Customer.where(active?: true)
    end
  end
end
