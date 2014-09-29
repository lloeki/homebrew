require "formula"

class Kbuild < Formula
  homepage "http://trac.netlabs.org/kbuild"
  url "ftp://ftp.netlabs.org/pub/kbuild/kBuild-0.1.5-p2-all.tar.gz"
  sha1 "2fba0522d0a3e157eff68cf174086d11506e8217"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  # patch out conflicting definitions
  patch :p0, :DATA

  def install
    ENV.deparallelize

    system("sed -i~ -e 's/-isysroot $(KBUILD_MACOSX_SDK)//' Config.kmk")
    system("sed -i~ -e 's/-Wl,-syslibroot,$(KBUILD_MACOSX_SDK)//' Config.kmk")
    system("sed -i~ -e 's/-mmacosx-version-min=10.4/-mmacosx-version-min=10.7/' Config.kmk")
    system("sed -i~ -e 's/-classic_ld//' Config.kmk")

    # AUTOPOINT=true because it wants autopoint from gettext 0.14
    system("AUTOPOINT=true kBuild/env.sh --full make -f bootstrap.gmk")
    system("kBuild/env.sh kmk BUILD_TYPE=release")

    bin.install Dir['out/darwin.amd64/release/kBuild/bin/darwin.amd64/*']
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test kBuild`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
--- src/kmk/kmkbuiltin/strlcpy.c.orig	2014-09-29 14:49:06.000000000 +0200
+++ src/kmk/kmkbuiltin/strlcpy.c	2014-09-29 14:49:10.000000000 +0200
@@ -41,7 +41,7 @@
  * will be copied.  Always NUL terminates (unless siz == 0).
  * Returns strlen(src); if retval >= siz, truncation occurred.
  */
-size_t strlcpy(dst, src, siz)
+size_t strlcpy_dis(dst, src, siz)
 	char *dst;
 	const char *src;
 	size_t siz;
--- src/sed/lib/getline.c.orig	2014-09-29 15:02:34.000000000 +0200
+++ src/sed/lib/getline.c	2014-09-29 15:02:39.000000000 +0200
@@ -31,7 +31,7 @@
    null terminator), or -1 on error or EOF.  */
 
 size_t
-getline (lineptr, n, stream)
+getline_dis (lineptr, n, stream)
      char **lineptr;
      size_t *n;
      FILE *stream;
--- src/kmk/kmkbuiltin.h.orig	2014-09-29 15:17:08.000000000 +0200
+++ src/kmk/kmkbuiltin.h	2014-09-29 15:17:58.000000000 +0200
@@ -50,7 +50,7 @@
 extern int kmk_builtin_rm(int argc, char **argv, char **envp);
 extern int kmk_builtin_rmdir(int argc, char **argv, char **envp);
 extern int kmk_builtin_sleep(int argc, char **argv, char **envp);
-extern int kmk_builtin_test(int argc, char **argv, char **envp, char ***ppapszArgvSpawn);
+extern int kmk_builtin_test(int argc, char **argv, char **envp, char **ppapszArgvSpawn);
 extern int kmk_builtin_kDepIDB(int argc, char **argv, char **envp);
 
 extern char *kmk_builtin_func_printf(char *o, char **argv, const char *funcname);
--- src/kmk/kmkbuiltin/test.c.orig	2014-09-29 15:17:17.000000000 +0200
+++ src/kmk/kmkbuiltin/test.c	2014-09-29 15:17:43.000000000 +0200
@@ -201,7 +201,7 @@
 }
 #endif
 
-int kmk_builtin_test(int argc, char **argv, char **envp, char ***ppapszArgvSpawn)
+int kmk_builtin_test(int argc, char **argv, char **envp, char **ppapszArgvSpawn)
 {
 	int res;
 	char **argv_spawn;
@@ -291,7 +291,7 @@
 			}
 			argv_new[i] = NULL;
 
-			*ppapszArgvSpawn = argv_new;
+			ppapszArgvSpawn = argv_new;
 			res = 0;
 #endif /* in kmk */
 --- src/ash/output.h.orig	2014-09-29 15:43:08.000000000 +0200
+++ src/ash/output.h	2014-09-29 15:43:32.000000000 +0200
@@ -65,7 +65,7 @@
     __attribute__((__format__(__printf__,2,3)));
 void out1fmt(const char *, ...)
     __attribute__((__format__(__printf__,1,2)));
-void dprintf(const char *, ...)
+void dprintf_dis(const char *, ...)
     __attribute__((__format__(__printf__,1,2)));
 void fmtstr(char *, size_t, const char *, ...)
     __attribute__((__format__(__printf__,3,4)));		}
--- src/ash/output.c.orig	2014-09-29 15:43:12.000000000 +0200
+++ src/ash/output.c	2014-09-29 15:43:24.000000000 +0200
@@ -231,7 +231,7 @@
 }
 
 void
-dprintf(const char *fmt, ...)
+dprintf_dis(const char *fmt, ...)
 {
 	va_list ap;
 
