require 'formula'

class Ssgenerator < Formula

    homepage 'https://github.com/nut-code-monkey/ssgenerator'
    url 'https://github.com/nut-code-monkey/ssgenerator.git'
    version '0.1.0'

    depends_on :xcode
    
    def install
        system "xcodebuild",
        "-target", "ssgenerator",
        "-configuration", "Release",
        "clean", "build",
        "SYMROOT=build",
        "DSTROOT=build"
        bin.install "build/Release/ssgenerator"
    end
end
