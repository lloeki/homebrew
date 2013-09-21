require 'formula'

# SuperCollider
class Supercollider < Formula
  homepage 'http://supercollider.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/' <<
      'supercollider/Source/3.6/SuperCollider-3.6.5-Source.tar.bz2'
  sha1 '05247e241c8ff0ece81b8c0f36bdbb0034da919f'

  option :universal

  depends_on 'readline'
  depends_on 'cmake' => :build
  depends_on 'qt' # should be => :optional, but see below

  def sdk
    '10.7'
  end

  def sdk_path
    '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/' <<
    "Developer/SDKs/MacOSX#{sdk}.sdk/"
  end

  def cmake_sdk
    [
      "-DCMAKE_OSX_SYSROOT=#{sdk_path}",
      "-DCMAKE_OSX_DEPLOYMENT_TARGET=#{sdk}",
    ]
  end

  def cmake_arches
    arches = ['x86_64']
    arches.unshift 'i386' if build.universal?
    ["-DCMAKE_OSX_ARCHITECTURES='#{arches.join(';')}'"]
  end

  def install
    ENV.j1

    args = std_cmake_args + cmake_arches + cmake_sdk + %W[
      -DCMAKE_BUILD_TYPE="Release"
    ]
    # although advertised as working, apparently has no effect
    # args << '-DSC_QT=0 -DSC_IDE=0' unless build.include? 'with-qt'
    args << '..'

    makeargs = fix_superenv([])

    mkdir 'build' do
      system 'cmake', *args
      system 'make', 'install', *makeargs
    end

    mkdir bin
    ln_s prefix/'SuperCollider/SuperCollider.app/Contents/Resources/scsynth', bin/'scsynth'
    ln_s prefix/'SuperCollider/SuperCollider.app/Contents/Resources/sclang', bin/'sclang'
  end

  def fix_superenv(args)
    cflags = "CFLAGS=-I#{HOMEBREW_PREFIX}/include " <<
             "-I#{Formula.factory('readline').opt_prefix}/include"
    ldflags = "LDFLAGS=-L#{HOMEBREW_PREFIX}/lib " <<
              "-L#{Formula.factory('readline').opt_prefix}/lib"

    # cflags = " -isysroot #{sdk_path}"
    # ldflags = " -isysroot #{sdk_path}"

    args << cflags
    args << ldflags
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if
    # you were more thorough. Run the test with `brew test SuperCollider`.
    system 'sclang -h'
    system 'scsynth'
  end
end
