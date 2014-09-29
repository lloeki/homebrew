require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Virtualbox < Formula
  homepage "http://virtualbox.org"
  url "http://download.virtualbox.org/virtualbox/4.3.16/VirtualBox-4.3.16.tar.bz2"
  sha1 "e4c23b713e8715b8e0172fa066f2197756e901fe"

  #depends_on 'kbuild' => :build
  depends_on 'pkgconfig'
  depends_on 'libidl'
  depends_on 'cdrtools'
  #depends_on 'glib'

  patch :p0, :DATA

  fails_with :llvm do
    cause <<-EOS.undent
      Cannt be built with llvm, needs apple-gcc42.
    EOS
  end

  fails_with :clang do
    cause <<-EOS.undent
      Cannt be built with clang, needs apple-gcc42.
    EOS
  end

  def install
    ENV.deparallelize

    #VBOX_PATH_APP_PRIVATE      = "/Applications/OpenSource/VirtualBox.app/Contents/MacOS"
    #VBOX_PATH_APP_PRIVATE_ARCH = "/Applications/OpenSource/VirtualBox.app/Contents/MacOS"
    #VBOX_PATH_SHARED_LIBS      = "/Applications/OpenSource/VirtualBox.app/Contents/MacOS"
    #VBOX_PATH_APP_DOCS         = "/Applications/OpenSource/VirtualBox.app/Contents/MacOS"
    #VBOX_WITH_TESTSUITE=
    #VBOX_WITH_TESTCASES=
    #kBuildGlobalDefaults_LD_DEBUG=
    #system 'echo "VBOX_PATH_MACOSX_DEVEL_ROOT = $(xcode-select -p)/Platforms/MacOSX.platform/Developer" >> LocalConfig.kmk'
    #system 'echo "VBOX_DEF_MACOSX_VERSION_MIN = 10.9" >> LocalConfig.kmk'

    system "./configure", "--disable-docs",
                          "--disable-xpcom",
                          "--disable-python",
                          "--disable-java",
                          "--disable-hardening",
                          "--build-headless",
                          "--target-arch=amd64"

    system ". ./env.sh && kmk"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test VirtualBox`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
--- configure.orig	2014-09-29 16:10:37.000000000 +0200
+++ configure	2014-09-29 16:33:45.000000000 +0200
@@ -2163,9 +2163,15 @@
       cnf_append "VBOX_WITHOUT_VBOXPYTHON_FOR_OSX_10_7" "1"
       ;;
     *)
-      echo "  failed to determine Darwin version. (uname -r: $darwin_ver)"
-      fail
-      darwin_ver="unknown"
+      sdk=$(ls -1d $(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/*.sdk | tail -1 2>/dev/null)
+      if [[ -n "$sdk" ]]; then
+        darwin_ver=$(echo $sdk | perl -ne '/(10\.\d+)\.sdk/ and print $1')
+        CXX_FLAGS="-mmacosx-version-min=$darwin_ver -isysroot $sdk -Wl,-syslibroot,$sdk"
+      else
+        echo "  failed to determine Darwin version. (uname -r: $darwin_ver)"
+        fail
+        darwin_ver="unknown"
+      fi
       ;;
   esac
   log_success "found version $darwin_ver (SDK: $sdk)"
