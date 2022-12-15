module ActiveSupport
  module DatabaseCache
    module EntryMarker
      class Async
        attr_reader :batch_size, :queue, :marker_thread, :writing_role

        def initialize(writing_role: nil, batch_size: 50, queue_size: 1000)
          @writing_role = writing_role
          @batch_size = batch_size
          @queue = SizedQueue.new(queue_size)
          @marker_thread = Thread.new { mark_loop }
        end

        def mark(ids)
          Array(ids).each { |id| queue.push(id) }
        end

        private
          def mark_loop
            record_ids = []
            loop do
              record_ids << queue.pop

              if record_ids.size == batch_size
                if writing_role
                  DatabaseCache::ApplicationRecord.connected_to(role: writing_role) { Entry.touch(record_ids) }
                else
                  Entry.touch(record_ids)
                end
                record_ids = []
              end
            end
          end
      end
    end
  end
end
