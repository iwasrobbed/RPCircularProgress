Pod::Spec.new do |spec|
  spec.name         = "RPCircularProgress"
  spec.summary      = "Swift UIView subclass with circular progress properties."
  spec.version      = "0.2.3"
  spec.homepage     = "https://github.com/iwasrobbed/RPCircularProgress"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors      = { "Rob Phillips" => "rob@desideratalabs.co" }
  spec.source       = { :git => "https://github.com/iwasrobbed/RPCircularProgress.git", :tag => "v" + spec.version.to_s }
  spec.source_files = "Source"
  spec.platform		= :ios, "8.0"
  spec.requires_arc = true
end