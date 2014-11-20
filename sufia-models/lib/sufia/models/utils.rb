module Sufia
  module Utils
    extend ActiveSupport::Concern

    def retry_unless(*args, &block)
      self.class.retry_unless(*args, &block)
    end

    def retry_rescue(*args, &block)
      self.class.retry_rescue(*args, &block)
    end

    module ClassMethods
      def retry_unless(enumerator, callable, &block)
        enumerator.each do
          result = block.call
          return result unless condition.call
        end
        raise RuntimeError, "retry_unless could not complete successfully. Try upping the # of tries?"
      end

      def retry_rescue(enumerator, exception, &block)
        enumerator.each do
          begin
            result = block.call
          rescue exception
            next
          else
            return result
          end
        end
        raise exception, "retry_rescue could not complete successfully. Try upping the # of tries?"
      end
    end
  end
end
