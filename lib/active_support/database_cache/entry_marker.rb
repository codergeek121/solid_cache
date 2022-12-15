module ActiveSupport
  module DatabaseCache
    module EntryMarker
      def self.lookup(marker, **options)
        # require_relative cannot be used here because the class might be
        # provided by another gem, like redis-activesupport for example.
        require "active_support/database_cache/entry_marker/#{marker}"
      rescue LoadError => e
        raise "Could not find read marker adapter for #{marker} (#{e})"
      else
        EntryMarker.const_get(marker.to_s.camelize).new(**options)
      end
    end
  end
end
