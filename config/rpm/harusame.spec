%define pkgname harusame
%define filelist %{pkgname}-%{version}-filelist
%define NVR %{pkgname}-%{version}-%{release}
%define maketest 1

Name:      harusame
Summary:   harusame - Multilingual Web page management tool
Version:   20100522
Release:   2.suika

Packager:  Wakaba <w@suika.fam.cx>
Vendor:    Suika yum repository <http://suika.fam.cx/gate/yum/>

License:   Perl
Group:     Applications/Text

BuildRoot: %{_tmppath}/%{name}-%{version}-%(id -u -n)
BuildArch: noarch
Prefix:    %(echo %{_prefix})

Source0:   harusame-20100522.tar.gz
Source11:  harusame-filter-requires.sh

# Filter the automatically generated dependencies.
#
# The original script might be /usr/lib/rpm/perl.req or
# /usr/lib/rpm/redhat/perl.req, better use the original value of the macro:
%{expand:%%define prev__perl_requires %{__perl_requires}}
%define __perl_requires %{SOURCE11} %{prev__perl_requires}

# When _use_internal_dependency_generator is 0, the perl.req script is
# called from /usr/lib/rpm{,/redhat}/find-requires.sh
# Likewise:
%{expand:%%define prev__find_requires %{__find_requires}}
%define __find_requires %{SOURCE11} %{prev__find_requires}

%{expand:%%define prev__perl_provides %{__perl_provides}}
%define __perl_provides %{SOURCE11} %{prev__perl_provides}

%description
The `harusame' script extracts a version of the HTML document
written in the specified natural language, from a source HTML document
that contains paragraphs in multiple natural languages.

The document management of a multilingual Web site where there are
multiple versions of a (conceptually same) document is somewhat
difficult in general.  If the author of an HTML document wants to edit
a part of the document, then he or she has to ensure not to forget
updating translations at the same time, otherwise documents in
different language versions also differ in their content versions.

Using the `harusame', one can generate versions of an HTML
document in different language from one source HTML document that
contains paragraphs written in all of those languages, such that
authors no longer have to manage different content versions and
different language versions in separate files.

%prep
%setup -q -n %{pkgname}-%{version} 
chmod -R u+w %{_builddir}/%{pkgname}-%{version}

%define extraroot %{_prefix}/share/%{pkgname}-%{version}
%define make_harusame_bin bin/harusame.pl
%define maked_harusame_bin blib/script/harusame

%build
cp %{make_harusame_bin} %{make_harusame_bin}.bak
rm -f %{make_harusame_bin}
echo "#!%{__perl}" > %{make_harusame_bin}
echo "use lib qw(%{extraroot}/modules/charclass/lib);" >> %{make_harusame_bin}
echo "use lib qw(%{extraroot}/modules/manakai/lib);" >> %{make_harusame_bin}
%{__cat} %{make_harusame_bin}.bak >> %{make_harusame_bin}
rm -f %{make_harusame_bin}.bak

grep -rsl '^#!.*perl' . |
grep -v '.bak$' |xargs --no-run-if-empty \
%__perl -MExtUtils::MakeMaker -e 'MY->fixin(@ARGV)'
CFLAGS="$RPM_OPT_FLAGS"
%{__perl} Makefile.PL `%{__perl} -MExtUtils::MakeMaker -e ' print qq|PREFIX=%{buildroot}%{_prefix}| if \$ExtUtils::MakeMaker::VERSION =~ /5\.9[1-6]|6\.0[0-5]/ '`
%{__make} 
%if %maketest
%{__make} test
%endif

chmod +x %{maked_harusame_bin}

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%{makeinstall} `%{__perl} -MExtUtils::MakeMaker -e ' print \$ExtUtils::MakeMaker::VERSION <= 6.05 ? qq|PREFIX=%{buildroot}%{_prefix}| : qq|DESTDIR=%{buildroot}| '`

%{__mkdir_p} %{buildroot}%{extraroot}
cp -R modules %{buildroot}%{extraroot}/modules

rm -f %{buildroot}/usr/local/share/man/man3/bin::harusame.3pm

cmd=/usr/share/spec-helper/compress_files
[ -x $cmd ] || cmd=/usr/lib/rpm/brp-compress
[ -x $cmd ] && $cmd

# SuSE Linux
if [ -e /etc/SuSE-release -o -e /etc/UnitedLinux-release ]
then
    %{__mkdir_p} %{buildroot}/var/adm/perl-modules
    %{__cat} `find %{buildroot} -name "perllocal.pod"`  \
        | %{__sed} -e s+%{buildroot}++g                 \
        > %{buildroot}/var/adm/perl-modules/%{name}
fi

# remove special files
find %{buildroot} -name "perllocal.pod" \
    -o -name ".packlist"                \
    -o -name "*.bs"                     \
    |xargs -i rm -f {}

# no empty directories
find %{buildroot}%{_prefix}             \
    -type d -depth                      \
    -exec rmdir {} \; 2>/dev/null

%{__perl} -MFile::Find -le '
    find({ wanted => \&wanted, no_chdir => 1}, "%{buildroot}");
    print "%doc readme.html.src readme.ja.html readme.en.html";
    for my $x (sort @dirs, @files) {
        push @ret, $x unless indirs($x);
        }
    print join "\n", sort @ret;

    sub wanted {
        return if /auto$/;

        local $_ = $File::Find::name;
        my $f = $_; s|^\Q%{buildroot}\E||;
        return unless length;
        return $files[@files] = $_ if -f $f;

        $d = $_;
        /\Q$d\E/ && return for reverse sort @INC;
        $d =~ /\Q$_\E/ && return
            for qw|/etc %_prefix/man %_prefix/bin %_prefix/share|;

        $dirs[@dirs] = $_;
        }

    sub indirs {
        my $x = shift;
        $x =~ /^\Q$_\E\// && $x ne $_ && return 1 for @dirs;
        }
    ' > %filelist

[ -z %filelist ] && {
    echo "ERROR: empty %files listing"
    exit -1
    }

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files -f %filelist
%defattr(-,root,root)

%changelog
* Sat May 22 2010 Wakaba <w@suika.fam.cx> - 20100522.2-suika
- Rebuilt.

* Sat May 22 2010 Wakaba <w@suika.fam.cx> - 20100522.1-suika
- Initial build.
