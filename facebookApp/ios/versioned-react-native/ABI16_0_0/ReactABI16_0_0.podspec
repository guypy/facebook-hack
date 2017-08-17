# coding: utf-8
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']

source = { :git => 'https://github.com/facebook/react-native.git' }
if version == '1000.0.0'
  # This is an unpublished version, use the latest commit hash of the react-native repo, which we’re presumably in.
  source[:commit] = `git rev-parse HEAD`.strip
else
  source[:tag] = "v#{version}"
end

Pod::Spec.new do |s|
  s.name                    = "ReactABI16_0_0"
  s.version                 = version
  s.summary                 = package["description"]
  s.description             = <<-DESC
                                React Native apps are built using the React JS
                                framework, and render directly to native UIKit
                                elements using a fully asynchronous architecture.
                                There is no browser and no HTML. We have picked what
                                we think is the best set of features from these and
                                other technologies to build what we hope to become
                                the best product development framework available,
                                with an emphasis on iteration speed, developer
                                delight, continuity of technology, and absolutely
                                beautiful and fast products with no compromises in
                                quality or capability.
                             DESC
  s.homepage                = "http://facebook.github.io/react-native/"
  s.license                 = package["license"]
  s.author                  = "Facebook"
  s.source                  = { :path => "." }
  s.default_subspec         = "Core"
  s.requires_arc            = true
  s.platform                = :ios, "8.0"
  s.pod_target_xcconfig     = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++14" }
  s.preserve_paths          = "package.json", "LICENSE", "LICENSE-CustomComponents", "PATENTS"
  s.cocoapods_version       = ">= 1.2.0"

  s.subspec "Core" do |ss|
    ss.dependency             "YogaABI16_0_0", "#{package["version"]}.React"
    ss.dependency             "ReactABI16_0_0/cxxReactABI16_0_0"
    ss.source_files         = "React/**/*.{c,h,m,mm,S}"
    ss.exclude_files        = "**/__tests__/*", "IntegrationTests/*", "React/DevSupport/*", "React/Modules/ABI16_0_0RCTDev{LoadingView,Menu}.*", "React/**/ABI16_0_0RCTTVView.*", "ReactCommon/ABI16_0_0yoga/*", "React/Cxx*/*"
    ss.framework            = "JavaScriptCore"
    ss.libraries            = "stdc++"
  end

  s.subspec "Exponent" do |ss|
    ss.dependency         "ReactABI16_0_0/Core"
    ss.source_files     = "Exponent/**/*.{h,m}"
  end

  s.subspec "DevSupport" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.dependency             "ReactABI16_0_0/RCTWebSocket"
    ss.source_files         = "React/DevSupport/*", "React/Modules/ABI16_0_0RCTDev{LoadingView,Menu}.*"
  end

  s.subspec "tvOS" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "React/**/ABI16_0_0RCTTVView.{h, m}"
  end

  s.subspec "ABI16_0_0jschelpers" do |ss|
    ss.source_files         = "ReactCommon/ABI16_0_0jschelpers/{ABI16_0_0JavaScriptCore,ABI16_0_0JSCWrapper}.{cpp,h}"
    ss.private_header_files = "ReactCommon/ABI16_0_0jschelpers/{ABI16_0_0JavaScriptCore,ABI16_0_0JSCWrapper}.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "$(PODS_TARGET_SRCROOT)/ReactCommon" }
    ss.framework            = "JavaScriptCore"
  end

  s.subspec "cxxReactABI16_0_0" do |ss|
    ss.dependency             "ReactABI16_0_0/ABI16_0_0jschelpers"
    ss.source_files         = "ReactCommon/cxxReactABI16_0_0/{ABI16_0_0JSBundleType,ABI16_0_0oss-compat-util}.{cpp,h}"
    ss.private_header_files = "ReactCommon/cxxReactABI16_0_0/{ABI16_0_0JSBundleType,ABI16_0_0oss-compat-util}.h"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "$(PODS_TARGET_SRCROOT)/ReactCommon" }
  end

  s.subspec "ART" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/ART/**/*.{h,m}"
  end

  s.subspec "RCTActionSheet" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/ActionSheetIOS/*.{h,m}"
  end

  s.subspec "RCTAdSupport" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/AdSupport/*.{h,m}"
  end

  s.subspec "RCTAnimation" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/NativeAnimation/{Drivers/*,Nodes/*,*}.{h,m}"
  end

  s.subspec "RCTCameraRoll" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.dependency             "ReactABI16_0_0/RCTImage"
    ss.source_files         = "Libraries/CameraRoll/*.{h,m}"
  end

  s.subspec "RCTGeolocation" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/Geolocation/*.{h,m}"
  end

  s.subspec "RCTImage" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.dependency             "ReactABI16_0_0/RCTNetwork"
    ss.source_files         = "Libraries/Image/*.{h,m}"
  end

  s.subspec "RCTNetwork" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/Network/*.{h,m,mm}"
  end

  s.subspec "RCTPushNotification" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/PushNotificationIOS/*.{h,m}"
  end

  s.subspec "RCTSettings" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/Settings/*.{h,m}"
  end

  s.subspec "RCTText" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/Text/*.{h,m}"
  end

  s.subspec "RCTVibration" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/Vibration/*.{h,m}"
  end

  s.subspec "RCTWebSocket" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/WebSocket/*.{h,m}"
  end

  s.subspec "RCTLinkingIOS" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/LinkingIOS/*.{h,m}"
  end

  s.subspec "RCTTest" do |ss|
    ss.dependency             "ReactABI16_0_0/Core"
    ss.source_files         = "Libraries/RCTTest/**/*.{h,m}"
    ss.frameworks           = "XCTest"
  end
end
