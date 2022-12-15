module ActiveSupport
  module DatabaseCache
    module EntryMarker
      class Sync
        attr_reader :writing_role

        def initialize(writing_role: nil)
          @writing_role = writing_role
        end

        def mark(record_id)
          if writing_role
            DatabaseCache::ApplicationRecord.connected_to(role: writing_role) { Entry.touch(record_id) }
          else
            Entry.touch(record_id)
          end
        end
      end
    end
  end
end
