module Sufia
  module GenericFile
    module ProxyDeposit
      extend ActiveSupport::Concern

      included do
        property :proxy_depositor, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#proxyDepositor') do |index|
          index.as :symbol
        end

        # This value is set when a user indicates they are depositing this for someone else
        property :on_behalf_of, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#onBehalfOf') do |index|
          index.as :symbol
        end

        after_create :create_transfer_request

        def proxy_depositor
          super.first
        end

        def on_behalf_of
          super.first
        end
      end


      def create_transfer_request
        Sufia.queue.push(ContentDepositorChangeEventJob.new(id, on_behalf_of)) if on_behalf_of.present?
      end

      def request_transfer_to(target)
        raise ArgumentError, "Must provide a target" unless target
        deposit_user = ::User.find_by_user_key(depositor)
        ProxyDepositRequest.create!(pid: id, receiving_user: target, sending_user: deposit_user)
      end
    end
  end
end
