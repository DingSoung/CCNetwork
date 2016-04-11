Pod::Spec.new do |s|
  s.name         = "CCNetwork"
  s.version      = "0.1.0"
  s.summary      = "HTTP tools"
  s.description  = <<-DESC
                   A  Network lib for iOS.
                   DESC
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/DingSoung/CCNetwork.git",
                     :tag => s.version }

  #s.source_files  = "CCKit/**/*.{swift}", "CCKit/**/**/*.{swift}"
  s.source_files  = "CCNetwork/CCNetwork.h"
  s.author             = { "SongWen Ding" => "DingSoung@gmail.com" }
  s.license      = "MIT"
  s.homepage     = "https://github.com/DingSoung/CCNetwork"
end
