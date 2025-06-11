Pod::Spec.new do |s|
  s.name     = 'SwiftTask'
  s.version  = '6.0.0'
  s.license  = { :type => 'MIT' }
  s.homepage = 'https://github.com/ReactKit/SwiftTask'
  s.authors  = { 'Yasuhiro Inami' => 'inamiy@gmail.com' }
  s.summary  = 'Promise + progress + pause + cancel + retry for Swift.'
  s.source   = { :git => 'https://github.com/ReactKit/SwiftTask.git', :tag => "#{s.version}" }
  s.source_files = 'SwiftTask/**/*.{h,swift}'
  s.requires_arc = true

  s.osx.deployment_target = '12.0'
  s.ios.deployment_target = '13.0'
  s.watchos.deployment_target = '8.0'
  s.tvos.deployment_target = '13.0'
end
