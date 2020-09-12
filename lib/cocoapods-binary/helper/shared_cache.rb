require 'digest'
require_relative '../tool/tool'

module Pod
    class Prebuild
        class SharedCache
            extend Config::Mixin

            # `true` if there is cache for the target
            # `false` otherwise
            #
            # @return [Boolean]
            def self.has?(target, options)
                has_local_cache_for?(target, options)
            end

            # `true` if there is local cache for the target
            # `false` otherwise
            #
            # @return [Boolean]
            def self.has_local_cache_for?(target, options)
                if Podfile::DSL.shared_cache_enabled
                    path = local_framework_cache_path_for(target, options)
                    path.exist?
                else
                    false
                end
            end

            # Copies input_path to target's cache
            def self.cache(target, input_path, options)
                if not Podfile::DSL.shared_cache_enabled
                    return
                end
                cache_path = local_framework_cache_path_for(target, options)
                cache_path.mkpath unless cache_path.exist?
                FileUtils.cp_r "#{input_path}/.", cache_path
            end

            # Path of the target's local cache
            #
            # @return [Pathname]
            def self.local_framework_cache_path_for(target, options)
                framework_cache_path = cache_root + xcode_version
                framework_cache_path = framework_cache_path + target.name
                framework_cache_path = framework_cache_path + target.version
                options_with_platform = options + [target.platform.name]
                framework_cache_path = framework_cache_path + Digest::MD5.hexdigest(options_with_platform.to_s).to_s
            end

            # Current xcode version.
            #
            # @return [String]
            private
            class_attr_accessor :xcode_version
            # Converts from "Xcode 10.2.1\nBuild version 10E1001\n" to "10.2.1".
            self.xcode_version = `xcodebuild -version`.split("\n").first.split().last || "Unkwown"

            # Path of the cache folder
            # Reusing cache_root from cocoapods's config
            # `~Library/Caches/CocoaPods` is default value
            #
            # @return [Pathname]
            private
            class_attr_accessor :cache_root
            self.cache_root = config.cache_root + 'Prebuild'
        end
    end
end
