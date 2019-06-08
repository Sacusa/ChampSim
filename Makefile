app = champsim

srcExt = cc
srcDir = src branch replacement prefetcher
objDir = obj
binDir = bin
inc = inc

debug = 1

CFlags = -Wall -O3 -std=c++11
LDFlags =
libs =
libDir =

def_print_reuse_stats =
def_print_access_pattern =
def_print_offset_pattern =
def_print_stride_distribution =
def_print_mlp =
def_inclusive_cache =
def_exclusive_cache =


#************************ DO NOT EDIT BELOW THIS LINE! ************************

ifeq ($(debug),1)
	debug=-g
else
	debug=
endif

ifeq ($(print_reuse_stats),1)
	def_print_reuse_stats=-D PRINT_REUSE_STATS
endif

ifeq ($(print_access_pattern),1)
	def_print_access_pattern=-D PRINT_ACCESS_PATTERN
endif

ifeq ($(print_offset_pattern),1)
	def_print_offset_pattern=-D PRINT_OFFSET_PATTERN
endif

ifeq ($(print_stride_distribution),1)
	def_print_stride_distribution=-D PRINT_STRIDE_DISTRIBUTION
endif

ifeq ($(print_mlp),1)
	def_print_mlp=-D PRINT_MLP
endif

ifeq ($(cache_config),1)
	def_inclusive_cache=-D INCLUSIVE_CACHE
endif

ifeq ($(cache_config),2)
	def_exclusive_cache=-D EXCLUSIVE_CACHE
endif

inc := $(addprefix -I,$(inc))
libs := $(addprefix -l,$(libs))
libDir := $(addprefix -L,$(libDir))
CFlags += -c $(debug) $(inc) $(libDir) $(libs) $(def_print_reuse_stats) $(def_print_access_pattern) $(def_print_offset_pattern) $(def_print_stride_distribution) $(def_print_mlp) $(def_inclusive_cache) $(def_exclusive_cache)
sources := $(shell find $(srcDir) -name '*.$(srcExt)')
srcDirs := $(shell find . -name '*.$(srcExt)' -exec dirname {} \; | uniq)
objects := $(patsubst %.$(srcExt),$(objDir)/%.o,$(sources))

ifeq ($(srcExt),cc)
	CC = $(CXX)
else
	CFlags += -std=gnu99
endif

.phony: all clean distclean


all: $(binDir)/$(app)

$(binDir)/$(app): buildrepo $(objects)
	@mkdir -p `dirname $@`
	@echo "Linking $@..."
	@$(CC) $(objects) $(LDFlags) -o $@

$(objDir)/%.o: %.$(srcExt)
	@echo "Generating dependencies for $<..."
	@$(call make-depend,$<,$@,$(subst .o,.d,$@))
	@echo "Compiling $<..."
	@$(CC) $(CFlags) $< -o $@

clean:
	$(RM) -r $(objDir)

distclean: clean
	$(RM) -r $(binDir)/$(app)

buildrepo:
	@$(call make-repo)

define make-repo
   for dir in $(srcDirs); \
   do \
	mkdir -p $(objDir)/$$dir; \
   done
endef


# usage: $(call make-depend,source-file,object-file,depend-file)
define make-depend
  $(CC) -MM       \
        -MF $3    \
        -MP       \
        -MT $2    \
        $(CFlags) \
        $1
endef
