module ActiveSupport::DatabaseCache
  class Entry < ApplicationRecord
    class << self
      def set(key, value, expires_at: nil)
        set_all([{key: key, value: value, expires_at: expires_at}])
      end

      def set_all(payloads, expires_at: nil)
        upsert_all(payloads, unique_by: upsert_unique_by, update_only: [ :value, :expires_at ])
      end

      def get(key, marker: nil)
        id, value = where(key: key).pick(:id, :value)
        marker.mark(id) if marker && id
        value
      end

      def get_all(keys, marker: nil)
        id_key_values = where(key: keys).pluck(:id, :key, :value)
        marker.mark(id_key_values.map { _1 }) if marker
        id_key_values.to_h { [_2, _3] }
      end

      def delete(key)
        where(key: key).delete_all.nonzero?
      end

      def delete_matched(matcher, batch_size:)
        like_matcher = arel_table[:key].matches(matcher, nil, true)
        where(like_matcher).select(:id).find_in_batches(batch_size: batch_size) do |entries|
          delete_by(id: entries.map(&:id))
        end
      end

      def increment(key, amount)
        transaction do
          amount += lock.pick_value(key).to_i
          set(key, amount)
          amount
        end
      end

      def touch(ids)
        where(id: ids).touch_all
      end

      def pick_value(key)
        where(key: key).pick(:value)
      end

      private
        def upsert_unique_by
          connection.supports_insert_conflict_target? ? :key : nil
        end
    end
  end
end
