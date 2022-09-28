# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Authors: James D. Trotter <james@simula.no>
#
# scotch-64-6.1.3-6.1.3

scotch-64-6.1.3-version = 6.1.3
scotch-64-6.1.3 = scotch-64-$(scotch-64-6.1.3-version)
$(scotch)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch)-srcurl = https://gitlab.inria.fr/scotch/scotch/-/archive/v$(scotch-version)/scotch-v$(scotch-version).tar.gz
$(scotch)-src = $($(scotch-src)-src)
$(scotch)-srcdir = $(pkgsrcdir)/$(scotch)
$(scotch)-builddeps = $(mpi) $(patchelf)
$(scotch)-prereqs = $(mpi)
$(scotch)-modulefile = $(modulefilesdir)/$(scotch)
$(scotch)-prefix = $(pkgdir)/$(scotch)

$($(scotch)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(scotch)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(scotch)-prefix)/.pkgunpack: $$($(scotch)-src) $($(scotch)-srcdir)/.markerfile $($(scotch)-prefix)/.markerfile $$(foreach dep,$$($(scotch)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(scotch)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(scotch)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch)-prefix)/.pkgunpack
# Modify source to allow correct shared library linking
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/libscotchmetis/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/libscotch/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(^),$$(AR) $$(ARFLAGS) $$(@) $$(^) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/esmumps/Makefile
	sed -i 's,$$(AR) $$(ARFLAGS) $$(@) $$(?),$$(AR) $$(ARFLAGS) $$(@) $$(?) $$(DYNLDFLAGS),g' $($(scotch)-srcdir)/src/esmumps/Makefile
	@touch $@

$($(scotch)-srcdir)/src/Makefile.inc: $($(scotch)-prefix)/.pkgunpack
	printf "" >$@.tmp
	echo "EXE             =" >>$@.tmp
	echo "LIB             = .so" >>$@.tmp
	echo "OBJ             = .o" >>$@.tmp
	echo "MAKE            = make" >>$@.tmp
	echo "AR              = gcc" >>$@.tmp
	echo "ARFLAGS         = -shared -o" >>$@.tmp
	echo "CAT             = cat" >>$@.tmp
	echo "CCS             = gcc" >>$@.tmp
	echo "CCP             = mpicc" >>$@.tmp
	echo "CCD             = gcc" >>$@.tmp
	echo "CFLAGS          = -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD -Drestrict=__restrict -DIDXSIZE64" >>$@.tmp
	echo "CLIBFLAGS       = -shared -fPIC" >>$@.tmp
	echo "LDFLAGS         = -lz -lm -lrt -pthread" >>$@.tmp
	echo "DYNLDFLAGS      = -lz -lm -lrt -pthread" >>$@.tmp
	echo "CP              = cp" >>$@.tmp
	echo "LEX             = flex -Pscotchyy -olex.yy.c" >>$@.tmp
	echo "LN              = ln" >>$@.tmp
	echo "MKDIR           = mkdir -p" >>$@.tmp
	echo "MV              = mv" >>$@.tmp
	echo "RANLIB          = echo" >>$@.tmp
	echo "YACC            = bison -pscotchyy -y -b y" >>$@.tmp
	mv $@.tmp $@

$($(scotch)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch)-prefix)/.pkgpatch $($(scotch)-srcdir)/src/Makefile.inc
# Parallel builds are not supported
	cd $($(scotch)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch)-builddeps) && \
		$(MAKE) MAKEFLAGS="AR=$${CC:-gcc} CCS=$${CC:-gcc} CCP=$${MPICC:-mpicc} CCD=$${CC:-gcc}" \
			scotch ptscotch esmumps ptesmumps --jobs=1
	@touch $@

$($(scotch)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch)-prefix)/.pkgbuild
	@touch $@

$($(scotch)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(scotch)-builddeps),$(modulefilesdir)/$$(dep)) $($(scotch)-prefix)/.pkgcheck
	cd $($(scotch)-srcdir)/src && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(scotch)-builddeps) && \
		$(MAKE) install prefix=$($(scotch)-prefix) \
			MAKEFLAGS="AR=$${CC} CCS=$${CC} CCP=$${MPICC} CCD=$${CC}" && \
		patchelf --add-needed libz.so $($(scotch)-prefix)/lib/*.so && \
		patchelf --add-needed libscotcherr.so $($(scotch)-prefix)/lib/libscotch.so && \
		patchelf --add-needed libscotch.so $($(scotch)-prefix)/lib/libptscotch.so && \
		patchelf --add-needed libptscotch.so $($(scotch)-prefix)/lib/libptscotchparmetis.so && \
		patchelf --add-needed libscotch.so $($(scotch)-prefix)/lib/libscotchmetis.so
	@touch $@

$($(scotch)-modulefile): $(modulefilesdir)/.markerfile $($(scotch)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(scotch)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(scotch)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(scotch)-description)\"" >>$@
	echo "module-whatis \"$($(scotch)-url)\"" >>$@
	printf "$(foreach prereq,$($(scotch)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SCOTCH_ROOT $($(scotch)-prefix)" >>$@
	echo "setenv SCOTCH_INCDIR $($(scotch)-prefix)/include" >>$@
	echo "setenv SCOTCH_INCLUDEDIR $($(scotch)-prefix)/include" >>$@
	echo "setenv SCOTCH_LIBDIR $($(scotch)-prefix)/lib" >>$@
	echo "setenv SCOTCH_LIBRARYDIR $($(scotch)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(scotch)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(scotch)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(scotch)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(scotch)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(scotch)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(scotch)-prefix)/share/man" >>$@
	echo "set MSG \"$(scotch)\"" >>$@

$(scotch)-src: $($(scotch)-src)
$(scotch)-unpack: $($(scotch)-prefix)/.pkgunpack
$(scotch)-patch: $($(scotch)-prefix)/.pkgpatch
$(scotch)-build: $($(scotch)-prefix)/.pkgbuild
$(scotch)-check: $($(scotch)-prefix)/.pkgcheck
$(scotch)-install: $($(scotch)-prefix)/.pkginstall
$(scotch)-modulefile: $($(scotch)-modulefile)
$(scotch)-clean:
	rm -rf $($(scotch)-modulefile)
	rm -rf $($(scotch)-prefix)
	rm -rf $($(scotch)-srcdir)
	rm -rf $($(scotch)-src)
$(scotch): $(scotch)-src $(scotch)-unpack $(scotch)-patch $(scotch)-build $(scotch)-check $(scotch)-install $(scotch)-modulefile
