# Copyright (C) 2017 Andrew Zah

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Use a TMP dir because the last step would be $(DIST_DIR)/%: $(DIST_DIR)/%
# otherwise. Obviously this is a circular dependency, but the step uses the
# targets to go through asset-manifest and append the hash.

TMP_DIR             := tmp
SRC_DIR             := static
JS_DIR              := $(SRC_DIR)/js
MIN_JS_DIR          := $(SRC_DIR)/js/min

STATIC_MIN_JS_FILES := $(wildcard $(SRC_DIR)/js/min/*)
PUBLIC_MIN_JS_FILES := $(public/js/min/*)

JS_FILES            := $(wildcard $(JS_DIR)/*.js)
MIN_JS_FILES        := ${patsubst $(JS_DIR)/%,$(MIN_JS_DIR)/%,$(JS_FILES:.js=.min.js) }

JS_TARGET           := $(JS_DIR)/bundle.js

.PHONY: all
all: js
js: uglifyjs bundlejs
uglifyjs: $(MIN_JS_FILES)
bundlejs: $(JS_TARGET)
removebundlejs:
	-@rm -rf $(JS_TARGET)
touchjs:
	touch $(wildcard $(JS_DIR)/*)
touchc:
	touch $(wildcard $(SRC_DIR)/stylesheets/*)
delmin:
	rm -rf $(MIN_JS_DIR)
	rm -rf $(PUBLIC_MIN_JS_DIR)

deploy:
	gutenberg build
	docker-compose build
	docker push kevinlmadison/site:latest

$(MIN_JS_DIR)/%.min.js: $(JS_DIR)/%.js
	uglifyjs -o $@ $<
	@echo "Minified JS ("$<")"

$(JS_TARGET): $(MIN_JS_FILES)
	@cat $^ > $@
	@echo "Made bundle! "$@": \n ->"$^
