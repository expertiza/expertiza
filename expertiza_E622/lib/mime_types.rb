module Mime
  class Types
    # Load Apache compatible mime.types file.
    # Adapted from WEBrick::HTTPUtils
    # Returns { 'mime/type' => ['ext1', 'ext2'] }
    #
    # Author: IPR -- Internet Programming with Ruby -- writers
    # Copyright (c) 2000, 2001 TAKAHASHI Masayoshi, GOTOU Yuuzou
    # Copyright (c) 2002 Internet Programming with Ruby writers. All rights reserved.
    def self.load_mime_types(file)
      open(file){ |io|
        hash = Hash.new
        io.each{ |line|
          next if /^#/ =~ line
          line.chomp!
          mimetype, ext0 = line.split(/\s+/, 2)
          next unless ext0
          next if ext0.empty?
          #ext0.split(/\s+/).each{ |ext| hash[ext] = mimetype }
          hash[mimetype] = ext0.split
        }
        hash
      }
    rescue
      {}
    end

    # Register mime types in file and return the newly registered types
    # Returns newly loaded extensions [['ext1'], ['ext2a', 'ext2b']]
    def self.import_apache_mime_types(file='/etc/mime.types')
      types = self.load_mime_types(file).map do |type, extensions|
        primary_ext = extensions.shift
        # Don't overwrite extensions that are already registered.
        # Also html stuff is already defined, and loading some of apache's makes xhtml go strict
        unless Mime.constants.include?(primary_ext.to_s.upcase) || type =~ /html/
          Mime::Type.register(type, primary_ext.to_sym, [], extensions) rescue nil # some extensions aren't constantizable. Ingore these
        end
      end
      types.compact
    end
  end
end
