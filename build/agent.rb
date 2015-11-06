#  Phusion Passenger - https://www.phusionpassenger.com/
#  Copyright (c) 2010-2015 Phusion Holding B.V.
#
#  "Passenger", "Phusion Passenger" and "Union Station" are registered
#  trademarks of Phusion Holding B.V.
#
#  See LICENSE file for license information.

AGENT_TARGET = "#{AGENT_OUTPUT_DIR}#{AGENT_EXE}"
AGENT_MAIN_OBJECT = "#{AGENT_OUTPUT_DIR}AgentMain.o"
AGENT_OBJECTS = {
  AGENT_MAIN_OBJECT =>
    "src/agent/AgentMain.cpp",
  "#{AGENT_OUTPUT_DIR}AgentBase.o" =>
    "src/agent/Shared/Base.cpp",
  "#{AGENT_OUTPUT_DIR}WatchdogMain.o" =>
    "src/agent/Watchdog/WatchdogMain.cpp",
  "#{AGENT_OUTPUT_DIR}CoreMain.o" =>
    "src/agent/Core/CoreMain.cpp",
  "#{AGENT_OUTPUT_DIR}CoreApplicationPool.o" =>
    "src/agent/Core/ApplicationPool/Implementation.cpp",
  "#{AGENT_OUTPUT_DIR}CoreController.o" =>
    "src/agent/Core/Controller/Implementation.cpp",
  "#{AGENT_OUTPUT_DIR}UstRouterMain.o" =>
    "src/agent/UstRouter/UstRouterMain.cpp",
  "#{AGENT_OUTPUT_DIR}SystemMetricsMain.o" =>
    "src/agent/SystemMetrics/SystemMetricsMain.cpp",
  "#{AGENT_OUTPUT_DIR}TempDirToucherMain.o" =>
    "src/agent/TempDirToucher/TempDirToucherMain.cpp",
  "#{AGENT_OUTPUT_DIR}SpawnPreparerMain.o" =>
    "src/agent/SpawnPreparer/SpawnPreparerMain.cpp",
  "#{AGENT_OUTPUT_DIR}SendCloudUsageMain.o" =>
    "src/agent/SendCloudUsage/SendCloudUsageMain.cpp"
}

# Define compilation tasks for object files.
AGENT_OBJECTS.each_pair do |object, source|
  define_cxx_object_compilation_task(
    object,
    source,
    :include_paths => [
      "src/agent",
      *CXX_SUPPORTLIB_INCLUDE_PATHS
    ],
    :flags => [
      AGENT_CFLAGS,
      LIBEV_CFLAGS,
      LIBUV_CFLAGS,
      PlatformInfo.curl_flags,
      PlatformInfo.zlib_flags
    ]
  )
end

# Define compilation task for the agent executable.
agent_libs = COMMON_LIBRARY.
  only(:base, :bas64, :json, :union_station_filter, :other).
  exclude('WatchdogLauncher.o')
dependencies = AGENT_OBJECTS.keys + [
  LIBBOOST_OXT,
  agent_libs.link_objects,
  LIBEV_TARGET,
  LIBUV_TARGET
].flatten.compact
file(AGENT_TARGET => dependencies) do
  sh "mkdir -p #{AGENT_OUTPUT_DIR}" if !File.directory?(AGENT_OUTPUT_DIR)
  create_cxx_executable(AGENT_TARGET,
    [
      agent_libs.link_objects_as_string,
      AGENT_OBJECTS.keys,
      LIBBOOST_OXT_LINKARG
    ],
    :flags => [
      libev_libs,
      libuv_libs,
      PlatformInfo.curl_libs,
      PlatformInfo.zlib_libs,
      PlatformInfo.portability_cxx_ldflags,
      AGENT_LDFLAGS
    ]
  )
end

task 'common:clean' do
  sh "rm -rf #{AGENT_OUTPUT_DIR}"
end
