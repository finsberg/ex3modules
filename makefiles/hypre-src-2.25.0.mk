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
# hypre-src-2.25.0

hypre-src-2.25-version = 2.25.0
hypre-src-2.25 = hypre-src-$(hypre-src-2.25-version)
$(hypre-src-2.25)-description = Scalable Linear Solvers and Multigrid Methods (source)
$(hypre-src-2.25)-url = https://github.com/hypre-space/hypre/
$(hypre-src-2.25)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-src-2.25-version).tar.gz
$(hypre-src-2.25)-builddeps =
$(hypre-src-2.25)-prereqs =
$(hypre-src-2.25)-src = $(pkgsrcdir)/hypre-$(notdir $($(hypre-src-2.25)-srcurl))

$($(hypre-src-2.25)-src): $(dir $($(hypre-src-2.25)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hypre-src-2.25)-srcurl)

$(hypre-src-2.25)-src: $($(hypre-src-2.25)-src)
$(hypre-src-2.25)-unpack:
$(hypre-src-2.25)-patch:
$(hypre-src-2.25)-build:
$(hypre-src-2.25)-check:
$(hypre-src-2.25)-install:
$(hypre-src-2.25)-modulefile:
$(hypre-src-2.25)-clean:
	rm -rf $($(hypre-src-2.25)-src)
$(hypre-src-2.25): $(hypre-src-2.25)-src $(hypre-src-2.25)-unpack $(hypre-src-2.25)-patch $(hypre-src-2.25)-build $(hypre-src-2.25)-check $(hypre-src-2.25)-install $(hypre-src-2.25)-modulefile
