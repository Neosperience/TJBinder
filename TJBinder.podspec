#
#  Be sure to run `pod spec lint TJBinder.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "TJBinder"
  s.version      = "0.0.2"
  s.summary      = "TJBinder is a lightweight but still powerful iOS implementation Cocoa bindings."

  s.description  = "TJBinder is a lightweight but still powerful iOS implementation of the model -- view binding technology seen in Cocoa bindings for OS-X. The aim is the same: to create a \"technology that provide a means of keeping model and view values synchronized without you having to write a lot of glue code.\""

  s.homepage     = "https://github.com/Neosperience/TJBinder"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Janos Tolgyesi" => "janos.tolgyesi@gmail.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/Neosperience/TJBinder.git", :tag => "0.0.2" }

  s.frameworks   = "Foundation", "UIKit"

  s.requires_arc = true

  s.source_files = "TJBinder/**/*.{h,m}"

end
