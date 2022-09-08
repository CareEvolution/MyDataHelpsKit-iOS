Pod::Spec.new do |spec|

  spec.name = "MyDataHelpsKit"
  spec.version = '1.3.0' #auto-generated
  spec.summary = "An SDK to integrate MyDataHelps™ with your apps to develop your own participant experiences"
  spec.homepage = "https://github.com/CareEvolution/MyDataHelpsKit-iOS"
  spec.documentation_url = "https://developer.mydatahelps.org"
  spec.license = { :type => "Apache", :file => "LICENSE" }
  spec.author = "CareEvolution, LLC"

  spec.swift_version = '5.0' #auto-generated
  spec.ios.deployment_target = '11.0' #auto-generated

  spec.source = { :git => "https://github.com/CareEvolution/MyDataHelpsKit-iOS.git", :tag => "#{spec.version}" }

  spec.source_files = "MyDataHelpsKit/**/*.{swift,h}"

end
