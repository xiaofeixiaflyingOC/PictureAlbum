Pod::Spec.new do |s|
s.name         = "PictureAlbum"
s.version      = "1.0.0"
s.summary      = "shengxin inc ios common framework"
s.description  = <<-DESC
                 The use of PhotoKit to read the local album, detection of photo album permissions, read all the big picture album, optimize the speed of collectionView
                   DESC
s.homepage     = "https://github.com/xiaofeixiaflyingOC/PictureAlbum"
s.license      = "MIT"
s.author             = { "shengxin" => "shengxin@tuxing2010.com" }
s.source       = { :git => "https://github.com/xiaofeixiaflyingOC/PictureAlbum.git", :tag => "1.0.0" }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'PictureAlbum/PictureAlbum/*.{h,m}'
s.exclude_files			= "Classes/Exclude"
s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'Photos', 'AssetsLibrary'

end
