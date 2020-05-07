# Copyright 2014-present Greg Hurrell. All rights reserved.
# Licensed under the terms of the BSD 2-clause license.

require 'open3'

module CommandT
  class Scanner
    class FileScanner
      # Uses svn ls -R to scan for files
      class SVNFileScanner < FindFileScanner
        LsFilesError = Class.new(::RuntimeError)

        def paths!
          Dir.chdir(@path) do
            command = %w[svn ls -R]
            all_files = list_files(command)

            filtered = all_files.
              map { |path| path.chomp }.
              reject { |path| path.end_with?("/") }.
              reject { |path| path_excluded?(path, 0) }
            truncated = filtered.take(@max_files)
            if truncated.count < filtered.count
              show_max_files_warning
            end
            truncated.to_a
          end
        rescue LsFilesError
          super
        rescue Errno::ENOENT
          # svn executable not present and executable
          super
        end

      private

        def list_files(command)
          stdin, stdout, stderr = Open3.popen3(*command)
          stdout.read.split("\n")
        ensure
          raise LsFilesError if stderr && stderr.gets
        end

      end
    end
  end
end
