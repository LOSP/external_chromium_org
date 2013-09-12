# This file is generated by gyp; do not edit.

include $(CLEAR_VARS)

LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_MODULE := gpu_disk_cache_proto_gyp
LOCAL_MODULE_SUFFIX := .a
LOCAL_MODULE_TAGS := optional
gyp_intermediate_dir := $(call local-intermediates-dir)
gyp_shared_intermediate_dir := $(call intermediates-dir-for,GYP,shared)

# Make sure our deps are built first.
GYP_TARGET_DEPENDENCIES := \
	$(gyp_shared_intermediate_dir)/protoc


### Generated for rule "gpu_gpu_gyp_disk_cache_proto_target_genproto":
# "{'inputs': ['../tools/protoc_wrapper/protoc_wrapper.py', '$(gyp_shared_intermediate_dir)/protoc'], 'msvs_cygwin_shell': '0', 'extension': 'proto', 'outputs': ['$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/%(INPUT_ROOT)s_pb2.py', '$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/%(INPUT_ROOT)s.pb.cc', '$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/%(INPUT_ROOT)s.pb.h'], 'rule_name': 'genproto', 'rule_sources': ['command_buffer/service/disk_cache_proto.proto'], 'action': ['python', '../tools/protoc_wrapper/protoc_wrapper.py', '--include', '', '--protobuf', '$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/%(INPUT_ROOT)s.pb.h', '--proto-in-dir', 'command_buffer/service', '--proto-in-file', '%(INPUT_ROOT)s$(suffix $<)', '--use-system-protobuf=0', '--', '$(gyp_shared_intermediate_dir)/protoc', '--cpp_out', '$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service', '--python_out', '$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service'], 'message': 'Generating C++ and Python code from $(RULE_SOURCES)', 'process_outputs_as_sources': '1'}":
$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py: gyp_local_path := $(LOCAL_PATH)
$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py: gyp_intermediate_dir := $(abspath $(gyp_intermediate_dir))
$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py: gyp_shared_intermediate_dir := $(abspath $(gyp_shared_intermediate_dir))
$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py: export PATH := $(subst $(ANDROID_BUILD_PATHS),,$(PATH))
$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py: $(LOCAL_PATH)/gpu/command_buffer/service/disk_cache_proto.proto $(LOCAL_PATH)/tools/protoc_wrapper/protoc_wrapper.py $(gyp_shared_intermediate_dir)/protoc $(GYP_TARGET_DEPENDENCIES)
	mkdir -p $(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service $(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service; cd $(gyp_local_path)/gpu; python ../tools/protoc_wrapper/protoc_wrapper.py --include "" --protobuf "$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.h" --proto-in-dir command_buffer/service --proto-in-file "disk_cache_proto$(suffix $<)" "--use-system-protobuf=0" -- "$(gyp_shared_intermediate_dir)/protoc" --cpp_out "$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service" --python_out "$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service"

$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.cc: $(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py ;
$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.h: $(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py ;
.PHONY: gpu_disk_cache_proto_gyp_rule_trigger
gpu_disk_cache_proto_gyp_rule_trigger: $(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py

### Finished generating for all rules

GYP_GENERATED_OUTPUTS := \
	$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py \
	$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.cc \
	$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.h

# Make sure our deps and generated files are built first.
LOCAL_ADDITIONAL_DEPENDENCIES := $(GYP_TARGET_DEPENDENCIES) $(GYP_GENERATED_OUTPUTS)

LOCAL_CPP_EXTENSION := .cc
$(gyp_intermediate_dir)/disk_cache_proto.pb.cc: $(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.cc
	mkdir -p $(@D); cp $< $@
LOCAL_GENERATED_SOURCES := \
	$(gyp_intermediate_dir)/disk_cache_proto.pb.cc \
	$(gyp_shared_intermediate_dir)/pyproto/gpu/command_buffer/service/disk_cache_proto_pb2.py \
	$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service/disk_cache_proto.pb.h \
	gpu_disk_cache_proto_gyp_rule_trigger

GYP_COPIED_SOURCE_ORIGIN_DIRS := \
	$(gyp_shared_intermediate_dir)/protoc_out/gpu/command_buffer/service

LOCAL_SRC_FILES :=


# Flags passed to both C and C++ files.
MY_CFLAGS_Debug := \
	--param=ssp-buffer-size=4 \
	-Werror \
	-fno-exceptions \
	-fno-strict-aliasing \
	-Wall \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-m32 \
	-mmmx \
	-march=pentium4 \
	-msse2 \
	-mfpmath=sse \
	-fuse-ld=gold \
	-ffunction-sections \
	-funwind-tables \
	-g \
	-fno-short-enums \
	-finline-limit=64 \
	-Wa,--noexecstack \
	-U_FORTIFY_SOURCE \
	-Wno-extra \
	-Wno-ignored-qualifiers \
	-Wno-type-limits \
	-fno-stack-protector \
	-Os \
	-g \
	-fomit-frame-pointer \
	-fdata-sections \
	-ffunction-sections

MY_DEFS_Debug := \
	'-DANGLE_DX11' \
	'-DWTF_VECTOR_INITIAL_SIZE=16' \
	'-D_FILE_OFFSET_BITS=64' \
	'-DNO_TCMALLOC' \
	'-DDISCARDABLE_MEMORY_ALWAYS_SUPPORTED_NATIVELY' \
	'-DSYSTEM_NATIVELY_SIGNALS_MEMORY_PRESSURE' \
	'-DDISABLE_NACL' \
	'-DCHROMIUM_BUILD' \
	'-DUSE_LIBJPEG_TURBO=1' \
	'-DUSE_PROPRIETARY_CODECS' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DUSE_OPENSSL=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DCLD_VERSION=1' \
	'-DPROTOBUF_USE_DLLS' \
	'-DGOOGLE_PROTOBUF_NO_RTTI' \
	'-DGOOGLE_PROTOBUF_NO_STATIC_INITIALIZER' \
	'-D__STDC_CONSTANT_MACROS' \
	'-D__STDC_FORMAT_MACROS' \
	'-DANDROID' \
	'-D__GNU_SOURCE=1' \
	'-DUSE_STLPORT=1' \
	'-D_STLP_USE_PTR_SPECIALIZATIONS=1' \
	'-DCHROME_BUILD_ID=""' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=1' \
	'-DWTF_USE_DYNAMIC_ANNOTATIONS=1' \
	'-D_DEBUG'


# Include paths placed before CFLAGS/CPPFLAGS
LOCAL_C_INCLUDES_Debug := \
	$(gyp_shared_intermediate_dir)/protoc_out \
	$(LOCAL_PATH) \
	$(LOCAL_PATH)/third_party/protobuf \
	$(LOCAL_PATH)/third_party/protobuf/src \
	$(PWD)/frameworks/wilhelm/include \
	$(PWD)/bionic \
	$(PWD)/external/stlport/stlport


# Flags passed to only C++ (and not C) files.
LOCAL_CPPFLAGS_Debug := \
	-fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-Wsign-compare \
	-Wno-error=c++0x-compat \
	-Wno-non-virtual-dtor \
	-Wno-sign-promo


# Flags passed to both C and C++ files.
MY_CFLAGS_Release := \
	--param=ssp-buffer-size=4 \
	-Werror \
	-fno-exceptions \
	-fno-strict-aliasing \
	-Wall \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-m32 \
	-mmmx \
	-march=pentium4 \
	-msse2 \
	-mfpmath=sse \
	-fuse-ld=gold \
	-ffunction-sections \
	-funwind-tables \
	-g \
	-fno-short-enums \
	-finline-limit=64 \
	-Wa,--noexecstack \
	-U_FORTIFY_SOURCE \
	-Wno-extra \
	-Wno-ignored-qualifiers \
	-Wno-type-limits \
	-fno-stack-protector \
	-Os \
	-fno-ident \
	-fdata-sections \
	-ffunction-sections \
	-fomit-frame-pointer \
	-fno-unwind-tables \
	-fno-asynchronous-unwind-tables

MY_DEFS_Release := \
	'-DANGLE_DX11' \
	'-DWTF_VECTOR_INITIAL_SIZE=16' \
	'-D_FILE_OFFSET_BITS=64' \
	'-DNO_TCMALLOC' \
	'-DDISCARDABLE_MEMORY_ALWAYS_SUPPORTED_NATIVELY' \
	'-DSYSTEM_NATIVELY_SIGNALS_MEMORY_PRESSURE' \
	'-DDISABLE_NACL' \
	'-DCHROMIUM_BUILD' \
	'-DUSE_LIBJPEG_TURBO=1' \
	'-DUSE_PROPRIETARY_CODECS' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DUSE_OPENSSL=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DCLD_VERSION=1' \
	'-DPROTOBUF_USE_DLLS' \
	'-DGOOGLE_PROTOBUF_NO_RTTI' \
	'-DGOOGLE_PROTOBUF_NO_STATIC_INITIALIZER' \
	'-D__STDC_CONSTANT_MACROS' \
	'-D__STDC_FORMAT_MACROS' \
	'-DANDROID' \
	'-D__GNU_SOURCE=1' \
	'-DUSE_STLPORT=1' \
	'-D_STLP_USE_PTR_SPECIALIZATIONS=1' \
	'-DCHROME_BUILD_ID=""' \
	'-DNDEBUG' \
	'-DNVALGRIND' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=0' \
	'-D_FORTIFY_SOURCE=2'


# Include paths placed before CFLAGS/CPPFLAGS
LOCAL_C_INCLUDES_Release := \
	$(gyp_shared_intermediate_dir)/protoc_out \
	$(LOCAL_PATH) \
	$(LOCAL_PATH)/third_party/protobuf \
	$(LOCAL_PATH)/third_party/protobuf/src \
	$(PWD)/frameworks/wilhelm/include \
	$(PWD)/bionic \
	$(PWD)/external/stlport/stlport


# Flags passed to only C++ (and not C) files.
LOCAL_CPPFLAGS_Release := \
	-fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-Wsign-compare \
	-Wno-error=c++0x-compat \
	-Wno-non-virtual-dtor \
	-Wno-sign-promo


LOCAL_CFLAGS := $(MY_CFLAGS_$(GYP_CONFIGURATION)) $(MY_DEFS_$(GYP_CONFIGURATION))
LOCAL_C_INCLUDES := $(GYP_COPIED_SOURCE_ORIGIN_DIRS) $(LOCAL_C_INCLUDES_$(GYP_CONFIGURATION))
LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS_$(GYP_CONFIGURATION))
### Rules for final target.

LOCAL_LDFLAGS_Debug := \
	-Wl,-z,now \
	-Wl,-z,relro \
	-Wl,-z,noexecstack \
	-fPIC \
	-m32 \
	-fuse-ld=gold \
	-nostdlib \
	-Wl,--no-undefined \
	-Wl,--exclude-libs=ALL \
	-Wl,--fatal-warnings \
	-Wl,--gc-sections \
	-Wl,--warn-shared-textrel \
	-Wl,-O1 \
	-Wl,--as-needed


LOCAL_LDFLAGS_Release := \
	-Wl,-z,now \
	-Wl,-z,relro \
	-Wl,-z,noexecstack \
	-fPIC \
	-m32 \
	-fuse-ld=gold \
	-nostdlib \
	-Wl,--no-undefined \
	-Wl,--exclude-libs=ALL \
	-Wl,-O1 \
	-Wl,--as-needed \
	-Wl,--gc-sections \
	-Wl,--fatal-warnings \
	-Wl,--warn-shared-textrel


LOCAL_LDFLAGS := $(LOCAL_LDFLAGS_$(GYP_CONFIGURATION))

LOCAL_STATIC_LIBRARIES :=

# Enable grouping to fix circular references
LOCAL_GROUP_STATIC_LIBRARIES := true

LOCAL_SHARED_LIBRARIES := \
	libstlport \
	libdl

# Add target alias to "gyp_all_modules" target.
.PHONY: gyp_all_modules
gyp_all_modules: gpu_disk_cache_proto_gyp

# Alias gyp target name.
.PHONY: disk_cache_proto
disk_cache_proto: gpu_disk_cache_proto_gyp

include $(BUILD_STATIC_LIBRARY)
