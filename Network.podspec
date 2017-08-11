Pod::Spec.new do |s|
  s.name         = "Network2"
  s.version      = "0.3.0"
  s.summary      = "no summary"
  s.homepage     = "https://github.com/DingSoung/Network"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Ding Songwen" => "DingSoung@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/DingSoung/Network.git", :tag => "#{s.version}" }
  s.source_files  = "Network/*.swift"
  s.dependency "Extension"
end
